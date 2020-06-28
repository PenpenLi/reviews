
local LandGlobalDefine = require("app.game.pdk.src.landcommon.data.LandGlobalDefine")

local FriendRoomController  = require("src.app.game.pdk.src.classicland.contorller.FriendRoomController")
local FriendJieSanLayer = class("FriendJieSanLayer", function()
    return display.newLayer()
end)

function FriendJieSanLayer:ctor(type)
    self.mType = type
    self:init()
    LAND_LOAD_OPEN_EFFECT(self.layout_bg)
end

function FriendJieSanLayer:init()
	
    local size = cc.Director:getInstance():getWinSize(); 

    local myNode = cc.CSLoader:createNode("src/app/game/pdk/res/csb/friend_land_cs/friend_main_jiesan.csb")

    local temp = myNode:getChildren()
    for i=1,#temp do
        temp[i]:setPositionY(temp[i]:getPositionY()*display.standardScale)
    end

    UIAdapter:adapter(myNode, handler(self, self.onTouchCallback))
    self:addChild(myNode,2)

    local function onTouchButton(sender,eventType)
        if sender then
            if eventType == ccui.TouchEventType.ended then
                self:buttonCallback(sender:getTag())
            end
        end
    end  
    self.layout_bg = myNode:getChildByName("layout_bg")

    --确定按钮
    local sureButton = self.layout_bg:getChildByName("btn_yes")
    tolua.cast(sureButton,"ccui.Button")
    sureButton:setTag(1)
    sureButton:addTouchEventListener(onTouchButton)

    --取消按钮
    local cancelButton = self.layout_bg:getChildByName("btn_no")
    tolua.cast(cancelButton,"ccui.Button")
    cancelButton:setTag(2)
    cancelButton:addTouchEventListener(onTouchButton)

    cancelButton:enableOutline({r = 177, g = 92, b = 30, a = 255}, 3)
    sureButton:enableOutline({r = 72, g = 137, b = 32, a = 255}, 3)

    local btn_yes_1 = self.layout_bg:getChildByName("btn_yes_1")
    tolua.cast(cancelButton,"ccui.Button")
    btn_yes_1:setTag(3)
    btn_yes_1:addTouchEventListener(onTouchButton)
    btn_yes_1:enableOutline({r = 72, g = 137, b = 32, a = 255}, 3)
    
    self.Text_1 = self.layout_bg:getChildByName("text_1")
    self.Text_2 = self.layout_bg:getChildByName("text_2")
    self.mTitleText = self.layout_bg:getChildByName("btn_yes_1")

    if self.mType == 1 then
        sureButton:setVisible(true)
        cancelButton:setVisible(true)
        self.mTitleText:setVisible(true)
        self.Text_1:setVisible(true)
        self.Text_2:setVisible(false)
        btn_yes_1:setVisible(false)
    else
        sureButton:setVisible(false)
        cancelButton:setVisible(false)
        self.mTitleText:setVisible(false)
        self.Text_1:setVisible(false)
        self.Text_2:setVisible(true)
        btn_yes_1:setVisible(true)
    end
end

function FriendJieSanLayer:buttonCallback(sender)
	if sender == 2 then
		self:removeFromParent()
	elseif sender == 1 then
		local roomID = FriendRoomController:getInstance():getRoomInfo()
		LogINFO("发送消息到服务器 请求解散房间,",roomID)
        ConnectManager:send2SceneServer(LandGlobalDefine.FRIEND_ROOM_GAME_ID, "CS_C2M_DismissLandVipRoom_Req", { LandGlobalDefine.FRIEND_ROOM_GAME_ID, roomID} )
    elseif sender == 3 then
        POP_GAME_SCENE()
	end
end

function FriendJieSanLayer:onTouchCallback( sender )
    local name = sender:getName()
    print("name: ", name)
    if name == "btn_close" then
        if self.mType == 1 then
            self:removeFromParent()
        else
            POP_GAME_SCENE()
        end
    end
end

return FriendJieSanLayer