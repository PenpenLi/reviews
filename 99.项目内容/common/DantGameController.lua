--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

----------------------------------------------------------------------------------------------------------
-- 项目：单挑
-- 时间: 2018-01-11
----------------------------------------------------------------------------------------------------------

local DantDirectory = "app.game.Pokersolo"
local DantSearchPath = "src/app/game/Pokersolo"
local DantProtoSearchPath = "app/game/Pokersolo/src/dantiao"

--local LK_GAME_SCENE_PATH = DantDirectory..".src.scene.DantScene"
-- local LK_GAME_SCENE_PATH = DantDirectory..".src.scene.DantMainScene"
local LK_GAME_SCENE_PATH = "src.app.game.Pokersolo.src.FiveStars.scene.FiveStarsScene"

local scheduler             = require("framework.scheduler")
-- local FiveStarsData = require("src.app.game.Pokersolo.src.FiveStars.config.FiveStarsData")

----------------------------------------------------------------------------------------------------------

-- local DtMessage = require("app.game.Pokersolo.src.data.DtMessage")
-- local DtSoundConfig = require("app.game.Pokersolo.src.data.DtSoundConfig")
-- local DtLogic = require("app.game.Pokersolo.src.data.DtLogic")
-- local DtErrorCode = require("app.game.Pokersolo.src.config.DtErrorCode")

-- require("app.game.Pokersolo.src.config.DtConfig")
-- require("app.game.Pokersolo.src.data.DtCardConfig")

local BaseGameController = import(".BaseGameController")
local DantGameController =  class("DantGameController",function()
    return BaseGameController.new()
end) 

DantGameController.instance = nil

-- 获取房间控制器实例
function DantGameController:getInstance()
    if DantGameController.instance == nil then
        DantGameController.instance = DantGameController.new()
    end
    return DantGameController.instance
end

function DantGameController:releaseInstance()
    if DantGameController.instance then
		DantGameController.instance:onDestory()
        DantGameController.instance = nil
		g_GameController = nil
    end
end

function DantGameController:ctor()
    print("DantGameController:ctor()")
    self:myInit()
end 

-- 初始化
function DantGameController:myInit()

    print("DantGameController:myInit()")
    -- 常量
    self.constPortalId = 800000          -- 界面入口

    self.m_roomData =  nil -- 获取房间数据
    self.m_gameAtomTypeId = 141001  --游戏id

    -- 变量
    self.gameScene = nil            -- 游戏场景
    --协议
    self.m_netMsgHandlerSwitch = {} 


    self.m_RealOnlineCount = 0 --实时在线人数
    self.m_TotalRound = {}  --历史总的场数
    self.m_BallHistory = {} --历史结果

    self.m_AccountData = {} --结算数据

    self.m_SelfGoldNumber = Player:getGoldCoin() --自己金币数据

    ---------------------------------
    self.m_SelfBetNum = {0,0,0,0,0,0,0,0,0,0,0} --下注信息
    self.m_TotalBetNum = 0 --总下注
    self.m_BetAddSumData = {0,0,0,0,0,0,0,0,0,0,0} --区域下注
     
    self._areaTotalValue={0,0,0,0,0,0,0,0,0,0,0}
    self._myareaTotalValue={0,0,0,0,0,0,0,0,0,0,0}
    self.m_BottomScore = {}

    self.m_CurSelectBSIndex = 1 --当前选中底分索引

    self.m_BetMaxPlayerId = 0 --下注最多的玩家账号ID
    self.m_BetMaxPlayerName = "" --下注最多的玩家昵称

    self.m_EachAccountResult = 0  --每局结算

    self.m_EachLuckResult = {} --每局中奖结果

    self.m_CuoPaiActions = {}  --戳牌动作

    -- 添加搜索路径
    ToolKit:addSearchPath(DantSearchPath.."/res")
    ToolKit:addSearchPath(DantSearchPath.."/src") 
    -- 加载场景协议以及游戏相关协议

    ToolKit:addSearchPath(DantProtoSearchPath)

    Protocol.loadProtocolTemp("app.game.Pokersolo.src.dantiao.protoReg")

    self:initDantMessage()

    --注册游戏协议
    self:initNetMsgHandlerSwitchData()

  --  addMsgCallBack(self, PublicGameMsg.MSG_C2H_ENTER_SCENE_ACK, handler(self, self.Handle_EnterSceneAck))

    self:setGamePingTime( 5, 0x7FFFFFFF )--心跳包

end

function DantGameController:initDantMessage()
    --分发消息
end

function DantGameController:initNetMsgHandlerSwitchData()
 
    --[[
    --  self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_Bet_Addition_Sum_Nty"]             =                   handler(self, self.gameBetAddtionSumNty)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_Bet_Ack"]                          =                   handler(self, self.gameBetAck)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_Bet_Nty"]                          =                   handler(self, self.gameBetNty)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_Bet_Sum_Nty"]                      =                   handler(self, self.gameBetSumNty)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_GameBalance_Nty"]                  =                   handler(self, self.gameBalanceNty)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_GameDanTiaoNumber_Nty"]            =                   handler(self, self.gameDanTiaoNumberNty)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_GameTimeLine_Nty"]                 =                   handler(self, self.gameTimeLineNty)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_BallHistory_Nty"]                  =                   handler(self, self.gameBallHistoryNty)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_RankPlayer_Nty"]                   =                   handler(self, self.gameRankPlayerNty) 
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_Player_Online_List_Ack"]           =                   handler(self, self.gamePlayerOnlineListAck)  
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_Win_GoldInfo_Nty"]                 =                   handler(self, self.gameWinGoldinfoNty)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_Watch_Message_Nty"]                =                   handler(self, self.gameWatchMessageNty)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_Total_Gold_Nty"]                   =                   handler(self, self.gameTotalGoldNty) 
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_CuoPai_Complete_Player_Nty"]       =                   handler(self, self.gameCuoPaiCompletePlayerNty)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_CuoPai_Start_Nty"]                 =                   handler(self, self.gameCuoPaiStartNty)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_Real_Online_Users_Nty"]            =                   handler(self, self.gameRealOnlineUsersNty)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_UserEachBet_Nty"]                  =                   handler(self, self.gameUserEachBetNty) 
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_TopPlayer_Nty"]                    =                   handler(self, self.ackPlayerShow)  
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_ChipAndAreaTimes_Nty"]             =                   handler(self, self.gameChipAndAreaTimes)   
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_Background_Ack"]                   =                   handler(self, self.gameBackgroundAck)   
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_BetContinue_Ack"]                  =                   handler(self, self.gameBetContinueAck)
    --]]

    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_Bet_Ack"] = handler(self, self.ON_CS_G2C_DanTiao_Bet_Ack)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_Bet_Nty"] = handler(self, self.ON_CS_G2C_DanTiao_Bet_Nty)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_Bet_Sum_Nty"] = handler(self, self.ON_CS_G2C_DanTiao_Bet_Sum_Nty)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_GameBalance_Nty"] = handler(self, self.ON_CS_G2C_DanTiao_GameBalance_Nty)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_GameDanTiaoNumber_Nty"] = handler(self, self.ON_CS_G2C_DanTiao_GameDanTiaoNumber_Nty)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_GameTimeLine_Nty"] = handler(self, self.ON_CS_G2C_DanTiao_GameTimeLine_Nty)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_BallHistory_Nty"] = handler(self, self.ON_CS_G2C_DanTiao_BallHistory_Nty)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_RankPlayer_Nty"] = handler(self, self.ON_CS_G2C_DanTiao_RankPlayer_Nty) 
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_Bet_Cancel_Ack"] = handler(self, self.ON_CS_G2C_DanTiao_Bet_Cancel_Ack)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_Player_Online_List_Ack"] = handler(self, self.ON_CS_G2C_DanTiao_Player_Online_List_Ack)  
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_Win_GoldInfo_Nty"] = handler(self, self.ON_CS_G2C_DanTiao_Win_GoldInfo_Nty)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_Watch_Message_Nty"] = handler(self, self.ON_CS_G2C_DanTiao_Watch_Message_Nty)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_Total_Gold_Nty"] = handler(self, self.ON_CS_G2C_DanTiao_Total_Gold_Nty) 
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_CuoPai_Complete_Player_Nty"] = handler(self, self.ON_CS_G2C_DanTiao_CuoPai_Complete_Player_Nty)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_CuoPai_Start_Nty"] = handler(self, self.ON_CS_G2C_DanTiao_CuoPai_Start_Nty)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_Real_Online_Users_Nty"] = handler(self, self.ON_CS_G2C_DanTiao_Real_Online_Users_Nty)
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_UserEachBet_Nty"] = handler(self, self.ON_CS_G2C_DanTiao_UserEachBet_Nty) 
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_TopPlayer_Nty"] = handler(self, self.ON_CS_G2C_DanTiao_TopPlayer_Nty)  
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_ChipAndAreaTimes_Nty"] = handler(self, self.ON_CS_G2C_DanTiao_ChipAndAreaTimes_Nty)   
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_Background_Ack"] = handler(self, self.ON_CS_G2C_DanTiao_Background_Ack)   
    self.m_netMsgHandlerSwitch["CS_G2C_DanTiao_BetContinue_Ack"] = handler(self, self.ON_CS_G2C_DanTiao_BetContinue_Ack)


    self.m_protocolList = {}
    for k,v in pairs(self.m_netMsgHandlerSwitch) do
        self.m_protocolList[#self.m_protocolList+1] = k
    end

    self:setNetMsgCallbackByProtocolList(self.m_protocolList, handler(self, self.netMsgHandler))

    -- addMsgCallBack(self, DtMessage.MSG_GAME_INIT, handler(self, self.msgGameSceneInit))

end

function DantGameController:netMsgHandler( __idStr, __info)
    if (self.m_netMsgHandlerSwitch[__idStr]) then
        (self.m_netMsgHandlerSwitch[__idStr])(__info)
    else
        print("未找到单挑游戏消息" .. (__idStr or ""))
    end
end


--region 消息函数体
function DantGameController:ON_CS_G2C_DanTiao_Bet_Ack(cmd)
    self.gameScene:ON_CS_G2C_DanTiao_Bet_Ack(cmd)
end
function DantGameController:ON_CS_G2C_DanTiao_Bet_Nty(cmd)
    self.gameScene:ON_CS_G2C_DanTiao_Bet_Nty(cmd)
end
function DantGameController:ON_CS_G2C_DanTiao_Bet_Sum_Nty(cmd)
    self.gameScene:ON_CS_G2C_DanTiao_Bet_Sum_Nty(cmd)
end
function DantGameController:ON_CS_G2C_DanTiao_GameBalance_Nty(cmd)
    self.gameScene:ON_CS_G2C_DanTiao_GameBalance_Nty(cmd)
end
function DantGameController:ON_CS_G2C_DanTiao_GameDanTiaoNumber_Nty(cmd)
    self.gameScene:ON_CS_G2C_DanTiao_GameDanTiaoNumber_Nty(cmd)
end
function DantGameController:ON_CS_G2C_DanTiao_GameTimeLine_Nty(cmd)
    self.gameScene:ON_CS_G2C_DanTiao_GameTimeLine_Nty(cmd)
end
function DantGameController:ON_CS_G2C_DanTiao_BallHistory_Nty(cmd)
    self.gameScene:ON_CS_G2C_DanTiao_BallHistory_Nty(cmd)
end
function DantGameController:ON_CS_G2C_DanTiao_RankPlayer_Nty(cmd)
    self.gameScene:ON_CS_G2C_DanTiao_RankPlayer_Nty(cmd)
end
function DantGameController:ON_CS_G2C_DanTiao_Bet_Cancel_Ack(cmd)
    self.gameScene:ON_CS_G2C_DanTiao_Bet_Cancel_Ack(cmd)
end
function DantGameController:ON_CS_G2C_DanTiao_Player_Online_List_Ack(cmd)
    self.gameScene:ON_CS_G2C_DanTiao_Player_Online_List_Ack(cmd)
end
function DantGameController:ON_CS_G2C_DanTiao_Win_GoldInfo_Nty(cmd)
    self.gameScene:ON_CS_G2C_DanTiao_Win_GoldInfo_Nty(cmd)
end
function DantGameController:ON_CS_G2C_DanTiao_Watch_Message_Nty(cmd)
    self.gameScene:ON_CS_G2C_DanTiao_Watch_Message_Nty(cmd)
end
function DantGameController:ON_CS_G2C_DanTiao_Total_Gold_Nty(cmd)
    self.gameScene:ON_CS_G2C_DanTiao_Total_Gold_Nty(cmd)
end
function DantGameController:ON_CS_G2C_DanTiao_CuoPai_Complete_Player_Nty(cmd)
    self.gameScene:ON_CS_G2C_DanTiao_CuoPai_Complete_Player_Nty(cmd)
end
function DantGameController:ON_CS_G2C_DanTiao_CuoPai_Start_Nty(cmd)
    self.gameScene:ON_CS_G2C_DanTiao_CuoPai_Start_Nty(cmd)
end
function DantGameController:ON_CS_G2C_DanTiao_Real_Online_Users_Nty(cmd)
    self.gameScene:ON_CS_G2C_DanTiao_Real_Online_Users_Nty(cmd)
end
function DantGameController:ON_CS_G2C_DanTiao_UserEachBet_Nty(cmd)
    self.gameScene:ON_CS_G2C_DanTiao_UserEachBet_Nty(cmd)
end
function DantGameController:ON_CS_G2C_DanTiao_TopPlayer_Nty(cmd)
    self.gameScene:ON_CS_G2C_DanTiao_TopPlayer_Nty(cmd)
end
function DantGameController:ON_CS_G2C_DanTiao_ChipAndAreaTimes_Nty(cmd)
    self.gameScene:ON_CS_G2C_DanTiao_ChipAndAreaTimes_Nty(cmd)
end
function DantGameController:ON_CS_G2C_DanTiao_Background_Ack(cmd)
    -- self.gameScene:ON_CS_G2C_DanTiao_Background_Ack(cmd)
end
function DantGameController:ON_CS_G2C_DanTiao_BetContinue_Ack(cmd)
    self.gameScene:ON_CS_G2C_DanTiao_BetContinue_Ack(cmd)
end

--endregion



--region
--[[ 
function DantGameController:netMsgHandler( __idStr,__info )
    print("__idStr = ",__idStr) 
    if self.m_netMsgHandlerSwitch[__idStr] then
        if self.gameScene.m_bIsInit == true then
            (self.m_netMsgHandlerSwitch[__idStr])( __info )
        else
            if "CS_G2C_DanTiao_UserEachBet_Nty" ~= __idStr then
                self.m_pNetMsgData = self.m_pNetMsgData or {}
                local isInsert = true;
                for index = 1, #self.m_pNetMsgData do
                    local item = self.m_pNetMsgData[index];
                    if(item.m_sMsgId == __idStr) then
                        item.m_pCmd = __info;
                        isInsert = false;
                        break;
                    end
                end
                if isInsert then
                    table.insert(self.m_pNetMsgData, {m_sMsgId = __idStr, m_pCmd =__info});
                end
            else
                (self.m_netMsgHandlerSwitch[__idStr])( __info )
            end
        end
        
    else
        print("未找到单挑游戏消息" .. (__idStr or ""))
    end
end

function DantGameController:msgGameSceneInit()
    if self.m_pNetMsgData == nil then 
       return
    end

    for index = 1, #self.m_pNetMsgData do
        local item = self.m_pNetMsgData[index];
        if self.m_netMsgHandlerSwitch[item.m_sMsgId] then
            (self.m_netMsgHandlerSwitch[item.m_sMsgId])( item.m_pCmd );
        end

    end


    -- for __, data in pairs(self.m_pNetMsgData) do
    --     local idStr = data.m_sMsgId;
    --     local info = data.m_pCmd;
    --     local callFunc = self.m_netMsgHandlerSwitch[idStr]
    --     if callFunc ~= nil then 
    --         callFunc( info )
    --     end
    -- end
end

function DantGameController:gameChipAndAreaTimes(__info)
    self.gameScene.m_MainLayer:gameChipAndAreaTimes(__info)
end

function DantGameController:ackPlayerShow(__info)
    self.gameScene.m_MainLayer:updateUserList(__info)
end

function DantGameController:gameBetAck(__info)
    --dump(__info, "DantGameController  == gameBetAck", 10)
    dump( __info )
    if __info.m_ret == 0 then
        self._myareaTotalValue[__info.m_betId]=  self._myareaTotalValue[__info.m_betId]+__info.m_betValue
        self.gameScene.m_MainLayer:setMyAreaText(__info.m_betId,self._myareaTotalValue[__info.m_betId])  
         self:setSelfBetNum(__info)
--	    self:updateSelfGoldInfo(__info.m_betValue) 
--        self.gameScene:updateSelfBetInfo(self:getSelfBetNum())
        self.gameScene:updateSelfGoldInfo(__info.m_curCoin) 
    else
        local str = ""
        if __info.m_ret ==-1 then
            str = "系统错误"
        elseif __info.m_ret ==-2 then
            str = "游戏不能下注"
         elseif __info.m_ret ==-3 then
            str = "金币不足"
          elseif __info.m_ret ==-4 then
            str = "新手时总投注额不能超过限制"
          elseif __info.m_ret ==-5 then
            str = "单区域投注总额不能超过限制"
          elseif __info.m_ret ==-200118 then
            str = "金币低于30，不能下注"
             elseif __info.m_ret ==-200119 then
            str = "下注筹码非法"
        end
        TOAST(str)

    end
	
end

function DantGameController:updateSelfGoldInfo(_betValue)
    self.m_SelfGoldNumber = self.m_SelfGoldNumber - _betValue
end

function DantGameController:setSelfBetNum(_info)
   self.m_SelfBetNum[_info.m_betId] = self.m_SelfBetNum[_info.m_betId] + _info.m_betValue
end

function DantGameController:getSelfBetNum()
    return self.m_SelfBetNum
end

--续压
function DantGameController:gameBetContinueAck(__info)
    --dump(__info, "DantGameController  == gameBetContinueAck", 10)
    if __info then
        if __info.m_ret ~= 0 then
            TOAST(DtErrorCode.errorTips[tostring(__info.m_ret)])
            return
        end

        self:setBCSelfBetNum(__info)
        self:updateBCSelfGoldInfo(__info)

        if self.gameScene then
            self.gameScene:updateSelfBetInfo(self:getSelfBetNum())
            self.gameScene:updateSelfGoldInfo(self:getSelfGoldNumber())
        end
    end
end

function DantGameController:setBCSelfBetNum(__info)
    for i=1, #__info.m_vecBetList do
        self.m_SelfBetNum[__info.m_vecBetList[i].m_betId] = self.m_SelfBetNum[__info.m_vecBetList[i].m_betId] + __info.m_vecBetList[i].m_betValue
    end
end

function DantGameController:updateBCSelfGoldInfo(__info)
    for i=1, #__info.m_vecBetList do
        self.m_SelfGoldNumber = self.m_SelfGoldNumber - __info.m_vecBetList[i].m_betValue
    end
end

function DantGameController:gameBetNty(__info)
    --dump(__info, "DantGameController  == gameBetNty", 10)
     self.gameScene.m_MainLayer:showMyBetTxt(__info.m_vecBetList)
    if __info then
        for i=1, #__info.m_vecBetList do
            for j=1, #__info.m_vecBetList[i].m_vecBet do
                self:setSelfBetNum(__info.m_vecBetList[i].m_vecBet[j])
            end
        end

        if self.gameScene then
            self.gameScene:updateSelfBetInfo(self:getSelfBetNum())
        end

    end

end

function DantGameController:gameBetSumNty(__info)
    --dump(__info, "DantGameController  == gameBetSumNty", 10) 
    self.gameScene.m_MainLayer:showAreaBetTxt(__info.m_vecBetSumList)
	if __info then
        self:setBetAddSumData1(__info.m_vecBetSumList)
        if self.gameScene then
            self.gameScene:updateBetAddSumInfo(self:getBetAddSumData())
        end
    end
end

function DantGameController:gameBetAddtionSumNty(__info)
    --dump(__info, "DantGameController  == gameBetAddtionSumNty", 10)
    if __info then
        self:setBetAddSumData(__info.m_vecBetAddSumList)
        if self.gameScene then
            self.gameScene:updateBetAddSumInfo(self:getBetAddSumData())
        end
    end
end

function DantGameController:setBetAddSumData1(_list)
    for i=1, #_list do
        self.m_BetAddSumData[_list[i].m_betId] = _list[i].m_betValue
    end
end

function DantGameController:setBetAddSumData(_list)
    for i=1, #_list do
        self.m_BetAddSumData[_list[i].m_betId] = self.m_BetAddSumData[_list[i].m_betId] + _list[i].m_betValue
    end
end

function DantGameController:getBetAddSumData()
    return self.m_BetAddSumData
end


function DantGameController:gameBalanceNty(__info)
    --dump(__info, "DantGameController  == gameBalanceNty", 10)
    self.gameScene.m_MainLayer:showGameStageView( 4 )
     self.gameScene.m_MainLayer:setStageVisible( true )
     self.gameScene.m_MainLayer:showRunTime( 6 ) 
     self.gameScene.m_MainLayer:dealGameResult(__info) 
end

--汇报结果
function DantGameController:gameDanTiaoNumberNty(__info)
    
    dump(__info, "DantGameController  == gameDanTiaoNumberNty", 10)

    if __info then
        if __info.m_luckNumberInfo.m_dantiaoNum > 0 then
            self:setEachLuckResult(__info.m_luckNumberInfo)
        end
    end
end

function DantGameController:setEachLuckResult(_luckNumberInfo)
    self.m_EachLuckResult = _luckNumberInfo
end

function DantGameController:getEachLuckResult()
    return self.m_EachLuckResult
end

--场景阶段
function DantGameController:gameTimeLineNty(__info)
    --dump(__info, "DantGameController  == gameTimeLineNty", 10)
    if __info then
        if self.gameScene then
            self.gameScene:updateGameScene(__info)
        end
    end
end

--历史结果
function DantGameController:gameBallHistoryNty(__info)
    --dump(__info, "DantGameController  == gameBallHistoryNty", 10)
    if __info then
      
        if self.gameScene then
--            if __info.m_type ==0 then 
--                self.m_BallHistory=__info.m_vecBallHistory
--            else
--                table.insert(self.m_BallHistory,__info.m_vecBallHistory[1])
--            end
            self.gameScene:updateBallHistory(__info.m_vecBallHistory)
        end
    end
end

function DantGameController:setBallHistory(_vecBallHistory)

    for i=#_vecBallHistory, 1, -1 do
        table.insert(self.m_BallHistory, _vecBallHistory[i])
    end
end

function DantGameController:getBallHistory()
    return self.m_BallHistory
end

--每局结算
function DantGameController:gameRankPlayerNty(__info)
    dump(__info, "DantGameController  == gameRankPlayerNty", 10)
    if __info then
        self:setAccountData(__info.m_vecRankPlayer)
    end
end

function DantGameController:setAccountData(_accountData)
    self.m_AccountData = _accountData
end

function DantGameController:getAccountData()
    return self.m_AccountData
end

 function DantGameController:reqPlayerOnlineList()
   ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_DanTiao_Player_Online_List_Req", {Player:getAccountID(), 1,100} )
end

-- 在线玩家 
 

function DantGameController:gamePlayerOnlineListAck(__info)
    --dump(__info, "DantGameController  == gamePlayerOnlineListAck", 10)
    self.gameScene.m_MainLayer:updateOnlineUserList(__info)
end
 
--总的轮数
function DantGameController:gameTotalRoundNty(__info)
    --dump(__info, "DantGameController  == gameTotalRoundNty", 10)
    if __info then
        self:setTotalRound(__info)
        if self.gameScene then
            self.gameScene:updateTotalRound(self:getTotalRound())
        end
    end
end

function DantGameController:setTotalRound(__info)
    self.m_TotalRound = __info
end

function DantGameController:getTotalRound()
    return self.m_TotalRound
end

--当前局赢输
function DantGameController:gameWinGoldinfoNty(__info)
    --dump(__info, "DantGameController  == gameWinGoldinfoNty", 10)
    if __info then
        self:setEachAccountResult(__info.Win_Gold)
        if self.gameScene then
            self.gameScene:showSelfAccountResult(self:getEachAccountResult())
        end
    end
end

function DantGameController:setEachAccountResult(_winGold)
    self.m_EachAccountResult = _winGold
end

function DantGameController:getEachAccountResult()
    return self.m_EachAccountResult
end

--观看消息
function DantGameController:gameWatchMessageNty(__info)
    --dump(__info, "DantGameController  == gameWatchMessageNty", 10)
    if __info then
        if self.gameScene then
            self.gameScene:updateWatchMessage(__info)
        end
    end
end

--玩家金币
function DantGameController:gameTotalGoldNty(__info)
    --dump(__info, "DantGameController  == gameTotalGoldNty", 10)
    self.gameScene.m_MainLayer:showMyInfo(__info.nTotalGold);
	 if __info then
        self:setSelfGoldNumber(__info.nTotalGold)
        if self.gameScene then 
            self.m_BottomScore = DtLogic:getBottomScore(__info.nTotalGold*0.01)

            self.gameScene:updateSelfGoldInfo(self:getSelfGoldNumber())
        end
    end
end

function DantGameController:setSelfGoldNumber(_number)
    self.m_SelfGoldNumber = _number
end

function DantGameController:getSelfGoldNumber()
    return self.m_SelfGoldNumber
end
  

function DantGameController:getTotalBetNum()
    return self.m_TotalBetNum
end

function DantGameController:gameShowMessageNty(__info)
    --dump(__info, "DantGameController  == gameShowMessageNty", 10)

end

function DantGameController:gameOnlineOfflineProfitNty(__info)
    --dump(__info, "DantGameController  == gameOnlineOfflineProfitNty", 10)
end

--下注最多玩家
function DantGameController:gameBetMaxPlayerNty(__info)
    --dump(__info, "DantGameController  == gameBetMaxPlayerNty", 10)
    if __info then
        self.m_BetMaxPlayerId = __info.m_accountId
        self.m_BetMaxPlayerName = __info.m_nickname
    end
end

--戳牌完成
function DantGameController:gameCuoPaiCompletePlayerNty(__info)
    --dump(__info, "DantGameController  == gameCuoPaiCompletePlayerNty", 10)
    if __info then
        self.gameScene.m_CuoPaiCompleteFlag = __info.m_nCuoPaiCompleteFlag

        if self.gameScene.m_CuoPaiCompleteFlag == 1 and  not self.gameScene.m_IsCuopai  then
            self.m_CuoPaiActions = {}
            self.gameScene:UpdateLeftPage(-1)
            self.gameScene.m_IsCuopaiFinish = true
        end

        if self.gameScene.m_CuoPaiCompleteFlag == 0 then
            self.m_CuoPaiActions  = {}
        end
    end
end

--开始戳牌
function DantGameController:gameCuoPaiStartNty(__info)
    --dump(__info, "DantGameController  == gameCuoPaiStartNty", 10)
    if __info then
        local cuoPaiAction = string.split(__info.m_nCuoPaiAction, ";")
        self.m_CuoPaiActions = self.m_CuoPaiActions or {}

        if self.gameScene.m_IsCuopai and self.gameScene.m_IsCuopai == true then return  end

        if __info.m_bRobotCuoPai == 0 then --真人戳牌
            for i = #cuoPaiAction,1,-1 do
                local curAction = string.split(cuoPaiAction[i], ",")
                local state = tonumber(curAction[1] )
                local beginPos = { x = tonumber(curAction[2]),y = tonumber(curAction[3]) }
                local cur_pos = { x = tonumber(curAction[4]),y = tonumber(curAction[5]) }
                if not self.gameScene.m_IsCuopai then
                    table.insert(self.m_CuoPaiActions, 1,{state = state,beginPos = beginPos, cur_pos = cur_pos })
                end
            end
        elseif __info.m_bRobotCuoPai == 1 then --机器人戳牌
            if self.gameScene then
              --  self.gameScene:showRobotChuoPaiEffect()
            end
        end
    end
end

--在线玩家
function DantGameController:gameRealOnlineUsersNty(__info)
    if __info then
        self:setRealOnlineUsers(__info.m_nRealOnlineCount)
        if self.gameScene then
            self.gameScene:updateRealOnlineUsers(self:getRealOnlineUsers())
        end
    end
end

function DantGameController:setRealOnlineUsers(_onlineUser)
    self.m_RealOnlineCount = _onlineUser
end

function DantGameController:getRealOnlineUsers()
    return self.m_RealOnlineCount
end

--下注广播
function DantGameController:gameUserEachBetNty(__info)
    --dump(__info, "DantGameController  == gameUserEachBetNty", 10)
    self._areaTotalValue[__info.nBetId]=  self._areaTotalValue[__info.nBetId]+__info.nBetCnt
    if self.gameScene.m_bIsInit == true then
        self.gameScene.m_MainLayer:dealXiaZhu(__info);
        self.gameScene.m_MainLayer:setTotalAreaText(__info.nBetId,self._areaTotalValue[__info.nBetId])
    end
end

--获取玩家下注数
function DantGameController:getAllBet()
    local allbet = 0

    for i= 1, #self.m_SelfBetNum do
        allbet = allbet + self.m_SelfBetNum[i]
    end

    return allbet
end

function DantGameController:resetData()
    self.m_SelfBetNum = {0,0,0,0,0,0,0,0,0,0,0} --下注信息
    self.m_TotalBetNum = 0 --总下注
    self.m_BetAddSumData = {0,0,0,0,0,0,0,0,0,0,0} --区域下注
    self.m_EachLuckResult = {}
     self._areaTotalValue={0,0,0,0,0,0,0,0,0,0,0}
    self._myareaTotalValue={0,0,0,0,0,0,0,0,0,0,0}
    self.m_CuoPaiActions = {}
end

function DantGameController:gameBetContinueAck(__info)
    --self._areaTotalValue[__info.nBetId]=  self._areaTotalValue[__info.nBetId]+__info.nBetCnt
    self.gameScene.m_MainLayer:betContinueAck(__info)
    if __info.m_result ~= 0 then return end

    if __info.m_betAccountId == Player:getAccountID() then
        self.gameScene:updateSelfGoldInfo(__info.m_curCoin) 
        for i = 1, #__info.m_continueBetArr do
            local v = __info.m_continueBetArr[i]
            self._myareaTotalValue[v.m_betAreaId]=  self._myareaTotalValue[v.m_betAreaId]+v.m_curBet
            self.gameScene.m_MainLayer:setMyAreaText(v.m_betAreaId, self._myareaTotalValue[v.m_betAreaId])  
            self.m_SelfBetNum[v.m_betAreaId] = self.m_SelfBetNum[v.m_betAreaId] + v.m_curBet
        end
    else
    end

end
--]]
--endregion
-----------------------------------------
--[[
function DantGameController:ExitTheDantScene()
    print("DantGameController:::::::::::ExitTheDantScene")

    local runningScene = cc.Director:getInstance():getRunningScene()
    -- 无->无
    if runningScene == nil or runningScene.__cname == nil then
        return
    end
    -- 单挑(无效)->大厅 or 单挑(无效)->重连
    if runningScene.__cname == "InvalidScene" then
        local pDantLayer = runningScene.pDantLayer
        local exitcode = pDantLayer.exitcode

        if exitcode==2 then
            --不发进入场景 performWithDelay(runningScene,function()
            --不发进入场景     ConnectManager:send2Server(Protocol.LobbyServer, "CS_C2H_EnterScene_Req", { 131001, 0, 0, 0, self.nLastClubSwitcherId } )
            --不发进入场景 end,0.1)
            return
        else
            if self.nLastClubId == 0 then
                print("单挑(无效)->大厅")
                UIAdapter:pop2RootScene()
            --    ConnectManager:send2Server(Protocol.LobbyServer, "CS_C2H_GamePortalList_Req", {0, 1}) -- 请求节点
            else
                print("单挑(无效)->俱乐部")
                UIAdapter:popScene() -- UIAdapter:pop2RootScene()
                --UIAdapter:popScene()
                --ConnectManager:send2Server(Protocol.LobbyServer, "CS_C2H_GamePortalList_Req", {0, 1}) -- 请求节点
            end
            return
        end
    end
    
    if runningScene.__cname == "DantScene" then
        local pDantLayer = runningScene.pDantLayer
        local exitcode = pDantLayer.exitcode
        self.nLastClubSwitcherId = pDantLayer.nClubSwitcherId -- 帮游戏场景记录下，它最后的模式选择
        -- 单挑(运行中,无exitcode)->打印错误日志
        if exitcode == nil then
            print("DantGameController:ExitTheDantScene without exitcode, pDantLayer==",pDantLayer)
            return
        end

        -- 单挑(运行中,有exitcode)-> 0:关闭socket,回到大厅,请求大厅节点
        if exitcode == 0 then
            if self.nLastClubId == 0 then
                print("单挑->大厅")
                runningScene:closeGameSvrConnect()
                UIAdapter:pop2RootScene()
             --   ConnectManager:send2Server(Protocol.LobbyServer, "CS_C2H_GamePortalList_Req", {0, 1}) -- 请求节点
            else -- 去娱乐城
                print("单挑->俱乐部")
                runningScene:closeGameSvrConnect()
                UIAdapter:popScene() -- UIAdapter:pop2RootScene()
            end
            return
        end

        -- 单挑(运行中,有exitcode)-> 1:关闭socket,回到大厅,请求大厅节点,请求打开商城
        if exitcode == 1 then
            -- 修改为直接弹出啊 -- x0.2.9 游戏外弹出商城
            --runningScene:closeGameSvrConnect()
            --UIAdapter:pop2RootScene()
            --ConnectManager:send2Server(Protocol.LobbyServer, "CS_C2H_GamePortalList_Req", {0, 1}) -- 请求节点
            --Dant_QkaGotoMallButGold()
            -- 修改为直接弹出商城啊 -- x0.2.10 游戏内弹出商城
            runningScene:closeGameSvrConnect()
            runningScene.__cname = "InvalidScene"
            runningScene.__reason = 1
            -- 屏蔽商场的状态下，反注销所有消息的处理 runningScene:Reset()
            return
        end        

        -- 单挑(运行中,有exitcode)-> 2:关闭socket,将DantScene置为InvalidScene,重新发送进入场景请求
        if exitcode == 2 then
            runningScene:closeGameSvrConnect()
            runningScene.__cname = "InvalidScene"
           --不发进入场景ReqperformWithDelay(runningScene,function()
           --不发进入场景Req    ConnectManager:send2Server(Protocol.LobbyServer, "CS_C2H_EnterScene_Req", { 131001, 0, 0, 0, self.nLastClubSwitcherId } )
           --不发进入场景Reqend,0.1)
            return
        end

        -- exitcode == 2 的代码已经在更换socket底层的时候，被占用了！新开exitcode == 3 的处理
        if exitcode == 3 then
            runningScene:closeGameSvrConnect()
            runningScene.__cname = "InvalidScene"
            performWithDelay(runningScene,function()
                print("self.nLastClubSwitcherId==",self.nLastClubSwitcherId)
                --ConnectManager:send2Server(Protocol.LobbyServer, "CS_C2H_EnterScene_Req", { 131001, 0, 0, 0, self.nLastClubSwitcherId } )
                
                print("DantGameController:ExitTheDantScene()")
                self:reqEnterScene(141001)
                
            end,0.1)
            return
        end

        -- 单挑(运行中,有exitcode)-> N:关闭socket,返回大厅,调用强制进入某游戏
        if exitcode > 9999 then 

            local nGotoGameAtomTypeId = exitcode
            runningScene:closeGameSvrConnect()
            --runningScene.__cname = "InvalidScene"
            self:forceEnterGame( RoomData.DANT , nGotoGameAtomTypeId )
            
            return
        end

    end
    
end

function DantGameController:GotoTheDantScene(withMyAck)
    
    local runningScene = cc.Director:getInstance():getRunningScene()
    -- 无->直接到单挑
    if runningScene == nil or runningScene.__cname == nil then
        print("GotoTheDantScene 无->直接到单挑")
        self:RunNewDantScene()
        return
    end
     if  runningScene.__cname == "LoginScene" then
        print(" 重连->直接到单挑")
        self:RunNewDantScene()
        return
    end
    -- 大厅->单挑
    if runningScene.__cname == "TotalScene" then
        print("GotoTheDantScene 大厅->单挑")
        --print(debug.traceback())
        self:RunNewDantScene()
        return
    end
    -- 俱乐部->单挑 复制来自 【大厅->单挑】
    if runningScene.__cname == "ClubScene" then
        print("GotoTheDantScene 俱乐部->单挑")
        print(debug.traceback())
        self:RunNewDantScene()
        return
    end
    -- 单挑(无效)->单挑(新)
    if runningScene.__cname == "InvalidScene" then
        print("GotoTheDantScene 单挑(无效)->单挑(新)")
        UIAdapter:popScene()
        self:RunNewDantScene()
        return
    end
    -- 单挑(运行中)->单挑(运行中)
    if runningScene.__cname == "DantScene" then 
        print("GotoTheDantScene 单挑(运行中)->单挑(运行中)")
        return
    end
   
    print("GotoTheDantScene FAILED: the runningScene.__cname==",runningScene.__cname)

end

function DantGameController:RunNewDantScene(is_re_enter)
    print("DantGameController:RunNewDantScene",os.time(),is_re_enter)
	
	if self.gameScene then
		return
	end
	
    -- 调用接口
    local nTmpAccountId = Player:getAccountID()
    local nTmpFaceId    = Player:getParam("FaceID")
    local sTmpName      = Player:getParam("NickName") 
    local nTmpGold      = Player:getParam("GoldCoin") -- 已经为0了
	
    self.gameScene = UIAdapter:pushScene(LK_GAME_SCENE_PATH, DIRECTION.HORIZONTAL, nil)
    self.gameScene.nTmpAccountId  = nTmpAccountId
    self.gameScene.nTmpFaceId     = nTmpFaceId   
    self.gameScene.sTmpName       = sTmpName      
    self.gameScene.nTmpGold       = nTmpGold
end
--]]

-- 析构函数
function DantGameController:onDestory()
    print("---------DantGameController:onDestory begin-----------")

    -- removeMsgCallBack(self, DtMessage.MSG_GAME_INIT)
    
	self.m_netMsgHandlerSwitch = {}

    -- 游戏场景
    if self.gameScene then
        --self.gameScene:onDestory()
		UIAdapter:popScene()
		self.gameScene = nil
	end

    self:clearData()

    self:removeMessageCallBack()
	
	self:onBaseDestory()
	
	print("---------DantGameController:onDestory end-----------")
end

function DantGameController:clearData()
    self.m_RealOnlineCount = 0 --实时在线人数
    self.m_TotalRound = {}  --历史总的场数
    self.m_BallHistory = {} --历史结果

    self.m_AccountData = {} --结算数据

    ---------------------------------
    self.m_SelfBetNum = {0,0,0,0,0,0,0,0,0,0,0} --下注信息
    self.m_TotalBetNum = 0 --总下注
    self.m_BetAddSumData = {0, 0, 0, 0, 0} --区域下注    

    self.m_CurSelectBSIndex = 1 --当前选中底分索引

    self.m_BetMaxPlayerId = 0 --下注最多的玩家账号ID
    self.m_BetMaxPlayerName = "" --下注最多的玩家昵称

    self.m_EachAccountResult = 0  --每局结算

    --self.m_EachLuckResult = {} --每局中奖结果

    self.m_CuoPaiActions = {}  --戳牌动作
end

function DantGameController:removeMessageCallBack()
    --removeMsgCallBack(self, PublicGameMsg.MSG_C2H_ENTER_SCENE_ACK)
end

--[[
function DantGameController:onEnterSomeLayer(keyword,tbl)
    -- 在单挑中，这个是商场专用的咯
    local runningScene = cc.Director:getInstance():getRunningScene()
    print("单挑 商场 DantGameController:onEnterSomeLayer()")
    print("tbl.name",tbl.name,"runningScene",runningScene,"runningScene.__reason",runningScene.__reason)
    if tbl.name == "back" and runningScene and runningScene.__reason == 1 then
        UIAdapter:pop2RootScene()
        self:GotoTheDantScene()
        print("DantGameController:onEnterSomeLayer()")
        self:reqEnterScene(141001)

    end
end
--]]

function DantGameController:Handle_CS_H2C_DoNothing( __idStr, __info )
    print("DantGameController:Handle_CS_H2C_DoNothing() __idStr = ",__idStr)
    -- "CS_H2C_EnterGame_Nty"
end

--[[
function DantGameController:Handle_CS_H2C_HandleMsg_Ack( __idStr, __info )
    print("DantGameController:Handle_CS_H2C_HandleMsg_Ack()__idStr = ",__idStr)

    if __idStr == "CS_H2C_HandleMsg_Ack" then
        if __info.m_result == 0 then

            if not __info.m_message[1] then print("CS_H2C_HandleMsg_Ack id = nil") return end

            local gameAtomTypeId = __info.m_gameAtomTypeId
            local cmdId = __info.m_message[1].id
            local info = __info.m_message[1].msgs
            
            if gameAtomTypeId ~= self:getGameAtomTypeId() then print("CS_H2C_HandleMsg_Ack gameAtomTypeId ~= 141001") return end
            
            local runingScene = cc.Director:getInstance():getRunningScene()

            if runingScene.__cname and runingScene.__cname == "DantScene" then

                -- 正在运行游戏场景的情况下的处理
                --------------------------------------------------------------------------------------------------------
                if cmdId == "CS_M2C_DanTiao_EnterRoom_Ack" then
                    if g_dant and g_dant.network then
                        local handler = g_dant.GetProtoHandlers()[cmdId]
                        if handler then
                            handler(g_dant.network,cmdId,info,nil)
                        end
                    end

                --------------------------------------------------------------------------------------------------------
                elseif cmdId == "CS_M2C_DanTiao_ExitScene_Ack" then
                    print("M2C------>CS_M2C_DanTiao_ExitScene_Ack:"..cmdId)

                --------------------------------------------------------------------------------------------------------
                else
                    print("M2C------>未注册消息:"..cmdId)
                end
            else
                
                print("M2C------>不在DantScene的情况下收到的消息: "..cmdId,"当前场景名字是: ",tostring(runingScene.__cname))
                
            end

        else

            print("找不到场景信息 gameAtomTypeId = ", __info.m_gameAtomTypeId)
            if __info.m_message and __info.m_message[1] then
                print("找不到场景信息 cmdId = ", __info.m_message[1].id)
            end
            
        end
    end
end
--]]

function DantGameController:ackEnterGame( __info )

    print("DantGameController:ackEnterGame( msgid,__info ) __info.m_gameAtomTypeId __info.m_ret __info.m_param1", __info.m_gameAtomTypeId,__info.m_ret,__info.m_param1)
    if __info.m_gameAtomTypeId ~= self:getGameAtomTypeId() then 
		return 
	end
	
	--压入场景
	--self:RunNewDantScene()
	 if tolua.isnull( self.gameScene ) and __info.m_ret == 0 then
		self.gameScene = UIAdapter:pushScene(LK_GAME_SCENE_PATH, DIRECTION.HORIZONTAL, nil)
    end
   
	--[[
    if type(__info.m_param1)=="number" and __info.m_param1 >0 then
        -- 从俱乐部进入
        self.nLastClubId = __info.m_param1
        self:GotoTheDantScene(true)
    else
        -- 从大厅进入
        self.nLastClubId = __info.m_param1
        print("单挑 ack说从大厅进入")
        self:GotoTheDantScene(true)
        self.gameScene:reqEnterRoom()
    end
	--]]
end

function DantGameController:handleError(__info)
    local reslut = __info.m_message[1].msgs.m_ret
    if reslut ~= 0 then

        --local runningScene = cc.Director:getInstance():getRunningScene()
        -- 无->无
        --if runningScene.__cname == "DantScene" or runningScene.__cname == "InvalidScene" then 
        --    UIAdapter:popScene() 
        --end
            
        --[[用我吧，函数还没加载，手打哦]]
        local box_title = "提示"
        local box_content = self:getErrorMsg(reslut) or "进入《单挑》失败"
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

-- '1-切到后台 2-切回游戏'},
function DantGameController:gameBackgroundReq( nType)
	if self.m_gameAtomTypeId then
		print("DantGameController:gameBackgroundReq", self.m_gameAtomTypeId, nType)
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_DanTiao_Background_Req", { nType})
	end
end

function DantGameController:gameBackgroundAck(__info)
    
end

--[[
function DantGameController:setGameAtomTypeId( _gameAtomTypeId )
    self.m_gameAtomTypeId = _gameAtomTypeId
end 

function DantGameController:getGameAtomTypeId()
    return self.m_gameAtomTypeId 
end
--]]
function DantGameController:getErrorMsg(_code)
    local pErrorMessagr = {
        [-2001] = "房间已满"
    }
    return pErrorMessagr[_code] or nil
end



return DantGameController