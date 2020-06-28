local UserCenterHeadIcon   = require("app.hall.userinfo.view.UserHeadIcon")
local CardSprite           = require("src.app.game.pdk.src.landcommon.models.CardSprite")
local LandGlobalDefine = require("app.game.pdk.src.landcommon.data.LandGlobalDefine")
local LandAnimationManager = require("src.app.game.pdk.src.landcommon.animation.LandAnimationManager")
local LandArmatureResource = require("src.app.game.pdk.src.landcommon.animation.LandArmatureResource")


local GameLandBGLayer = class("GameLandBGLayer", function()
    return display.newLayer()
end)

function GameLandBGLayer:ctor(gameID)
	self.game_atom = gameID
	self.diHide = false
    self.m_bIsMoveMenu = false --弹出菜单变量
	self:addBG()
	self:addInfoBG()
	self:initInfoBG()
	self:initSelfInfo()
	self:initCardSprite()
    self:initAnimationManager()
end
function GameLandBGLayer:initAnimationManager()
    self._animationLayer = display.newLayer()
    self._animationLayer:setAnchorPoint(cc.p(0.5,0.5))
    local diffX = 145-(1624-display.size.width)/2 
    self._animationLayer:setPosition(cc.p(display.cx+diffX,display.cy))

    self:addChild(self._animationLayer,6)
    self._animationLayer:setVisible( true )
    self._animationLayer:setLocalZOrder(100)
    self.landAnimationManager = LandAnimationManager.new(self._animationLayer) 
end
function GameLandBGLayer:playWaitAni()
    self.landAnimationManager:PlayAnimation(LandArmatureResource.WAIT_START)
end
function GameLandBGLayer:removeWaitAni()
     self.landAnimationManager:stopAndClearArmatureAnimation(LandArmatureResource.WAIT_START)
end

function GameLandBGLayer:playMatchWaitAni()
    self.landAnimationManager:PlayAnimation(LandArmatureResource.MATCH_WAIT)
end
function GameLandBGLayer:removeMatchWaitAni()
     self.landAnimationManager:stopAndClearArmatureAnimation(LandArmatureResource.MATCH_WAIT)
end
function GameLandBGLayer:addBG()
	local path = "src/app/game/pdk/res/csb/classic_land_cs/game_land_bg.csb"
	if IS_HAPPY_LAND( self.game_atom) then
		path = "src/app/game/pdk/res/csb/classic_land_cs/game_happyland_bg.csb"
	end
	
	local node = UIAdapter:createNode( path )

	local bg = nil
	if IS_HAPPY_LAND( self.game_atom) then
		bg = node:getChildByName("hldz_bg_background")
	else
		bg = node:getChildByName("ddz_bg_background")
	end  
    local center = node:getChildByName("center") 
     local diffY = (display.size.height - 750) / 2
    node:setPosition(cc.p(0,diffY))
     
    local diffX = 145-(1624-display.size.width)/2 
    center:setPositionX(diffX)
    local t = center:getChildByName("Node_6")
--	bg:setTexture("csb/resouces/big_pic/doudizhu_jinjing.jpg")
	self:addChild( node , -1 )
	
	local image_bg = ccui.ImageView:create();
	node:addChild(image_bg);
	image_bg:loadTexture("csb/resouces/big_pic/FJBgRes.png");
	local node_size = node:getContentSize();
	image_bg:setPosition(node_size.width/2, node_size.height/2);
	image_bg:setPosition(display.cx, display.cy);


	--UIAdapter:adapter( node ) 
   UIAdapter:praseNode(node,self) 
    self.BtnPush:setVisible(false) 
    self.Node_pop:setVisible(false)
    self.Node_pop:setLocalZOrder(10000)
    self.BtnExit:addTouchEventListener(handler(self, self.onReturnClicked))
    self.BtnPop:addTouchEventListener(handler(self, self.onPopClicked))
    self.BtnPush:addTouchEventListener(handler(self, self.onPushClicked))
    self.BtnPush2:addTouchEventListener(handler(self, self.onPushClicked)) 
    self.BtnRule:addTouchEventListener(handler(self, self.onRuleClicked))
    self.BtnMusic:addTouchEventListener(handler(self, self.onMusicClicked))
    self.BtnRecord:addTouchEventListener(handler(self, self.onSoundClicked))
end
function GameLandBGLayer:onReturnClicked(sender,eventType)
    if eventType == ccui.TouchEventType.ended then 
			g_GameController:reqUserLeftGameServer()  
    end
end

function GameLandBGLayer:onPopClicked(sender,eventType)
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

function GameLandBGLayer:onPushClicked(sender,eventType)
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
function GameLandBGLayer:onRuleClicked(sender,eventType)
     if eventType == ccui.TouchEventType.ended then
          self:getParent():showRuleLayer() 
    end
end

function GameLandBGLayer:addInfoBG()
	local path = "src/app/game/pdk/res/csb/classic_land_cs/game_self_bg.csb"
	self.root = UIAdapter:createNode( path )
	self:addChild( self.root )
	UIAdapter:adapter( self.root , handler(self, self.onTouchCallback) ) 
end

function GameLandBGLayer:initInfoBG()
	self:initMyHead()
	self:initTopPanel()
	self:initMiddleUI()
	self:initBottomPanel()
end

function GameLandBGLayer:initSelfInfo()
	local name = Player:getNickName()
	local gold = Player:getGoldCoin()
	self:setMyNickNameUI( name )
	self:showMyHead()

	local _head_bg_size = self.lord_btn_circle:getContentSize()
	self.nick_name_label:setFontName("app/game/pdk/res/csb/resources/font/jcy.TTF")
    self.nick_name_label:setFontSize(25)
    self.nick_name_label:setAnchorPoint(cc.p(0.5, 0.5))
    self.nick_name_label:setPosition(cc.p(97, 115))
end
----------中间牌友房信息--------
function GameLandBGLayer:initMiddleUI()
	self.friend_room_label = self.root:getChildByName("friend_room_info")
	self.friend_room_label:setVisible(false)
end

function GameLandBGLayer:setFriendRoomLabel( str )
	self.friend_room_label:setVisible(true)
	self.friend_room_label:setString( str )
end
----------底部面板开始----------
function GameLandBGLayer:initMyHead()
	--self.lord_btn_head = self.root:getChildByName("lord_bg_head")
	self.lord_btn_circle = self.root:getChildByName("lord_btn_circle")
	self.lord_bg_head    = self.root:getChildByName("lord_bg_head")
--	self.lord_bg_head:setVisible(true)
	local _head_bg_size = self.lord_btn_circle:getContentSize()
	self.imgHead = UserCenterHeadIcon.new({_size =_head_bg_size ,_clip = false })
	--self.imgHead:setScale(0.8)
	self.imgHead:setAnchorPoint(cc.p(0.5,0.5))
	self.imgHead:setPosition(self.lord_btn_circle:getPosition())
	--self.imgHead:setLocalZOrder(-1)
	--self.lord_bg_head:addChild( self.imgHead )
	self.imgHead:updateTexture( Player:getFaceID() , Player:getAccountID() )
      self.lord_bg_head:setVisible(false)
    self.lord_btn_head = display.newNode()
    self.lord_btn_head:setAnchorPoint(0.5,0.5)
    self.lord_btn_head:setPosition(self.lord_bg_head:getPositionX()-50,self.lord_bg_head:getPositionY()-50)

    self.lord_btn_head:addChild( self.imgHead )
    self.root:addChild( self.lord_btn_head )
end

function GameLandBGLayer:initBottomPanel()
	self.bottom_panel      = self.root:getChildByName("bg_user")
	self.nick_name_label   = self.bottom_panel:getChildByName("bg_user_nam")
	
	--self.text_round        = self.bottom_panel:getChildByName("text_round")
	self.text_rank         = self.bottom_panel:getChildByName("text_rank")
	self.text_match_info   = self.bottom_panel:getChildByName("text_match_info")

	self:initClock()
end

function GameLandBGLayer:initClock()
	self.bottom_clock = self.bottom_panel:getChildByName("clock_node")
	local size = self.bottom_clock:getContentSize()
	local alabel = cc.LabelAtlas:_create("", "number/lord_num_time.png",14,22,48)
	alabel:setAnchorPoint(0,0.5)
	alabel:setPosition(cc.p(0,size.height/2))
	self.bottom_clock:addChild( alabel )
	self.bottom_clock:setVisible(true)
	function updateClock()
		local str = os.date("%H:%M",os.time())
		alabel:setString( str )
	end
	local a1 = cc.CallFunc:create( updateClock )
    local a2 = cc.DelayTime:create(1)
    self.bottom_clock:runAction(cc.RepeatForever:create(cc.Sequence:create(a1,a2)))
end

function GameLandBGLayer:hideTimeLabel()
	self.bottom_clock:setVisible(false)
end


function GameLandBGLayer:setRankLabel( _str )
    self.text_rank:setVisible( true )
    self.text_rank:setString( _str )
	self:updateLablePos()
end

function GameLandBGLayer:setMatchInfoLabel( _str )
    self.text_match_info:setVisible( true )
    self.text_match_info:setString( _str )
    self:updateLablePos()
end

function GameLandBGLayer:updateLablePos()
	-- local grap = 30
	-- local mLw = self.text_match_info:getContentSize().width
	-- local ocx = self.bottom_clock:getPositionX()

	-- self.text_match_info:setPositionX(ocx - grap)
	-- self.text_rank:setPositionX(ocx - grap - mLw - grap)

	local wid = self.text_rank:getContentSize().width
	local x = self.text_rank:getPositionX()
	self.text_match_info:setPositionX(x+wid+25)

end

function GameLandBGLayer:setMyNickNameUI( str )
	self.nick_name_label:setString( str )
end

function GameLandBGLayer:showMyHead()
	self.lord_btn_head:setVisible(true)
	self.imgHead:setVisible( true )
	self.lord_btn_circle:setVisible( true )
	self.lord_btn_head:setVisible(true)
end

function GameLandBGLayer:hideMyHead()
	if self.imgHead then
		self.imgHead:setVisible( false )
	end
	self.lord_btn_circle:setVisible( false )
	self.lord_btn_head:setVisible(false)
end

-- 牌精灵
function GameLandBGLayer:initCardSprite()
    self.m_cardSprite = CardSprite.new(601)
end
----------底部面板结束----------

----------顶部面板开始----------
function GameLandBGLayer:initTopPanel()
	self.top_panel      = self.root:getChildByName("top_info_panel")
	self.top_panel:setVisible(false)
	self.top_card_panel = self.top_panel:getChildByName("card_panel")
	self.top_poker       = {}
	self.top_bg_pos      = {}
	self.bottom_bg_pos   = {}
	
	for i=1,3 do
		self.top_poker[i]      = self.top_panel:getChildByName("top_poker_"..i)
		self.top_bg_pos[i]     = cc.p( self.top_card_panel:getChildByName("top_bg_"..i):getPosition() )
		self.bottom_bg_pos[i]  = cc.p( self.top_card_panel:getChildByName("bottom_bg_"..i):getPosition() )
	end

	self.bg_layout_topbg = self.top_panel:getChildByName("bg_layout_topbg")

	-- 欢乐跑得快底牌版型显示
	self.top_card_type_panel = self.top_panel:getChildByName("top_card_type_panel")
	self.top_card_type_panel:setVisible(false)
	self.card_type_panel = self.top_panel:getChildByName("card_type_panel")
	self.card_type_panel:setVisible(false)

	self.top_state_panel = self.top_panel:getChildByName("state_panel")

	--[[self.top_state_panel_posx = self.top_state_panel:getPositionX()
	self.top_state_panel_posx_for_moveto = self.top_state_panel_posx + 120
	if IS_FREE_ROOM( self.game_atom ) then
		self.top_state_panel_posx_for_moveto = self.top_state_panel_posx + 180
	end--]]

	self.cent_panel = self.top_state_panel:getChildByName("cent_panel")
	self.cent_panel:setVisible(g_GameController:isMatchGame() == false);
	self.cent_panel_posx = self.cent_panel:getPositionX()
	self.cent_panel_posy = self.cent_panel:getPositionY()
	
	self.label_room_name  = self.top_state_panel:getChildByName("text_title")
	self.label_room_name:setString("")
	self.startcent_name   = self.top_state_panel:getChildByName("startcent_name")

	self.label_start_cent = self.top_state_panel:getChildByName("startcent_value")
    self.label_start_cent:setString("")
	self.label_start_cent:enableOutline(cc.c4b(65, 27, 23, 255), 2)

	--self.label_start_cent:setString("")

	--[[if self.bPoint == nil then
		self.bPoint = ccui.TextAtlas:create("0", "ddz_shuzi_2.png", 21, 27, "0")
		self.bPoint:setAnchorPoint(cc.p(0, 0.5))
		self.bPoint:addTo(self.label_start_cent)
	else
		self.bPoint:setString("0")
	end--]]

	
	self.double_name      = self.top_state_panel:getChildByName("double_name")
	self.label_double     = self.top_state_panel:getChildByName("double_value")
    self.label_double:setString("")
	self.label_double:enableOutline(cc.c4b(65, 27, 23, 255), 2)

	--[[self.label_double:setString("")

	if self.dPoint == nil then
		self.dPoint = ccui.TextAtlas:create("0", "ddz_shuzi_2.png", 21, 27, "0")
		self.dPoint:setAnchorPoint(cc.p(0, 0.5))
		self.dPoint:addTo(self.label_double)
	else
		self.dPoint:setString("0")
	end--]]

	self:resetTopPanel()

	-- 去掉三张牌显示
	self.top_card_panel:setVisible(false)
  	for i=1,3 do
    	self.top_poker[i]:setOpacity(0)
  	end
  	-- 文字内容
 	-- self.top_panel:setPositionY(100)
 	self.game_room_name = ccui.ImageView:create("")
    self.game_room_name:loadTexture("fj_game_room_name.png", 1)
 	self.game_room_name:setPosition(display.cx, display.cy)
 	self.top_state_panel:addChild(self.game_room_name)
 	self.startcent_name:setFontSize(40)
 	self.startcent_name:setString("")
--	self.startcent_name:setColor( cc.c3b(0x90, 0x90, 0x90) )
	self.label_start_cent:setOpacity(0)
	self.double_name:setOpacity(0)
	self.label_double:setOpacity(0)
	-- 色彩處理
	local addGrayNode = function (node)  
    	--变灰的  
    	local pProgram = cc.GLProgram:createWithByteArrays(self.vertDefaultSource,self.psGrayShader)  
    	pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)  
    	pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)  
    	pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)  
  
    	pProgram:link()  
    	pProgram:use()  
    	pProgram:updateUniforms()  
    	node:setGLProgram(pProgram)  
	end
end

function GameLandBGLayer:resetTopPanel()
	self:setTopPanelVisible(true)
	for k,v in pairs( self.top_poker ) do
		v:setVisible(false)
		local point = v:getChildByName("lord_icon_greencircle")
		point:setVisible(false)
	end
	self.bg_layout_topbg:setVisible(false)

	self.diHide = false
	self.top_card_panel:removeAllChildren()
	--self.top_state_panel:setPositionX( self.top_state_panel_posx )
	self:updateDoubleUI(1)
end

function GameLandBGLayer:setTopPanelVisible(isVisible)
	self.top_panel:setVisible(isVisible)
end

function GameLandBGLayer:setTopTypePanelVisible(isVisible)
	self.top_card_type_panel:setVisible(isVisible)
end

function GameLandBGLayer:setBgHeadVisible(isVisible)
	self.lord_btn_head:setVisible(isVisible)
end

function GameLandBGLayer:setRoomInfo( atomID , roomID )
	self.top_panel:setVisible(true)
	local roomName = ""
	if roomID then
		self:hideStartCent()
		roomName = "房号: "..roomID
	else
		--[[local data  = RoomData:getRoomDataById( atomID )
		roomName = data.phoneGameName]]--
	end
	self:updateRoomNameUI( roomName )
	self:updateStartCentUI(0)
	self:updateDoubleUI(1)
end

function GameLandBGLayer:hideStartCent()
	self.startcent_name:setVisible( false )
	self.label_start_cent:setVisible( false )
	--self:updateCentPanelPosX()
	self.cent_panel:setPositionX(-46)
end

function GameLandBGLayer:hideDoubleLabel()
	self.double_name:setVisible(false)
	self.label_double:setVisible(false)
end

function GameLandBGLayer:setBottomPoker( backCardValues )
	--重连进来或者退出进入
	self.bg_layout_topbg:setVisible(true)
	for i=1,3 do
		self.top_poker[i]:setVisible(true)
		self.top_poker[i]:setSpriteFrame(self.m_cardSprite:createSmallCard(backCardValues[i],true))
	end
end

function GameLandBGLayer:updateRoomNameUI( str )
	if IS_FREE_ROOM( self.game_atom ) then
		self.label_room_name:setVisible( false )
		return
	end
	local str_tbl = string.split(str, "（")
	self.label_room_name:setString( str_tbl[1] )
end

function GameLandBGLayer:updateStartCentUI( str )
	self.label_start_cent:setString( str )
	self.label_start_cent:setVisible(true)
	if not str or str == "" then 
		self.startcent_name:setString("")
	else
		self.startcent_name:setString( "底分：" .. str )
	end

	--self.bPoint:setString(str)
	if IS_FREE_ROOM( self.game_atom ) then
		--self:updateCentFontSize()
	end
	--self:updateCentPanelPosX()
end

function GameLandBGLayer:updateDoubleUI( _num )
	local num = math.max(1,_num)
	self.label_double:setString( num )
	--self.dPoint:setString(num)
	if IS_FREE_ROOM( self.game_atom ) then
		--self:updateCentFontSize()
	end
	--self:updateCentPanelPosX()
end

--[[function GameLandBGLayer:updateCentFontSize()
	local fontSize = 32
	self.startcent_name:setFontSize(fontSize)
	self.label_start_cent:setFontSize(fontSize)
	self.double_name:setFontSize(fontSize)
	self.label_double:setFontSize(fontSize)
	self.cent_panel:setPositionY( self.cent_panel_posy + 4 )
end--]]

--[[function GameLandBGLayer:updateCentPanelPosX()
	local gap = 10
	local labelCentX = self.startcent_name:getContentSize().width + gap
	self.label_start_cent:setPositionX( labelCentX )
	
	local dx = labelCentX + self.label_start_cent:getContentSize().width + gap
	if not self.startcent_name:isVisible() then
		dx = 0
	end
	local ldx = dx + self.double_name:getContentSize().width + gap
	self.double_name:setPositionX( dx )
	self.label_double:setPositionX( ldx )

	local totalWidth = ldx + self.label_double:getContentSize().width
	if IS_FREE_ROOM( self.game_atom ) and self.top_poker and self.top_poker[1] and self.top_poker[1]:isVisible() == true then
		self.cent_panel:setPositionX(0)
	else
		self.cent_panel:setPositionX( self.cent_panel_posx - totalWidth/2 )
	end
end--]]

function GameLandBGLayer:addBackFrontCard( i , cardVal )
	local scale = 0.60
	local backCard = display.newSprite("#lord_poker_back.png")
	backCard:setScale(scale)
	backCard:setPosition( self.bottom_bg_pos[i] )
	self.top_card_panel:addChild( backCard )

	local frontCard = self.m_cardSprite:createCard( cardVal , scale)
	if frontCard then
		frontCard:setPosition( self.bottom_bg_pos[i] )
		self.top_card_panel:addChild( frontCard )
		frontCard:setVisible(false)
	end

	return backCard,frontCard
end

--底牌翻转动作
function GameLandBGLayer:createBottomCardAction( i , cardVal , frontCard )
	local rollSec   = 0.2
	local moveSec   = 0.2
	local function moveWithScale()
		frontCard:runAction( cc.MoveTo:create(moveSec, self.top_bg_pos[i]) )
		frontCard:runAction( cc.ScaleTo:create(moveSec, 0.33) )
		
		if IS_HAPPY_LAND( self.game_atom ) then
			self.card_type_panel:setVisible(false)
		end
	end

	local function moveDone()
		frontCard:setVisible(false)
		self.bg_layout_topbg:setVisible(true)
		self.top_poker[i]:setVisible(true)
		self.top_poker[i]:setSpriteFrame(self.m_cardSprite:createSmallCard(cardVal,true))
		if IS_HAPPY_LAND( self.game_atom ) then
			if self.diHide == true then
				self.top_card_type_panel:setVisible(false)
			else
				self.top_card_type_panel:setVisible(true)
			end
			
		end
		if i==3 then
			--self.top_state_panel:runAction(cc.MoveTo:create(moveSec, cc.p(self.top_state_panel_posx_for_moveto, self.top_state_panel:getPositionY())))
			--self:updateCentPanelPosX()
		end
	end

	local frontCardAC = {}
	frontCardAC[1] = cc.Show:create()
	frontCardAC[2] = cc.OrbitCamera:create(rollSec,1,0,90,-90,0,0)
	local delayT = 1.5
	if self.card_type_panel:isVisible() == false then
		delayT = 0
	end
	frontCardAC[3] = D(delayT)
	frontCardAC[4] = cc.CallFunc:create( moveWithScale )

	--牌翻转完毕
	frontCardAC[5] = D(moveSec)
	frontCardAC[6] = cc.CallFunc:create( moveDone )
	
	
	local ac = {}
	ac[1] = cc.OrbitCamera:create(rollSec,1,0,0,-90,0,0)
	ac[2] = cc.Hide:create()
	ac[3] = cc.TargetedAction:create( frontCard , cc.Sequence:create( frontCardAC ) )
	local seq = cc.Sequence:create( ac )
	return seq
end

function GameLandBGLayer:rollOverOneCard( i , cardVal)
	local backCard , frontCard = self:addBackFrontCard( i , cardVal)
	backCard:runAction( self:createBottomCardAction( i ,cardVal , frontCard ))
end

function GameLandBGLayer:TurnOverCard( backCardValues , bottomMul , m_GameLogic)
	self.top_card_panel:removeAllChildren()
	self:updateCardType(backCardValues, bottomMul, m_GameLogic)
	for i=1,3 do
		self:rollOverOneCard(i,backCardValues[i])
	end
end

function GameLandBGLayer:showBackCard()
	self.top_card_panel:removeAllChildren()
	for i=1,3 do
		self:addBackFrontCard( i )
	end
end

function GameLandBGLayer:restoreHappyBottomCard( backCardValues , bottomMul , m_GameLogic )
	self:setBottomPoker( backCardValues )
	--self.top_state_panel:setPositionX( self.top_state_panel_posx_for_moveto )
	local  img_str = self:getBackCardTypeImgStr( backCardValues , m_GameLogic )
	self:showTopCardType( bottomMul , img_str )
end

function GameLandBGLayer:showTopCardType( bottomMul , img_str )
	if not img_str or not bottomMul or bottomMul < 1 then return end
	self.top_card_type_panel:setVisible(true)
	local top_imp_type = self.top_card_type_panel:getChildByName("hldz_img_type_tonghuashun")
	top_imp_type:setSpriteFrame(display.newSpriteFrame(img_str))
	local text_num =  self.top_card_type_panel:getChildByName("text_num")
	text_num:setString(bottomMul.."倍")
end

function GameLandBGLayer:updateGreenPoint( outCard , bottom )
	if type( outCard ) ~= "table" or type( bottom ) ~= "table" then return end
	local ret = {}
	local tbl = EXCHANGE_KEY_VAL( bottom )
	for k,v in pairs( outCard ) do
		if tbl[v] then
			table.insert( ret , tbl[v] )
		end
	end
	for i,v in ipairs( ret ) do
		local point = self.top_poker[v]:getChildByName("lord_icon_greencircle")
		point:setVisible(true)
	end
end

----------顶部面板结束----------



-- 欢乐跑得快底牌 判定展示 

function GameLandBGLayer:getBackCardTypeImgStr( backCardValues , m_GameLogic )
	local img_str = nil
	local card_type = m_GameLogic:GetBackCardType( backCardValues )
	if  card_type == LandGlobalDefine.BCT_DOUBLE_KING then  -- 王炸
		img_str = "hldz_img_type_shuangwang.png"
	elseif card_type == LandGlobalDefine.BCT_THREE then -- 三条
		img_str = "hldz_img_type_santiao.png"
	elseif card_type == LandGlobalDefine.BCT_DOUBLE then -- 一对
		img_str = "hldz_img_type_duizi.png"
	elseif card_type == LandGlobalDefine.BCT_SINGLE_LINE_SAME_COLOR then -- 同花顺
		img_str = "hldz_img_type_tonghuashun.png"
	elseif card_type == LandGlobalDefine.BCT_SAME_COLOR then -- 同花
		img_str = "hldz_img_type_tonghua.png"
	elseif card_type == LandGlobalDefine.BCT_SINGLE_LINE then -- 顺子
		img_str = "hldz_img_type_shunzi.png"
	end
	return img_str
end

function GameLandBGLayer:updateCardType(backCardValues, bottomMul, m_GameLogic)
	if not IS_HAPPY_LAND( self.game_atom ) then
		self.top_card_type_panel:setVisible(false)
		self.card_type_panel:setVisible(false)
		return
	end

	if bottomMul == 0 then
		self.diHide = true
		self.top_card_type_panel:setVisible(false)
		self.card_type_panel:setVisible(false)
		return
	end

	self.top_card_type_panel:setVisible(false)
	self.card_type_panel:setVisible(true)

	local img_type = self.card_type_panel:getChildByName("img_type")
	local textNum = self.card_type_panel:getChildByName("text_num")
	textNum:setVisible(false)
	local numPos = cc.p(textNum:getPosition())

	local top_imp_type = self.top_card_type_panel:getChildByName("hldz_img_type_tonghuashun")
	local text_num =  self.top_card_type_panel:getChildByName("text_num")
	text_num:setString((bottomMul or 1).."倍")
	
	local cloneCardTbl = {}
	for k,v in pairs(backCardValues) do
		cloneCardTbl[k] = v
	end


	local  img_str = self:getBackCardTypeImgStr( cloneCardTbl , m_GameLogic )
	if  not img_str then
		self.diHide = true
		self.top_card_type_panel:setVisible(false)
		self.card_type_panel:setVisible(false)
	else
		--self.top_card_type_panel:setVisible(true)
		self.card_type_panel:setVisible(true)

		img_type:setSpriteFrame(display.newSpriteFrame(img_str))
		top_imp_type:setSpriteFrame(display.newSpriteFrame(img_str))

		if self.card_type_panel:getChildByName("NumLabel") then
			self.card_type_panel:removeChildByName("NumLabel")
		end
		local label = cc.LabelAtlas:_create("", "number/hldz_num_beishu.png",30,38,48)
		label:setString( bottomMul )
		label:setName("NumLabel")
		label:setAnchorPoint(cc.p(0.5,0.5))
		label:setPosition(numPos)
		self.card_type_panel:addChild( label )
	end
end

function GameLandBGLayer:onTouchCallback( sender )
    local name = sender:getName()
    LogINFO("GameLandBGLayer: ", name)
end

return GameLandBGLayer