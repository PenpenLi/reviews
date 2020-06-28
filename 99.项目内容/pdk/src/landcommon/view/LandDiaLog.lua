-- LandDiaLog
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 跑得快弹窗
local XbDialog        = require("app.hall.base.ui.CommonView")
local LandGlobalDefine = require("app.game.pdk.src.landcommon.data.LandGlobalDefine")
local LandDiaLog = class("LandDiaLog", function()
    return XbDialog.new()
end)


function LandDiaLog:ctor()
	self:initCSB()
	self:initButton()
	self:showDialog()
end

function LandDiaLog:initCSB()
	self.root = UIAdapter:createNode("src/app/game/pdk/res/csb/land_common_cs/land_dialog.csb")
	UIAdapter:adapter(self.root, handler(self, self.onTouchCallback))
    self:addChild(self.root)
end

function LandDiaLog:initButton()
	self.btnYes   = self.root:getChildByName("btn_yes")
	self.btnNo    = self.root:getChildByName("btn_no")
	self.btnMid   = self.root:getChildByName("btn_yes_middle")
	self.btnYes:enableOutline({r = 72, g = 137, b = 32, a = 255}, 3)
	self.btnNo:enableOutline({r = 183, g = 42, b = 42, a = 255}, 3)

	self.btnMidLabel = self.root:getChildByName("btn_yes_label")
	self.btnMidLabel:enableOutline({r = 72, g = 137, b = 32, a = 255}, 3)
end

function LandDiaLog:hideCloseBtn()
	local btn = self.root:getChildByName("btn_close")
	btn:setVisible(false)
	self:forbidClickBG()
end

function LandDiaLog:forbidClickBG()
	self.forbid_click_bg = true
end

function LandDiaLog:onClickCloseBtn()
	if self.closeBtnFun then
		self.closeBtnFun()
	else
		self:closeDialog()
	end
end

function LandDiaLog:onClickBG()
	if self.forbid_click_bg then return end
	self:onClickCloseBtn()
end

function LandDiaLog:showYesBtn( _str , callBack )
	self.btnYes:setVisible(true)
	local str = _str or "是"
	self.btnYes:setTitleText( str )
	local function onClick( sender , eventType )
		if eventType ~= ccui.TouchEventType.ended then return end
		if callBack then
			callBack()
		end
	end
	self.btnYes:addTouchEventListener( onClick )
end

function LandDiaLog:showNoBtn( _str , callBack )
	self.btnNo:setVisible(true)
	local str = _str or "否"
	self.btnNo:setTitleText( str )
	local function onClick( sender , eventType )
		if eventType ~= ccui.TouchEventType.ended then return end
		if callBack then
			callBack()
		end
	end
	self.btnNo:addTouchEventListener( onClick )
end

function LandDiaLog:showSingleBtn( _str , callBack )
	self.btnMid:setVisible(true)
	self.btnMidLabel:setVisible(true)
	local str = _str or "确定"
	self.btnMidLabel:setString( str )
	if #str > 20 then
		self.btnMid:setScaleX(1.5)
	end
	local function onClick( sender , eventType )
		if eventType ~= ccui.TouchEventType.ended then return end
		if callBack then
			callBack()
		else
			self:closeDialog()
		end
	end
	self.btnMid:addTouchEventListener( onClick )
end

function LandDiaLog:setCloseBtnFun( callBack )
	self.closeBtnFun = callBack
end

function LandDiaLog:setTitle( str )
	local label = self.root:getChildByName("text_title")
	label:setString( str )
end

function LandDiaLog:setContent( str , _fontSize )
	local bg = self.root:getChildByName("bg")
	local size = bg:getContentSize()
	local params = {tip = str,fontSize = _fontSize or 30}
	local label = self:createLabel( params )
	label:setPosition(size.width/2,size.height/2+30)

	bg:removeAllChildren()
	bg:addChild( label )
end


function LandDiaLog:createLabel( param )
	local label = display.newTTFLabel({
        text = param.tip or "",
        font = "ttf/jcy.TTF",
        size = param.fontSize or 30,
        color = cc.c3b(68, 99, 154),
        align = cc.ui.TEXT_ALIGN_CENTER , 
        valign = cc.ui.TEXT_VALIGN_CENTER  , 
        dimensions = param.areaSize or cc.size(540, 128),  
    })
    return label
end


function LandDiaLog:onTouchCallback( sender )
    local name = sender:getName()
    LogINFO("点击了 LandDiaLog: ", name)
    if name == "layout" then
    	self:onClickBG()
    elseif name == "btn_close" then
    	self:onClickCloseBtn()
    end
end

return LandDiaLog