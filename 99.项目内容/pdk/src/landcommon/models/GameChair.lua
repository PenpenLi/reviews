-- GameChair
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 打牌椅子 行为和UI表现
-- 叫分,出牌
local CardSprite = require("app.game.pdk.src.landcommon.models.CardSprite")
local UserCenterHeadIcon = require("app.hall.userinfo.view.UserHeadIcon")
local FriendRoomController  = require("src.app.game.pdk.src.classicland.contorller.FriendRoomController") 
local LandPublicController  = require("src.app.game.pdk.src.classicland.contorller.LandPublicController")
local LandSoundManager     = require("src.app.game.pdk.src.landcommon.data.LandSoundManager")
local LandGlobalDefine     = require("src.app.game.pdk.src.landcommon.data.LandGlobalDefine")
local LandAnimationManager = require("src.app.game.pdk.src.landcommon.animation.LandAnimationManager")
local LandArmatureResource = require("src.app.game.pdk.src.landcommon.animation.LandArmatureResource")
local CardKit = require("src.app.game.pdk.src.common.CardKit")

--创建圆形进度条
function createCircleLoadingBar(parent, pos, percentage)	
	pos = pos or cc.p(parent:getContentSize().width/2, parent:getContentSize().height/2)
	percentage = percentage or 100
	-- --创建一个图片精灵作为背景 需要一个空心圆形的图片	
	-- local spriteBg = cc.Sprite:create("loadingBarBg.png")	
	-- parent:addChild(spriteBg)	
	-- spriteBg:setPosition(pos)	

	--创建一个进度条图片精灵 需要一个空心圆形的图片	
	local sprite = cc.Sprite:createWithSpriteFrameName("fj_op_cd_pb.png")
	--创建进度条	
	local circleProgressBar = cc.ProgressTimer:create(sprite)	
	--设置类型	
	circleProgressBar:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)	
	--指定父节点
	parent:addChild(circleProgressBar)	
	--指定位置	
	circleProgressBar:setPosition(pos)	
	--还可以指定层级 名字	
	circleProgressBar:setLocalZOrder(100)	
	--设置进度	
	circleProgressBar:setPercentage(percentage)
    return circleProgressBar
end

local GameChair = class("GameChair", function()
    return display.newLayer()
end)

function GameChair:ctor( chair , clientChair , gameAtom )
	print("GameChair_GameChair", chair , clientChair , gameAtom )
	self.game_atom = gameAtom
	self:initData( chair )
	self:setThisClientChair( clientChair )
	self:initCSB()
	self:initUI()
end

function GameChair:initData( chair )
	self.chair              = chair --椅子号
	self.cur_hand_card      = nil    --剩余哪些牌 
	self.card_count         = 0     --剩余牌数量
	self.lord_chair         = nil   --地主椅子ID
	self.tuo_guan_status    = 0     --是否托管中
	self.card_out           = {}    --出牌记录
	self.cardSpriteMGR      = CardSprite.new()
end

function GameChair:initCSB()
	local csbName = self:getCSBName()
	self.root  = cc.CSLoader:createNode("src/app/game/pdk/res/csb/classic_land_cs/player_panel_"..csbName..".csb")
    UIAdapter:adapter(self.root, handler(self, self.onTouchCallback))
	self:addChild(self.root)
    self.panel     = self.root:getChildByName("panel")
    --
    local tPos = {
		["left"] = cc.p(-70, 40),
		["right"] = cc.p(70, 40),
		["self"] = cc.p(0, 0),
	}
    self.root:setPosition(tPos[csbName])
end

function GameChair:initUI()
	local UI_TBL = 
	{
		"poker_out",
		"happy_small_poker",
		"land_speak_panel",
		"land_speak",
		"clock_panel",
		"clock_num_label",
		"clock_bg",
		"lord_bg_head",
		"lord_btn_circle",
		"player_name",
		"node_card_num",
		"gold_win_lose",
		"last_step",
		"player_score",
		"land_outline",
		"land_tuoguan",
		"img_mingpai",
		"img_jiabei",
	}
	
	for k,v in pairs( UI_TBL ) do
		self[v] = self.root:getChildByName(v)
		if self[v] then
			self[v]:setVisible(false)
		end
	end 

	-- changeui
    self.clock_bg:loadTexture("fj_op_cd_bg1.png", 1)
    self.clock_bg:setScale(0.65)
    if self.client_chair == self.chair then
    	self.clock_num_label:setScale( 1.5 )
    	self.clock_num_label:setAnchorPoint(cc.p(0.5, 0.5))
    	self.clock_num_label:setPosition(self.clock_bg:getContentSize().width*0.5, self.clock_bg:getContentSize().height/2)
    else
    	self.clock_num_label:setPositionX(self.clock_num_label:getPositionX() + 3)
    	self.clock_num_label:setPositionY(self.clock_num_label:getPositionY() - 2)
    end
    self.clock_pregress = createCircleLoadingBar(self.clock_bg)
    -- local temp_player_score = ccui.Text:create()
    -- temp_player_score:setFontSize(24)
    -- temp_player_score:setPosition(self.player_score:getPositionX(), self.player_score:getPositionY())
    -- temp_player_score:setLocalZOrder(self.player_score:getLocalZOrder())
    -- self.player_score:getParent():addChild(temp_player_score)
    -- self.player_score = temp_player_score
   	self.land_speak_panel:setOpacity(0)
	self.land_speak:setOpacity(0)
    local tip_yaobuqi = ccui.ImageView:create("")
    tip_yaobuqi:loadTexture("fj_op_st_00.png", 1)
    tip_yaobuqi:setPosition(self.land_speak_panel:getPositionX(), self.land_speak_panel:getPositionY())
    tip_yaobuqi:setLocalZOrder(self.land_speak_panel:getLocalZOrder())
    tip_yaobuqi:setScale(0.7)
    tip_yaobuqi:setVisible(false)
    self.land_speak_panel:getParent():addChild(tip_yaobuqi)
    self.tip_yaobuqi = tip_yaobuqi
    if self:getCSBName() == "left" then
    	tip_yaobuqi:setPositionX(tip_yaobuqi:getPositionX() +100)
    end
    if self.client_chair == self.chair then
    	self.player_score:setPositionY(self.player_score:getPositionY() - 140)
    end
	-- 
    self.playerPosy = self.root:getPositionY()
    self.posy = self.player_score:getPositionY()
	self.poker_outPosY = self.poker_out:getPositionY()
	self.last_stepPosY = self.last_step:getPositionY()
    self.playerPosy1 = self.panel:getPositionY()
	self:initInfoPanel()
	self:initPlayerFace()  
	self:initPlayerScore()
	self:initAlarm()
	self:initTiRen()
    self:updateScoreLabelPos()
end

function GameChair:hideHead()
	if not self.lord_bg_head then return end

   	self.lord_bg_head:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 1), 
   		cc.CallFunc:create(function ()
   			--self.lord_bg_head:setVisible(true)
   			--self.lord_bg_head:removeAllChildren()

   			self.lord_bg_head:setVisible(false)
   			self.imgHead:setVisible(false)
			self.player_face:setVisible(true) 
			
        end)))

end

function GameChair:showHead( faceID , acc )
	if not self.lord_btn_circle then return end
	if self.imgHead then return end
	self.lord_btn_circle:setVisible( false )
	self.lord_bg_head:setVisible( true )
	local _head_bg_size = self.lord_btn_circle:getContentSize()
	self.imgHead = UserCenterHeadIcon.new({_size =_head_bg_size ,_clip = false , _id = math.random(1,20)})
	self.imgHead:setAnchorPoint(cc.p(0.5,0.5))
	self.imgHead:setPosition(self.lord_btn_circle:getPosition())
	self.imgHead:setName("self.imgHead")
--	self.lord_bg_head:addChild( self.imgHead )
    self.lord_bg_head:setVisible(false)
    local node = display.newNode()
    node:setAnchorPoint(0.5,0.5)
    node:setPosition(self.lord_bg_head:getPositionX()-50,self.lord_bg_head:getPositionY()-50)
    
    node:addChild( self.imgHead )
    self.panel:addChild( node )
	self.imgHead:updateTexture( faceID , acc )
	self.imgHead._showhead_img_head:setVisible(true)

	self.faceID = faceID
	self.myAcc  = acc

	--
    local player_name = ccui.Text:create()
    player_name:setFontName("app/game/pdk/res/csb/resources/font/jcy.TTF")
    player_name:setPosition(cc.p(self.imgHead:getPositionX(), self.imgHead:getPositionY() - _head_bg_size.height * 0.6))
    player_name:setFontSize(25)
    node:addChild(player_name)
   	self.player_name = player_name
end

function GameChair:hidePlayerName()
	if not self.player_name then return end
	-- if IS_PAI_YOU_FANG( self.game_atom ) then 
	-- 	self.player_name:setVisible(true)
	-- else
	-- 	self.player_name:setVisible(false)
	-- end
end

function GameChair:updatePlayerNameUI()
	if not self.player_name then return end
	-- if IS_FAST_GAME( self.game_atom ) or IS_FREE_ROOM( self.game_atom ) then return end
	self.player_name:setFontName("")
	self.player_name:setString( self.nick_name )
	self.player_name:setVisible(true)
end

function GameChair:initPlayerScore()
	if not IS_FREE_ROOM( self.game_atom ) then
		local oldX = self.player_score:getPositionX()
		local icon = self.player_score:getChildByName("gold_icon")
		-- if icon then icon:setVisible(false) end
		self.player_score:setPositionX( oldX - 45/4 )
	end
end

function GameChair:updatePlayerScoreUI()
	self.player_score:setVisible(true) 
	if not IS_PAI_YOU_FANG( self.game_atom ) then
        if g_GameController:isMatchGame()then
            self.player_score:setString( self.score_num )
        else
		    self.player_score:setString( self.score_num *0.01)
        end
	else
		self.player_score:setString( self.score_num.."分" )
	end
end

function GameChair:initInfoPanel()
	self.info_panel = self.panel:getChildByName("playerinfo_panel")
	if not self.info_panel then return end
	self:setInfoPanel(false)
	self.biaoqing_btn_tbl = {}
	local tbl = {"jidan","xianhua","songchaopiao","diutuoxie"}
	for k,v in pairs(tbl) do
		local btn = self.info_panel:getChildByName("biaoqing_"..v)
		if btn then
			local function onClickBiaoQing( sender , eventType )
				if eventType ~= ccui.TouchEventType.ended then return end
				GAME_SCENE_DO("huDongBiaoQing",v,self.chair)
				self:setInfoPanel(false)
				LandPublicController:getInstance():setLastSendBiaoQing( self.myAcc , os.time() )
			end
			btn:addTouchEventListener( onClickBiaoQing )
			self.biaoqing_btn_tbl[k] = btn
		end
	end
end

function GameChair:setInfoPanel( tag )
	if not self.info_panel then return end
	self.info_panel:setVisible( tag )
	self.info_panel:stopAllActions()
	if tag == true then
		function f()
			self:updateBiaoQingCD()
		end
		self.info_panel:runAction(cc.RepeatForever:create(cc.Sequence:create(CALL_FUNC(f),D(1))))
	end
end

function GameChair:updateBiaoQingCD()
	if type( self.biaoqing_btn_tbl ) ~= "table" then return end
	local lastSend = LandPublicController:getInstance():getBiaoQingCD( self.myAcc )
	local cd = lastSend + 10 - os.time() 
	local label = self.info_panel:getChildByName("label_biaoqing_cd")
	if not label then return end
	local opVal = 255
	local enableBtn = true

	if cd > 0 then
		label:setVisible(true)
		label:setString(cd)
		opVal = 30
		enableBtn = false
	else
		label:setVisible(false)
	end
	
	for k,v in pairs( self.biaoqing_btn_tbl ) do
		v:setTouchEnabled( enableBtn )
		v:setOpacity(opVal)
	end
end

function GameChair:updateInfoPanel()
	if not self.info_panel then return end
	local bg = self.info_panel:getChildByName("biaoqing_bg_head")
	if IS_FREE_ROOM( self.game_atom ) or IS_FAST_GAME( self.game_atom ) then
		bg:setVisible(false)
		local bgSize = bg:getContentSize()
		local panel = self.info_panel:getChildByName("panel_biaoqing")
		panel:setPositionY(bgSize.height/2)
		return
	end
	
	local label = bg:getChildByName("player_name")
	label:setFontName("")
	label:setString( self.nick_name )

	local headBG = self.info_panel:getChildByName("lord_btn_circle")
	local size = headBG:getContentSize()
	local head = UserCenterHeadIcon.new({_size =size ,_clip = false , _id = math.random(1,20)})
	head:setAnchorPoint(cc.p(0.5,0.5))
	head:setPosition(cc.p(size.width/2,size.height/2))
	
	headBG:addChild( head )
	head:updateTexture( self.faceID , self.myAcc )
	head._showhead_img_head:setVisible(true)
end

function GameChair:setPlayerName( name )
	self.nick_name = name
	self:updatePlayerNameUI()
	self:updateInfoPanel()	
end

function GameChair:setPlayerScoreRet( num )
	self.score_ret = num
	local ret = self.score_num + self.score_ret
	 
	self:setPlayerScore( ret )
end

function GameChair:setPlayerScore( num )
	self.score_num = num
	self:updatePlayerScoreUI()
end

function GameChair:getPlayerScore()
	return self.score_num
end

function GameChair:updateCardCount( ret )
	local change = self.card_count - ret
	local csbName = self:getCSBName()
	if csbName ~= "self" and change > 0 then
		if not IS_PAI_JU_HUIFANG( self.game_atom ) then
			if ret == 2 then
				LandSoundManager:getInstance():playEffect("LAST_TWO_POKET")
			elseif ret ==1 then
				LandSoundManager:getInstance():playEffect("LAST_ONE_POKET")
			end
		end
	end
	self:setCardCount( ret )
end

function GameChair:initCardCount( num )
	self.card_out = {}
	self:setCardCount( num )
end

function GameChair:setCardCount( num )
	self.card_count = num
	self:updateUICardCount( self.card_count )
end

function GameChair:logOutCard( tbl )
	if type( tbl ) ~= "table" then return end
	for k,v in pairs( tbl ) do
		self.card_out[v] = 1
	end
end

---------------------行为通知-------------------
function GameChair:onReadyCarryOn()
	self:showSpeak("OK")
	self.gold_win_lose:setVisible(true)
	self:hideJiaBeiFlag()
end
function GameChair:onChuPai( tbl , num )
	self:logOutCard( tbl )
	self:updateCurHandCard()
	self:updateCardCount( num )
	self:showChuPaiUI( tbl )
end

function GameChair:showChuPaiUI( tbl )
	self:updateAlarm()
	self:hideSpeak()
	self:hideClock()
	if #tbl > 0 then
		self:playAnimation("chupai", 0)
		self:showPokerOut( tbl )
	else
		self:onPass()	
	end
end

function GameChair:onPass()
	self:clearPokerOut()
	self:showSpeak("不出")
	self:playAnimation("daiji")
end

function GameChair:onXuanPai( xuanPaiSec )
	self:clearPokerOut()
	self:hideSpeak()
	if self.tuo_guan_status == 0 then
		self:showClock( xuanPaiSec )
		self:playAnimation("xuanpai")
	end
end
--思考是否加倍
function GameChair:onJiaBeiThink( _sec )
	local sec = _sec or 15
	self:showClock( sec )
end

function GameChair:onJiaBei( num )
	if num >= 1 then
		self:showSpeak("加倍")
		self:showJiaBeiFlag()
	else
		self:showSpeak("不加倍")
	end
	self:hideClock()
end

function GameChair:onComeBackJiaoFenThink( gap )
	local leftSec = self.clock_sec - gap
	if leftSec > 0 then
		self:onJiaoFenThink( leftSec )
	end
end

function GameChair:onJiaoFenThink( _sec )
	local sec = _sec or 15
	self:showClock( sec )
	self:hideSpeak()
end

function GameChair:onJiaoFen( num , opTag )
	self:hideClock()
	local str = self:getClassicCallStr( num )
	if IS_HAPPY_LAND( self.game_atom ) then
		str = self:getHappyCallStr( opTag )
	end
	LogINFO(self.chair,"号椅子叫了",num,"分","操作标志", opTag , str )
	self:showSpeak( str )
	
end

function GameChair:onOpenPoker( vec , flag , cardCount)
	self:hideClock()
	if #vec > 0 then
		self:showSpeak("明牌")
		self:setCurHandCard( vec )
		self:showHappySmallPoker(flag, cardCount)
		self:showMingPaiFlag()

		if 1 or self:GetGender( _landUser ) == LandGlobalDefine.GENDER_BOY then
            LandSoundManager:getInstance():playEffect("BOY_CALLSCORE_MINGPAI")
        else
            LandSoundManager:getInstance():playEffect("GIRL_CALLSCORE_MINGPAI")
        end
	else
		self:showSpeak("不明牌")
		self:hideMingPaiFlag()
	end
end

local happy_call_str = 
{
	[0] = "不叫",
	[1] = "叫地主",
	[2] = "不抢",
	[3] = "抢地主",
}

function GameChair:getHappyCallStr( _key )
	local key = _key or 0
	return happy_call_str[ key ]
end

function GameChair:getClassicCallStr( score )
	local str = "不叫"
	if score and score > 0 then str = score.."分" end
	return str
end

function GameChair:setLord( lordP )

	self:setLordPos( lordP )
	self:initAnimation()

	self:playBianDa()

	self:hidePlayerName()
	self:updateScoreLabelPos()
end

function GameChair:updateScoreLabelPos()
	if self:getCSBName() == "self" then 
        self.panel:setPositionY(self.playerPosy-223) 
        self.player_score:setPositionY(self.posy+60)
    else
        local winSize = cc.Director:getInstance():getWinSize()
--         if (winSize.width / winSize.height > 1.78) then 
--            if self:isDiZhu() then
--                self.panel:setPositionY(self.playerPosy1-17) 
--            else
--                self.panel:setPositionY(self.playerPosy1-25) 
--            end
--        else
            -- if self:isDiZhu() then
            --     self.panel:setPositionY(self.playerPosy1-60) 
            -- else
                self.panel:setPositionY(self.playerPosy1-75) 
            -- end
       -- end
	end
end

function GameChair:setLastHandCard( tbl )
	self.last_hand_card = clone( tbl )
end

function GameChair:setCurHandCard( vec )
	self.cur_hand_card = {}
	for k,v in pairs( vec ) do
		table.insert( self.cur_hand_card , v )
	end
end

function GameChair:updateCurHandCard()
	if type( self.cur_hand_card ) ~= "table" or type( self.card_out ) ~= "table" then return end
	local ret = {}
	for k,v in pairs( self.cur_hand_card ) do
		if not self.card_out[v] then
			ret[k] = v
		end
	end
	self:setCurHandCard( ret )
	self:showHappySmallPoker(false)
end

function GameChair:showLastPoker()
	self:clearHappySmallPoker()
	self:showPokerOut( self.last_hand_card )
	local layout = self.poker_out:getChildByName("out_poker")
	local csbName = self:getCSBName()
	if layout and csbName == "self" then
		layout:setPositionY(layout:getPositionY()-90)
		self.last_step:setPositionY(self.last_step:getPositionY()-70)
	end
end

function GameChair:showLastStepUI()
	self.last_step:setLocalZOrder(9999)
	self.last_step:setVisible(true)
	local csbName = self:getCSBName()
	local layout = self.poker_out:getChildByName("out_poker")
	if layout and csbName == "right" then
		if #self.last_hand_card > 10 then
			self.last_step:setPositionX(self.last_step:getPositionX()- 250)
			self.last_step:setPositionY(self.last_step:getPositionY()-70)
		end
	elseif layout and csbName == "left" then
		if #self.last_hand_card > 10 then 
			self.last_step:setPositionY(self.last_step:getPositionY()-70)
		end
	
	end
end

function GameChair:onGameEnd( lastOutCardPos )
	self.game_end = true
	self:setCardCount(0)
	self:hideSpeak()
	self:hideClock()
	GAME_SCENE_DO("hideAllInfoPanel")
	self:hideCardCountUI()
	self:updateAlarm()
	self:playWinLose( lastOutCardPos )
end

function GameChair:playWinLose( lastOutCardPos )
	if not self.lord_chair then return end
	local ret = self:winOrLose( lastOutCardPos )
	if ret > 0 then

		self:playAnimation("shengli")
		--[[self:changeSpriteFrameState(self.spriteFrameList[2])--]]
	else
		--[[self:changeSpriteFrameState(self.spriteFrameList[3])--]]
		self:playAnimation("shibai")
	end
	self:showScoreGold( ret )
end

function GameChair:hideScoreGold()
	self.gold_win_lose:setVisible(false)
end

function GameChair:showScoreGold( score )
    
	local numVal = math.abs( self.score_ret )*0.01
    if g_GameController:isMatchGame() then
         numVal = math.abs( self.score_ret )
    end
	self.gold_win_lose:removeAllChildren()
	self.gold_win_lose:setVisible(true)

	local label = self:createGameScoreSprite( score )
	local csbName = self:getCSBName()
	if csbName == "right" then 
		label:setAnchorPoint(1,0.5)
		label:setPosition(cc.p(self.gold_win_lose:getContentSize().width, self.gold_win_lose:getContentSize().height/2))
	else
		label:setAnchorPoint(0,0.5)
		label:setPosition(cc.p(0, self.gold_win_lose:getContentSize().height/2))
	end
	
	label:setString(":"..numVal)
	self.gold_win_lose:addChild( label )
end

function GameChair:winOrLose( lastOutCardPos )
	if self.chair == lastOutCardPos then return 1 end
	if not self:isDiZhu() and lastOutCardPos ~= self.lord_chair then return 1 end
	return -1
end

function GameChair:lordScore( scoreTBL )
	for k,v in pairs( scoreTBL ) do
		if k == self.lord_chair then return v end
	end
end

function GameChair:updateTuoGuan( status )
	self.tuo_guan_status = status
	self:setTuoGuan(self.tuo_guan_status)
end

function GameChair:getTuoGuanStatus()
	return self.tuo_guan_status
end



----------------------UI零件------------------------
function GameChair:showHappySmallPoker(isTure, cardCount)  -- 参数为true 说明是明牌时的操作 要绘牌,false不用
	if not self.happy_small_poker then return end
	local layout = self:createHappySmallLayout(isTure, cardCount)
	if not layout then return end
	self.happy_small_poker:setVisible( true )
	self.happy_small_poker:removeAllChildren()
	self.happy_small_poker:addChild( layout )
end

function GameChair:clearHappySmallPoker()
	if not self.happy_small_poker then return end
	self.happy_small_poker:setVisible( false )
	self.happy_small_poker:removeAllChildren()
end

function GameChair:createHappySmallLayout(isTure, cardCount)
	if type( self.cur_hand_card ) ~= "table" then return end
	local csbName = self:getCSBName()
	local cardGap = 23
	local size  = self.happy_small_poker:getContentSize()
	local width = table.nums( self.cur_hand_card ) * cardGap
	local layout = ccui.Layout:create()
	layout:setContentSize(cc.size(width,size.height))
	if csbName == "right" then
		layout:setAnchorPoint(1,0)
	else
		layout:setAnchorPoint(0,0)
	end
	if not isTure then
		local clientTBL = CONVERT_AND_SORT( self.cur_hand_card )
		local n = 0
		for k,v in pairs( clientTBL ) do
			n = n + 1
			local img = CREATE_HAPPY_SMALL_CARD( v )
			if img then
				img:setAnchorPoint(0,0)
				img:setPositionX( (n-1)*cardGap )
				layout:addChild( img )
			end
		end
		return layout
	elseif isTure == true then
		if cardCount and cardCount == 0 then
			return self:dispatchCard(layout, 0)
		elseif cardCount and cardCount > 0 then
			for i=1,cardCount do
				local img    = CREATE_HAPPY_SMALL_CARD( S2C_CARD_CONVERT(  self.cur_hand_card[i] ) )
				if img then
					img:setAnchorPoint(0,0)
					img:setPositionX( (i-1)*cardGap )
					layout:addChild( img )
				end
			end
			return self:dispatchCard(layout, cardCount)
		end
	end
end

function GameChair:dispatchCard(layout, count)
	local cardGap = 23
	local n = count
	local doSomething  = cc.CallFunc:create(function ()
		n = n + 1
		print(" n=", n)
		local img    = CREATE_HAPPY_SMALL_CARD( S2C_CARD_CONVERT( self.cur_hand_card[n] ) )
		if img then
			img:setAnchorPoint(0,0)
			img:setPositionX( (n-1)*cardGap )
			layout:addChild( img )
		end
	end)

	local se = cc.Sequence:create(D(0.5), doSomething)
	local rea = cc.Repeat:create(se, table.nums( self.cur_hand_card ) - count )
	layout:runAction(rea)
	return layout
end

function GameChair:clearPokerOut()
	self.poker_out:removeAllChildren()
	self.last_step:setVisible(false)
end

function GameChair:clearScroe()
	self.gold_win_lose:removeAllChildren()
	--self.gold_win_lose:setVisible(true)
end


function GameChair:clearHead() 
	if self.armature_tbl and self.armature_tbl[1] then
		self.armature_tbl[1]:setVisible(false)
	end

	if self.spriteFrameIcon then
		self.spriteFrameIcon:setVisible(false)
	end


	if not self.lord_bg_head then return end
	self.lord_bg_head:setVisible(true)
	if not self.imgHead then return end
	self.imgHead:setVisible(true)

end

function GameChair:showPokerOut( tbl )
	self.poker_out:setVisible( true )
	self.poker_out:removeAllChildren()
	local csbName = self:getCSBName()
	local layout = nil
	local cardGap = 70
	if #tbl > 8 then cardGap = 50 end

	tbl = CardKit:S2C_CONVERT( tbl )
	tbl = CARD_SORT(tbl)

	if csbName == "self" then
		layout = self:createSelfCard( tbl , cardGap )
	elseif csbName == "left" then
		layout = self:createOtherCard( tbl , cardGap )
	else
		layout = self:createOtherCard( tbl , cardGap )
		layout:setAnchorPoint(1,1)
		local size = self.poker_out:getContentSize()
		layout:setPosition(size.width,size.height)
	end
	layout:setName("out_poker")
	self.poker_out:addChild( layout )
end

function GameChair:createOtherCard( tbl , cardGap )
	local size = self.poker_out:getContentSize()
	local width = size.width + math.min(9,(#tbl-1))*cardGap
	local layout = ccui.Layout:create()
	layout:setContentSize( cc.size(width, size.height) )

	for k,v in ipairs( tbl ) do
		local sprite = self:createOneCard( v )
		sprite:setAnchorPoint(0,0)
		local x,y = self:getCardXY(k,cardGap)
		sprite:setPosition(x,y)
		layout:addChild(sprite)
	end
	return layout
end

function GameChair:createSelfCard( tbl , cardGap )
	local stbl = tbl

	local size = self.poker_out:getContentSize()
	local layout = ccui.Layout:create()
	layout:setAnchorPoint(0.5,0.5)
	layout:setPosition(size.width/2,size.height/2) 
	
	for k,v in ipairs( stbl ) do
		local sprite = self:createOneCard( v )
		local psize  = sprite:getContentSize()
		sprite:setAnchorPoint(0,0)
		sprite:setPositionX((k-1)*cardGap)
		layout:addChild(sprite)
	end
	
	local width = size.width + (#tbl-1)*cardGap
	layout:setContentSize( cc.size(width, size.height) )
	return layout
end

function GameChair:createOneCard( v )
	local sprite  = self.cardSpriteMGR:createCard( v )
	if self:isDiZhu() then
		local diZhuFlag = display.newSprite("#land_icon_lord.png")
		diZhuFlag:setScale(1.5)
		diZhuFlag:setAnchorPoint(1,1)
		diZhuFlag:setPosition(sprite:getContentSize().width - 10, sprite:getContentSize().height - 7)
		sprite:addChild( diZhuFlag )
	end
	return sprite
end

function GameChair:getCardXY( k , gap )
	local oneLineCardNum = 10
	local n = k
	if k > oneLineCardNum then n = k-oneLineCardNum end
	local x = (n-1)*gap
	local y = -120*math.floor(k/(oneLineCardNum+1))
	return x,y
end

function GameChair:getMiddleCardXY( k )
	local x = k*50
	local y = 100
	return x,y
end

function GameChair:getLineAniPlayPos()
	local pos = cc.p(self.poker_out:getPositionX(),self.poker_out:getPositionY()-40)
	local ret = nil
	if self:getCSBName() == "self" then
		ret = self.poker_out:convertToWorldSpace(pos)
		ret = cc.p(ret.x, ret.y+30) 
	else
		ret = self.poker_out:convertToWorldSpace(pos)
		ret = cc.p(ret.x, ret.y - 40) 
	end
	
	return ret
end

function GameChair:playBoom()

    --[[local name = "zhadan"
    local csbName = self:getCSBName()
    if csbName == "left" then
    	name = "zhadan"
    elseif csbName == "right" then
    	name = "zhadan"
    end
    local armature = self.armature_tbl[1]
    armature:setVisible(true)
    if csbName == "self" then
    	armature:setScaleX(display.width/1280)
    end
    armature:getAnimation():play(name, -1,0)--]]
end

function GameChair:getClockSec()
	return self.clock_sec
end

function GameChair:showClock( sec )
	self:hideSpeak()
	self.clock_panel:setVisible(true)
	self.clock_bg:setVisible(true)
	-- self.clock_bg:loadTexture("lord_img_oclock01.png",1)
	self.clock_sumsec = sec
	self.clock_pregress:setPercentage(100)
	self.clock_num_label:setVisible(true)
	self.clock_sec = sec
	self.clock_num_label:setString( self.clock_sec )
	self:startClockAction()
end

function GameChair:hideClock()
	self.clock_panel:setVisible(false)
	self.clock_num_label:stopAllActions()
end

function GameChair:startClockAction( sec )
	self.clock_num_label:stopAllActions()
	local function updateClock()
		self.clock_sec = self.clock_sec - 1
		self.clock_pregress:setPercentage(100 * self.clock_sec / self.clock_sumsec)
		if self.clock_sec > 0 then
			self.clock_num_label:setString( self.clock_sec )
			if self.clock_sec <= 5 then
				LandSoundManager:getInstance():playEffect("ET_CLOCK")
				-- self.clock_bg:loadTexture("lord_img_oclock.png",1)
			end
		else
			-- if IS_PAI_YOU_FANG( self.game_atom ) then
			-- 	self.clock_num_label:setString( 0 )
			-- else
			-- 	if self:getCSBName() == "self" then
			-- 		GAME_SCENE_DO("onClockRunToZero")
			-- 	end
			-- 	self:hideClock()
			-- end
			self.clock_num_label:setString( 0 )
		end
	end
	local action = cc.RepeatForever:create( cc.Sequence:create( D(1) , cc.CallFunc:create( updateClock ) ) )
	self.clock_num_label:runAction( action )
end

function GameChair:initTiRen()
	self.btn_tiren = self.panel:getChildByName("btn_tiren")
	if not self.btn_tiren then return end
	self.btn_tiren:setTouchEnabled(true)
	self.btn_tiren:setVisible( false )
	local function clickTiRen( sender , eventType )
		if eventType ~= ccui.TouchEventType.ended then return end
		FriendRoomController:getInstance():onClickTiRen( self.chair )
	end
	self.btn_tiren:addTouchEventListener( clickTiRen )
end

function GameChair:setTiRenBtn( tag )
	print("tag",tag)
	print("self.chair", self.chair)
	if not self.btn_tiren then return end
	self.btn_tiren:setVisible( tag )
end

function GameChair:setOffLine( tag )
	if not self.land_outline then return end
	self.land_outline:setVisible( tag == 1 )
	-- 设置头像变灰
	if self.imgHead and self.imgHead.setHeadGray then 
		self.imgHead:setHeadGray(tag == 1 )
	end
end

function GameChair:setTuoGuan( tag )
	if not self.land_tuoguan then return end
	self.land_tuoguan:setVisible( tag == 1 )
end

function GameChair:showJiaBeiFlag()
	if not self.img_jiabei then return end
	self.img_jiabei:setVisible( true )
end

function GameChair:hideJiaBeiFlag()
	if not self.img_jiabei then return end
	self.img_jiabei:setVisible( false )
end

function GameChair:showMingPaiFlag()
	if not self.img_mingpai then return end
	self.img_mingpai:setVisible( true )
end

function GameChair:hideMingPaiFlag()
	if not self.img_mingpai then return end
	self.img_mingpai:setVisible( false )
end

function GameChair:initAlarm()
	self.lord_alarm = self.panel:getChildByName("lord_alarm")
	if not self.lord_alarm then 
		self.lord_alarm = ccui.ImageView:create("")
        self.panel:addChild(self.lord_alarm)
		-- return 
	end
	self.lord_alarm:setVisible(false)
	self.alarm_armature  = self:createArmature("ani_alarm")
	self.alarm_armature:setAnchorPoint(0,0)
	self.lord_alarm:addChild( self.alarm_armature )
end

function GameChair:updateAlarm()
	if not self.lord_alarm then return end
	if self.card_count < 1 or self.card_count > 1 then
		self.lord_alarm:setVisible( false )
	else
		self.lord_alarm:setVisible( true )
		--[[if self.alarm_armature then
			self.alarm_armature:getAnimation():play("ani_alarm")
		else
			self.alarm_armature  = self:createArmature("ani_alarm")
			self.alarm_armature:setAnchorPoint(0,0)
			self.lord_alarm:addChild( self.alarm_armature )
			self.alarm_armature:getAnimation():play("ani_alarm")
		end--]]

		self.alarm_armature:getAnimation():play("ani_alarm", -1, 1)
	end
end

function GameChair:showSpeak( str )
	if str ~= "不出" then return end
	self:hideScoreGold()
	self:hideClock()
	self.land_speak_panel:setVisible(true)
	self.land_speak:setVisible(true)
	self.land_speak:setString(str)
	self.tip_yaobuqi:setVisible(true)
end

function GameChair:hideSpeak()
	self.land_speak_panel:setVisible(false)
	self.tip_yaobuqi:setVisible(false)
end

function GameChair:updateUICardCount( num )
	self.card_count = num
	if not self.cardNumLabel then return end
	if not self.cur_hand_card or #self.cur_hand_card == 0 then
		self.cardNumLabel:setVisible(true)
	else
	 	self.cardNumLabel:setVisible(false)
	end

	self.cardNumLabel:setString( string.format("%02d", num) )
end

function GameChair:hideCardCountUI()
	if not self.cardNumLabel then return end
	self.cardNumLabel:setVisible(false)
end

-------------------农民地主动画-----------------
function GameChair:initPlayerFace()
	self.player_face     = self.panel:getChildByName("player_face")
	self.particle_bg     = self.panel:getChildByName("Particle_1")

	if self:getCSBName() ~= "self" then
		self.cardNumLabel = ccui.Text:create() --cc.LabelAtlas:_create( "0",  "number/lord_num_pai.png",24,32,48)
		self.cardNumLabel:setFontSize(24)
	    self.cardNumLabel:setAnchorPoint(cc.p(0.5,0.5))
	    self.panel:addChild(self.cardNumLabel)
	    self.cardNumLabel:setPosition( self.node_card_num:getPosition())--self:getCSBName() == "left" and cc.p(205,240) or cc.p(97,233))
	    self.cardNumLabel:setVisible(false)
	    self.cardNumLabel:setLocalZOrder(self.happy_small_poker:getLocalZOrder()-1)
	    -- 
	   	local image_bg = ccui.ImageView:create("")
	   	image_bg:loadTexture("poker_back.png", 1)
	   	image_bg:setScale(0.6)
	   	image_bg:setLocalZOrder(-1)
	   	image_bg:setAnchorPoint(cc.p(0.05, 0.15))
	   	image_bg:setPosition(self.cardNumLabel:getContentSize().width, self.cardNumLabel:getContentSize().height)
		self.cardNumLabel:addChild(image_bg);
	end
	
	local function onClickFace( sender, eventType )
		if eventType ~= ccui.TouchEventType.ended then return end

		if self.info_panel == nil then return end

		local curState = self.info_panel:isVisible()
		GAME_SCENE_DO("hideAllInfoPanel")
		if self.game_end then return end
		if curState ==  false then

			self:setInfoPanel(true)
		end
	end
	self.player_face:addTouchEventListener( onClickFace )

	if self:getCSBName() == "self" then
		self.player_face:setTouchEnabled(false)
	end
end

function GameChair:initAnimation()
	self:hideHead()
	self:initArmature()  

	--self:initSpriteFrameState()
end

function GameChair:initSpriteFrameState()
	self.spriteFrameList = {}
	if self:isDiZhu() then
		self.spriteFrameList = {"ddz_renwu_dizhu.png", "ddz_renwu_dizhu_1.png", "ddz_renwu_dizhu_2.png"}
	else
		self.spriteFrameList = {"ddz_renwu_nongming.png", "ddz_renwu_nongming_1.png", "ddz_renwu_nongming_2.png"}
	end

	self.spriteFrameIcon = cc.Sprite:createWithSpriteFrameName(self.spriteFrameList[1])
	self.spriteFrameIcon:setPosition(cc.p(self.player_face:getContentSize().width / 2, self.player_face:getContentSize().height / 2 + 20))
	self.spriteFrameIcon:setVisible(false)
	if self:getCSBName() == "right" then
		self.spriteFrameIcon:setScaleX(-1)
	end

	self.spriteFrameIcon:addTo(self.player_face)
end

function GameChair:changeSpriteFrameState(spriteFrameName)
	if self.spriteFrameIcon then
		self.spriteFrameIcon:setSpriteFrame(spriteFrameName)
	end
end

function GameChair:addBackLiZi()
	local par = cc.ParticleSystemQuad:create("lizi/back_lizi.plist")
    par:setAutoRemoveOnFinish(true)
    par:setPosition(cc.p(0,0))
    self.particle_bg:addChild( par )
end

function GameChair:playBianDa()
	local armature = self.armature_tbl[1]
	armature:setVisible(true)

	if self.spriteFrameIcon then
		self.spriteFrameIcon:setVisible(true)
	end

	if self:isDiZhu() then
		self:playDiZhuEffect()
	end
end

function GameChair:playDiZhuEffect()
	local armature = self.armature_tbl[2]
	armature:setVisible(true)
	armature:getAnimation():play("Animation2", -1,0)
end

function GameChair:playAnimation(name, loop)
	if type( self.armature_tbl ) ~= "table" then return end
	local armature = self.armature_tbl[1]
	armature:getAnimation():play(name, -1,loop or 1)
end

function GameChair:initArmature()

	self.armature_tbl = {}
	local tbl = {"nongmindongzuo"}
	if self:isDiZhu() then 
		--[[if IS_HAPPY_LAND( self.game_atom ) then
			tbl = {"huanledizhudongzuo","zhadan","lord_eff_head"}
		else
			tbl = {"dizhudongzuo","zhadan","lord_eff_head"}
		end--]]

		tbl = {"dizhudongzuo", "lord_eff_head"}
	end
    self.player_face:removeAllChildren()
	for k,v in ipairs( tbl ) do
		self.armature_tbl[k] = self:createArmature(v)
		self.armature_tbl[k]:setPosition(cc.p(self.player_face:getContentSize().width/2, self.player_face:getContentSize().height/2))
		self.armature_tbl[k]:setVisible(false)
		if k == 1 then
			self.armature_tbl[k]:setPositionY(self.player_face:getContentSize().height/2-45)
			if self:getCSBName() == "right" then
				self.armature_tbl[k]:setScaleX(-1)
			end
		end
       
		self.player_face:addChild( self.armature_tbl[k] )
	end

	self.armature_tbl[1]:getAnimation():setMovementEventCallFunc(handler(self,self.aniEventCallBack))
end

function GameChair:createArmature( name )
	local pathDir = "src/app/game/pdk/res/animation/"	
	local arm = ToolKit:createArmatureAnimation( pathDir..name.."/", name )
	return arm
end

function GameChair:aniEventCallBack( armature, movementType, movementID )
	if self.game_end then return end
	if movementType == ccs.MovementEventType.complete then
		if movementID == "bianda" or movementID == "chupai" then
			self:playAnimation("daiji")
		end
	end
end

-----------------------地主农民动画结束-------------------------------

function GameChair:createGameScoreSprite( tag ) 
	local path = "number/lord_num_win.png"
	if tag < 0 then path = "number/lord_num_lost.png" end
	local str =math.abs( self.score_ret )*0.01
	return ccui.TextAtlas:create(  tostring(str), path,30,40,".")
end

function GameChair:setLordPos( pos )
	self.lord_chair = pos
end

function GameChair:setThisClientChair( pos )
	self.client_chair = pos
end

function GameChair:isDiZhu()
	if self.chair == self.lord_chair then return true end
end

function GameChair:getCSBName()
    if self.chair == self.client_chair then return "self" end
    if ( self.chair - self.client_chair == 1 ) or ( self.chair - self.client_chair == -2 ) then return "right" end
    return "left"
end

function GameChair:onTouchCallback( sender )
    local name = sender:getName()
    LogINFO("GameChair: ", name)
end



return GameChair