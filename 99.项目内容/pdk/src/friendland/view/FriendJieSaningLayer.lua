local scheduler = require("framework.scheduler")

local FriendRoomController  = require("src.app.game.pdk.src.classicland.contorller.FriendRoomController")
local StackLayer = require("app.hall.base.ui.StackLayer")
local UserCenterHeadIcon = require("app.hall.userinfo.view.UserHeadIcon")

local FriendJieSaningLayer = class("FriendJieSaningLayer", function()
    --return StackLayer.new()
    return display.newLayer()
end)

function FriendJieSaningLayer:ctor(mainScene)
    self.mMainScene = mainScene
    self.statusTimer_ = nil
    self.mTime = 300
    self:init()
end
function FriendJieSaningLayer:onEnter()
    print("---------------FriendJieSaningLayer:onEnter()-------------")
end
function FriendJieSaningLayer:onExit()
    print("---------------FriendJieSaningLayer:onExit()-------------")
end
-------------------------------------------------------------------------------------------------------------------
---------------------------------------初始化       ---------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
function FriendJieSaningLayer:init()
	self:initUI()
    LAND_LOAD_OPEN_EFFECT(self.layout_bg)
end

function FriendJieSaningLayer:initUI()
    local size = cc.Director:getInstance():getWinSize()
    local function closeCallback()
    end
    local item = cc.MenuItemImage:create()
    item:setContentSize(cc.size(size.width, size.height))
    item:registerScriptTapHandler(closeCallback)
    local menu = cc.Menu:create(item)
    self:addChild(menu)
    self.m_pMainNode = cc.CSLoader:createNode("src/app/game/pdk/res/csb/friend_land_cs/friend_main_jiesaning.csb")
    UIAdapter:adapter(self.m_pMainNode, handler(self, self.onTouchCallback))
    self:addChild(self.m_pMainNode)

    self.layout_bg = self.m_pMainNode:getChildByName("layout_bg")
    
    self:initButton()

end

function FriendJieSaningLayer:initButton( ... )
    self.btn_no_agree = self.m_pMainNode:getChildByName("btn_no_agree")
    self.btn_no_agree:addTouchEventListener(handler(self,self.onBackCallBack))
    self.btn_text_no = self.btn_no_agree:getChildByName("btn_text")
    self.btn_text_no:enableOutline({r = 72, g = 137, b = 32, a = 255}, 3)

    self.btn_agree = self.m_pMainNode:getChildByName("btn_agree")
    self.btn_agree:addTouchEventListener(handler(self,self.OnShareButtonBtn))
    self.btn_text_yes = self.btn_agree:getChildByName("btn_text")
    self.btn_text_yes:enableOutline({r = 72, g = 137, b = 32, a = 255}, 3)

    self.text_title = self.m_pMainNode:getChildByName("text_title")
    self.text_title_0 = self.m_pMainNode:getChildByName("text_title_0")
    self.text_title:setFontName("")

    self.text_clock_0 = self.m_pMainNode:getChildByName("text_clock_0")
    self.text_clock_0_0 = self.m_pMainNode:getChildByName("text_clock_0_0")
    self.text_clock_0:setVisible(false)
    self.text_clock_0_0:setVisible(false)

    self.text_clock = self.m_pMainNode:getChildByName("text_clock")
    self.text_clock:setVisible(false)
    local players = FriendRoomController:getInstance():getPlayers()
    for i=1,3 do
        self["player_node_"..i] = {}
        self["player_node_"..i].root = self.m_pMainNode:getChildByName("player_node_"..i)
        self:initPlayerNode(self["player_node_"..i], self["player_node_"..i].root, players[i])
    end
end

function FriendJieSaningLayer:initPlayerNode(playerNode, root, playerData)

    playerNode.accoutId = playerData:getAccountId()
    playerNode.text_player_name = root:getChildByName("text_player_name")
    playerNode.text_player_name:setString(playerData:getNickname())
    playerNode.text_player_name:setFontName("")

    playerNode.lord_friend_bg_mask = root:getChildByName("lord_friend_bg_mask")

    playerNode.text_all_score = root:getChildByName("text_all_score")
    playerNode.lord_dismiss_icon_gou = root:getChildByName("lord_dismiss_icon_gou")
    playerNode.lord_dismiss_icon_cha = root:getChildByName("lord_dismiss_icon_cha")
    playerNode.text_all_score:setVisible(true)
    playerNode.lord_dismiss_icon_gou:setVisible(false)
    playerNode.lord_dismiss_icon_cha:setVisible(false)

    local _head_bg_size = playerNode.lord_friend_bg_mask:getContentSize()
    playerNode._img_head = UserCenterHeadIcon.new({_size =_head_bg_size ,_clip = true })
    playerNode._img_head:setAnchorPoint(cc.p(0.5,0.5))
    playerNode._img_head:setScale(0.95)
    playerNode._img_head:setPosition(cc.p(playerNode.lord_friend_bg_mask:getPositionX(), playerNode.lord_friend_bg_mask:getPositionY()))--_head_bg_pos.x/2,_head_bg_pos.y/2)

    local faceID = playerData:getFaceId()
    if playerNode.accoutId == Player:getAccountID() then
    	faceID = Player:getFaceID()
    end
    playerNode.lord_friend_bg_mask:setVisible(false)
    playerNode._img_head:updateTexture( faceID , playerNode.accoutId )
    playerNode.root:addChild(playerNode._img_head)

end

function FriendJieSaningLayer:updateShowZhu( m_accountId)
    print("function FriendJieSaningLayer:updateShowZhu(m_accountId)")

    local players = FriendRoomController:getInstance():getPlayers()

    for i=1,3 do
        if self["player_node_"..i].accoutId == m_accountId then
            self:statusTimerBegin()
            if self["player_node_"..i].accoutId == m_accountId then
                self.text_title:setString(players[i]:getNickname())
                local wid1 = self.text_title:getContentSize().width
                local wid2 = self.text_title_0:getContentSize().width
                local all_wid = wid1+wid2
                local posX = 837/2 - all_wid/2
                self.text_title:setPositionX(posX)
                self.text_title_0:setPositionX(posX+wid1+10)
            end
            self["player_node_"..i].text_all_score:setVisible(false)
            self["player_node_"..i].lord_dismiss_icon_gou:setVisible(true)
            self["player_node_"..i].lord_dismiss_icon_cha:setVisible(false)
            self.btn_no_agree:setVisible(false)
            self.btn_agree:setVisible(false)
            self.btn_text_yes:setVisible(false)
            self.btn_text_no:setVisible(false)
            self.text_clock_0:setVisible(true)
            self.text_clock_0_0:setVisible(false)
        end
    end

end

function FriendJieSaningLayer:updateShowKe( m_accountId)
    print("function FriendJieSaningLayer:updateShowKe(m_accountId)")

    local players = FriendRoomController:getInstance():getPlayers()

    for i=1,3 do
        if self["player_node_"..i].accoutId == m_accountId then
            self:statusTimerBegin()

            self.text_title:setString(players[i]:getNickname())
            local wid1 = self.text_title:getContentSize().width
            local wid2 = self.text_title_0:getContentSize().width
            local all_wid = wid1+wid2
            local posX = 837/2 - all_wid/2
            self.text_title:setPositionX(posX)
            self.text_title_0:setPositionX(posX+wid1+10)


            self["player_node_"..i].text_all_score:setVisible(false)
            self["player_node_"..i].lord_dismiss_icon_gou:setVisible(true)
            self["player_node_"..i].lord_dismiss_icon_cha:setVisible(false)
            self.btn_no_agree:setVisible(true)
            self.btn_agree:setVisible(true)
            self.btn_text_yes:setVisible(true)
            self.btn_text_no:setVisible(true)
            self.text_clock_0:setVisible(false)
            self.text_clock_0_0:setVisible(true)
        end
    end
end

function FriendJieSaningLayer:updateShow(idList, isAgree, m_accountId , time)
    print("function FriendJieSaningLayer:updateShow()")
    dump(idList)
    dump(isAgree)
    print(m_accountId)
    self.m_accountId = m_accountId
    if time ~= 0 then
        self:statusTimerEnd()
        if time >300 then
            time = 300
        end
        self.mTime = time 
        self:statusTimerBegin()
    end

    local players = FriendRoomController:getInstance():getPlayers()
    for j=1,#idList do
        for i=1,3 do
            if self["player_node_"..i].accoutId == idList[j] then
                --self:statusTimerBegin()
                if self["player_node_"..i].accoutId == m_accountId then
                    self.text_title:setString(players[i]:getNickname())
                    local wid1 = self.text_title:getContentSize().width
                    local wid2 = self.text_title_0:getContentSize().width
                    local all_wid = wid1+wid2
                    local posX = 837/2 - all_wid/2
                    self.text_title:setPositionX(posX)
                    self.text_title_0:setPositionX(posX+wid1+10)
                end

                if isAgree[j] == 0 then
                    self["player_node_"..i].text_all_score:setVisible(false)
                    self["player_node_"..i].lord_dismiss_icon_gou:setVisible(true)
                    self["player_node_"..i].lord_dismiss_icon_cha:setVisible(false)
                elseif isAgree[j] == 1 then
                    self["player_node_"..i].text_all_score:setVisible(false)
                    self["player_node_"..i].lord_dismiss_icon_gou:setVisible(true)
                    self["player_node_"..i].lord_dismiss_icon_cha:setVisible(false)
                    self.btn_no_agree:setVisible(false)
                    self.btn_agree:setVisible(false)
                    self.btn_text_yes:setVisible(false)
                    self.btn_text_no:setVisible(false)
                elseif isAgree[j] == 2 then
                    self["player_node_"..i].text_all_score:setVisible(false)
                    self["player_node_"..i].lord_dismiss_icon_gou:setVisible(false)
                    self["player_node_"..i].lord_dismiss_icon_cha:setVisible(true)
                elseif isAgree[j] == 3 then
                    self["player_node_"..i].text_all_score:setVisible(false)
                    self["player_node_"..i].lord_dismiss_icon_gou:setVisible(true)
                    self["player_node_"..i].lord_dismiss_icon_cha:setVisible(false)
                elseif isAgree[j] == 4 then
                    self["player_node_"..i].text_all_score:setVisible(true)
                    self["player_node_"..i].lord_dismiss_icon_gou:setVisible(false)
                    self["player_node_"..i].lord_dismiss_icon_cha:setVisible(false)             
                end
            end
        end
    end
end


function FriendJieSaningLayer:statusTimerBegin()
    if self.mlabel then 
        self.mlabel:removeFromParent()
        self.mlabel = nil
    end

    self.mlabel = cc.LabelAtlas:_create(tostring(self.mTime), "number/lord_num_time.png",14,22,48)
    self.mlabel:setAnchorPoint(cc.p(0.5, 0.5))
    self.mlabel:setScale(1.5)
    self.text_clock:getParent():addChild(self.mlabel)
    self.mlabel:setPosition(self.text_clock:getPosition())


    -- if self.statusTimer_ then
    --     scheduler.unscheduleGlobal(self.statusTimer_)
    -- end
    -- self.statusTimer_ = scheduler.scheduleGlobal(handler(self, self.LandScore), 1)

    local function f()
        self:LandScore()
    end
    self:schedule( f , 1, "FriendJieSaningLayer")
end

function FriendJieSaningLayer:statusTimerEnd()
    -- if not self.statusTimer_ then
    --     return
    -- end
    -- scheduler.unscheduleGlobal(self.statusTimer_)
    -- self.statusTimer_ = nil
    -- if self.unschedule then
    --     self:unschedule("FriendJieSaningLayer")
    -- end
    
    self:stopAllActions()
end


function FriendJieSaningLayer:LandScore()
    if self.mTime > 0 then
        print("LandScore():ShowClockByViewChairId")
        self.mTime = self.mTime - 1

        --self.text_clock:setString(tostring(self.mTime))
        self.mlabel:setString(tostring(self.mTime))
    else
        self:statusTimerEnd()
        print("同意LandScore")
        if self.m_accountId ~= Player:getAccountID() then
            FriendRoomController:getInstance():sendReqAgreeJieShanGameing(1)
        end
    end
end


function FriendJieSaningLayer:onBackCallBack( sender, eventType )
    if eventType == ccui.TouchEventType.ended then
        print("不同意onBackCallBack")
        FriendRoomController:getInstance():sendReqAgreeJieShanGameing(0)
        self.btn_no_agree:setVisible(false)
        self.btn_agree:setVisible(false)   
    end
end


function FriendJieSaningLayer:OnShareButtonBtn( sender, eventType )
    if eventType == ccui.TouchEventType.ended then
        print("同意OnShareButtonBtn")
        FriendRoomController:getInstance():sendReqAgreeJieShanGameing(1)
        self.btn_no_agree:setVisible(false)
        self.btn_agree:setVisible(false)
    end
end

-- 点击事件回调
function FriendJieSaningLayer:onTouchCallback( sender )
    local name = sender:getName()
    print("name: ", name)
end


return FriendJieSaningLayer