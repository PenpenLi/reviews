--LandSystemSet
-- Author: 
-- Date: 2018-08-07 18:17:10
--跑得快功能设置面板
local LandGlobalDefine = require("app.game.pdk.src.landcommon.data.LandGlobalDefine")
local FriendJieSanLayer = require("src.app.game.pdk.src.friendland.view.FriendJieSanLayer")
local LandGlobalDefine = require("app.game.pdk.src.landcommon.data.LandGlobalDefine")
local FriendRoomController  = require("src.app.game.pdk.src.classicland.contorller.FriendRoomController") 
local GameRecordLayer= require("src.app.newHall.childLayer.GameRecordLayer")

local LandSystemSet = class("LandSystemSet",function()
	 return display.newLayer()
end)

local DDS_PO = {
    [1] = cc.p(215,120),--{x = 215, y = 110},
    [2] = cc.p(75,0),--{x = 75 , y = 0},
    [3] = cc.p(215,-120),--{x = 215, y = -110},

}

function LandSystemSet:ctor( landMainScene , gameId)
    print("land_set_sysytem:ctor")
    self.m_GameId =  gameId
    self.functionButtons = {}
    self.isFunctionButtonsShow = false
    self.m_landMainScene = landMainScene
    self.functionButtons = {}
    for i=1,4 do
    self.functionButtons[i] = {}
    end
    self:init()

    --self:checkIOS()
end

function LandSystemSet:init()
	local function closeCallback()
        self.backMenu:setEnabled(false)
        self:hideFuctionButtons()
    end
    local size = cc.Director:getInstance():getWinSize()
    local item = cc.MenuItemImage:create()
    item:setContentSize(cc.size(size.width, size.height))
    item:registerScriptTapHandler(closeCallback)
    self.backMenu = cc.Menu:create(item)
    self:addChild(self.backMenu)
    self.backMenu:setEnabled(false)

	self.m_pSettingNode = cc.CSLoader:createNode("src/app/game/pdk/res/csb/land_common_cs/land_set_system.csb")
    self:addChild(self.m_pSettingNode)
    self.m_pSettingNode:setContentSize(display.size)
    UIAdapter:adapter(self, handler(self.m_pSettingNode, self.onTouchCallback))

    self.right_vertical_panel = self.m_pSettingNode:getChildByName("right_vertical_panel")

    --按钮背景
    self.btn_layout = self.right_vertical_panel:getChildByName("btn_layout")

    --设置按钮
    self.set_button = self.right_vertical_panel:getChildByName("set_button")
    tolua.cast( self.set_button,"ccui.Button")
    self.set_button:setTag(LandGlobalDefine.SYSTEMSET_SET)
    self.set_button:addTouchEventListener(handler(self,self.OnTouchSystemSetButton))
    
    --设置面板
    self.set_panel = self.right_vertical_panel:getChildByName("set_root_node")
    self.set_panel:setVisible(false)
    self.set_Node = self.set_panel:getChildByName("set_node")
    self.set_NodePostion = cc.p(self.set_Node:getPositionX(),self.set_Node:getPositionY())
     
    self.setBg = self.m_pSettingNode:getChildByName("bg_layout")
    -- self.setBg:setScaleY(1.3)
    self.setBg:setVisible(false)

    --规则按钮
    self.functionButtons[1].button = self.set_panel:getChildByName("btn_rule")
    self.functionButtons[1].button:setTag(LandGlobalDefine.SYSTEMSET_RULE)
    self.functionButtons[1].postion = cc.p(self.functionButtons[1].button:getPositionX(),self.functionButtons[1].button:getPositionY())
    self.functionButtons[1].button:addTouchEventListener(handler(self,self.OnTouchSystemSetButton))
    self.functionButtons[1].spr = self.functionButtons[1].button:getChildByName("spr")
    
    --上手牌
    self.functionButtons[2].button = self.set_panel:getChildByName("btn_pai")
    self.functionButtons[2].button:setTag(LandGlobalDefine.SYSTEMSET_LAST_HAND)
    self.functionButtons[2].postion = cc.p(self.functionButtons[2].button:getPositionX(),self.functionButtons[2].button:getPositionY())
    self.functionButtons[2].button:addTouchEventListener(handler(self,self.OnTouchSystemSetButton))
    self.functionButtons[2].spr = self.functionButtons[2].button:getChildByName("spr")

    --音效
    self.functionButtons[3].button = self.set_panel:getChildByName("btn_music")
    self.functionButtons[3].button:setTag( LandGlobalDefine.SYSTEMSET_MUSIC )
    self.functionButtons[3].postion = cc.p(self.functionButtons[3].button:getPositionX(),self.functionButtons[3].button:getPositionY())
    self.functionButtons[3].button:addTouchEventListener(handler(self,self.OnTouchSystemSetButton))
    self.functionButtons[3].spr = self.functionButtons[3].button:getChildByName("spr")

    --退出
    self.functionButtons[4].button = self.set_panel:getChildByName("btn_music_exit")
    self.functionButtons[4].button:setTag(LandGlobalDefine.SYSTEMSET_EXIT)
    self.functionButtons[4].postion = cc.p(self.functionButtons[4].button:getPositionX(), self.functionButtons[4].button:getPositionY())
    self.functionButtons[4].button:addTouchEventListener(handler(self,self.OnTouchSystemSetButton))
    self.functionButtons[4].spr = self.functionButtons[4].button:getChildByName("spr")


    self.m_chatButton =  self.right_vertical_panel:getChildByName("chat_button")

    if IS_FAST_GAME(self.m_GameId ) == true or IS_DING_DIAN_SAI(self.m_GameId) == true then
        self.functionButtons[1].spr:setSpriteFrame(display.newSpriteFrame("ddz_gengduo_jiangli.png"))
    end

    if IS_PAI_YOU_FANG(self.m_GameId ) == true then
        if self.m_landMainScene:getGameState() < 1 then -- 未开局

            local roomId, roomInfo = FriendRoomController:getInstance():getRoomInfo()

            if FriendRoomController:getInstance():checkMyselfIsFangzhu() then
                --print("我为自己创建并加入,我有返回解散功能")
                self.functionButtons[2].spr:setSpriteFrame(display.newSpriteFrame("ddz_gengduo_huidating.png"))
                self.functionButtons[4].spr:setSpriteFrame(display.newSpriteFrame("ddz_gengduo_jiesan.png"))
            elseif FriendRoomController:getInstance():checkMyselfIsCiFangzhu() then
                --print("我是第一个加入,我能T人,离开 ,不能回大厅")
                self.functionButtons[2].spr:setSpriteFrame(display.newSpriteFrame("ddz_gengduo_ssp.png"))   

                self.functionButtons[4].spr:setSpriteFrame(display.newSpriteFrame("ddz_gengduo_tuichu.png")) 
            elseif FriendRoomController:getInstance():checkMyselfIsFangKe() then
                --print("我是房客, 只能退出 ")
                self.functionButtons[2].spr:setSpriteFrame(display.newSpriteFrame("ddz_gengduo_ssp.png")) 

                self.functionButtons[4].spr:setSpriteFrame(display.newSpriteFrame("ddz_gengduo_tuichu.png"))   
            end
            self.m_chatButton:setVisible(true)
        else
            --print("已经开始")
           self.functionButtons[2].spr:setSpriteFrame(display.newSpriteFrame("ddz_gengduo_ssp.png")) 
        self.functionButtons[4].spr:setSpriteFrame(display.newSpriteFrame("ddz_gengduo_jiesan.png"))
        end
    else
        --print("不是牌友房 退出")
        self.functionButtons[4].spr:setSpriteFrame(display.newSpriteFrame("ddz_gengduo_tuichu.png"))  
        self.m_chatButton:setVisible(false)
        self.set_button:setPositionY(125)--self.set_button:getPositionY())
        self.set_panel:setPositionY(167)--self.set_panel:getPositionY())
    end
   -- self:initChatLayer()

      self.m_chatButton:loadTextures("hall/image/sanguosgj.png","hall/image/sanguosgj.png","hall/image/sanguosgj.png",0)  
      self.m_chatButton:setPositionY(420)
      self.m_chatButton:setVisible(true)
    self.m_chatButton:addTouchEventListener(handler(self,self.onClickRecordBtn))
end

function LandSystemSet:onClickRecordBtn( sender, eventType )
	if eventType == ccui.TouchEventType.ended then
		local GameRecordLayer = GameRecordLayer.new(2)
        self:addChild(GameRecordLayer)   
        GameRecordLayer:setScaleX(display.scaleX)
         ConnectManager:send2Server(Protocol.LobbyServer, "CS_C2H_GetGameResult_Req", {206})
	end
end

--[[
function LandSystemSet:checkIOS()
    if GlobalConf.IS_IOS_TS == true then
        self.m_chatButton:setVisible(false)
    end
end
--]]
  
function LandSystemSet:initPosition()
    if IS_DING_DIAN_SAI(self.m_GameId) == true then
            --规则按钮
        self.functionButtons[1].button:setPosition(DDS_PO[1])
        self.functionButtons[1].button:setVisible(false)
        self.functionButtons[1].postion = cc.p(self.functionButtons[1].button:getPositionX(), self.functionButtons[1].button:getPositionY())
        --上手牌
        self.functionButtons[2].button:setPosition(DDS_PO[2])
        self.functionButtons[2].button:setVisible(false)
        self.functionButtons[2].postion = cc.p(self.functionButtons[2].button:getPositionX(), self.functionButtons[2].button:getPositionY())
        --音效
        self.functionButtons[3].button:setPosition(DDS_PO[3])
        self.functionButtons[3].button:setVisible(false)
        self.functionButtons[3].postion = cc.p(self.functionButtons[3].button:getPositionX(), self.functionButtons[3].button:getPositionY())
        --退出
        self.functionButtons[4].button:setVisible(false)
        table.remove(self.functionButtons, 4)
    end
end

function LandSystemSet:initChatLayer()
    local ChatSystemLayer =  RequireEX( "app.game.common.chat.ChatSystemLayer" )
    local params = 
    {
        gameAtomTypeId = LandGlobalDefine.FRIEND_ROOM_GAME_ID,
        serverReq = "CS_C2M_LVRClientChat_Req",
        serverAck = "CS_M2C_LVRClientChat_Nty",
    }
    self.m_chatSystemLayer = ChatSystemLayer.new( params )
    self.m_chatSystemLayer:setPositionX(self.m_chatSystemLayer:getPositionX()-20)
    self.m_chatSystemLayer:setPositionY(self.m_chatSystemLayer:getPositionY()+130)

    
    if self.m_chatSystemLayer.talkNode then
        self.m_chatSystemLayer.talkNode:setPosition(cc.p(display.cx+20,display.cy-100))
    end
    self:addChild( self.m_chatSystemLayer ) 

    self.m_chatSystemLayer.messageButton:setVisible(false)
    self.m_chatSystemLayer.talkButton:setVisible(false)

    self.m_chatButton:addTouchEventListener(handler(self, self.onPressChatBtn))
end 

function LandSystemSet:onPressChatBtn( sender,eventType )
	local frameSet = 5
	print("点击事件",eventType)
	if eventType == ccui.TouchEventType.began then 
		self.press_frame = 0
		print("点击开始",self.press_frame)
		function updateClock()
			self.press_frame = self.press_frame + 1
			print("时间片",self.press_frame)
			if self.press_frame > frameSet then
				print("长按判断成立,长按开始",self.press_frame)
				self.press_frame = frameSet
				self.m_chatButton:stopAllActions()
				self.m_chatSystemLayer:ontVoiceBtnPressButtons( sender , ccui.TouchEventType.began )
			end
		end
		local a1 = cc.CallFunc:create( updateClock )
    	local a2 = cc.DelayTime:create(0.1)
    	self.m_chatButton:runAction(cc.RepeatForever:create(cc.Sequence:create(a1,a2)))
    elseif eventType == ccui.TouchEventType.ended then
		self.m_chatButton:stopAllActions()
    	print("点击结束,时间片",self.press_frame)
    	if self.press_frame >= frameSet then
    		self.m_chatSystemLayer:ontVoiceBtnPressButtons( sender , ccui.TouchEventType.ended )
    	else
    		self.m_chatSystemLayer:onPressMessageButtons( sender , ccui.TouchEventType.began )
    	end
    elseif eventType == ccui.TouchEventType.moved then
    	print("点击移动,时间片",self.press_frame)
    	if self.press_frame >= frameSet then
    		self.m_chatSystemLayer:ontVoiceBtnPressButtons( sender , ccui.TouchEventType.moved )
    	end
    elseif eventType == ccui.TouchEventType.canceled then
    	self.m_chatButton:stopAllActions()
    	print("点击取消,时间片",self.press_frame)
    	self.m_chatSystemLayer:ontVoiceBtnPressButtons( sender , ccui.TouchEventType.canceled )
	end
end

function LandSystemSet:ontVoiceBtnPressButtons(sender,eventType)
    if  sender then 
        if eventType == ccui.TouchEventType.began then 
            print("-----------------------ccui.TouchEventType.began-----------------------")


        elseif eventType == ccui.TouchEventType.moved then
            print("-----------------------ccui.TouchEventType.moved------------------------")

        elseif eventType == ccui.TouchEventType.ended then
            print("-----------------------ccui.TouchEventType.ended-------------------------------")

        elseif eventType == ccui.TouchEventType.canceled then
            print("--------------------ccui.TouchEventType.canceled---------------------------")

        end
    end
end
   
function LandSystemSet:updatePlayerIDS(  _userId , _pos , _pos2 , _isFlipX , _isFlipY )
    if not self.m_chatSystemLayer then return end
    local params = 
    {
        userID        = _userId,       --玩家id
        messagepos    = _pos,          --播放快捷聊天位置/语音的位置
        expressionPos = _pos2,         -- 表情的位置
        isFlippedX    = _isFlipX ,     -- 播放快捷聊天背景/语音背景
        isFlippedY    = _isFlipY ,     -- 播放快捷聊天背景/语音背景
        gender        = 2              -- 性别：0.未知1.男 2.女.
    }

    self.m_chatSystemLayer:setUserIDPos( params )
end

function LandSystemSet:OnTouchSystemSetButton(sender, eventType)
    
    print("sender:::", sender:getName())

    if sender and sender:getTag() then
        local tag = sender:getTag()
        print("sender:getTag()",tostring(tag))
        if eventType == ccui.TouchEventType.ended then
            if tag == LandGlobalDefine.SYSTEMSET_CHAT then
               --聊天
            elseif tag == LandGlobalDefine.SYSTEMSET_SET then
                --设置
                if self.isFunctionButtonsShow == true then
                    self:hideFuctionButtons()
                else
                    self:showFuctionButtons()
                end
            elseif tag == LandGlobalDefine.SYSTEMSET_RULE then
                --规则
                self.m_landMainScene:showRuleLayer()
                self:hideFuctionButtons()
            elseif tag == LandGlobalDefine.SYSTEMSET_LAST_HAND then
                print("上手牌")
                local roomId, roomInfo = FriendRoomController:getInstance():getRoomInfo()
                if IS_PAI_YOU_FANG(self.m_GameId ) == true then
                    if self.m_landMainScene:getGameState() < 1 then -- 未开局
                        if FriendRoomController:getInstance():checkMyselfIsFangzhu()  then
                            print("我为自己创建并加入,我有返回功能")
                            FriendRoomController:getInstance():onClickGoBack(roomId)
                        else
                            self.m_landMainScene:ShowShangShouPai()
                        end
                    else
                        self.m_landMainScene:ShowShangShouPai()
                    end
                else
                    self.m_landMainScene:ShowShangShouPai()
                end
                self:hideFuctionButtons()
            elseif tag == LandGlobalDefine.SYSTEMSET_MUSIC then
                --音效
                self.m_landMainScene:showSettingLayer()
                self:hideFuctionButtons()
            elseif tag == LandGlobalDefine.SYSTEMSET_EXIT then
                --退出
				self:hideFuctionButtons()
                if IS_PAI_YOU_FANG(self.m_GameId ) == true then
                    if self.m_landMainScene:getGameState() < 1 then -- 未开局
                        local roomId, roomInfo = FriendRoomController:getInstance():getRoomInfo()
                        if FriendRoomController:getInstance():checkMyselfIsFangzhu()  then
                            print("解散 房间")
                            self:createFriendJieSanLayer(1)
                        else
                            print("次房主  房客 退出 房间")
                            ConnectManager:send2SceneServer(LandGlobalDefine.FRIEND_ROOM_GAME_ID, "CS_C2M_LandVipRoomQuit_Req", { LandGlobalDefine.FRIEND_ROOM_GAME_ID } )
                        end
                    else
                        --开局了,发起解散游戏投票
                        FriendRoomController:getInstance():sendReqJieShanGameing()
                        --self.m_landMainScene:showJieShanGameLayer(Player:getAccountID())
                    end
                elseif IS_FREE_ROOM(self.m_GameId) then
                    print("金币房退出直接向服务器发送第一次请求")
					g_GameController:reqUserLeftGameServer()
					--g_GameController:releaseInstance()
                else
                    print("a")
                    if self.m_landMainScene:getGameState() < 1 then -- 未开局
                        g_GameController:releaseInstance()
                    else
                        self.m_landMainScene:showExitGameLayer()
                    end
                end
                
            end
        end
    end
end

function LandSystemSet:createFriendJieSanLayer(type)
    if self.mFriendJieSanLayer then
        self.mFriendJieSanLayer = nil
    end
    self.mFriendJieSanLayer = FriendJieSanLayer.new(type)
    self:addChild(self.mFriendJieSanLayer)
end

--显示功能按钮
function LandSystemSet:showFuctionButtons()
    if IS_FAST_GAME(self.m_GameId ) == true or IS_DING_DIAN_SAI(self.m_GameId) == true then
        self.functionButtons[1].spr:setSpriteFrame(display.newSpriteFrame("ddz_gengduo_jiangli.png"))
    end

    if IS_PAI_YOU_FANG(self.m_GameId ) == true then
        if self.m_landMainScene:getGameState() < 1 then -- 未开局
            local roomId, roomInfo = FriendRoomController:getInstance():getRoomInfo()
            if FriendRoomController:getInstance():checkMyselfIsFangzhu() then
                --print("我为自己创建并加入,我有返回解散功能")
                self.functionButtons[2].spr:setSpriteFrame(display.newSpriteFrame("ddz_gengduo_huidating.png"))
                self.functionButtons[4].spr:setSpriteFrame(display.newSpriteFrame("ddz_gengduo_jiesan.png"))
            elseif FriendRoomController:getInstance():checkMyselfIsCiFangzhu() then
                --print("我是第一个加入,我能T人,离开 ,不能回大厅")
                self.functionButtons[2].spr:setSpriteFrame(display.newSpriteFrame("ddz_gengduo_ssp.png"))
                self.functionButtons[4].spr:setSpriteFrame(display.newSpriteFrame("ddz_gengduo_tuichu.png"))
            elseif FriendRoomController:getInstance():checkMyselfIsFangKe() then
               -- print("我是房客, 只能退出 ")
                self.functionButtons[2].spr:setSpriteFrame(display.newSpriteFrame("ddz_gengduo_ssp.png"))
                self.functionButtons[4].spr:setSpriteFrame(display.newSpriteFrame("ddz_gengduo_tuichu.png"))
            end
        else
            --print("已经开始")
            self.functionButtons[2].spr:setSpriteFrame(display.newSpriteFrame("ddz_gengduo_ssp.png"))
            self.functionButtons[4].spr:setSpriteFrame(display.newSpriteFrame("ddz_gengduo_jiesan.png"))
        end
    else
        -- 退出
        if not (IS_DING_DIAN_SAI(self.m_GameId) == true ) then
            self.functionButtons[4].spr:setSpriteFrame(display.newSpriteFrame("ddz_gengduo_tuichu.png"))
        end
    end

    self.set_panel:setVisible(true)
    self.setBg:setVisible( true )

	--[[for i=1,table.nums( self.functionButtons ) do
        local  po = cc.p((self.functionButtons[i].postion.x + self.set_NodePostion.x)/2, (self.functionButtons[i].postion.y + self.set_NodePostion.y)/2)
		self.functionButtons[i].button:setPosition(po)
		self.functionButtons[i].button:setVisible(false)
        self.functionButtons[i].button:setEnabled(false)

        
		self.functionButtons[i].button:runAction(cc.Sequence:create(cc.Show:create(),cc.MoveTo:create(0.1,self.functionButtons[i].postion),cc.CallFunc:create(hideSetPanel)))
	end--]]

    local function hideSetPanel()
        self.backMenu:setEnabled( true )
        self.isFunctionButtonsShow = true
    end

    self.btn_layout:setScale(0.1)
    self.btn_layout:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 1), cc.CallFunc:create(hideSetPanel)))

end

--隐藏功能按钮
function LandSystemSet:hideFuctionButtons()
	local function hideSetPanel()
		self.set_panel:setVisible(false)
        self.setBg:setVisible(false)
        self.isFunctionButtonsShow = false
	end

    self.btn_layout:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 0.1), cc.CallFunc:create(hideSetPanel)))

    self.backMenu:setEnabled(false)

	--[[for i=1,table.nums( self.functionButtons ) do
        self.functionButtons[i].button:setEnabled(true)
        local  po = cc.p((self.functionButtons[i].postion.x + self.set_NodePostion.x)/2, (self.functionButtons[i].postion.y + self.set_NodePostion.y)/2)
		self.functionButtons[i].button:runAction(cc.Sequence:create(cc.MoveTo:create(0.1,po),cc.Hide:create(),cc.CallFunc:create(hideSetPanel)))
	end--]]


end

--设置按钮的可点状态
function LandSystemSet:setSetPanelEnabeled( isEnable )
    self.set_button:setEnabled( isEnable )
end

function LandSystemSet:onTouchCallback(...)

end

return LandSystemSet

