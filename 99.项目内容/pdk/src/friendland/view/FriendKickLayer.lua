local scheduler = require("framework.scheduler")
local StackLayer = require("app.hall.base.ui.StackLayer")
local LandGlobalDefine = require("app.game.pdk.src.landcommon.data.LandGlobalDefine")

local FriendKickLayer = class("FriendKickLayer", function()
    return display.newLayer()
end)

function FriendKickLayer:ctor( landMainScene)
    self.kick_target_account = nil
    self:initUI()
end

function FriendKickLayer:initUI()
    self.m_pMainNode = UIAdapter:createNode("src/app/game/pdk/res/csb/friend_land_cs/friend_main_ti.csb")
    UIAdapter:adapter(self.m_pMainNode, handler(self, self.onTouchCallback))
    self:addChild(self.m_pMainNode)
    self:initKickOthersOut()
    self:initBeenKickOut()
end

function FriendKickLayer:initKickOthersOut( ... )
    self.kick_others_out_panel = self.m_pMainNode:getChildByName("layout_zudong")
    self.kick_player_name_text = self.kick_others_out_panel:getChildByName("player_name")
    self.kick_out_btn_yes = self.kick_others_out_panel:getChildByName("btn_yes")
    self.kick_out_btn_yes:addTouchEventListener(handler(self,self.OnClickYesKickOutBtn))
    self.kick_out_btn_yes:enableOutline({r = 72, g = 137, b = 32, a = 255}, 3)

    self.kick_out_btn_no  = self.kick_others_out_panel:getChildByName("btn_no")
    self.kick_out_btn_no:enableOutline({r = 177, g = 92, b = 30, a = 255}, 3)
    self.kick_out_btn_no:addTouchEventListener(handler(self,self.OnClickNoKickOutBtn))
end

function FriendKickLayer:initBeenKickOut( ... )
    self.inform_panel = self.m_pMainNode:getChildByName("layout_beidong")
    self.i_know_btn   = self.inform_panel:getChildByName("btn_sure")
    self.i_know_btn:enableOutline({r = 72, g = 137, b = 32, a = 255}, 3)
    self.i_know_btn:addTouchEventListener(handler(self,self.OnClickIKnowBtnBtn))
end

function FriendKickLayer:showKickOutDialog( _acc, player_name )
    self.kick_target_account = _acc
    self.inform_panel:setVisible( false )
    self.kick_others_out_panel:setVisible( true )
    local str = "是否要将"..player_name.."请离房间?"
    self.kick_player_name_text:setString(str)
    self.kick_player_name_text:setFontName("")
    LAND_LOAD_OPEN_EFFECT(self.kick_others_out_panel)
end

function FriendKickLayer:showKickOutInform( ... )
    self.kick_others_out_panel:setVisible( false )
    self.inform_panel:setVisible( true )
    LAND_LOAD_OPEN_EFFECT(self.inform_panel)
end

--点击了确认踢人按钮
function FriendKickLayer:OnClickYesKickOutBtn( sender, eventType )
    if eventType == ccui.TouchEventType.ended then
        if self.kick_target_account then
            ConnectManager:send2SceneServer(LandGlobalDefine.FRIEND_ROOM_GAME_ID, "CS_C2M_LandVipRoomKick_Req", { self.kick_target_account } )
        else
            print("FriendKickLayer:OnClickYesKickOutBtn 异常 self.kick_target_account : ",self.kick_target_account)
        end
    end
end

--点击了取消踢人按钮
function FriendKickLayer:OnClickNoKickOutBtn( sender, eventType )
    if eventType == ccui.TouchEventType.ended then
        print( "FriendKickLayer:OnClickNoKickOutBtn" )
        self:setVisible(false)
    end
end


--点击了我知道了按钮
function FriendKickLayer:OnClickIKnowBtnBtn( sender, eventType )
    if eventType == ccui.TouchEventType.ended then
        print("点击了我知道了按钮")
        POP_GAME_SCENE()
    end
end

-- 点击事件回调
function FriendKickLayer:onTouchCallback( sender )
    local name = sender:getName()
    print("name: ", name)
end

return FriendKickLayer