local scheduler = require("framework.scheduler")
local FriendRoomController  = require("src.app.game.pdk.src.classicland.contorller.FriendRoomController")
local StackLayer = require("app.hall.base.ui.StackLayer")
local UserCenterHeadIcon = require("app.hall.userinfo.view.UserHeadIcon")
local LandGlobalDefine      = require("src.app.game.pdk.src.landcommon.data.LandGlobalDefine")

local FriendAccountLayer = class("FriendAccountLayer", function()
    return StackLayer.new()
end)

local tip = {
    [1] = "发起解散",
    [2] = "同意解散",
    [3] = "拒绝解散",
    [4] = "超时未选",
    [5] = "超时未选"
}

function FriendAccountLayer:ctor(info)
    self.mInfo = info
    self:init()
    --self:checkIOS()
end
function FriendAccountLayer:onEnter()
    print("---------------FriendAccountLayer:onEnter()-------------")
end
function FriendAccountLayer:onExit()
    print("---------------FriendAccountLayer:onExit()-------------")
end
-------------------------------------------------------------------------------------------------------------------
---------------------------------------初始化       ---------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
function FriendAccountLayer:init()
	  self:initUI()
end
function FriendAccountLayer:initUI()
    self.m_pMainNode = cc.CSLoader:createNode("src/app/game/pdk/res/csb/friend_land_cs/friend_main_accounts.csb")
    local temp = self.m_pMainNode:getChildren()
    for i=1,#temp do
        temp[i]:setPositionY(temp[i]:getPositionY()*display.standardScale)
    end
    UIAdapter:adapter(self.m_pMainNode, handler(self, self.onTouchCallback))
    self:addChild(self.m_pMainNode)

    self:initButton()

end

function FriendAccountLayer:initButton()
    self.btn_back = self.m_pMainNode:getChildByName("btn_back")
    self.btn_back:addTouchEventListener(handler(self,self.onBackCallBack))


    self.share_button = self.m_pMainNode:getChildByName("share_button")
    self.share_button:addTouchEventListener(handler(self,self.OnShareButtonBtn))

    for i=1,3 do
        self["player_node"..i] = {}
        self["player_node"..i].root = self.m_pMainNode:getChildByName("player_node_"..i)
        self:initPlayerNode(self["player_node"..i],self["player_node"..i].root)
    end
end

--[[
function FriendAccountLayer:checkIOS()
    if GlobalConf.IS_IOS_TS == true then
        self.share_button:setVisible(false)
        self.share_label:setVisible(false)
    end
end
--]]

function FriendAccountLayer:initPlayerNode(playerNode, root)
    playerNode.text_player_name = root:getChildByName("text_player_name")
    playerNode.img_dizhu_label = root:getChildByName("img_dizhu_label")
    playerNode.text_dizhu_count = root:getChildByName("text_dizhu_count")
    playerNode.lord_friend_bg_mask = root:getChildByName("lord_friend_bg_mask")
    playerNode.layout_number = root:getChildByName("layout_number")

    local _head_bg_size = playerNode.lord_friend_bg_mask:getContentSize()
    playerNode._img_head = UserCenterHeadIcon.new({_size =_head_bg_size ,_clip = true })
    playerNode._img_head:setAnchorPoint(cc.p(0.5,0.5))

    playerNode._img_head:setPosition(cc.p(playerNode.lord_friend_bg_mask:getPositionX(), playerNode.lord_friend_bg_mask:getPositionY()))
    --playerNode.lord_friend_bg_mask:setVisible(false)
    playerNode.root:addChild(playerNode._img_head)

end

function FriendAccountLayer:updateGameResult(m_lvrGameOverData, Gametype)
    print("function FriendAccountLayer:updateGameResult(bobomNum,baseNum,m_lvrGameOverData)")

    FriendRoomController:getInstance():clearRoomInfo()

    local players = FriendRoomController:getInstance():getPlayers()
    for i=1,3 do
        local playerNode = self["player_node"..i]
        local onePlayer = players[i]

        playerNode.text_player_name:setString(onePlayer:getNickname())
        playerNode.img_dizhu_label:setVisible(false)
        playerNode.text_dizhu_count:setString("叫地主次数:"..tostring(m_lvrGameOverData[i].m_isLandNum))

        playerNode._resultNumAtlas = self:createGameScoreSprite(m_lvrGameOverData[i].m_score)
        playerNode._resultNumAtlas:setVisible(true)
        playerNode.layout_number:setVisible(true)
        local size = playerNode.layout_number:getContentSize()
        local anchorPoint= cc.p(0.5,0.5)
        playerNode._resultNumAtlas:setAnchorPoint(cc.p(anchorPoint))
        playerNode._resultNumAtlas:setPosition(cc.p(size.width/2, size.height/2 ))
        playerNode.layout_number:addChild(playerNode._resultNumAtlas)

        local faceID = onePlayer:getFaceId()
	    if onePlayer:getAccountId() == Player:getAccountID() then
	    	faceID = Player:getFaceID()
	    end

	    playerNode._img_head:updateTexture( faceID , onePlayer:getAccountId() )
        playerNode._img_head:setScale(0.88)

    end
end

--生成分数Sprite
function FriendAccountLayer:createGameScoreSprite( value )
    local tempLabel
    if value > 0 then
        local str =":"..value
        tempLabel = cc.LabelAtlas:_create(str, "number/lord_account_num_win.png",26,34,48)
    elseif value == 0 then
        tempLabel = cc.LabelAtlas:_create("0", "number/lord_account_num_win.png",26,34,48)
    else
        local score  = math.abs(value)
        local str = ":"..score
        tempLabel = cc.LabelAtlas:_create(str, "number/lord_account_num_lose.png",26,34,48)
    end

    tempLabel:setScale(0.8)

    return tempLabel
end


function FriendAccountLayer:clearScore()

    for i=1,LandGlobalDefine.GAME_PLAYER do
       self.m_playerPanelViews[i].gold_win_lose:setVisible(false)
       self.m_playerPanelViews[i]._playerPanel:removeChild(self.m_playerPanelViews[i]._resultNumAtlas,true)
       self.m_playerPanelViews[i]._resultNumAtlas = nil
    end
end

--点击了开始游戏按钮
function FriendAccountLayer:onBackCallBack( sender, eventType )
    if eventType == ccui.TouchEventType.ended then
        self:removeFromParent()
        POP_GAME_SCENE()
        local function f()
            DOHALL_CENTER("updateJoinBtn")
        end              
        DO_ON_FRAME( GET_CUR_FRAME()+2 , f )

    end
end

function FriendAccountLayer:OnShareButtonBtn( sender, eventType )
    if eventType ~= ccui.TouchEventType.ended then return end
    -- 牌友房分享不走这条.特殊处理走截屏分享的
    --QKA_SHARE( LandGlobalDefine.FRIEND_ROOM_GAME_ID )
    local func = function (isSucess, filePath)
        if isSucess then
            local callback = function (code)
                if code == XbShareUtil.WX_SHARE_NOWX then
                    ToolKit:showErrorTip(501) --请先安装微信
                elseif code == XbShareUtil.WX_SHARE_OK then
                    TOAST("分享成功!")
                end
            end
            XbShareUtil:wxShareImg(XbShareUtil.SHARE_FRIEND, filePath, callback)
        end
    end
    ToolKit:captureScreenEx(func, "land_loard_share.jpg")
end

-- 点击事件回调
function FriendAccountLayer:onTouchCallback( sender )
    local name = sender:getName()
    print("FriendAccountLayer:onTouch ", name)
end


return FriendAccountLayer