-- FriendReplayBtnLayer
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 牌友房回放操作面板
local LandGlobalDefine = require("src.app.game.pdk.src.landcommon.data.LandGlobalDefine")
local GamePlayerInfo = require("src.app.game.common.data.GamePlayerInfo")
local FriendReplayController    =  require("src.app.game.pdk.src.classicland.contorller.FriendReplayController"):getInstance()
local StackLayer = require("app.hall.base.ui.StackLayer")
local CardKit = require("src.app.game.pdk.src.common.CardKit")

local FriendReplayBtnLayer = class("FriendReplayBtnLayer", function()
    return StackLayer.new()
end)

function FriendReplayBtnLayer:ctor( landMainScene , gameID )
	self.landMainScene = landMainScene
	self.gameID = gameID
    self:initUI()
    self:initGameData()
end

function FriendReplayBtnLayer:initGameData()	
	local path = "app.game.pdk.src.landcommon.data.LandReplayData"
    self.dataObj = RequireEX( path ).new()
    local tbl = FriendReplayController:getInstance():getPaiJuByGameID( self.gameID )
    self.dataObj:setVecData( tbl )

    self.cur_paiju = 1
    self.cur_speed_type = 0
    self:updateCurSpeed(1)

    local round_data = self.dataObj:getRoundData()
	local roomID     = round_data[3]
    self.landMainScene.gameRoomBgLayer:setRoomInfo( LandGlobalDefine.FRIEND_REPLAY_ID , roomID )
    local tbl = self.dataObj:getPlayerData()
    self:initPlayer( tbl )
    self.landMainScene:reciveChairTable( self.__players , self.meChair , 0 )

    self:resetCurGameData( self.cur_paiju )
end

function FriendReplayBtnLayer:updateMiddleUI()
	local round_data = self.dataObj:getRoundData()
	local totalRound = self.dataObj:getTotalRound()
	local limitBoom  = round_data[4]
	local isDouble   = round_data[5]
	self.landMainScene:setMiddleUI( self.cur_paiju , totalRound , limitBoom , isDouble )
end


function FriendReplayBtnLayer:initPlayer( tbl )
	local myAcc = Player:getAccountID()
	self.meChair = nil
	self.__players = {}
	
	for chair,v in pairs( tbl ) do
		local acc = v[1]
    	if acc == myAcc then self.meChair = chair end
        local info = GamePlayerInfo.new()
        self.__players[chair] = info
        info:setChairId(chair)
        info:setAccountId(acc)  
        info:setFaceId(v[2])
        info:setNickname(v[3])
        -- 这两项不知道要不要
        info:setGoldCoin(0)
        info:setGameScore(0)
        info.m_offine = 0
    end
end

function FriendReplayBtnLayer:onEnter()
    print("---------------FriendReplayBtnLayer:onEnter()-------------")
end
function FriendReplayBtnLayer:onExit()
    print("---------------FriendReplayBtnLayer:onExit()-------------")
end
-------------------------------------------------------------------------------------------------------------------
---------------------------------------初始化       ---------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

function FriendReplayBtnLayer:initUI()
    self.root = cc.CSLoader:createNode("src/app/game/pdk/res/csb/friend_land_cs/friend_land_replay.csb")
    self:addChild(self.root)
    UIAdapter:adapter(self.root, handler(self, self.onTouchCallback))
    self.layout_bg = self.root:getChildByName("layout_bg")
    self:initButton()
end

function FriendReplayBtnLayer:resetCurGameData( key )
    self:onGameBegin()
    self.dataObj:setCurGameData( key )
    self:initAllStep()
    self:updateGameScoreUI()
    self:updateMiddleUI()
end

function FriendReplayBtnLayer:onDrawCardDone()
	self:unlock()
end

function FriendReplayBtnLayer:lock()
    self.lock_status = true
end

function FriendReplayBtnLayer:unlock()
    self.lock_status = false
end

function FriendReplayBtnLayer:onGameBegin()
	self.landMainScene:onGameBeginUI()
	self.gameLayer = self.landMainScene:getGameLayer()
	self:updateGameScoreUI()
end

function FriendReplayBtnLayer:initAllStep()
    self.cur_step = 0
    self.all_step = {}
    self.all_step[0] = {self.onGameBegin}
    self.all_step[1] = {self.onGameFaPai}
    
    local call    = self.dataObj:getCallScore()
    for i,v in ipairs( call ) do
    	table.insert(self.all_step,{self.onCallScore,i})
    end

    local bottomCard = self.dataObj:getBottomCard()
    if #bottomCard > 1 then
    	table.insert(self.all_step,{self.onGameLordResult})
    end

    local jiabei = self.dataObj:getJiaBeiInfo()
    for i,v in ipairs( jiabei ) do
    	table.insert(self.all_step,{self.onJiaBei,i})
    end

    local OutCard = self.dataObj:getAllOutCardData()
    for i,v in ipairs( OutCard ) do
        table.insert(self.all_step,{self.onOutCard,i})
    end

    local win_lose_data = self.dataObj:getWinLoseData()
    if self:winLoseDataCheck( win_lose_data ) then 
    	table.insert(self.all_step,{self.onGameJieSuan})
    end

    local allGame = self.dataObj:getAllGameData()
    if #allGame > 1 then
    	table.insert(self.all_step,{self.onGameNext})
    end
end


function FriendReplayBtnLayer:onGameFaPai()
	self:onGameBegin()
    local my_17_poker = self.dataObj:getMy17Poker()
    if my_17_poker and #my_17_poker > 1 then
    	self:lock()
    	self.gameLayer:setMyHandCard( my_17_poker )
    	self.gameLayer.cardScene:DispatchCard( CardKit:S2C_CONVERT(my_17_poker) )
    end
end

function FriendReplayBtnLayer:onGameLordResult()
	local lordPos = self.dataObj:getDiZhuChair()
	local call_score = self.dataObj:getCallScore()
	local bottomCard = self.dataObj:getBottomCard()

	if #bottomCard < 1 then return end
	
	self.gameLayer:UpdataPlayerCardNum(0,17)
	
	local vecCards = CONVERT_AND_SORT( bottomCard )
	self.gameLayer:onLordResult( lordPos , vecCards , 0 )
end

function FriendReplayBtnLayer:onGameJieSuan()
    local win_lose_data = self.dataObj:getWinLoseData()
    if not self:winLoseDataCheck( win_lose_data ) then return end
    
    for i,v in ipairs( win_lose_data ) do
    	self.gameLayer.game_chair_tbl[i]:setPlayerScoreRet(v)
    end
    self.gameLayer:clearAllPokerOut()
    self.gameLayer:clearMyCardUI()
    self:updateGameScoreUI( win_lose_data )

    self.gameLayer:playWinLoseAnimation( win_lose_data )
end

function FriendReplayBtnLayer:winLoseDataCheck( tbl )
	if type(tbl) ~= "table" or #tbl < 3 then return end
	for k,v in pairs( tbl ) do
		if v > 0 then return true end
	end
end

function FriendReplayBtnLayer:updateGameScoreUI( _winLose )
    local gameScores = self.dataObj:getJuGameScore( self.cur_paiju )
    local winLose = _winLose or {0,0,0}
    for chair,v in ipairs( gameScores ) do
    	local ret = v+winLose[chair]
        self.gameLayer.game_chair_tbl[chair]:setPlayerScore( ret )
    end
end

function FriendReplayBtnLayer:onGameNext()
	self:updateCurPaiJu(1)
end

function FriendReplayBtnLayer:onCallScore( key )
	local data = self.dataObj:getCallScore( key )
	self.gameLayer:chairCallScore( data[1] , data[2] )
end

function FriendReplayBtnLayer:onJiaBei( key )
	local data = self.dataObj:getJiaBeiInfo( key )
	self.gameLayer.game_chair_tbl[ data.opChair ]:onJiaBei( data.call )
	local beiShu = data.bei_shu[ self.meChair ]
	self.gameLayer:setDouble( beiShu )
end

function FriendReplayBtnLayer:onOutCard( key )
    self.gameLayer:hideAllSpeak()
    local data    = self.dataObj:getOutCardData( key )
    local beiShu  = data.bei_shu[ self.meChair ]
    local outCard = data.out_card or {}
    self.gameLayer:setDouble( beiShu )

    local pos = data.chair
    self.gameLayer:chairOutCard( pos , outCard , #data.cur_card[pos] )
    self.gameLayer.game_chair_tbl[ pos ]:setCardCount( #data.cur_card[pos] )
    
    local xiaJia = self.gameLayer:getXiaJiaChair( pos )
    self.gameLayer.game_chair_tbl[ xiaJia ]:clearPokerOut()

    
    self.gameLayer:setMyHandCard( data.cur_card[self.meChair] )
    self.gameLayer:updateMyCardUI()
    
end

function FriendReplayBtnLayer:initButton()
    self.pre_btn = self.layout_bg:getChildByName("Button_pre")
    self.pre_btn:addTouchEventListener(handler(self,self.onclickPlayBtn))

    self.next_btn = self.layout_bg:getChildByName("Button_next")
    self.next_btn:addTouchEventListener(handler(self,self.onclickPlayBtn))

    self.speed_btn = self.layout_bg:getChildByName("Button_speed")
    self.speed_btn:addTouchEventListener(handler(self,self.onclickPlayBtn))

    self.exit_btn = self.layout_bg:getChildByName("Button_exit")
    self.exit_btn:addTouchEventListener(handler(self,self.OnClickExitBtn))
end


function FriendReplayBtnLayer:onclickPlayBtn( sender,eventType )
    if eventType ~= ccui.TouchEventType.ended then return end
    if self.lock_status then return end
    if sender == self.pre_btn then
        self:OnClickPreBtn()
    elseif sender == self.next_btn then
        self:OnClickNextBtn()
    elseif sender == self.speed_btn then
        --if self.replay == false then
            self:OnClickSpeedBtn()
        --else
            --self.replay = false
            --self:resetCurGameData( self.cur_paiju )
            --self:OnClickSpeedBtn()
        --end
    end
end

function FriendReplayBtnLayer:OnClickPreBtn()
    self.gameLayer:hideAllSpeak()
    self.gameLayer:hideAllJiaBeiFlag()
    self:stopAutoPlay()
    self.gameLayer:clearAllPokerOut()
    self:updateCurStep(-1)
    self:playCurStep()
end

function FriendReplayBtnLayer:OnClickNextBtn()
    self:stopAutoPlay()
    self:updateCurStep(1)
    self:playCurStep()
end

function FriendReplayBtnLayer:OnClickSpeedBtn()
    self:updateCurSpeed(1)
    self:autoPlay()
end

function FriendReplayBtnLayer:OnClickExitBtn( sender,eventType  )
	if eventType == ccui.TouchEventType.ended then
	   print("FriendReplayBtnLayer OnClickExitBtn")
	   self.landMainScene:exit()
	end
end

function FriendReplayBtnLayer:playCurStep()
    print("FriendReplayBtnLayer:playCurStep ",self.cur_paiju , " , ",self.cur_step)
    if self.cur_step < 0 or self.cur_step > #self.all_step then
    	local allGame = self.dataObj:getAllGameData()
        if self.cur_paiju >= #allGame then
            TOAST("牌局播放完毕")
            self:stopAutoPlay()
            self.cur_speed_type = 1
            self.cur_paiju = 1
            self:updateSpeedBtn()
            self.replay = true
        end
        return
    end
    local step = self.all_step[self.cur_step]
    local fun = step[1]
    fun(self,step[2])
end

function FriendReplayBtnLayer:updateCurStep( tag )
    self.cur_step = math.max(0,self.cur_step + tag)
    self.cur_step = math.min(self.cur_step,#self.all_step+1)
end

function FriendReplayBtnLayer:updateCurPaiJu( tag )
    local allGame = self.dataObj:getAllGameData()
    if self.cur_paiju >= #allGame then return end
    self.cur_paiju = math.max(1,self.cur_paiju + tag)
    self:resetCurGameData( self.cur_paiju )
end

function FriendReplayBtnLayer:updateCurSpeed( tag )
    local tbl = {24,12,6,3}
    self.cur_speed_type = math.max(1,self.cur_speed_type+tag)
    self.cur_speed_type = math.min(#tbl+1,self.cur_speed_type)
    if self.cur_speed_type > #tbl then
        self.cur_speed_type = 2
    end
    self.gapTime = tbl[self.cur_speed_type]/10
    self:updateSpeedBtn()
end

function FriendReplayBtnLayer:updateSpeedBtn()
    local tbl = {"播放","播放X1","播放X2","播放X3"}
    local str = tbl[self.cur_speed_type]
    self.speed_btn:setTitleText( str )
end

function FriendReplayBtnLayer:autoPlay()
    self:stopAutoPlay()
    local function playNext()
        if not self.lock_status then
            self:updateCurStep(1)
            self:playCurStep()
        end
    end
    local a1 = cc.CallFunc:create( playNext )
    local a2 = cc.DelayTime:create( self.gapTime )
    local auto_play_action = cc.RepeatForever:create( cc.Sequence:create(a1,a2) )
    self.speed_btn:runAction( auto_play_action )
end

function FriendReplayBtnLayer:stopAutoPlay()
    self.speed_btn:stopAllActions()
end

-- 点击事件回调
function FriendReplayBtnLayer:onTouchCallback( sender )
    local name = sender:getName()
    print("name: ", name)
end

return FriendReplayBtnLayer