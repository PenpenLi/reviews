-- GameMainLayer
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 打牌主界面
local scheduler            = require("framework.scheduler")
local LandGlobalDefine     = require("src.app.game.pdk.src.landcommon.data.LandGlobalDefine")
local LandAccounts          = require("src.app.game.pdk.src.landcommon.view.LandAccounts")
local LandOverTopInfo      = require("src.app.game.pdk.src.landcommon.view.LandOverTopInfo")
local CardScene            = RequireEX("src.app.game.pdk.src.landcommon.view.CardScene")
local StackLayer           = require("app.hall.base.ui.StackLayer")
local CardSprite           = require("src.app.game.pdk.src.landcommon.models.CardSprite")
local GameChair            = RequireEX("src.app.game.pdk.src.landcommon.models.GameChair")
local GameLogic            = require("app.game.pdk.src.landcommon.logic.GameLogic")
local JumpLabel            = require("src.app.game.pdk.src.landcommon.view.JumpLabel")
local FriendJiabeiLayer    = RequireEX("src.app.game.pdk.src.friendland.view.FriendJiabeiLayer")

local LandAnimationManager = require("src.app.game.pdk.src.landcommon.animation.LandAnimationManager")
local LandArmatureResource = require("src.app.game.pdk.src.landcommon.animation.LandArmatureResource")
local LandSoundManager     = require("src.app.game.pdk.src.landcommon.data.LandSoundManager")
local GameRecordLayer= require("src.app.newHall.childLayer.GameRecordLayer")
local GameSetLayer= require("src.app.newHall.childLayer.SetLayer") 
local CardKit = require("src.app.game.pdk.src.common.CardKit")

local HNLayer= require("src.app.newHall.HNLayer")
local GameMainLayer = class("GameMainLayer", function()
    return StackLayer.new()
    -- return HNLayer.new()
end)

function GameMainLayer:ctor( landMainScene , gameAtom )
	self.game_atom = gameAtom
	self.m_landMainScene = landMainScene
	self.gameRoomBgLayer = landMainScene.gameRoomBgLayer
	self.m_GameLogic     = GameLogic:new()
	self.m_GameLogic:setXXDelegate(handler(self, self.getCardsNumber))
	self:initCSB()
	
	
	self:initCallScorePanel()
	self:initOutCardButtons()
	self:initHandCardScene()
	self:initCardSprite()
	self:initTuoGuanPanel()
	self:initJiaBeiPanel()
	
	self:initAnimationManager()

	self.m_landSoundManager = LandSoundManager:getInstance()   -- 声音管理器




-- 	self.meChairID = 1
-- 	self.enemy_out_card = {}
-- local function updateEnemyOutCard( pos , tbl )
-- 	if not self.enemy_out_card then self.enemy_out_card = {} end
-- 	self.enemy_out_card[pos] = tbl
-- end
-- local function getEnemyOutCard()
-- 	if not self.enemy_out_card then return end
-- 	local shangJiaChair   = self:getShangJiaChair()
-- 	local shangJiaOutCard = self.enemy_out_card[ shangJiaChair ] or {}
-- 	if #shangJiaOutCard > 0 then return shangJiaOutCard end

-- 	local xiaJiaChair = self:getXiaJiaChair()
-- 	return self.enemy_out_card[xiaJiaChair]
-- end
-- updateEnemyOutCard(1, {1})
-- print("getEnemyOutCardxxxxxxxxxxxxxxxxxxxxxxx 1", getEnemyOutCard())
-- updateEnemyOutCard(2, {2})
-- print("getEnemyOutCardxxxxxxxxxxxxxxxxxxxxxxx 2", getEnemyOutCard())
-- updateEnemyOutCard(3, {3})
-- print("getEnemyOutCardxxxxxxxxxxxxxxxxxxxxxxx 3", getEnemyOutCard())

end

function GameMainLayer:getCardsNumber( ... )
	-- body
	local nReturn = 0
	if type(self.game_chair_tbl) == "table" and type(self.meChairID) == "number"
	 and self.game_chair_tbl[self.meChairID]
	 and type(self.game_chair_tbl[self.meChairID].card_count) == "number" then 
	 		nReturn = self.game_chair_tbl[self.meChairID].card_count
	end
	return nReturn
end

function GameMainLayer:initCSB()
	self.root = cc.CSLoader:createNode("src/app/game/pdk/res/csb/classic_land_cs/free_land_main.csb")
    self:addChild(self.root, 6) -- 比gamechire要高
    UIAdapter:adapter(self.root, handler(self, self.onTouchCallback))
    UIAdapter:praseNode(self.root,self)
    self.BtnPush:setVisible(false) 
    self.Node_pop:setVisible(false)
    self.Node_menu:setLocalZOrder(10000)
     local diffX = 145-(1624-display.size.width)/2 
	self.Node_menu:setPositionX(diffX)
	self.panle:setPositionX(diffX);
	self.panle:setVisible(false);
    self.BtnExit:addTouchEventListener(handler(self, self.onReturnClicked))
    self.BtnPop:addTouchEventListener(handler(self, self.onPopClicked))
    self.BtnPush:addTouchEventListener(handler(self, self.onPushClicked))
    self.BtnPush2:addTouchEventListener(handler(self, self.onPushClicked)) 
    self.BtnRule:addTouchEventListener(handler(self, self.onRuleClicked))
    self.BtnMusic:addTouchEventListener(handler(self, self.onMusicClicked))
    self.BtnRecord:addTouchEventListener(handler(self, self.onRecordClicked))
    --
    self.mTextRecord = UIAdapter:CreateRecord(nil, 25)
	self.root:addChild(self.mTextRecord)
	self.mTextRecord:setLocalZOrder(100)
	self.mTextRecord:setAnchorPoint(cc.p(0, 0))
	-- self.mTextRecord:setOpacity(50)
	self.mTextRecord:setPosition(cc.p(180, display.size.height - 35))
	self.mTextRecord:setString("")
end

function GameMainLayer:refreshView()
	-- dump(g_GameController, "refreshView_refreshView")

	if g_GameController:isMatchGame() then
		self.panle:setVisible(true);
		local text_1 = self.panle:getChildByName("text_1");
		local text_2 = self.panle:getChildByName("text_2");
		local text_3 = self.panle:getChildByName("text_3");
		-- 96,55,33
		text_1:enableOutline(cc.c4b(96,55,33,255), 2);
		text_2:enableOutline(cc.c4b(96,55,33,255), 2);
		text_3:enableOutline(cc.c4b(96,55,33,255), 2);
		text_1:setColor(cc.c3b(255,255, 255));
		text_2:setColor(cc.c3b(255,255, 255));
		text_3:setColor(cc.c3b(255,255, 255));

g_GameController.m_roundPlayerNum = g_GameController.m_roundPlayerNum or 0
g_GameController.m_upgradeCnt = g_GameController.m_upgradeCnt or 0
g_GameController.minScore = g_GameController.minScore or 0
g_GameController.m_curRank = g_GameController.m_curRank or 0
g_GameController.m_roundPlayerNum = g_GameController.m_roundPlayerNum or 0

		if g_GameController.m_upgradeCnt == 1 then
			text_1:setString("总决赛");
		else
			text_1:setString(string.format( "%d进%d", g_GameController.m_roundPlayerNum, g_GameController.m_upgradeCnt));
		end
		text_2:setString(string.format( "第%d/%d局", g_GameController.m_inning, g_GameController.m_totalInning));
		text_3:setString(string.format( "底分:%d", self.double_num or g_GameController.minScore));
	
		local rank_text = self.panle:getChildByName("rank_text");
		rank_text:setString(string.format( "排名 %d/%d", g_GameController.m_curRank, g_GameController.m_roundPlayerNum));
	else
		self.panle:setVisible(false);
	end
end

function GameMainLayer:onRecordClicked( sender, eventType )
	if eventType == ccui.TouchEventType.ended then
		local GameRecordLayer = GameRecordLayer.new(2)
        self:addChild(GameRecordLayer,100)    
         ConnectManager:send2Server(Protocol.LobbyServer, "CS_C2H_GetGameResult_Req", {206})
	end
end
function GameMainLayer:onMusicClicked( sender, eventType )
	if eventType == ccui.TouchEventType.ended then
		 local layer = GameSetLayer.new();
		self:addChild(layer,100); 
	end
end

function GameMainLayer:onReturnClicked(sender,eventType)
    if eventType == ccui.TouchEventType.ended then 
    	print("selfxxxm_state", self.m_state )
    	-- g_GameController:releaseInstance()
    	if self.m_state ~= 1 then
            TOAST("游戏中无法退出！")
            return
        end
		g_GameController:reqUserLeftGameServer()  
    end
end

function GameMainLayer:onPopClicked(sender,eventType)
    if eventType == ccui.TouchEventType.ended then
--        if self.m_bIsMoveMenu then
--            return
--        end
        self.m_bIsMoveMenu = true
    
        self.Node_pop:setPosition(cc.p(0, 145))
        self.BtnPush2:setVisible(true)
        local call = cc.CallFunc:create(function()
            self.BtnPop:setVisible(false)
            self.BtnPush:setVisible(true)
        end)
        local call2 = cc.CallFunc:create(function()
            self.m_bIsMoveMenu = false
        end)
        UIAdapter:showMenuPop(self.Node_pop, call, call2, 0, 0)
    end
end

function GameMainLayer:onPushClicked(sender,eventType)
     if eventType == ccui.TouchEventType.ended then
--        if self.m_bIsMoveMenu then
--            return
--        end
        self.m_bIsMoveMenu = true
    
        self.BtnPush2:setVisible(false)
        local call = cc.CallFunc:create(function()
            self.BtnPop:setVisible(true)
            self.BtnPush:setVisible(false)
        end)
        local call2 = cc.CallFunc:create(function()
            self.m_bIsMoveMenu = false
        end)
        UIAdapter:showMenuPush(self.Node_pop, call, call2, 0, 145)
    end
end
function GameMainLayer:onRuleClicked(sender,eventType)
     if eventType == ccui.TouchEventType.ended then
          self:getParent():showRuleLayer() 
    end
end
--初始化自己的手牌
function GameMainLayer:initHandCardScene()
    --我的手牌中间那张
    local toShowCard = self.root:getChildByName("poker_clubs")
    toShowCard:setVisible(false)
    self.m_meshowcardpos = cc.p(toShowCard:getPositionX(), toShowCard:getPositionY())


    self.cardScene = CardScene.new( self.m_landMainScene , self.outCardBtnsPanel )
    self.cardScene:SetBenchmarkPos(cc.p(self.m_meshowcardpos.x, self.m_meshowcardpos.y))
    self:addChild(self.cardScene, 3)
end

-- 牌精灵
function GameMainLayer:initCardSprite()
    self.m_cardSprite = CardSprite.new(self.m_landMainScene:getLandGameType())
end

----------底牌面板结束----------

----------出牌面板开始----------
function GameMainLayer:initOutCardButtons()
    self.outCardBtnsPanel = self.root:getChildByName("out_card_btns_panel")
    --不出
    self.passButton = self.outCardBtnsPanel:getChildByName("pass_button")
	self.passButtonLabel =self.outCardBtnsPanel:getChildByName("pass_label")
    
    self.passButton:addTouchEventListener(handler(self,self.onClickPassBtn))
	self.passButtonLabel:enableOutline({r = 103, g = 142, b = 28, a = 255}, 3)

    --提示
    self.prometButton =  self.outCardBtnsPanel:getChildByName("promet_button")
    self.prometButton:loadTextures("fj_op_btn_02.png", "", "", 1)
    self.prometButton:setTag( LandGlobalDefine.OPERATION_CARD_PROMET )
    self.prometButton:addTouchEventListener(handler(self,self.onClickPrometBtn))
    --
    self.prometButtonLabel =self.outCardBtnsPanel:getChildByName("promet_label")
	self.prometButtonLabel:setVisible(false)
	local prometButtonLabel = ccui.ImageView:create("fj_op_btn_txt_tip.png", 1);
	prometButtonLabel:setPosition(self.prometButton:getContentSize().width * 0.5, self.prometButton:getContentSize().height * 0.5)
    self.prometButtonLabel:getParent():addChild(prometButtonLabel)
	self.prometButtonLabel = prometButtonLabel
-- self.prometButtonLabel:enableOutline({r = 28, g = 142, b = 122, a = 255}, 3)

    --出牌
    self.outcardButton =  self.outCardBtnsPanel:getChildByName("outcard_button")
    self.outcardButton:loadTextures("fj_op_btn_03.png", "", "", 1)
    self.outcardButton:setTag(LandGlobalDefine.OPERATION_CARD_OUTCARD)
    self.outcardButton:addTouchEventListener(handler(self,self.onClickOutCardBtn))
    --
    self.outcardButtonLabel = self.outCardBtnsPanel:getChildByName("outcard_label")
	self.outcardButtonLabel:setVisible(false)
	local outcardButtonLabel = ccui.ImageView:create("fj_op_btn_txt_out_invalid.png", 1);
	outcardButtonLabel:setPosition(self.outcardButton:getContentSize().width * 0.5, self.outcardButton:getContentSize().height * 0.5)
    self.outcardButtonLabel:getParent():addChild(outcardButtonLabel)
	self.outcardButtonLabel = outcardButtonLabel
--	self.outcardButtonLabel:enableOutline({r = 103, g = 142, b = 28, a = 255}, 3)

    self:setOutCardButtonsVisible(false)

    self.lord_txt_qxtgsb = self.outCardBtnsPanel:getChildByName("lord_txt_qxtgsb") -- 取消托管失败
    self.lord_txt_bfhcpgz = self.outCardBtnsPanel:getChildByName("lord_txt_bfhcpgz") -- 不符合 出牌规则 
    self.lord_txt_qxtgsb:setVisible(false)
    self.lord_txt_bfhcpgz:setVisible(false)

	self.prometButton:setPositionX(self.passButton:getPositionX())
    self.passButton:setOpacity(0)
    self.passButton:setEnable(false)
    self.passButton:setPositionX(-1000)
end

--控制出牌面板的显示
function GameMainLayer:setOutCardButtonsVisible( isShow )
    self.outCardBtnsPanel:setVisible( isShow )
end

---显示出牌按钮
function GameMainLayer:showOutCardPanel()
    self:setOutCardButtonsVisible( true )
    self:updateOutCardPanel()
    self:updateOutCardBtn()
end

function GameMainLayer:updateOutCardBtn()
	local flag = self:verdictOutCard() or false
	self:setOutCardButtonsEnable( LandGlobalDefine.OPERATION_CARD_OUTCARD , flag )
end

function GameMainLayer:updateOutCardPanel()
	local enemyCard = self:getEnemyOutCard() or {}
	if #enemyCard < 1 then
		self:setOutCardButtonsEnable( LandGlobalDefine.OPERATION_CARD_PASS , false )
		self:setOutCardButtonsEnable( LandGlobalDefine.OPERATION_CARD_PROMET , true )
		self:setOutCardButtonsEnable( LandGlobalDefine.OPERATION_CARD_OUTCARD , false )
	else
		self:setOutCardButtonsEnable( LandGlobalDefine.OPERATION_CARD_PROMET , true )
		self:setOutCardButtonsEnable( LandGlobalDefine.OPERATION_CARD_PASS , true )
	end
end

--设置出牌按钮的状态
function GameMainLayer:setOutCardButtonsEnable( nId, bEnable )
    if nId == LandGlobalDefine.OPERATION_CARD_PASS then
        --self.passButton:setEnable(bEnable)
		if bEnable==false then
			self.passBtnIsClick = false
			local iconName = "lord_btn_new_gray.png"
			self.passButton:loadTextures(iconName, iconName, iconName, 1)
			self.passButtonLabel:enableOutline({r = 99, g = 99, b = 99, a = 255}, 3)
		else
			self.passBtnIsClick = true
			local iconName = "lord_btn_green.png"
			self.passButton:loadTextures(iconName, iconName, iconName, 1)
			self.passButtonLabel:enableOutline({r = 103, g = 142, b = 28, a = 255}, 3)
		end
    elseif nId == LandGlobalDefine.OPERATION_CARD_PROMET then
    	bEnable = true
        self.prometButton:setEnable(bEnable)
	    if bEnable==false then
	    	self.promeBtnIsClick = false
	    	-- local iconName = "lord_btn_new_gray.png"
	    	-- self.prometButton:loadTextures(iconName, iconName, iconName, 1)
			-- self.prometButtonLabel:enableOutline({r = 99, g = 99, b = 99, a = 255}, 3)
			self.prometButton:loadTextures("fj_op_btn_02.png", "", "", 1)
		else
			self.promeBtnIsClick = true
			-- local iconName = "lord_btn_bluegreen.png"
			-- self.prometButton:loadTextures(iconName, iconName, iconName, 1)
			-- self.prometButtonLabel:enableOutline({r = 28, g = 142, b = 122, a = 255}, 3)
			self.prometButton:loadTextures("fj_op_btn_02.png", "", "", 1)
		end
    elseif nId == LandGlobalDefine.OPERATION_CARD_OUTCARD then
		if bEnable==false then
			self.isCanOutCard = false
			-- self.isCanOutCard = true
			local iconName = "lord_btn_new_gray.png"
			iconName = "fj_op_btn_03.png"
			self.outcardButton:loadTextures(iconName, iconName, iconName, 1)
			-- self.outcardButtonLabel:enableOutline({r = 99, g = 99, b = 99, a = 255}, 3)
			iconName = "fj_op_btn_txt_out_invalid.png"
			self.outcardButtonLabel:loadTexture(iconName,1)
		else
			self.isCanOutCard = true
			local iconName = "lord_btn_green.png"
			iconName = "fj_op_btn_01.png"
			self.outcardButton:loadTextures(iconName, iconName, iconName, 1)
			-- self.outcardButtonLabel:enableOutline({r = 103, g = 142, b = 28, a = 255}, 3)
			iconName = "fj_op_btn_txt_out.png"
			self.outcardButtonLabel:loadTexture(iconName, 1)
		end		
    end
end

function GameMainLayer:onClickPassBtn( sender, eventType )
	if eventType ~= ccui.TouchEventType.ended then return end
	if self.passBtnIsClick == false then return end
	self:onPassCard()
end

function GameMainLayer:onClickPrometBtn( sender, eventType )
	if eventType ~= ccui.TouchEventType.ended then return end
	if self.promeBtnIsClick == false then return end
	self:clickPrompt() 
end

function GameMainLayer:onClickOutCardBtn( sender, eventType )
	if eventType ~= ccui.TouchEventType.ended then return end

	if self.isCanOutCard == false then
		self.lord_txt_bfhcpgz:setVisible(true)
		self.lord_txt_bfhcpgz:stopAllActions()
		self.lord_txt_bfhcpgz:runAction(cc.Sequence:create(D(1),cc.Hide:create()))
		return
    end

	local outCards = self.cardScene:GetShootCard()
	if not outCards or #outCards == 0 then return end
	-- self:fakeOutCard( outCards )
	self:onClickOutCard()
	self:reqOutCard( CardKit:C2S_CONVERT( outCards ) )
end

function GameMainLayer:onClickOutCard()
	self:setOutCardButtonsVisible(false)
	self.game_chair_tbl[ self.meChairID ]:hideClock()
	local sec = self.game_chair_tbl[ self.meChairID ]:getClockSec()
end

function GameMainLayer:onSlowOutCard( sec )
	if IS_PAI_YOU_FANG( self.game_atom ) then return end
	local str = "因为您多次缓慢出牌,您的出牌时间被缩短为"..sec.."秒"
	local notice =  require("src.app.game.pdk.src.landcommon.view.LandRollNotice").new(str, 1, 5)
    ToolKit:addBeginGameNotice(notice, 5)
end
----------出牌面板结束----------

----------叫分面板开始----------
function GameMainLayer:initCallScorePanel()
    self.callScorePanel = self.root:getChildByName("call_score_panel")
    self.score_btn_tbl = {}
    for i=0,3 do
    	self.score_btn_tbl[i] = self.callScorePanel:getChildByName("score_button_"..i)
    	self.score_btn_tbl[i].label = self.callScorePanel:getChildByName("score_label_"..i)
    	self.score_btn_tbl[i].label:enableOutline({r = 28, g = 142, b = 122, a = 255}, 3)
    	self.score_btn_tbl[i]:addTouchEventListener( handler(self,self.onClickScoreBtn) )
    	self.score_btn_tbl[i].score = i
    end
    self:hideCallScorePanel()
end

function GameMainLayer:onClickScoreBtn( sender, eventType )
	if eventType ~= ccui.TouchEventType.ended then return end
	self:reqJiaoFen( sender.score )
end

function GameMainLayer:hideCallScorePanel()
	self.callScorePanel:setVisible( false )
end

function GameMainLayer:showCallScorePanel( score )
	self.callScorePanel:setVisible( true )
	for i,v in ipairs( self.score_btn_tbl ) do
		v:setEnable( (i > score) or (i==0) )
		if i > score or i == 0 then
			v.label:enableOutline({r = 28, g = 142, b = 122, a = 255}, 3)
		else
			v.label:enableOutline({r = 99, g = 99 , b = 99 , a = 255}, 3)
		end
	end
end
----------叫分面板结束----------


----------加倍面板开始----------
function GameMainLayer:initJiaBeiPanel()
	self.jiaBeiPanel = FriendJiabeiLayer.new( self.game_atom )
	self:addChild(self.jiaBeiPanel,5)
	self.jiaBeiPanel:setVisible(false)
end

function GameMainLayer:showJiaBeiPanel()
	self.jiaBeiPanel:setVisible(true)
end

function GameMainLayer:hideJiaBeiPanel()
	self.jiaBeiPanel:setVisible(false)
end

----------加倍面板结束----------
----------托管面板开始----------

function GameMainLayer:initTuoGuanPanel()
	self.tuoGuanPanel = LandOverTopInfo.new( self.m_landMainScene )
	self:addChild( self.tuoGuanPanel , 5 )
end

-- 显示要不起面板
function GameMainLayer:showNotAfford()
    self.tuoGuanPanel:setNotAffordVisible(true)
end

-- 隐藏要不起面板
function GameMainLayer:hideNotAfford()
    self.tuoGuanPanel:setNotAffordVisible(false)
end

function GameMainLayer:updateTuoGuanUI()
	local meChair = self:getMeChairID()
	local val = self.game_chair_tbl[ meChair ]:getTuoGuanStatus()
	self.tuoGuanPanel:setHostingBtnVisible( val == 1 )
	if val == 1 and meChair ~= self:getLordChair() then
		self:toastTuoGuan()
	end
end

function GameMainLayer:toastTuoGuan()
	if not self.last_toast then self.last_toast = 0 end
	if os.time() - self.last_toast < 2 then return end
	self.last_toast = os.time()
	TOAST("超时未出牌，开始托管")
end

function GameMainLayer:hideTuoGuanPanel()
	self:hideNotAfford()
	self.tuoGuanPanel:setHostingBtnVisible(false)
end
----------底部面板结束----------
function GameMainLayer:initChairTable( players )
	self.game_chair_tbl = {}
	self.gameRoomBgLayer:showMyHead()
	if not players then return end
	for k,v in pairs( players ) do
		local score = v:getGameScore()
		if not g_GameController:isMatchGame() then 
            score = v:getGoldCoin()
        end
		local chair  = v:getChairId()
		local aChair = GameChair.new( chair , self.meChairID , self.game_atom )
		local faceID = v:getFaceId()
		local acc    = v:getAccountId()
		aChair:showHead( faceID , acc )
		aChair:setPlayerName( v:getNickname() )
		aChair:setPlayerScore( score )
		aChair:setOffLine( v.m_offine or 0 )
		local zorder = 4
		if chair == self.meChairID then zorder = 5 end
		self:addChild( aChair , zorder )
		self.game_chair_tbl[ chair ] = aChair
		local csbName = aChair:getCSBName()
		self:setChatPos( acc , csbName , aChair )
	end
end

function GameMainLayer:clearUIForGoon()
	for k,v in pairs( self.game_chair_tbl ) do
		v:clearPokerOut()
		v:clearScroe()
		v:clearHead()
		v:hideJiaBeiFlag()
	end
end

function GameMainLayer:updateOffLine( players )
	if type( players ) ~= "table" or type( self.game_chair_tbl ) ~= "table" then return end
	for chair,v in pairs( self.game_chair_tbl ) do
		local data = players[chair]
		local flag = 0
		if data and data.m_offine then
			flag = data.m_offine
		end
		v:setOffLine( flag )
	end
end

function GameMainLayer:hideInfoPanel()
	if type( self.game_chair_tbl ) ~= "table" then return end
	for k,v in pairs( self.game_chair_tbl ) do
		v:setInfoPanel( false )
	end
end

function GameMainLayer:setChatPos( acc , csbName , aChair )

	local isFlippedX = false
	local isFlippedY = false
	if csbName == "right" then
		isFlippedX = true
	end
    
    local point = aChair.land_speak:convertToWorldSpaceAR(cc.p(aChair.land_speak:getPositionX()+100,aChair.land_speak:getPositionX()-30))
    local expressionPos = nil  --表情的位置 
    local expressionPos1 = nil -- 文字的位置            
    
    if csbName == "self" then
        expressionPos  = cc.p(point.x-265,point.y-190)  --表情的位置
        expressionPos1 = cc.p(point.x-200,point.y-130) -- 文字的位置
    elseif csbName == "left" then
        expressionPos  = cc.p(point.x-260,point.y-125)  --表情的位置 
        expressionPos1 = cc.p(point.x-150,point.y-150) -- 文字的位置
    elseif csbName == "right" then
        expressionPos  = cc.p(point.x,point.y-110)  --表情的位置 
        expressionPos1 = cc.p(point.x-100,point.y-150) -- 文字的位置
    end
    if self.m_landMainScene.m_landSystemSet then
    	self.m_landMainScene.m_landSystemSet:updatePlayerIDS( acc , expressionPos1 , expressionPos , isFlippedX , isFlippedY )            
    end
end

function GameMainLayer:setTiRen( tag )
	if type( self.game_chair_tbl ) ~= "table" then return end
	for k,v in pairs( self.game_chair_tbl ) do
		v:setTiRenBtn( tag )
	end
end

-- 动画层.游戏中要播放的动画都放在这里边播放
function GameMainLayer:initAnimationManager()
    self._animationLayer = display.newLayer()
    self._animationLayer:setAnchorPoint(cc.p(0.5,0.5))
    self._animationLayer:setPosition(cc.p(display.cx,display.cy))

    self:addChild(self._animationLayer,6)
    self._animationLayer:setVisible( true )
    self.landAnimationManager = LandAnimationManager.new(self._animationLayer) 
end
function GameMainLayer:playWaitAni()
    self.landAnimationManager:PlayAnimation(LandArmatureResource.WAIT_START)
end
function GameMainLayer:removeWaitAni()
     self.landAnimationManager:stopAndClearArmatureAnimation(LandArmatureResource.WAIT_START)
end
--播放牌型动画
function GameMainLayer:playOutCardAni( chair , tbl )
	local pos  = nil
	local wOutCardType = self.m_GameLogic:GetCardType( CardKit:S2C_CONVERT(tbl) )

	print("wOutCardType============", wOutCardType)

	-- 	如果是xx, xx类型.要传一个坐标过去
	if false
		or wOutCardType == LandGlobalDefine.CT_SINGLE_LINE or wOutCardType == LandGlobalDefine.CT_DOUBLE_LINE 
		-- or wOutCardType == LandGlobalDefine.CT_BOMB_CARD
		-- or wOutCardType == LandGlobalDefine.CT_FEIJI_TAKE_TWO
		or wOutCardType == LandGlobalDefine.CT_THREE_TAKE_TT or wOutCardType == LandGlobalDefine.CT_THREE_TAKE_ONE
		or wOutCardType == LandGlobalDefine.CT_FOUR_TAKE_THREE
		then
        pos = self.game_chair_tbl[chair]:getLineAniPlayPos()
        self.landAnimationManager:playAnimationWithType( wOutCardType , pos )
        return
    end
    -- 其他类型
    self.landAnimationManager:playAnimationWithType( wOutCardType , pos )
end

function GameMainLayer:clearMyCardUI()
	self.cardScene:ClearHandCard()
end

function GameMainLayer:updateMyCardUI()
	self.cardScene:setModel(2)
	table.sort( self.myHandCard ,SortCardTable )
	self:clearMyCardUI()
	self.cardScene:SetCardData( self.myHandCard , #self.myHandCard )
end

function GameMainLayer:showSomeOfMyCard( per )
	self.cardScene:setModel(1)
	table.sort( self.myHandCard ,SortCardTable )
	local total = #self.myHandCard
	local n = math.ceil(per/(75/total))
	local ret = {}
	for k,v in ipairs( self.myHandCard ) do
		if k <= n then
			table.insert( ret , v )
		end
	end
	self:clearMyCardUI()
	self.cardScene:SetCardData( ret , total )
	self:UpdataPlayerCardNum(0,#ret)
end

function GameMainLayer:playWinLoseAnimation( lastOutCardPos )
	for k,v in pairs( self.game_chair_tbl ) do
		v:onGameEnd( lastOutCardPos )
	end
end

--出牌提示
function GameMainLayer:clickPrompt()
--    local popTable = self:getShootCardDataServer()
--    local resultTable = self:getTipsOutCardData( popTable )
 
    local myCardsServer   = CardKit:C2S_CONVERT( self.myHandCard )
    local lastCardsServer = self:getEnemyOutCard() or {}
    dump(myCardsServer, "clickPrompt__myCardsServer")
    dump(lastCardsServer, "clickPrompt__lastCardsServer")

    local resultTable = self.m_GameLogic:SearchOutCard(myCardsServer, lastCardsServer, true)
    dump(resultTable, "clickPrompt__resultTable")

    local resultTableNum = table.nums(resultTable)
    if resultTableNum > 0 then
        self.cardScene:SetShootCard(resultTable, resultTableNum)
        self:updateOutCardBtn()
    end

   -- 	-- 自己隨便出牌
  	-- local enemyCard = lastCardsServer
   --  if #enemyCard < 1 then
   --      local tab = {}
   --      if self.myHandCard[#self.myHandCard]%16 ~= self.myHandCard[#self.myHandCard-1]%16 then
   --          table.insert(tab, self.myHandCard[#self.myHandCard])
   --      else 
   --          if self.myHandCard[#self.myHandCard-2]  then
   --             if  self.myHandCard[#self.myHandCard-1]%16 ~= self.myHandCard[#self.myHandCard-2]%16 then
   --                   table.insert(tab, self.myHandCard[#self.myHandCard])
   --                   table.insert(tab, self.myHandCard[#self.myHandCard-1])
   --              else
   --                    table.insert(tab, self.myHandCard[#self.myHandCard])
   --                   table.insert(tab, self.myHandCard[#self.myHandCard-1])
   --                   table.insert(tab, self.myHandCard[#self.myHandCard-2])
   --              end
   --          else
   --              table.insert(tab, self.myHandCard[#self.myHandCard])
   --              table.insert(tab, self.myHandCard[#self.myHandCard-1])
   --          end
   --      end
   --      self.cardScene:SetShootCard(tab, #tab)
   --      self:updateOutCardBtn()
   --  	--self.cardScene:ResetShootCard()
   --  end
end

--获取推荐出的牌
function GameMainLayer:getTipsOutCardData( __shootCardServer )
--	self:CalcTipsOutCardData()
    local cardData = __shootCardServer or {}
--    local resultTableServer = qka.LandCGameLogic:GetInstance():GetPromptByClickLua( cardData ) 
    local resultTableServer = {}

    local resultTableClient = CardKit:S2C_CONVERT( resultTableServer )
    return resultTableClient
end

--计算提示能出的牌
function GameMainLayer:CalcTipsOutCardData()
    local myCardsServer   = CardKit:C2S_CONVERT( self.myHandCard )
    local lastCardsServer = self:getEnemyOutCard() or {}
    qka.LandCGameLogic:GetInstance():GetCardPromptDataLua( myCardsServer, lastCardsServer )
end

function GameMainLayer:getShootCardDataServer()
    --获取已经弹起来的牌
    local shootCardsDataClient = self.cardScene:GetShootCard() or {}    
    local shootCardsDataServer = CardKit:C2S_CONVERT( shootCardsDataClient )
    return shootCardsDataServer
end
----------欢乐跑得快消息处理开始---------------
function GameMainLayer:HLLand_LoginData_Nty( _info )
	local state = _info.m_eRoundState
	if state == LandGlobalDefine.GAME_OPEN_POKER then
		self:restoreStatusOpenPoker( _info )
	elseif state == LandGlobalDefine.GAME_LAND_OPEN_POKER then
		self:restoreStatusLandOpenPoker( _info )
	else
		self:LandLord_LoginData_Nty( _info )
	end
end

function GameMainLayer:restoreStatusOpenPoker( _info )
	local lordPos = _info.m_nLordChairIdx
	LogINFO("断线重连恢复到进度条明牌状态,地主 : " , lordPos )
	local totalSec  = ADD_UP_TABLE( _info.m_nOpenTime )/1000
	local leftSec   = _info.m_nOperateTime
	local alreadyUseSec     = totalSec - leftSec
	self.showJiaBeiTime     = os.time() + leftSec
	self.openPokerLayer     = self.m_landMainScene:addHappyOpenPokerLayer()
	local meChair = self:getMeChairID()
	local tbl = _info["m_vec"..meChair.."ChairCards"]
	self:setMyHandCard( tbl )

	self.happy_jiabei_opsec =  _info.m_nDouTime
	self.bottom_card  = CONVERT_AND_SORT( _info.m_vecUnderPoker )
	self.diPaiBeishu  = _info.m_nUnderMul
	self.openPokerLayer:setLoadingBarText( _info )
	self.openPokerLayer:restoreStatus( totalSec , leftSec )
	self.openPokerLayer:startLoadingBarTimer()
	if lordPos > 0 then
		self.lord_chair = lordPos
		self.openPokerLayer:hideOpenPokerBG()
		self:setOthersOpenPoker( _info )
		self:delayShowJiaBeiPanel()
		local cardCount = self:calculateCardCount( alreadyUseSec )
		self.game_chair_tbl[ self.lord_chair ]:onOpenPoker(  _info.m_vecLandOpenCards , true , cardCount )
	end
end

function GameMainLayer:restoreStatusLandOpenPoker( _info )
	local pos = _info.m_nOperateChair
	local meChair = self:getMeChairID()
	self:setTheLord( _info.m_nLordChairIdx )

	self.bottom_card = CONVERT_AND_SORT( _info.m_vecUnderPoker )
	self.gameRoomBgLayer:restoreHappyBottomCard(self.bottom_card, _info.m_nUnderMul, self.m_GameLogic)

	self.openPokerLayer = self.m_landMainScene:addHappyOpenPokerLayer()
	self.openPokerLayer:hideOpenPokerBG()
	
	local tbl = _info["m_vec"..meChair.."ChairCards"]
	self:setMyHandCard( tbl )
	self:updateMyCardUI()
	self.game_chair_tbl[pos]:showClock( _info.m_nOperateTime )
	if pos == meChair then
		self:showHappyMingPai()
	end
	self:setPlayerCardCount()
end

function GameMainLayer:HLLand_Begin_Nty( _info )
	self.openPokerLayer = self.m_landMainScene:addHappyOpenPokerLayer()
	self:setMyHandCard( _info.m_vecGetCards )
	

	local totalSec = ADD_UP_TABLE( _info.m_nOpenTime )/1000
	self.showJiaBeiTime = os.time() + totalSec
	self.diPaiBeishu =  _info.m_nLastCardsMul or 1  -- 底牌倍数
	self.openPokerLayer:setLoadingBarText( _info )
	self.openPokerLayer:startLoadingBarTimer()
end

function GameMainLayer:calOpenPokerOpSec( tbl )
	local ret = 0
	for k,v in pairs( tbl ) do
		ret = ret + v
	end
	ret = ret/1000
	return ret
end

function GameMainLayer:delayShowJiaBeiPanel()
	local function f()
		if self and self.bottom_card then
			self.cardScene:SetBackCardData( self.bottom_card )
			if self.lord_chair and self.lord_chair == self:getMeChairID() then
				self:addCardToMyHand( self.bottom_card )
			else
				self:updateMyCardUI()
			end
			self:onLordResult( self.lord_chair , self.bottom_card, self.diPaiBeishu )
			self.game_chair_tbl[ self:getMeChairID() ]:showClock( self.happy_jiabei_opsec )
			self:showJiaBeiPanel()
			self:clearHappyLayer()
		end
	end
	scheduler.performWithDelayGlobal( f , self.showJiaBeiTime - os.time() )
end

function GameMainLayer:showOtherFarmerPoker()
	local pos = self:getOtherFarmerChair()
	if not pos then return end
	self.game_chair_tbl[ pos ]:showHappySmallPoker()
end

function GameMainLayer:ntyNotOpenPoker( pos , opSec )
	if not pos or not self.game_chair_tbl[ pos ] then return end
	self.game_chair_tbl[ pos ]:showClock( opSec )
	self:UpdataPlayerCardNum(0,17)
	self:updateMyCardUI()
	self:clearHappyLayer()
	if pos == self:getMeChairID() then
		self:showHappyJiaoDiZhu()
	end
	self.gameRoomBgLayer:showBackCard()
end

function GameMainLayer:ntyOpenPoker( _info )
	self.diPaiBeishu = _info.m_nLastCardsMul
	self.lord_chair  = _info.m_nOpenPosition
	self:setDouble( _info.m_nOpenMul )
	self:setBrightButtonsVisible()
	
	self.happy_jiabei_opsec = _info.m_nNextTime
	self.bottom_card  = CONVERT_AND_SORT( _info.m_vecLastCards )
	local runTime = 12 - (self.showJiaBeiTime - os.time())
	local cardCount = self:calculateCardCount(runTime)

	self.game_chair_tbl[ self.lord_chair ]:onOpenPoker( _info.m_vecChairCards , true , cardCount)

	local otherFarmer = self:getOtherFarmerChair()
	if self.game_chair_tbl[ otherFarmer ] then
		self.game_chair_tbl[ otherFarmer ]:setCurHandCard( _info.m_vecFarmerCards )
	end

	self:delayShowJiaBeiPanel()
end

function GameMainLayer:calculateCardCount(time)
	return math.ceil(time/(12/17))
end

function GameMainLayer:showHappyJiaoDiZhu()
	self:showTakeLord(1)
end


function GameMainLayer:showHappyQiangDiZhu()
	self:showTakeLord(2)
end

function GameMainLayer:showHappyMingPai()
	self:showTakeLord(3)
end

function GameMainLayer:HLLand_OpenPoker_Nty( _info )
	if _info.m_nOpenMul > 1 then
		self:ntyOpenPoker( _info )
	else
		self:ntyNotOpenPoker( _info.m_nNextPosition , _info.m_nNextTime )
	end
end

function GameMainLayer:clearHappyLayer()
	self.m_landMainScene:removeHappyOpenPokerLayer()
	self.openPokerLayer = nil
end

function GameMainLayer:HLLand_Result_Nty( _info )
	self:LandLord_esult_Nty( _info )
end

function GameMainLayer:HLLand_LandOpenPoker_Nty( _info )
	local meChair = self:getMeChairID()
	self:clearHappyLayer()
	self:setDouble( _info.m_nOpenMul )
	local lordPos = self:getLordChair()
	self.game_chair_tbl[ lordPos ]:onOpenPoker( _info.m_vecChairCards , false )
	self:onMyTurnJiaBei( _info.m_nNextTime )

	local otherFarmer = self:getOtherFarmerChair()
	if self.game_chair_tbl[ otherFarmer ] then
		self.game_chair_tbl[ otherFarmer ]:setCurHandCard( _info.m_vecFarmerCards )
	end
end

function GameMainLayer:onMyTurnJiaBei( opSec )
	self:showJiaBeiPanel()
	self.game_chair_tbl[ self:getMeChairID() ]:showClock( opSec )
end

--  每张牌绘制的回调
function GameMainLayer:UpdataBrightCardProgress( num )
	
end

function GameMainLayer:setBrightButtonsVisible()
	if self.openPokerLayer then
		self.openPokerLayer:hideOpenPokerBG()
	end
end

function GameMainLayer:showTakeLord( num )
	if not self.openPokerLayer then
		self.openPokerLayer = self.m_landMainScene:addHappyOpenPokerLayer()
	end
	if self.openPokerLayer then
		self.openPokerLayer:showCallBG(num)
	end
end

function GameMainLayer:hideTakeLord()
	if self.openPokerLayer then
		self.openPokerLayer:hideCallBG()
	end
end

----------欢乐跑得快结束-------------------------------
----------游戏服消息处理开始----------
function GameMainLayer:LandLord_LoginData_Nty( _info )
	self.m_landMainScene:setGameState( _info.m_eRoundState )
	if _info.m_eRoundState == LandGlobalDefine.GAME_READY then
		LogINFO("等待状态")
		self:restoreStatusReady()
	elseif _info.m_eRoundState == LandGlobalDefine.GAME_OUTCARD then
		LogINFO("出牌状态")
		self:restoreStatusPlay( _info )
	elseif _info.m_eRoundState == LandGlobalDefine.GAME_LANDSCORE then
		LogINFO("叫分状态")
		self:restoreStatusJiaoFen( _info )
	elseif _info.m_eRoundState == LandGlobalDefine.GAME_END then
		LogINFO("结束状态")
		self:restoreStatusGameEnd( _info )
	elseif _info.m_eRoundState == LandGlobalDefine.GAME_JIABEI then
		LogINFO("加倍状态")
		self:restoreStatusGameJiaBei( _info )
	elseif _info.m_eRoundState == LandGlobalDefine.GAME_CARRY_ON then
		LogINFO("继续状态")
		self:restoreStatusGameCarryOn( _info )
	end 
end

function GameMainLayer:restoreStatusGameCarryOn( _info )
	self.m_landMainScene:restoreGameCarryOn( _info )
	for chair,v in ipairs( _info.m_vecValue ) do
		if v == 1 then
			self.game_chair_tbl[chair]:onReadyCarryOn()
		end
	end
end

function GameMainLayer:restoreStatusGameJiaBei( _info )
	local meChair = self:getMeChairID()
	local tbl = _info["m_vec"..meChair.."ChairCards"]
	
	self.bottom_card = CONVERT_AND_SORT( _info.m_vecUnderPoker )
	self.gameRoomBgLayer:restoreHappyBottomCard(self.bottom_card, _info.m_nUnderMul, self.m_GameLogic)
	
	self:setDouble( _info.m_nTotalMultiple )
	self:setMyHandCard( tbl )
	self:updateMyCardUI()
	self:setTheLord( _info.m_nLordChairIdx )
	self:setPlayerCardCount()

	local status = _info.m_vecValue[meChair]
	if status == 0 then
		LogINFO("断线重连恢复到加倍状态,断线之前我还没有做出选择")
		local opSec = _info.m_nOperateTime
		self.game_chair_tbl[ meChair ]:showClock( opSec )
		self:showJiaBeiPanel()
	elseif status == 1 then
		LogINFO("断线重连恢复到加倍状态,断线之前我选择了不加倍")
		self.game_chair_tbl[ meChair ]:onJiaBei(0)
	else
		LogINFO("断线重连恢复到加倍状态,断线之前我选择了加倍,倍数是,",status)
		self.game_chair_tbl[ meChair ]:onJiaBei( status )
	end

	self:setOthersOpenPoker( _info )
end

function GameMainLayer:restoreStatusReady()
	-- if IS_FAST_GAME( self.game_atom ) then return end
	-- self:sendReady()
end

function GameMainLayer:setPlayerCardCount()
	for k,v in pairs( self.game_chair_tbl ) do
		-- if k == self:getLordChair() then
		-- 	v:initCardCount(20)
		-- else
			v:initCardCount(16)
		-- end
	end
end

function GameMainLayer:delaySendReady( sec )
	local function f()
		if not self or not self.sendReady then return end
		self:sendReady()
	end
	scheduler.performWithDelayGlobal( f , sec )
end

function GameMainLayer:restoreStatusGameEnd( _info )
	self:setTheLord( _info.m_nLordChairIdx )
end

function GameMainLayer:restoreStatusJiaoFen( _info )
	for i,v in ipairs( _info.m_vecValue ) do
		if v >= 0 then
			self:chairCallScore( i , v , v )
		end
	end
	self:setPlayerCardCount()
	local opTag = self:getMaxCall()
	self:chairShouldCallScore( _info.m_nOperateChair , _info.m_nOperateTime , opTag )
	
	local meChair = self:getMeChairID()
	local tbl = _info["m_vec"..meChair.."ChairCards"]
	self:setMyHandCard( tbl )
	self:updateMyCardUI()
	self.gameRoomBgLayer:showBackCard()
end

function GameMainLayer:restoreStatusPlay( _info )
	self:restoreTuoGuan( _info.m_vecTrusteeShip )
	self.bottom_card = CONVERT_AND_SORT( _info.m_vecUnderPoker )
	self.gameRoomBgLayer:restoreHappyBottomCard(self.bottom_card, _info.m_nUnderMul, self.m_GameLogic)
	self.gameRoomBgLayer:updateGreenPoint( _info.m_vecOutCards , CardKit:C2S_CONVERT(self.bottom_card) )
	
	local meChair = self:getMeChairID()
	local tbl = _info["m_vec"..meChair.."ChairCards"]
	self:setDouble( _info.m_nTotalMultiple )
	self:setMyHandCard( tbl )
	self:updateMyCardUI()
	self:setTheLord( _info.m_nLordChairIdx )
	self.m_pRecordLayer:addCard(self.myHandCard);
	self.m_pRecordLayer:showView();
	if _info.m_nLastOutChair > 0 then
		self:chairOutCard( _info.m_nLastOutChair , _info.m_vecLastOutPokers , _info.m_vecValue[ _info.m_nLastOutChair ] )
	end
	
	for i,v in ipairs( _info.m_vecValue ) do
		self.game_chair_tbl[i]:initCardCount(v)
		local jiaBeiStatus = _info.m_vecDouStatus[i]
		if jiaBeiStatus == 2 then
			self.game_chair_tbl[i]:showJiaBeiFlag()
		end
	end

	local opChair = _info.m_nOperateChair
	local thinkTime = self.m_thinkTime
	self:chairShouldOutCard( opChair , thinkTime , 0 )
	self:setOthersOpenPoker( _info , true )
end

function GameMainLayer:restoreTuoGuan( tbl )
	for chair,v in pairs( tbl ) do
		self.game_chair_tbl[ chair ]:setTuoGuan( v )
	end
end

function GameMainLayer:setOthersOpenPoker( _info , showFarmer )
	if _info.m_vecLandOpenCards and #_info.m_vecLandOpenCards > 0 then
		local lordPos = self:getLordChair()
		if lordPos ~= meChair then
			self.game_chair_tbl[ lordPos ]:setCurHandCard( _info.m_vecLandOpenCards )
			self.game_chair_tbl[ lordPos ]:showHappySmallPoker()
			self.game_chair_tbl[ lordPos ]:showMingPaiFlag()
		end
	end
	dump(_info.m_vecChairCards)
	if _info.m_vecFarmerOpenCards and #_info.m_vecFarmerOpenCards > 0 then
		local otherFarmer = self:getOtherFarmerChair()
		if self.game_chair_tbl[ otherFarmer ] then
			self.game_chair_tbl[ otherFarmer ]:setCurHandCard( _info.m_vecFarmerOpenCards )
			if showFarmer then
				self:showOtherFarmerPoker()
			end
		end
	end
end

function GameMainLayer:LandLord_Begin_Nty( _info )
	self:setMyHandCard( _info.m_vecGetCards )
    self.cardScene:DispatchCard( self.myHandCard )
	self.game_begin_pos = _info.m_nBeginPosition
	self:setPlayerCardCount()
	if self.game_begin_pos ~= self.meChairID then
		self.call_score_think_chair = self.game_begin_pos
		self.game_chair_tbl[ self.game_begin_pos ]:onJiaoFenThink()
	end
	if self.m_landAccountLayer then
		self.m_landAccountLayer:setVisible(false);
	end
end

function GameMainLayer:removeHandCard( tbl )
	self.myHandCard = IPARE_TABLE( UPDATE_TABLE( self.myHandCard ,CardKit:S2C_CONVERT( tbl ) ) )
	self:updateMyCardUI()
end

function GameMainLayer:setMyHandCard( tbl )
	self.myHandCard = CardKit:S2C_CONVERT( tbl )
end

function GameMainLayer:onDrawCardDone()
	self.gameRoomBgLayer:showBackCard()
	if self.game_begin_pos ~= self.meChairID then return end
	self.call_score_think_chair = self.meChairID
	self.game_chair_tbl[ self.meChairID ]:onJiaoFenThink(13)
	self:showCallScorePanel( self:getMaxCall() )
end

--绘牌完毕才进入叫分流程
--如果接收到叫分消息则强制终止绘牌流程
function GameMainLayer:stopDrawCard()
	self.cardScene:statusTimerEnd()
	self:UpdataPlayerCardNum(0,17)
	self:updateMyCardUI()
end

function GameMainLayer:LandLord_BeLord_Nty( _info )
	self:stopDrawCard()
	local pos     = _info.m_nCallPosition
	local nextPos = _info.m_nNextPosition
	local opSec   = 15
	if IS_HAPPY_LAND( self.game_atom ) then
		opSec = _info.m_nNextTime
	end
	
	self:hideCallScorePanel()
	self:hideTakeLord()
	self:chairCallScore( pos , _info.m_nCent , _info.m_nCallOpt )
	if nextPos > 0 then
		self:chairShouldCallScore( nextPos , opSec , _info.m_nCallOpt )
	end
	
	
	if nextPos < 1 and _info.m_nCallOpt == 3 then
		LandSoundManager:getInstance():playEffect("BOY_CALLSCORE_WQ")
	else
		self:playScoreSound( _info.m_nCent , _info.m_nCallOpt)
	end
end

function GameMainLayer:LandLord_DoubleOpt_Nty( _info )
	local opTbl = _info.m_nPosArr
	for k,v in pairs( opTbl ) do
		self.game_chair_tbl[v]:onJiaBeiThink()
		if v == self:getMeChairID() then
			self:showJiaBeiPanel()
		end
	end
end

function GameMainLayer:LandLord_Double_Nty( _info )
	local pos = _info.m_nPos
	self:setDouble( _info.m_nTotalDou )
	self.game_chair_tbl[ pos ]:onJiaBei( _info.m_nDou )

	if _info.m_nDou == 1 then
		self.m_landSoundManager:playEffect("BOY_CALLSCORE_DOUBLE")
	else
		self.m_landSoundManager:playEffect("BOY_CALLSCORE_NOTDOUBLE")
	end
	
	if pos == self.meChairID then
		self:hideJiaBeiPanel()
	end

	if _info.m_nOptNum == 3 then
		local lordPos = self:getLordChair()
		self.game_chair_tbl[ lordPos ]:showClock(30)
		if lordPos == self:getMeChairID() then
			self:showOutCardPanel()
		end
		self:showOtherFarmerPoker()
	end
end


function GameMainLayer:chairShouldCallScore( pos , opSec , _opTag )
	local opTag = _opTag or 0
	self.call_score_think_chair = pos 
	self.game_chair_tbl[pos]:onJiaoFenThink( opSec )
	if pos == self.meChairID then
		if IS_HAPPY_LAND( self.game_atom ) then
			if opTag < 1 then
				self:showHappyJiaoDiZhu()
			else
				self:showHappyQiangDiZhu()
			end
		else
			self:showCallScorePanel( self:getMaxCall() )
		end
	end
end

function GameMainLayer:comeBackCallScore( timeGap )
	local pos = self:getCallScoreThinkChair()
	LogINFO("回到前台,继续叫分",timeGap , pos)
	if not pos or type( self.game_chair_tbl ) ~= "table" or not self.game_chair_tbl[pos] then return end
	self.game_chair_tbl[pos]:onComeBackJiaoFenThink( timeGap )
end

function GameMainLayer:getCallScoreThinkChair()
	return self.call_score_think_chair or 0
end

function GameMainLayer:chairCallScore( pos , score , opTag )
	self:updateMaxCall( score )
	self.game_chair_tbl[pos]:onJiaoFen( score , opTag )
end

function GameMainLayer:playScoreSound( _landScore , _opTag)
	print("GameMainLayer:playScoreSound( _landScore , _opTag)", _landScore, _opTag)
	if IS_HAPPY_LAND( self.game_atom ) then
		local musicType = {
			[0] = "_CALLSCORE_BUJIAO",--"不叫",
			[1] = "_CALLSCORE_JIAO",--"叫地主",
			[2] = "_CALLSCORE_BUQIANG",--"不抢",
			[3] = "_CALLSCORE_QIANG",--"抢地主",
		}
		if 1 or self:GetGender( _landUser ) == LandGlobalDefine.GENDER_BOY then
	        self.m_landSoundManager:playEffect("BOY"..musicType[_opTag])
	    else
	        self.m_landSoundManager:playEffect("GIRL"..musicType[_opTag])
	    end
	else
		if _landScore <= 3 and _landScore > 0 then
	        local eType = _landScore + 50
	        if 1 or self:GetGender( _landUser ) == LandGlobalDefine.GENDER_BOY then
	            self.m_landSoundManager:playEffect(eType)
	        else
	            self.m_landSoundManager:playEffect(100+eType)
	        end
	    else
	        if 1 or self:GetGender( _landUser ) == LandGlobalDefine.GENDER_BOY then
	            self.m_landSoundManager:playEffect("BOY_SCORE_BUJIAO")
	        else
	            self.m_landSoundManager:playEffect("GIRL_SCORE_BUJIAO")
	        end
	    end
	end
end

function GameMainLayer:playBuYaoSound()
	if GET_CUR_FRAME() % 2 == 0 then
		self.m_landSoundManager:playEffect("BOY_BUYIAO")
	else
		self.m_landSoundManager:playEffect("BOY_BUYIAO_4")
	end
end

function GameMainLayer:PlayGameOutCard( cbCardData, cbCardCount )
	if cbCardCount < 1 then
		self:playBuYaoSound()
		return
	end
	
	self.m_landSoundManager:playEffect("ET_CHUPAI")
    local wType = self.m_GameLogic:GetCardType(cbCardData)
    local effectType = 0
    LogINFO("ClassicMainScene:PlayGameOutCard wType ="..wType)

    if wType == LandGlobalDefine.CT_MISSILE_CARD then
    	self.m_landSoundManager:playEffect("BOY_MISSILE_CARD")
    	self.m_landSoundManager:playEffect("ET_ROCKET")
    elseif wType == LandGlobalDefine.CT_BOMB_CARD then
    	self.m_landSoundManager:playEffect("BOY_BOMB_CARD")
    	self.m_landSoundManager:playEffect("ET_BOMB")
    elseif wType == LandGlobalDefine.CT_FOUR_LINE_TAKE_ONE then -- 4带两单
    	self.m_landSoundManager:playEffect("BOY_FOUR_LINE_TAKE_ONE")
    elseif wType == LandGlobalDefine.CT_FOUR_LINE_TAKE_TWO then -- 4带两双
    	self.m_landSoundManager:playEffect("BOY_FOUR_LINE_TAKE_TWO")
    elseif wType == LandGlobalDefine.CT_FOUR_TAKE_THREE then -- 4带3
    	self.m_landSoundManager:playEffect("BOY_FOUR_TAKE_THREE")
    elseif wType == LandGlobalDefine.CT_FEIJI_TAKE_ONE or  -- 飞机带翅膀
    	wType == LandGlobalDefine.CT_FEIJI_TAKE_TWO  then
    	self.m_landSoundManager:playEffect("BOY_FEIJI_TAKE_ONE_OR_TWO")
    	self.m_landSoundManager:playEffect("ET_FEIJI_TAKE_ONE_OR_TWO")
    elseif  wType == LandGlobalDefine.CT_THREE_LINE then  -- 飞机  333444
    	self.m_landSoundManager:playEffect("BOY_FEIJI")
    	self.m_landSoundManager:playEffect("ET_FEIJI")
    elseif wType == LandGlobalDefine.CT_THREE_TAKE_ONE then -- 3带1
    	self.m_landSoundManager:playEffect("BOY_THREE_TAKE_ONE")
    elseif wType == LandGlobalDefine.CT_THREE_TAKE_TWO then -- 3带1对
    	self.m_landSoundManager:playEffect("BOY_THREE_TAKE_TWO")
    elseif  wType == LandGlobalDefine.CT_DOUBLE_LINE then  --   334455
    	self.m_landSoundManager:playEffect("BOY_DOUBLE_LINE")
   	elseif  wType == LandGlobalDefine.CT_SINGLE_LINE then  --   34567
    	self.m_landSoundManager:playEffect("BOY_SINGLE_LINE")
   	elseif  wType == LandGlobalDefine.CT_THREE then  --   333
    	self.m_landSoundManager:playEffect("BOY_THREE")
    elseif wType == LandGlobalDefine.CT_DOUBLE then  --对牌
        local cbTempValue = GetCardValue(cbCardData[1])
        effectType = cbTempValue + 31
        self.m_landSoundManager:playEffect(effectType)
    elseif wType == LandGlobalDefine.CT_SINGLE then  -- 单牌
        local cbTempValue = GetCardValue(cbCardData[1])
        effectType = cbTempValue + 15
        self.m_landSoundManager:playEffect(effectType)
   	end
end

function GameMainLayer:updateMaxCall( num )
	if not self.max_call then self.max_call = num end
	if num > self.max_call then self.max_call = num end
	self:setDouble( self.max_call )
end

function GameMainLayer:setDouble( num )
	self.double_num = num
	self.gameRoomBgLayer:updateDoubleUI( self.double_num )
	local text_3 = self.panle:getChildByName("text_3");
	if self.double_num <= 0 then
		text_3:setString(string.format( "底分:%d", g_GameController.minScore ));
	else
		text_3:setString(string.format( "底分:%d", self.double_num ));
	end
	
end

function GameMainLayer:LandLord_BeLordResult_Nty( _info )
	LogINFO("接收到叫分总结果")
	local meChair       = self:getMeChairID()
	local pos           = _info.m_nLordPosition
	local nextISJiaBei  = _info.m_nIsDouOpt
	self.bottom_card    = CONVERT_AND_SORT( _info.m_vecCards )
	local num           = _info.m_nLandCent
	local opSec         = _info.m_nNextTime
	
	self:setDouble( num )
	if pos == meChair then
		self.cardScene:SetBackCardData( self.bottom_card )
		self:addCardToMyHand( self.bottom_card )
	end
	
	if nextISJiaBei == 0 then
		self.game_chair_tbl[pos]:showClock(30)
		if pos == meChair then
			self:showOutCardPanel()
		end
	elseif nextISJiaBei == 1 then
		if IS_HAPPY_LAND( self.game_atom ) then
			self.game_chair_tbl[pos]:showClock(opSec)
			if pos == meChair then
				self:showHappyMingPai()
			end
		end
	end
	self:onLordResult( pos , self.bottom_card , _info.m_nLastCardsMul )
end

function GameMainLayer:onLordResult( lordPos , tbl , bottomMul )
	LogINFO("地主诞生")
	self.m_landSoundManager:playEffect("ET_GAMESTART")
	self:setTheLord( lordPos )
	self:setPlayerCardCount()
	self.gameRoomBgLayer:TurnOverCard( tbl , bottomMul , self.m_GameLogic)
	self:delayHideAllSpeak()
	self.call_score_think_chair = 0
end

function GameMainLayer:delayHideAllSpeak()
	local function exeFun()
		if not self or not self.hideAllSpeak then return end
		self:hideAllSpeak()
	end
	scheduler.performWithDelayGlobal( exeFun , 2 )
end

function GameMainLayer:hideAllSpeak()
	if not self.game_chair_tbl then return end
	for k,v in pairs( self.game_chair_tbl ) do
		v:hideSpeak()
	end
end

function GameMainLayer:hideAllJiaBeiFlag()
	if not self.game_chair_tbl then return end
	for k,v in pairs( self.game_chair_tbl ) do
		v:hideJiaBeiFlag()
	end
end

function GameMainLayer:setTheLord( pos )
	self.lord_chair = pos
	self:hideCallScorePanel()

	--去掉换头像
	-- self.gameRoomBgLayer:hideMyHead()

	-- for k,v in pairs( self.game_chair_tbl ) do
	-- 	v:setLord( pos )
	-- end
end

function GameMainLayer:fakeOutCard( tbl )
	local serverTBL = CardKit:C2S_CONVERT(tbl)  
	self:updateLastOutCard( self.meChairID , CardKit:C2S_CONVERT(CARD_SORT(tbl)))
	self:playOutCardAni( self.meChairID , serverTBL )
	self:PlayGameOutCard( tbl , #tbl )
	self.game_chair_tbl[ self.meChairID ]:showChuPaiUI( serverTBL )
	
	local fakeTBL = IPARE_TABLE( UPDATE_TABLE( self.myHandCard , tbl ) )
	table.sort( fakeTBL ,SortCardTable )
	self:clearMyCardUI()
	self.cardScene:SetCardData( fakeTBL , #fakeTBL )
end



function GameMainLayer:LandLord_Out_Nty( _info )
    if _info.m_result~=0 and _info.m_outAccountId == Player:getAccountID() then
        self:setOutCardButtonsVisible(true)
        self.lord_txt_bfhcpgz:setVisible(true)
        self.lord_txt_bfhcpgz:stopAllActions()
        self.lord_txt_bfhcpgz:runAction(cc.Sequence:create(D(1),cc.Hide:create()))
        self.game_chair_tbl[_info.m_nPosition]:clearPokerOut()
        return
     end
	local delay      = 0
	local pos        = _info.m_nPosition
	local nextPos    = _info.m_nNextPosition
	local nextPosSec = _info.m_nNextTime
	local tbl        = _info.m_vecOutCards
	self:setOutCardButtonsVisible(false)
	self:hideJiaBeiPanel()
	
	if pos == self:getLordChair() then
		self.gameRoomBgLayer:updateGreenPoint( _info.m_vecOutCards , CardKit:C2S_CONVERT(self.bottom_card) )
	end
	
	if pos == nextPos then 
		delay = 2
		self:clearOtherChairPokerOut( pos )
		self:hideAllSpeak()
	end

	self:setDouble( _info.m_nTotalDou )
	self:chairOutCard( pos , tbl , _info.m_nCardsNum )

	if pos == self.meChairID then
		self:removeHandCard( tbl )
		if _info.m_nPunTime > 0 then
			self:onSlowOutCard( _info.m_nPunTime )
		end
	end
	
	if pos == self.meChairID and nextPos == self.meChairID then
		self:clearEnemyCard()
	end
	
	if nextPos == 0 then
		self:setGameEndOutChair( pos )
	else
		self:chairShouldOutCard( nextPos , nextPosSec , delay )
	end
end

function GameMainLayer:playGameEndSound( lastOutCardPos )
	LogINFO("播放比赛结束声音")
    local ret = self:winOrLose( lastOutCardPos )
    if ret == "win" then
        self.m_landSoundManager:playEffect("ET_GAMEWIN")
    else
        self.m_landSoundManager:playEffect("ET_GAMEFAIL")
    end
end

function GameMainLayer:winOrLose( lastOutCardPos )
	local meChair = self:getMeChairID()
	if meChair == lastOutCardPos then return "win" end
	if meChair ~= self:getLordChair() and lastOutCardPos ~= self:getLordChair() then return "win" end
	return "lose"
end

function GameMainLayer:clearOtherChairPokerOut( outCardChair )
	for k,v in pairs( self.game_chair_tbl ) do
		if k ~= outCardChair then
			v:clearPokerOut()
		end
	end
end

function GameMainLayer:clearAllPokerOut()
	for k,v in pairs( self.game_chair_tbl ) do
		v:clearPokerOut()
	end
end

--某位置出了牌
function GameMainLayer:chairOutCard( pos , tbl , leftCardNum )
	local ret = self:alreadyFakeOutCard( pos , tbl )
	print("GameMainLayer:chairOutCard", pos , tbl , leftCardNum, ret)
	
	if pos ~= self.meChairID then
		self:updateEnemyOutCard( pos , tbl )
	end
	if pos == self.meChairID and #tbl < 1 then
		self.game_chair_tbl[pos]:onPass()
		local status = self.game_chair_tbl[ self.meChairID ]:getTuoGuanStatus()
		if status == 1 then
			self:playBuYaoSound()
		end
	end
	
	if ret then return end
	self:updateLastOutCard( pos , CardKit:C2S_CONVERT(CARD_SORT(CardKit:S2C_CONVERT(tbl ))))
	self:playOutCardAni( pos , tbl )
	self:PlayGameOutCard( CardKit:S2C_CONVERT(tbl) , #tbl )
	self.game_chair_tbl[pos]:onChuPai( tbl , leftCardNum )

end

function GameMainLayer:alreadyFakeOutCard( pos , tbl )
	if pos == self.meChairID and #tbl < 1 then return true end
	if pos ~= self.meChairID or #tbl < 1 then return end
	if not self.last_out_card or not self.last_out_card[ self.meChairID ] then return end
	local tA = CardKit:S2C_CONVERT(self.last_out_card[ self.meChairID ])
	local tB = CardKit:S2C_CONVERT(tbl)
	table.sort( tA , SortCardTable )
	table.sort( tB , SortCardTable )
	if unpack(tA) == unpack(tB) then return true end
end

--轮到这个位置要出牌了
function GameMainLayer:chairShouldOutCard(  pos , opSec , delay )
	print("chairShouldOutCard",  pos , opSec , delay, self.m_thinkTime )
	-- self.m_landMainScene:setGameState( LandGlobalDefine.GAME_OUTCARD )
    --	self:clearKingBoomTimer()
    if pos then
    	opSec = opSec or 15
	    self.game_chair_tbl[ pos ]:onXuanPai( opSec )
    end
	-- local function exeFun()
	-- 	if not self.game_chair_tbl or not self.game_chair_tbl[ pos ] then return end
	-- 	if pos == self:getMeChairID() then
	-- 		local ret = self:dealNotAfford()
	-- 		if ret then
	-- 			self.game_chair_tbl[ pos ]:onXuanPai( opSec )
	-- 		end
	-- 	else
	-- 		self.game_chair_tbl[ pos ]:onXuanPai( opSec )
	-- 	end
	-- end
	-- self.king_boom_timer = scheduler.performWithDelayGlobal( exeFun , delay )
end

function GameMainLayer:clearKingBoomTimer()
	if self.king_boom_timer then
        scheduler.unscheduleGlobal( self.king_boom_timer )
        self.king_boom_timer = nil 
    end
end

function GameMainLayer:LandLord_AutoControl_Nty( _info )
	ToolKit:removeLoadingDialog()
	local pos = _info.m_nPosition
	local val = _info.m_bOpenOrClose
	self.game_chair_tbl[pos]:updateTuoGuan( val )
	
	if pos == self:getMeChairID() then
		self:updateTuoGuanUI()
		if val == 1 then 
			self.outCardBtnsPanel:setOpacity(0)
		else
			self.outCardBtnsPanel:setOpacity(255)
		end
	end

	if val == 1 then
		self.game_chair_tbl[pos]:hideClock()
	end

	if pos == self:getMeChairID() then
		self:clearHappyLayer()
	end
end

function GameMainLayer:LandLord_CarryOn_Nty( _info )
	local pos = _info.m_nPosition
	self.game_chair_tbl[pos]:onReadyCarryOn()
end

function GameMainLayer:LandLord_Result_Nty( _info ) 
	self.m_pResultInfo = _info;
	self:clearKingBoomTimer()
	self.m_landMainScene:hideExitGameLayer()
	local scoreRet = _info.m_vecScore
	self:hideTuoGuanPanel()
	self.cardScene:ClearHandCard()

	for i=1,3 do
        -- if not g_GameController:isMatchGame() then 
		--     local tbl = _info["m_vec"..i.."ChairCards"]
		--     self.game_chair_tbl[i]:setLastHandCard( tbl )
		--     self.game_chair_tbl[i]:showLastPoker()
		--     if i == self.game_end_out_chair then
		-- 	    self.game_chair_tbl[i]:showLastStepUI()
		--     end 
		-- end
		local tbl = _info["m_vec"..i.."ChairCards"]
		self.game_chair_tbl[i]:setLastHandCard( tbl )
		self.game_chair_tbl[i]:showLastPoker()
		if i == self.game_end_out_chair then
			self.game_chair_tbl[i]:showLastStepUI()
		end 
        self.game_chair_tbl[i]:setPlayerScoreRet( scoreRet[i] )
	end
	self:playWinLoseAnimation( _info.m_nEndPos )
	self:playGameEndSound( _info.m_nEndPos )

	self.gameRoomBgLayer:updateDoubleUI( _info.m_nTotalMultiple )

	if _info.m_bSpring == 1 then
		self:showChunTian()
	end
	if IS_HAPPY_LAND( self.game_atom ) and IS_FREE_ROOM( self.game_atom ) then
		self:showGameResultLayer(_info)
	end

	_info[string.format( "m_vec%dChairCards", _info.m_nEndPos)] = {};
	if _info.m_bSpring == 1 then
		g_GameController.gameScene:showMatchResultView(3, self.m_pResultInfo, self.game_chair_tbl);
	else
		g_GameController.gameScene:showMatchResultView(1.5, self.m_pResultInfo, self.game_chair_tbl);
	end
end

function GameMainLayer:showGameResultLayer(_info)
	local retFlag = self:winOrLose( _info.m_nEndPos )
	LogINFO("显示欢乐跑得快分享界面,输赢结果 : ",retFlag)

	local gameEndPram = {}

    gameEndPram.Wbeishu    = _info.m_nTotalMultiple --总倍数
    gameEndPram.bChuntian  = _info.m_bSpring -- 是否春天
    gameEndPram.lGameScore = _info.m_vecScore -- 三人分数

    gameEndPram.bomCount   = _info.m_nTotalBombs -- 炸弹个数

    gameEndPram.meChair   = self:getMeChairID() --我的ID
    gameEndPram.lordChair = _info.m_nLandPos -- 地主ID

    gameEndPram.minScore = self.m_landMainScene.minScore --底分

    gameEndPram.jiaNum   = _info.m_nDoubleMul -- 欢乐中是加倍的倍数 小于1为无 大于1 则为几倍
    gameEndPram.mingNum   = _info.m_nOpenMul -- 欢乐中是明牌的倍数 0为无
    gameEndPram.qiangNum  = _info.m_nCallMul -- 欢乐中是抢地主的倍数 0为无
    gameEndPram.teNum     = _info.m_nLastCardsMul -- 欢乐中是特殊底牌的倍数 0为无

    -- 惩罚分2种 一种是扣金币惩罚 一种是不扣金币的惩罚

    local isGoldPunish = self:getGoldPunish( retFlag , _info.m_vecScore )
    gameEndPram.isChen = isGoldPunish

	self:runAction(cc.Sequence:create(cc.DelayTime:create(6), cc.CallFunc:create(function ()
        if self.m_landAccountLayer == nil then
		    self.m_landAccountLayer = LandAccounts.new( self.m_landMainScene , retFlag, self.game_atom)
	        self.m_landMainScene:addChild(self.m_landAccountLayer,  12)
        else
             self.m_landAccountLayer:setVisible(true)
        end
	    self.m_landAccountLayer:updateHappyLandGameResult(gameEndPram)
	    self.m_landAccountLayer :setContinueButtonEnable(true)
	end)))
end

function GameMainLayer:getGoldPunish( ret , scoreTBL )
	local meChair = self:getMeChairID()
	if ret == "win" then 
		if scoreTBL[meChair] == 0 then 
			LogINFO("我赢了但是金币为0,判断为受到了金币惩罚")
			return true
		end
	else
		local otherFarmer = self:getOtherFarmerChair()
		if otherFarmer and scoreTBL[otherFarmer] == 0 then
			LogINFO("我输了,是农民,另外一个农民扣金币0,则判断我受到了金币惩罚,被扣了更多的钱")
			return true
		end 
	end
	return false
end

function GameMainLayer:showChunTian()
	local function f()
		if not self or not self.landAnimationManager then return end
		LogINFO("春天动画阶段")
		self.landAnimationManager:PlayAnimation(LandArmatureResource.ANI_SPRING)
		self.m_landSoundManager:playEffect("BOY_SPRING")
	end
	scheduler.performWithDelayGlobal(f,2)
end

function GameMainLayer:clearEnemyCard()
	self.enemy_out_card = {}
end

function GameMainLayer:updateEnemyOutCard( pos , tbl )
	if not self.enemy_out_card then self.enemy_out_card = {} end
	self.enemy_out_card[pos] = tbl
end

function GameMainLayer:getEnemyOutCard()
	if not self.enemy_out_card then return end
	local shangJiaChair   = self:getShangJiaChair()
	local shangJiaOutCard = self.enemy_out_card[ shangJiaChair ] or {}
	if #shangJiaOutCard > 0 then return shangJiaOutCard end

	local xiaJiaChair = self:getXiaJiaChair()
	return self.enemy_out_card[xiaJiaChair]
end

function GameMainLayer:updateLastOutCard( pos , tbl )
	if not self.last_out_card then self.last_out_card = {} end
	if self.last_out_card[pos] then
		self:updateShangShouPai( pos , self.last_out_card[pos] )
	end
	self.last_out_card[pos] = tbl
end

function GameMainLayer:updateShangShouPai( pos , tbl )
	if not self.last_last_out_card then self.last_last_out_card = {} end
	self.last_last_out_card[pos] = tbl
end

function GameMainLayer:getShangShouPai( UI_ID )
	if not self.last_last_out_card then return end
	local chair = nil
	
	if UI_ID == 0 then chair = self:getXiaJiaChair() end
	if UI_ID == 1 then chair = self:getMeChairID() end
	if UI_ID == 2 then chair = self:getShangJiaChair() end

	if self.last_last_out_card[chair] then return self.last_last_out_card[chair] end
end

function GameMainLayer:getLastOutCard( chair )
	if not self.last_out_card then return end
	if self.last_out_card[chair] then return self.last_out_card[chair] end
end

function GameMainLayer:getShangJiaChair()
	local meChair = self:getMeChairID()
	if meChair == 1 then return 3 end
	local ret = meChair - 1
	return ret
end

function GameMainLayer:getXiaJiaChair( chair )
	local curChair = chair or self:getMeChairID()
	if curChair == 3 then return 1 end
	local ret = curChair+1
	return ret
end

function GameMainLayer:getOtherFarmerChair()
	local lordPos = self:getLordChair()
	local meChair = self:getMeChairID()
	if lordPos == meChair then return end
	for i=1,3 do
		if i ~= lordPos and i ~= meChair then
			return i
		end
	end
end

function GameMainLayer:getMaxCall()
	return self.max_call or 0
end

function GameMainLayer:setGameAtom( id )
	self.game_atom = id
end

--最后一个出牌椅子
function GameMainLayer:setGameEndOutChair( pos )
	self.game_end_out_chair = pos
end

function GameMainLayer:setMeChairID( id )
	self.meChairID = id
end

function GameMainLayer:getMeChairID()
	return self.meChairID
end

function GameMainLayer:getLordChair()
	return self.lord_chair or 0
end

function GameMainLayer:onPassCard()
	self.game_chair_tbl[ self.meChairID ]:onPass()
	self:onClickOutCard()
	self:reqOutCard({})
	self:playBuYaoSound()
end

function GameMainLayer:addCardToMyHand( tbl )
	--防止重复插入
	local tempTBL = EXCHANGE_KEY_VAL( self.myHandCard )
	for k,v in pairs( tbl ) do
		if not tempTBL[v] then
			table.insert( self.myHandCard , v )
		end
	end
	self:updateMyCardUI()
end

function GameMainLayer:reportException( enemyCard )
	local cardType = self.m_GameLogic:GetCardType( self.myHandCard )
	if cardType == LandGlobalDefine.CT_BOMB_CARD or cardType == LandGlobalDefine.CT_MISSILE_CARD then
		local enemyCardStr  = require("cjson").encode( enemyCard )
		local myHandCardStr = require("cjson").encode( CardKit:C2S_CONVERT( self.myHandCard ) )
		local content = self.game_atom.."#"..enemyCardStr.."#"..myHandCardStr
		--qka.BuglyUtil:reportException("landlordsException",content)
	end
end
---判断是否要得起
function GameMainLayer:dealNotAfford()
	local status = self.game_chair_tbl[ self.meChairID ]:getTuoGuanStatus()
	if status == 1 then return end
	local enemyCard      = self:getEnemyOutCard() or {}
    local resultTable    = self:getTipsOutCardData()
    local resultTableNum = table.nums(resultTable)



    if #enemyCard > 0 and resultTableNum < 1 then
    	self:reportException( enemyCard )
		self:setOutCardButtonsVisible( false )
        self.cardScene:ResetShootCard()
        if #self.myHandCard == 1 then -- 要不起,刚好我的手牌又只有一张的情况
    		self:onPassCard()
    		return
    	end
    	self:showNotAfford()
        return true
    end

    local cardType = self.m_GameLogic:GetCardType( self.myHandCard )
    --如果打得过并且刚好剩下王炸
    if cardType == LandGlobalDefine.CT_MISSILE_CARD then
    	self:autoOutAllMyCard()
    	return false
    end

    --如果打得过并且刚好剩下4个牌炸弹
    if #self.myHandCard == 4 and self.m_GameLogic:isContainBomb( self.myHandCard ) then
    	self:autoOutAllMyCard()
    	return false
    end

    --如果提示牌刚好是我的手牌数量并且不包含炸弹
    if resultTableNum == #self.myHandCard and not self.m_GameLogic:isContainBomb( self.myHandCard ) then
    	self:autoOutAllMyCard()
    	return false
    end

    if #enemyCard == 0 then
    	local boom = false
		if self.m_GameLogic:isContainBomb( self.myHandCard ) and #self.myHandCard ~= 4 then boom = true end
		if cardType ~=  LandGlobalDefine.CT_ERROR and not boom then
		 	self:autoOutAllMyCard()
		 	return false
		end    	
    end

	self:showOutCardPanel()

	if #self.cardScene:GetShootCard() > 0 then
		return true
	end

	local autoTip = cc.UserDefault:getInstance():getBoolForKey("AutoTip", false)
	if autoTip == true then
		self:clickPrompt()
	end
	return true
end

function GameMainLayer:autoOutAllMyCard()
    local function exeFun()
		if not self.myHandCard then return end
		self:reqOutCard( CardKit:C2S_CONVERT( self.myHandCard ) )
	end
	scheduler.performWithDelayGlobal( exeFun , 0.3 )
end

--出牌判断
function GameMainLayer:verdictOutCard()
	-- if true then return true end

   local curShootCard = self.cardScene:GetShootCard() or {}
   local count  = table.nums(curShootCard)
   if count < 1 then return end
   
   --牌型扑克
   table.sort(curShootCard,SortCardTable)
   --分析类型
   print("GameMainLayer:verdictOutCard GetCardType")
   local cardType = self.m_GameLogic:GetCardType( curShootCard)
   if cardType ==  LandGlobalDefine.CT_ERROR then return end
   
   print("GameMainLayer:verdictOutCard enemyCard")
   local enemyCard = CardKit:S2C_CONVERT( self:getEnemyOutCard() or {} )
   if #enemyCard < 1 then return true end

   print("GameMainLayer:verdictOutCard CompareCard")
   local ret = self.m_GameLogic:CompareCard(enemyCard, curShootCard)
   return ret
end

--点击单张牌回调
function GameMainLayer:onLeftHitCard( val )
	--print(">>>>>>>>>>", val)
	self:updateOutCardBtn()
	if val < 0 then 
		return 
	end
	--此处掉用C++接口数据
    --------------------------------------------------------------------------
    local curShootCard        = self.cardScene:GetShootCard() or {}
    local selfCardDataServer  = CardKit:C2S_CONVERT( self.myHandCard )
    local shootCardDataServer = CardKit:C2S_CONVERT( curShootCard )
    local lastCardDtaServer   = self:getEnemyOutCard() or {}
    local hitingCardServer    = C2S_CARD_CONVERT( val )

    -- for i=1,#shootCardDataServer do
    --     if shootCardDataServer[i] == hitingCardServer then
    --         table.remove(shootCardDataServer,i)
    --     end
    -- end


    --  点击单张牌
    -- vecCardData1 : 自己手牌
    -- vecShoot     : 已经弹起的牌
    -- vecDiscards  : 上家出的牌(没人出牌传空)
    -- u8CardClick  : 点中的牌(一定是未弹起的牌,如果是已经弹起的牌,就直接缩回去)
    -- return : 如果是空就是没有
    local resultTableServer = shootCardDataServer -- qka.LandCGameLogic:GetInstance():SelectTraitCardsOnceLua( selfCardDataServer, shootCardDataServer, lastCardDtaServer, hitingCardServer )     
    local resultTableClient = CardKit:S2C_CONVERT( resultTableServer )   
    local resultTableNum    = table.nums(resultTableClient)
    if resultTableNum > 0 then
        self.cardScene:SetShootCard(resultTableClient, resultTableNum)
    end
    self:updateOutCardBtn()
end

----------游戏服消息处理结束----------

----------对外接口开始----------
--更新玩家手中牌的张数
function GameMainLayer:UpdataPlayerCardNum( id, _cardCount )
	local cardCount = math.min(17,_cardCount)
	for i=1,3 do
		self.game_chair_tbl[i]:updateUICardCount( cardCount )
	end
end

function GameMainLayer:onClickEmptySpace()
	if self.tuoGuanPanel:HostingBtnIsVisible() == false then
		return
	end
	local meChair = self:getMeChairID()
	local val = self.game_chair_tbl[ meChair ]:getTuoGuanStatus()
	if val == 1 then
		self:reqCancelTuoGuan()
	end
end

function GameMainLayer:onMoveSelectCard( tbl )
	-- if true then return end
	local selectCardDataServer = CardKit:C2S_CONVERT( tbl )
	local shootCardDataServer = self:getShootCardDataServer() or {}

	local selectCardBefore = {}
	for k,v in pairs(selectCardDataServer) do
		table.insert(selectCardBefore, v)
	end

	local selectCardBefore2 = self.cardScene:getLastShootCard()
	for k,v in pairs(selectCardDataServer) do
		table.insert(selectCardBefore2, v)
	end

	-- 判断和上次选中的是否能合一
	local xxCardType = self.m_GameLogic:GetCardType( CardKit:S2C_CONVERT(selectCardBefore2) ) 
	if xxCardType ~= LandGlobalDefine.CT_ERROR then
		selectCardBefore = selectCardBefore2
	else
		-- 如果不能合一，判断能否去掉部分牌; 目前只针对 单连 双连
		local xxCardType = self.m_GameLogic:GetCardTypeEX( CardKit:S2C_CONVERT(selectCardBefore2) )
		if xxCardType then 
			selectCardBefore = xxCardType
		end
	end

	-- local resultTableServer = qka.LandCGameLogic:GetInstance():SelectDragCardOnceLua(selectCardDataServer, shootCardDataServer)
	local resultTableServer = selectCardBefore

	local resultTableClient = CardKit:S2C_CONVERT( resultTableServer )
	local resultTableNum = table.nums(resultTableClient)

	if resultTableNum > 0 then
        self.cardScene:SetShootCard(resultTableClient, resultTableNum)
        self:updateOutCardBtn()
    else
        self.cardScene:ResetShootCard()
    end
end

function GameMainLayer:clearData( )
	self:clearKingBoomTimer()
end
----------对外接口结束----------
function GameMainLayer:onTouchCallback( sender )
    local name = sender:getName()
    LogINFO("name: ", name)
end

------------------------------------------------------------------------------------
----------------------------新消息处理发送-------------------------------
function GameMainLayer:reqStartTuoGuan()
	-- ConnectManager:send2GameServer( self.game_atom, "CS_C2G_LandLord_AutoControl_Nty",{ 1 } )
	-- ConnectManager:send2GameServer( self.game_atom, "CS_C2G_Run_AutoControl_Req",{ Player:getAccountID(), 1 } )
end
function GameMainLayer:reqCancelTuoGuan()
	ToolKit:addLoadingDialog(1, "取消托管中......")
	-- ConnectManager:send2GameServer( self.game_atom, "CS_C2G_LandLord_AutoControl_Nty",{ 0 } )
	ConnectManager:send2GameServer( self.game_atom, "CS_C2G_Run_AutoControl_Req",{ Player:getAccountID(), 0 } )
end
function GameMainLayer:reqOutCard( tbl )
	-- ConnectManager:send2GameServer( self.game_atom, "CS_C2G_LandLord_Out_Nty",{ tbl } )
	ConnectManager:send2GameServer( self.game_atom, "CS_C2G_Run_OutCard_Req",{ Player:getAccountID(), tbl } )
end
function GameMainLayer:reqJiaoFen( score )
	-- ConnectManager:send2GameServer( self.game_atom, "CS_C2G_LandLord_BeLord_Nty",{ score } )
end
function GameMainLayer:sendReady()
	ConnectManager:send2GameServer( self.game_atom, "CS_C2G_Run_Ready_Req",{ self.meChairID, Player:getAccountID() } )
end

-------------------------新消息处理接收----------------------------------
function GameMainLayer:Run_AutoControl_Nty( _info )
	ToolKit:removeLoadingDialog()
	local pos = _info.m_nPosition
	local val = _info.m_bOpenOrClose
	self.game_chair_tbl[pos]:updateTuoGuan( val )
	
	if pos == self:getMeChairID() then
		self:updateTuoGuanUI()
	end

	if val == 1 then
		self.game_chair_tbl[pos]:hideClock()
	end

	if pos == self:getMeChairID() then
		self:clearHappyLayer()
	end
end
function GameMainLayer:Run_In_Wait_Nty( _info )
	-- self.m_landMainScene:setGameState( _info.m_eRoundState )
	LogINFO("等待状态")
	self:delaySendReady(1.7)
	self:Run_restoreStatus__(_info)
end
function GameMainLayer:Run_In_PlayGame_Nty( _info )
	-- self:LandLord_LoginData_Nty(_info)
	LogINFO("出牌状态")
	self:Run_restoreStatus__( _info )
end
function GameMainLayer:Run_Begin_Nty( _info )
	for k,v in pairs( self.game_chair_tbl ) do
		v:clearPokerOut()
	end
	self:hideAllSpeak()
	self:clearEnemyCard()
	_info.m_recordId = _info.m_recordId or ""
	self.mTextRecord:setString("牌局ID:" .. _info.m_recordId)
	self.outCardBtnsPanel:setOpacity(255)

	-- self:LandLord_Begin_Nty(_info)
	self.m_state = 2
--	self:updateMyCardUI()
	if self.m_landAccountLayer then
		self.m_landAccountLayer:setVisible(false);
	end

	self:clearAllPokerOut()
	local function f()
		if not self then return end
		-- _info.m_cards = { 0x13, 0x03, 0x04, 0x14, 0x05, 0x06, 0x07, 0x09, 0x19, 
		-- 0x11, 0x21, 0x31, 0x01, 0x12, 0x22, 0x32,}
		-- _info.m_cards = { 0x13, 0x03, 0x04, 0x14, 0x05, 0x15, 0x29, 0x09, 0x19, 
		-- 0x11, 0x21, 0x31, 0x01, 0x12, 0x22, 0x32,}

		self:setMyHandCard( _info.m_cards )
    	self.cardScene:DispatchCard( self.myHandCard )
		self:setPlayerCardCount()
	end
	scheduler.performWithDelayGlobal( f , 1 ) 

	if g_GameController:isMatchGame() then self:reqCancelTuoGuan() end
end

function GameMainLayer:Run_Action_Nty( _info )
	self:Run_Operate_Nty(_info)
end
function GameMainLayer:Run_Pass_Nty( _info )
	self:Run_Pass_Nty(_info)
end
function GameMainLayer:Run_OutCard_Nty( _info )
	self:Run_OutCard__(_info)
end
function GameMainLayer:Run_OutCard_Ack( _info )
	if _info.m_result == 0 then
		self:Run_OutCard__(_info)
	else
		local tInfo = 
		{
			[-300] = "玩家账户不存在",
			[-1] = "出牌失败",
			[-1252] = "牌型错误",
			[-1253] = "出牌太小",
		}
		local sInfo = tInfo[_info.m_result]
		if sInfo then 
			TOAST(sInfo)
		end
		self:Run_Operate_Nty(_info)
	end
end
function GameMainLayer:Run_Bomb_Nty( _info )
	-- 处理得分显示
	-- self:setDouble( _info.m_nTotalDou )
end
function GameMainLayer:Run_Warning_Nty( _info )
	-- 剩余一张警告
end
function GameMainLayer:Run_GameEnd_Nty( _info )
	self:Run_GameResult__(_info)
	self.m_state = 1
end
function GameMainLayer:Run_restoreStatus__( _info )
	-- 等待状态
	self.mTextRecord:setString("")
	self:refreshView()
	self.outCardBtnsPanel:setOpacity(255)
	self:setOutCardButtonsVisible(false)
	self:restoreStatusReady()
	self:getParent():onRefreshPlayerInfo(_info)
	self.m_thinkTime = _info.m_thinkTime
	if not self.m_thinkTime or self.m_thinkTime <= 0 then
		self.m_thinkTime = 15
	end

-- -- 托管通知
-- local xx_info = {
-- 	m_nPosition = 1,
-- 	m_bOpenOrClose = 1,
-- }
-- g_GameController:onTestMsg("CS_G2C_Run_AutoControl_Nty", xx_info)
-- local curShootCard = {
-- 	0x03, 0x13, 0x23, 0x34,
-- }
-- local curShootCardCount = #curShootCard
-- local cardType = self.m_GameLogic:GetCardType( curShootCard, curShootCardCount)
-- dump(cardType, "cardType__xx__cardType")

	self.m_state = _info.m_state
	-- self.m_landMainScene:setGameState( _info.m_state )
	if _info.m_state == 1 then 
		if g_GameController:isMatchGame() then self:reqCancelTuoGuan() end
		return
	end

	-- qingli
	for k,v in pairs( self.game_chair_tbl ) do
		v:clearPokerOut()
	end
	self:hideAllSpeak()
	self:clearEnemyCard()
	_info.m_recordId = _info.m_recordId or ""
	self.mTextRecord:setString("牌局ID:" .. _info.m_recordId)

	-- 发牌状态，游戏中
	_info.m_vecOutCards = {}
	_info.m_vecValue = _info.m_handCounts
	_info.m_nLastOutChair = 0
	_info.m_vecLastOutPokers = {}
	local tOutCardKeys = {"m_chairOneOutCards", "m_chairTwoOutCards", "m_chairThreeOutCards"}
	if #_info.m_chairOneOutCards + #_info.m_chairTwoOutCards + #_info.m_chairThreeOutCards > 0 then
		for i=1,2 do
			local nChair = _info.m_operChairId - i
			if nChair <= 0 then nChair = nChair + 3 end
			local n_xxx = _info[tOutCardKeys[nChair]][1]
			print("n_xxxn_xxxn_xxxn_xxx", n_xxx, i)
			if n_xxx and n_xxx ~= 0 then
				_info.m_nLastOutChair = nChair
				_info.m_vecLastOutPokers = _info[tOutCardKeys[nChair]]
				break
			else
				self:Run_Pass_Nty({m_chairId = nChair}, true)
			end
		end
	end
--	for i=1,table.maxn(tOutCardKeys) do
--        local v = tOutCardKeys[i]
--		_info.m_vecValue[i] = v
--	end
	-- _info.m_myCards = { 0x13, 0x03, 0x04, 0x14, 0x05, 0x06, 0x07, 0x09, 0x19, 
	-- 0x11, 0x21, 0x31, 0x01, 0x12, 0x22, 0x32,}
	-- _info.m_myCards = { 0x13, 0x03, 0x04, 0x14, 0x05, 0x15, 0x29, 0x09, 0x19, 
	-- 0x11, 0x21, 0x31, 0x01, 0x12, 0x22, 0x32,}

	local preInfo = _info
--	local vecUnderPoker = _info.m_vecUnderPoker
--	local nUnderMul = _info.m_nUnderMul
--	local meChair = self:getMeChairID()
	local vecTrusteeShip = _info.m_autoChairId
	local vecOutCards = _info.m_vecOutCards
	local tbl = _info.m_myCards
	local opChair = _info.m_operChairId
	local opTime = self.m_thinkTime
	local nLastOutChair = _info.m_nLastOutChair 
	local vecLastOutPokers = _info.m_vecLastOutPokers 
	local vecValue = _info.m_vecValue
    self.nLastOutChair = nLastOutChair

	self:restoreTuoGuan( vecTrusteeShip )
	for k,v in pairs(vecTrusteeShip) do
		self:Run_AutoControl_Nty( {m_nPosition = k, m_bOpenOrClose = v} )
	end

	-- self.bottom_card = CONVERT_AND_SORT( vecUnderPoker )
	-- self.gameRoomBgLayer:restoreHappyBottomCard(self.bottom_card, nUnderMul, self.m_GameLogic)
	-- self.gameRoomBgLayer:updateGreenPoint( vecOutCards , CardKit:C2S_CONVERT(self.bottom_card) )
	self:setMyHandCard( tbl )
	self:updateMyCardUI()

	if nLastOutChair > 0 then
		self:chairOutCard( nLastOutChair , vecLastOutPokers , vecValue[nLastOutChair ] )
	end
	for i,v in ipairs( vecValue ) do
		self.game_chair_tbl[i]:initCardCount(v)
		self.game_chair_tbl[i]:updateAlarm()
	end
	-- self:chairShouldOutCard( opChair , opTime , 0 )
	-- self:setOthersOpenPoker( preInfo , true )
	self:Run_Operate_Nty({m_chairId = opChair})
end
function GameMainLayer:Run_OutCard__( _info )
	-- dump(_info, "Run_OutCard__")
	-- if _info.m_chairId ~= self.meChairID then
	-- 	_info.m_cards = {
	-- 		-- 0x03, 0x13, 0x23, 0x33, 0x04, 0x14, 0x24, 0x05, 0x06, 0x07,
	-- 		-- 0x03, 0x04, 0x05, 0x06, 0x07,
	-- 		-- 0x03, 0x04, 0x13, 0x14,
	-- 		0x03, 0x13, 0x23, 0x04, 0x14,
	-- 	}
	-- end

	local punTime = 10 --_info.m_nPunTime
	local pos = _info.m_chairId
	local tbl = _info.m_cards
	local cardsNum 	= self.game_chair_tbl[pos].card_count - table.maxn(tbl)
	print("xxxxxxxxxssssssxxxxxxx", cardsNum, self.game_chair_tbl[pos].card_count, table.maxn(tbl))
	self.nLastOutChair = pos
	self.m_GameLogic:ClearOutCard()
	self:chairOutCard( pos , tbl , cardsNum )

	self:setOutCardButtonsVisible(false)
	if pos ~= self.meChairID then
		self:updateEnemyOutCard( pos , tbl )
		dump(self:getEnemyOutCard(), "getEnemyOutCard")
	end
	if pos == self.meChairID then
		self:removeHandCard( tbl )
		-- if punTime > 0 then
		-- 	self:onSlowOutCard( punTime )
		-- end
	end
end
function GameMainLayer:Run_Operate_Nty( _info )
	local pos = _info.m_chairId
    local nextPos    = self.nLastOutChair
	local nextPosSec = self.m_thinkTime
	local delay = 0
	print("Run_Operate_Nty_Run_Operate_Nty", self.meChairID, pos, nextPos)
		
	-- if nextPos == 0 then
	-- 	self:setGameEndOutChair( pos )
	-- else
		self:chairShouldOutCard( pos , nextPosSec , delay )
	-- end
	if pos == nextPos then
		delay = 2
		for k,v in pairs( self.game_chair_tbl ) do
			v:clearPokerOut()
		end
		self:hideAllSpeak()
		self.nLastOutChair = 0
		self:clearEnemyCard()
		dump(self:getEnemyOutCard(), "getEnemyOutCard")
	end
    if pos == self.meChairID then
    	-- self.cardScene:SetShootCard({}, 0)
       --  self:setOutCardButtonsVisible(true)
      	-- self:setOutCardButtonsEnable( LandGlobalDefine.OPERATION_CARD_OUTCARD , false )
      	self:showOutCardPanel()

        -- self.lord_txt_bfhcpgz:setVisible(true)
        -- self.lord_txt_bfhcpgz:stopAllActions()
        -- self.lord_txt_bfhcpgz:runAction(cc.Sequence:create(D(1),cc.Hide:create()))
        self.game_chair_tbl[_info.m_chairId]:clearPokerOut()
        self.game_chair_tbl[_info.m_chairId]:hideSpeak()
        return
    end

	-- local tbl        = _info.m_cards
	self:setOutCardButtonsVisible(false)
	self:hideJiaBeiPanel()
	
	-- if pos == self:getLordChair() then
	-- 	self.gameRoomBgLayer:updateGreenPoint( _info.m_cards , CardKit:C2S_CONVERT(self.bottom_card) )
	-- end
end
function GameMainLayer:Run_Pass_Nty( _info , _withoutsound)
	self.game_chair_tbl[_info.m_chairId]:clearPokerOut()
	if _info.m_chairId == self.meChairID then
		self:setOutCardButtonsVisible(false)
	end
	self.game_chair_tbl[_info.m_chairId]:onPass()
	self:updateEnemyOutCard( _info.m_chairId , {} )
	if not _withoutsound then self:playBuYaoSound() end
end
function GameMainLayer:Run_GameResult__( _info ) 
	self.m_pResultInfo = _info;
	local pResultInfo = _info
	local indemnityChairId = _info.m_indemnityChairId --包赔玩家
	local allResult = _info.m_allResult
	-- local scoreRet = _info.m_vecScore
	-- local nEndPos= _info.m_nEndPos
	-- local nTotalMultiple = _info.m_nTotalMultiple

	self:setOutCardButtonsVisible(false)
	self:hideAllSpeak()
	self:clearEnemyCard()
	self:clearKingBoomTimer()
	self.m_landMainScene:hideExitGameLayer()
	self:hideTuoGuanPanel()
	self.cardScene:ClearHandCard()

	for i=1,3 do
		local tbl = allResult[i]
		self.game_chair_tbl[i]:setLastHandCard( tbl.m_cards )
		self.game_chair_tbl[i]:showLastPoker()
		if i == self.game_end_out_chair then
			self.game_chair_tbl[i]:showLastStepUI()
		end 
        self.game_chair_tbl[i]:setPlayerScoreRet( tbl.m_calScore )
	end
	self:playWinLoseAnimation( nEndPos )
	self:playGameEndSound( nEndPos )

	-- 
	if IS_HAPPY_LAND( self.game_atom ) and IS_FREE_ROOM( self.game_atom ) then
		self:Run_showGameResultLayer(pResultInfo)
	end

	-- 
	_info.m_cardsNum = {}
	_info.m_vecScore = {}
	_info.m_nTotalBombs = {}
	-- local nBomb = 0
	for k,v in pairs(_info.m_allResult) do
		local s_xxx = string.format( "m_vec%dChairCards", v.m_chairId)
		_info[s_xxx] = v.m_cards
		_info.m_vecScore[v.m_chairId] = v.m_netProfit
		_info.m_nTotalBombs[v.m_chairId] = v.m_bombCount
		-- nBomb = nBomb + v.m_bombCount
	end
	-- _info.m_nTotalBombs = nBomb

	g_GameController.gameScene:showMatchResultView(1.5, self.m_pResultInfo, self.game_chair_tbl);
end
function GameMainLayer:Run_onShowChairTable( players, meChairID )
    if type(self.game_chair_tbl) == "table" then
        for k, v in pairs(self.game_chair_tbl) do
            v:removeFromParent()
        end
    end
	self.game_chair_tbl = {}
	self.gameRoomBgLayer:showMyHead()
	self.meChairID = meChairID
	if not players then return end
	for k,v in pairs( players ) do
		local score = v:getGameScore()
		local chair  = v:getChairId()
		local aChair = GameChair.new( chair, self.meChairID , self.game_atom )
		local faceID = v:getFaceId()
		local acc    = v:getAccountId()
		aChair:showHead( faceID , acc )
		aChair:setPlayerName( v:getNickname() )
		aChair:setPlayerScore( score )
		aChair:setOffLine( v.m_offine or 0 )
		local zorder = 4
		if chair == self.meChairID then zorder = 5 end
		self:addChild( aChair , zorder )
		self.game_chair_tbl[ chair ] = aChair
		local csbName = aChair:getCSBName()
		self:setChatPos( acc , csbName , aChair )
	end
end
function GameMainLayer:Run_showGameResultLayer(_info)
end

return GameMainLayer