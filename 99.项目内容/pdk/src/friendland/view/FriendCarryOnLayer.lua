local scheduler = require("framework.scheduler")
local LandGlobalDefine     = require("src.app.game.pdk.src.landcommon.data.LandGlobalDefine")
local StackLayer = require("app.hall.base.ui.StackLayer")

local FriendCarryOnLayer = class("FriendCarryOnLayer", function()
    return StackLayer.new()
end)

function FriendCarryOnLayer:ctor( landMainScene)
    self:initUI()
end
function FriendCarryOnLayer:onEnter()
    print("---------------FriendCarryOnLayer:onEnter()-------------")
end
function FriendCarryOnLayer:onExit()
    print("---------------FriendCarryOnLayer:onExit()-------------")
end
-------------------------------------------------------------------------------------------------------------------
---------------------------------------初始化       ---------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

function FriendCarryOnLayer:initUI()
    self.m_pMainNode = cc.CSLoader:createNode("src/app/game/pdk/res/csb/friend_land_cs/friend_main_goon.csb")
    self:addChild(self.m_pMainNode)
    UIAdapter:adapter(self.m_pMainNode, handler(self, self.onTouchCallback))
    self.layout_bg = self.m_pMainNode:getChildByName("layout_bg")
    self.layout_bg:setContentSize(display.width, display.height)
    self:initButton()
end

function FriendCarryOnLayer:initButton( ... )
    self.carry_on_btn = self.layout_bg:getChildByName("btn_game_goon")
    local Text_13 = self.layout_bg:getChildByName("Text_13")
    Text_13:enableOutline({r = 198, g = 126, b = 23, a = 255}, 2)
    self.carry_on_btn:addTouchEventListener(handler(self,self.OnClickCarryOnBtn))
end

--点击了继续游戏按钮
function FriendCarryOnLayer:OnClickCarryOnBtn( sender, eventType )
    if eventType == ccui.TouchEventType.ended then
        print("点击了继续游戏按钮")
        FRIEND_ROOM_SCENE_DO("clearUIForGoon")
        
        ConnectManager:send2GameServer(LandGlobalDefine.FRIEND_ROOM_GAME_ID, "CS_C2G_LandLord_CarryOn_Req", {} )
    end
end

-- 点击事件回调
function FriendCarryOnLayer:onTouchCallback( sender )
    local name = sender:getName()
    print("name: ", name)
end

return FriendCarryOnLayer