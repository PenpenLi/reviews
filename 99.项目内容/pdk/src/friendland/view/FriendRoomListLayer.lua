local XbDialog = require("app.hall.base.ui.CommonView")
local EventManager = require("app.game.pdk.src.common.EventManager")
local FriendRoomController  = require("src.app.game.pdk.src.classicland.contorller.FriendRoomController")
local LandGlobalDefine = require("app.game.pdk.src.landcommon.data.LandGlobalDefine")
local LandAnimationManager = require("src.app.game.pdk.src.landcommon.animation.LandAnimationManager")
local LandArmatureResource = require("src.app.game.pdk.src.landcommon.animation.LandArmatureResource")

local FriendRoomListLayer = class("FriendRoomListLayer", function () 
    return XbDialog.new()
    end)

function FriendRoomListLayer:ctor()
    self:setName("FriendRoomListLayer")
    self:initUI()
    FriendRoomController:getInstance():sendReqMyRoomList()
end

function FriendRoomListLayer:initUI()

    local function closeCallback()
        self:closeDialog()
    end
    local size = cc.Director:getInstance():getWinSize()
    local item = cc.MenuItemImage:create()
    item:setContentSize(cc.size(size.width, size.height))
    item:registerScriptTapHandler(closeCallback)
    self.backMenu = cc.Menu:create(item)
    self:addChild(self.backMenu)


	local myNode = cc.CSLoader:createNode("src/app/game/pdk/res/csb/friend_land_cs/land_room_ctrl.csb")
    UIAdapter:adapter(myNode, handler(self, self.onTouchCallback))
    self:addChild(myNode)

    self.layout_bg = myNode:getChildByName("layout_bg")
    
    self:initListView()
    self.animation_node = myNode:getChildByName("animation_node")
    self.animation_node:setVisible(false)

    LAND_LOAD_OPEN_EFFECT(self.layout_bg)
end

function FriendRoomListLayer:initListView()
	self.mListView = self.layout_bg:getChildByName("ListView")
    self.mListView:removeAllItems()
    self.mListView:setItemsMargin(3.0)
end

function FriendRoomListLayer:init()
    local size = cc.Director:getInstance():getWinSize()
	local function closeCallback()
        self:setVisible(false)
    end
	
    local item = cc.MenuItemImage:create()
    item:setContentSize(cc.size(size.width, size.height))
    item:registerScriptTapHandler(closeCallback)
    local menu = cc.Menu:create(item)
    self:addChild(menu)
end

function FriendRoomListLayer:updateRoomList(roomList)
    
    dump(roomList, "房间列表:", 10)

    self.mRoomList = roomList
    self.mListView:removeAllItems()
    self.animation_node:setVisible(false)

    if #self.mRoomList <= 0 then
       --[[ self.animation_node:setVisible(true)
        local animation = LandAnimationManager:getInstance():PlayAnimation(LandArmatureResource.ANI_DIZHUSHAOBA, self.animation_node)
        animation:setScale(1.6)--]]
        self.animation_node:setVisible(true)
        return  
    end

    for i=1,#self.mRoomList do
        local itemClone = cc.CSLoader:createNode("friend_land_cs/land_room_item.csb")--self.mListViewItem:clone()
        local imgBg = itemClone:getChildByName("Panel_1")
        local listItemLayout = ccui.Layout:create()
        listItemLayout:setContentSize(imgBg:getContentSize())
        listItemLayout:addChild(itemClone)
        itemClone:setPosition(cc.p(0, 0))
        listItemLayout:setTag(i-1)
        self.mListView:insertCustomItem(listItemLayout, i-1)
        self:initItem(itemClone, self.mRoomList[i])

    end
    self.mListView:refreshView()
end

function FriendRoomListLayer:initItem(item, data)
    print("initItem")
    local img_title = item:getChildByName("img_title")

    local text_room_number = item:getChildByName("text_room_number")
    text_room_number:setString(tostring(data.m_roomId))

    local text_wanfa = item:getChildByName("text_wanfa")
    local pei = "加倍"
    if data.m_isDouble == 1 then
        pei = "加倍"
    else
        pei = "不加倍"
    end

    local ding = ""
    if data.m_limitBomb == 0 then
        ding = "不封顶"
    else
        ding = data.m_limitBomb .. "炸"
    end
    local ju = "6局"
    if data.m_roundNum then
        ju = data.m_roundNum.."局"
    end
    
    text_wanfa:setString(pei.." "..ding.. " "..ju)

    local text_player_count = item:getChildByName("text_player_count")
    text_player_count:setString(data.m_playerNum.."/3")

    local btn_yaoqing = item:getChildByName("btn_yaoqing")
    btn_yaoqing:addTouchEventListener(function (sender, eventType)
        if sender then
            if eventType == ccui.TouchEventType.ended then
                FriendRoomController:getInstance():weiXinInvite( data.m_roomId , data.m_isDouble , data.m_limitBomb , data.m_roundNum )
            end
        end
    end)
    local btn_jieshan = item:getChildByName("btn_jieshan")
    btn_jieshan:addTouchEventListener(function (sender, eventType)
        if sender then
            if eventType == ccui.TouchEventType.began then    
            elseif eventType == ccui.TouchEventType.canceled then
            elseif eventType == ccui.TouchEventType.ended then
                print("解散 房间号为:"..data.m_roomId)
                ConnectManager:send2SceneServer(LandGlobalDefine.FRIEND_ROOM_GAME_ID, "CS_C2M_DismissLandVipRoom_Req", { LandGlobalDefine.FRIEND_ROOM_GAME_ID, data.m_roomId} )
            end
        end
    end)
    local text_zhuangtai = item:getChildByName("text_zhuangtai")
    text_zhuangtai:setVisible(false)
    
    if data.m_playerNum >=3 then
        text_zhuangtai:setVisible(true)
        btn_jieshan:setVisible(false)
        btn_yaoqing:setVisible(false)
    else
        text_zhuangtai:setVisible(false)
        btn_jieshan:setVisible(true)
        btn_yaoqing:setVisible(true)
    end
end

function FriendRoomListLayer:removeRoom( roomId )
    print("function FriendRoomListLayer:removeRoom()",roomId)
    local index = 0
    for i=1,#self.mRoomList do
        if self.mRoomList[i].m_roomId == roomId then
            index = i
            break
        end
    end
    table.remove(self.mRoomList, index)
    
    self.mListView:removeItem(index-1)
    self.mListView:refreshView()
end

function FriendRoomListLayer:onTouchCallback( sender )
    local name = sender:getName()
    print("name: ", name)
    if name  == "btn_close" then
        self:closeDialog()
    end
end

return FriendRoomListLayer






