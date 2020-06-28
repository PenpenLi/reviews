--
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 超快赛比赛报名对话框
local scheduler = require("framework.scheduler")
local StackLayer = require("app.hall.base.ui.StackLayer")

local FastRoomController    =  require("src.app.game.pdk.src.classicland.contorller.FastRoomController")
local MatchSignUpController =  require("src.app.game.pdk.src.classicland.contorller.MatchSignUpController")
local DDSRoomController =  require("src.app.game.pdk.src.classicland.contorller.DingDianSaiRoomController")
local EventManager = require("app.game.pdk.src.common.EventManager")
local GlobalItemInfoMgr = GlobalItemInfoMgr or require("app.hall.bag.model.GoodsData").new()
local SignUpGameNewDialog = class("SignUpGameNewDialog", function ()
	return display.newLayer() 
end)


function SignUpGameNewDialog:ctor( _atomID )
	self.gameAtomID = _atomID
	self.mRoomData  = RoomData:getRoomDataById( self.gameAtomID )
	self.mButtonType = 0
	self:initOptionData()
	self:initUI()

	LAND_LOAD_OPEN_EFFECT(self.layout_bg)

	ToolKit:registDistructor( self, handler(self, self.onDestory) )
end

function SignUpGameNewDialog:onDestory()
	LogINFO("跑得快报名页面被摧毁")
	FastRoomController:getInstance():reqMatchCloseSignupPage()
end

function SignUpGameNewDialog:initUI()
	local function closeCallback()
		self:onClose()
	end

	local size = cc.Director:getInstance():getWinSize()
	local item = cc.MenuItemImage:create()
	item:setContentSize(cc.size(size.width, size.height))
	item:registerScriptTapHandler(closeCallback)
	self.backMenu = cc.Menu:create(item)
	self:addChild(self.backMenu)

  
	local path = "src/app/game/pdk/res/csb/land_match_cs/land_match_joinin.csb"
	self.node = cc.CSLoader:createNode(path)
	UIAdapter:adapter( self.node , handler(self, self.onTouchCallback) )
	self:addChild( self.node )

	self.layout_bg = self.node:getChildByName("layout_bg")

	self.close_btn = self.node:getChildByName("btn_close")
	self.close_btn:addTouchEventListener( handler(self,self.onClickCloseBtn ) )

	self.layout_close = self.node:getChildByName("layout_close")
	self.layout_close:addTouchEventListener(handler(self, self.onClickCloseBtn))

	self.baoming_btn = self.node:getChildByName("Button_baoming")
	self.baoming_btn:addTouchEventListener( handler(self,self.onClickBaoMingBtn ) )

	self.tuisai_btn = self.node:getChildByName("Button_tuisai")
	self.tuisai_btn:addTouchEventListener( handler(self,self.onClickTuiSaitn ) )
	self.tuisai_btn:setVisible(false)
	
	self.text_title = self.node:getChildByName("text_title_0")
	self.text_title:setString(self.mRoomData.phoneGameName)

	self.t_bg = self.node:getChildByName("t_bg")

	local width = self.text_title:getContentSize().width + 80 > 380 and self.text_title:getContentSize().width + 80 or 380

	self.t_bg:setContentSize(cc.size(width, 48))

	for i=1,3 do
		self["panel_button"..i] = self.node:getChildByName("panel_button_"..i)
		self["panel_button"..i]:setTag(100+i)
	end
	self:initCurInfoLabel()
	self:updatePanelClick()
end

function SignUpGameNewDialog:initCurInfoLabel()
	self.open_info_label = self.node:getChildByName("open_time")
	self.cur_info_label  = self.node:getChildByName("text_tip_3")
	self:showBaoMingNum()
	self:updateOpenLabel()
end

function SignUpGameNewDialog:updateOpenLabel()
	if IS_DING_DIAN_SAI( self.gameAtomID ) then
		local str = "开赛时间: "..DDSRoomController:getInstance():getDDSOpenTimeStr( self.gameAtomID )
		self.open_info_label:setString( str )
	else
		self.open_info_label:setString( self.mRoomData.roomLeftDownTips )
	end
end

function SignUpGameNewDialog:getBaoMingNum()
	local ret = FastRoomController:getInstance():getFastGameCnt( self.gameAtomID )
	if IS_DING_DIAN_SAI( self.gameAtomID ) then
		ret = DDSRoomController:getInstance():getDDSPeopleCnt( self.gameAtomID )
	end
	return ret
end
function SignUpGameNewDialog:showBaoMingNum()
	self.cur_info_label:stopAllActions()
	local candidates = self:getBaoMingNum()
	self:setBaoMingLabel( candidates )  
end

function SignUpGameNewDialog:updateBaoMingNum()
	local num = self:getBaoMingNum()
	self:setBaoMingLabel( num+1 )
end

function SignUpGameNewDialog:setBaoMingLabel( candidates )
	self.cur_info_label:setVisible(false)
	self.cur_info_label:setString("已报名: "..candidates.."人")
end

function SignUpGameNewDialog:showCountDownTimer()
	if not IS_DING_DIAN_SAI( self.gameAtomID ) then return end
	self.cur_info_label:setVisible(true)
	self.cur_info_label:setString( self:getCountDownStr() )
	local function updateCountDownLabel()
		self.cur_info_label:setString( self:getCountDownStr() )
	end
	self:startCountDown( updateCountDownLabel )
end

function SignUpGameNewDialog:startCountDown( exeFun )
	self.cur_info_label:stopAllActions()
	if not IS_DING_DIAN_SAI( self.gameAtomID ) then return end
	local a1 = cc.CallFunc:create( exeFun )
	local a2 = cc.DelayTime:create(1)
	self.cur_info_label:runAction(cc.RepeatForever:create(cc.Sequence:create(a1,a2)))
end

function SignUpGameNewDialog:getCountDownStr()
	local sec    = math.max(0,DDSRoomController:getInstance():getCountDown( self.gameAtomID ))
	local hour   = string.format("%02d",math.floor(sec/3600))
	local min    = string.format("%02d",math.floor((sec - hour*3600)/60))
	local second = string.format("%02d",sec - hour*3600 - min*60)
	return hour..":"..min..":"..second
end

function SignUpGameNewDialog:updatePanelClick()

	if #self.option_data == 0 then
		self.node:getChildByName("text_name"):setString("免费")
	else
		self.node:getChildByName("text_name"):setString(self.option_data[1].num .. self.option_data[1].itemName)
	end
end

function SignUpGameNewDialog:onClickCloseBtn( sender, eventType )
	if eventType == ccui.TouchEventType.ended then
		self:onClose()
	end
end

function SignUpGameNewDialog:onClose()
	LogINFO("点击了报名页关闭按钮")
	DOHALL_CENTER("removeDialog")
end

function SignUpGameNewDialog:onClickBaoMingBtn( sender, eventType )
	if eventType ~= ccui.TouchEventType.ended then return end
	if not self.last_click_baoming_btn_time then self.last_click_baoming_btn_time = 0 end
	if os.time() - self.last_click_baoming_btn_time < 3 then return end
	self.last_click_baoming_btn_time = os.time()	
	LogINFO("点击了报名按钮 报名选项",self.mButtonType)
	MatchSignUpController:getInstance():reqSignUp( self.gameAtomID , self.mButtonType )
end

function SignUpGameNewDialog:onClickTuiSaitn( sender, eventType )
	if eventType == ccui.TouchEventType.ended then
		LogINFO("点击了 退赛按钮")
		self.tuisai_btn:setTouchEnabled(false)
		local function hideSetPanel()
			self.tuisai_btn:setTouchEnabled(true)
		end
		self.tuisai_btn:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(hideSetPanel)))
		MatchSignUpController:getInstance():reqCancelSignUp( self.gameAtomID , self.gameAtomID )
	end
end

function SignUpGameNewDialog:showSignUpTips(tag)
	local path = "src.app.game.pdk.src.landcommon.view.match.SignUpTips"
	local SignUpTips = RequireEX( path )
	if self.mSignUpTips then
		self:removeChild( self.mSignUpTips )
		self.mSignUpTips = nil
	end
	self.mSignUpTips = SignUpTips.new(tag , self.gameAtomID)
	local cb = function ()
		if self.close_btn then
			self.close_btn:setVisible(true)
		end
	end
	if self.close_btn then
		self.close_btn:setVisible(false)
	end
	self.mSignUpTips:setCallBack(cb)
	self:addChild( self.mSignUpTips )
end
function SignUpGameNewDialog:showBaoMingBtn()
	if self.baoming_btn then
		self.baoming_btn:setVisible(true)
		self.baoming_btn:setTouchEnabled(true)
	end
	if self.tuisai_btn then
		self.tuisai_btn:setVisible(false)
		self.tuisai_btn:setTouchEnabled(false)
	end
	self.last_click_baoming_btn_time = 0
end

function SignUpGameNewDialog:showTuiSaiBtn()
	if self.baoming_btn then
		self.baoming_btn:setVisible(false)
	end
	if self.tuisai_btn then
		self.tuisai_btn:setVisible(true)
		self.tuisai_btn:setTouchEnabled(true)
	end
	
end

function SignUpGameNewDialog:removeUI(name, ...)
	if self then self:removeFromParent() end
end

function SignUpGameNewDialog:initOptionData()
	self.option_data = {}
	if self.mRoomData.conditionType == 1 then return end
	local names = {"物品","金币","钻石"}
	for i=1,3 do
		local jsonSTR = self.mRoomData["condition"..i]
		local tbl = require("cjson").decode( jsonSTR )
		if tbl and type(tbl[1]) == "table" then
			local info = tbl[1]
			local itemName = names[ info.type ]
			if info.itemId then
				local item = GlobalItemInfoMgr:getItemInfoByID( info.itemId )
				itemName = item:getName()
			end
			info.itemName = itemName
			self.option_data[i] = info
		end
	end
end

function SignUpGameNewDialog:onTouchCallback( sender )
	local name = sender:getName()
	local tag = sender:getTag()
	LogINFO("SignUpGameNewDialog name: ", name)
	if name =="panel_button_1" then
		self:showSignUpTips(tag)
	elseif name =="panel_button_2" then
		self:showSignUpTips(tag)
	elseif name =="panel_button_3" then
		TOAST("敬请期待")
	end
end

return SignUpGameNewDialog
