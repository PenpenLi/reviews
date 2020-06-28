local scheduler = require("framework.scheduler")
local StackLayer = require("app.hall.base.ui.StackLayer")

local FriendJiabeiLayer = class("FriendJiabeiLayer", function()
    return StackLayer.new()
end)

function FriendJiabeiLayer:ctor( protocolId )
    self.mProtocolId = protocolId
    self:init()
end

function FriendJiabeiLayer:init()
	  self:initUI()
end

function FriendJiabeiLayer:initUI()
    self.m_pMainNode = cc.CSLoader:createNode("src/app/game/pdk/res/csb/friend_land_cs/friend_main_jiabei.csb")
    self:addChild(self.m_pMainNode)
    UIAdapter:adapter(self.m_pMainNode, handler(self, self.onTouchCallback))
    self.layout_bg = self.m_pMainNode:getChildByName("layout_bg")
    self:initButton()
end

function FriendJiabeiLayer:initButton( ... )
    self.btn_game_yes = self.layout_bg:getChildByName("btn_game_yes")
    self.btn_game_yes:addTouchEventListener(handler(self,self.OnClickYesBtn))

    self.btn_game_no = self.layout_bg:getChildByName("btn_game_no")
    self.btn_game_no:addTouchEventListener(handler(self,self.OnClickNoBtn))

    self.btn_game_yes:enableOutline({r = 72, g = 137, b = 32, a = 255}, 3)
    self.btn_game_no:enableOutline({r = 28, g = 142, b = 122, a = 255}, 3)
end

function FriendJiabeiLayer:OnClickYesBtn( sender, eventType )
    if eventType == ccui.TouchEventType.ended then
        ConnectManager:send2GameServer(self.mProtocolId, "CS_C2G_LandLord_Double_Req", { 1 } )
    end
end

function FriendJiabeiLayer:OnClickNoBtn( sender, eventType )
    if eventType == ccui.TouchEventType.ended then
        ConnectManager:send2GameServer(self.mProtocolId, "CS_C2G_LandLord_Double_Req", { 0 } )
    end
end

function FriendJiabeiLayer:onTouchCallback( sender )
    local name = sender:getName()
    print("name: ", name)
end

return FriendJiabeiLayer