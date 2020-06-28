

-- ExitGameLayer
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 离开界面
local LandGlobalDefine = require("app.game.pdk.src.landcommon.data.LandGlobalDefine") 

local ExitGameLayer = class("ExitGameLayer", function()
    return display.newLayer()
end)

function ExitGameLayer:ctor( landMainScene , gameAtom )
    self.game_atom = gameAtom
    self.room_name = ""
    self.m_landMainScene = landMainScene
    self:init()
    --LAND_LOAD_OPEN_EFFECT(self.exitgameDialogpanel)
end

function ExitGameLayer:init()
	
    local size = cc.Director:getInstance():getWinSize(); 

	local function closeCallback()
        self:setVisible(false)
    end
	
    local item = cc.MenuItemImage:create()
    item:setContentSize(cc.size(size.width, size.height))
    item:registerScriptTapHandler(closeCallback)
    local menu = cc.Menu:create(item)
    self:addChild(menu)

    local myNode = cc.CSLoader:createNode("land_common_cs/land_set_exitgame.csb")
    UIAdapter:adapter(myNode, handler(self, self.onTouchCallback))
    self:addChild(myNode)

    local function onTouchButton(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            if not self.last_click then self.last_click = 0 end
            if os.time() - self.last_click < 1 then return end
            self.last_click = os.time()
            self:buttonCallback(sender:getTag())
        end
    end  
    self.exitgameDialogpanel = myNode:getChildByName("exitgame_panel")
    --确定按钮
    local sureButton = self.exitgameDialogpanel:getChildByName("btn_yes")
    sureButton:enableOutline({r = 72, g = 137, b = 32, a = 255}, 3)
    tolua.cast(sureButton,"ccui.Button")
    sureButton:setTag(1)
    sureButton:addTouchEventListener(onTouchButton)


    local btn_close = self.exitgameDialogpanel:getChildByName("btn_close")
    tolua.cast(sureButton,"ccui.Button")
    sureButton:setTag(1)
    btn_close:addTouchEventListener(handler(self, self.onTouchCallback))

    --取消按钮
    local cancelButton = self.exitgameDialogpanel:getChildByName("btn_cancle")
	cancelButton:enableOutline({r = 177, g = 92, b = 30, a = 255}, 3)
    tolua.cast(cancelButton,"ccui.Button")
    cancelButton:setTag(2)
    cancelButton:addTouchEventListener(onTouchButton)

    self.text_center = self.exitgameDialogpanel:getChildByName("text_center")

end

function ExitGameLayer:setRoomName( roomName )
    local str = ""
    if roomName == LandGlobalDefine.ROOM_TYPE_MATCHFULL or roomName == LandGlobalDefine.ROOM_TYPE_MATCHTOIMER then
        str = "比赛"
    elseif roomName == LandGlobalDefine.ROOM_TYPE_SYSTEM or roomName ==  LandGlobalDefine.ROOM_TYPE_FREE then
        str = "游戏"
    end
    self.room_name = str

end

function ExitGameLayer:setCenterText( _str )
    local str = _str or "游戏还在激烈的进行中,确定退出吗?"
    local bg = self.exitgameDialogpanel:getChildByName("Panel_2")
    local size = bg:getContentSize()
    local label = self:createLabel({tip=str,fontSize=36})
    label:setPosition(size.width/2,size.height/2+50)
    bg:removeAllChildren()
    bg:addChild( label )
    self.text_center:setVisible(false)
end

function ExitGameLayer:createLabel( param )
    local label = display.newTTFLabel({
        text = param.tip or "",
        font = "ttf/jcy.TTF",
        size = param.fontSize or 30,
        color = cc.c3b(68, 99, 154),
        align = cc.ui.TEXT_ALIGN_CENTER , 
        valign = cc.ui.TEXT_VALIGN_CENTER  , 
        dimensions = param.areaSize or cc.size(620, 128),  
    })
    return label
end

function ExitGameLayer:buttonCallback(sender)
	if sender == 2 then
		self:setVisible(false)
	elseif sender == 1 then
		LogINFO("点击了确定退出按钮")
        if IS_FREE_ROOM( self.game_atom ) then
            g_GameController:reqSysExitSpecialConfirm()
        else
			g_GameController:releaseInstance()
        end
	end
end

-- 点击事件回调
function ExitGameLayer:onTouchCallback( sender )
    local name = sender:getName()
    print("name: ", name)
    if name == "btn_close" then
        self:setVisible(false)
    end
end


return ExitGameLayer