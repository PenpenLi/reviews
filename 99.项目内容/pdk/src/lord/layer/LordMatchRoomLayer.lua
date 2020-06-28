local CommonRoom = import("app.newHall.layer.CommonRoom")
local LordRoomLayer = class("LordRoomLayer", function()
    return CommonRoom.new()
end) --继承基类
local ddzRankLayer = import("src.app.newHall.childLayer.DDZRankLayer")
local ddzMatchRuleLayer = import("src.app.newHall.childLayer.DDZMatchRuleLayer")
local PREFIX        = "game/lord/"
local PATH_ROOM_CSB = "game/lord/csb/gui-lord-roomChoose.csb"
local PATH_ROOM_UI  = "game/lord/csb/gui-lord-roomMatchLayer.csb"
local PATH_ROOM_LOAD = "game/lord/csb/gui-lord-roomChoose2.csb"

local MUSIC = "game/lord/sound/MusicEx_Normal.mp3"

local CONFIG = {
	[1] = {
        RoomScore   = 1,
		AnimName 	= PREFIX .. "effect/325ddz_baiwanchang_donghua/325ddz_baiwanchang_donghua",
	},
	[2] = {
        RoomScore   = 200,
		AnimName 	= PREFIX .. "effect/325ddz_weikaifang02_donghua/325ddz_weikaifang02_donghua",
	},
	[3] = {
        RoomScore   = 2000,
		AnimName 	= PREFIX .. "effect/325ddz_weikaifang03_donghua/325ddz_weikaifang03_donghua",
	},
--	[4] = {
--        RoomScore   = 10000,
--		AnimName 	= PREFIX .. "effect/325ddz_baiwanchang_donghua/325ddz_baiwanchang_donghua",
--	},
--    [5] = {
--        RoomScore   = 50000,
--		AnimName 	= PREFIX .. "effect/325ddz_weikaifang02_donghua/325ddz_weikaifang02_donghua",
--	},
--    [6] = {
--        RoomScore   = 200000,
--		AnimName 	= PREFIX .. "effect/325ddz_weikaifang03_donghua/325ddz_weikaifang03_donghua",
--	},
}

local MUSIC = "game/lord/sound/MusicEx_Normal.mp3"

function LordRoomLayer:ctor(roomList) 
    self:init(roomList)
end

function LordRoomLayer:init(roomList)
    self._roomList = roomList
    self:initCSB()
    self:initNode()
    self:initCommonRoom()
end

function LordRoomLayer:onEnter()
    self.super:onEnter()
end

function LordRoomLayer:onExit()
    self.super:onExit()
end

function LordRoomLayer:initCSB()

    --node path
    self.m_pathUI = cc.CSLoader:createNode(PATH_ROOM_CSB):addTo(self)

    --node base
    self.m_pNodeUI = self.m_pathUI:getChildByName("Layer_base") 
    local diffY = (display.size.height - 750) / 2
     self.m_pathUI:setPosition(cc.p(0,diffY)) 
    local diffX = 145-(1624-display.size.width)/2 
    self.m_pNodeUI:setPositionX(diffX)
    --node child
    self.m_pNodeBack  = self.m_pNodeUI:getChildByName("Node_back")
    self.m_pNodeBg    = self.m_pNodeUI:getChildByName("Node_bg")
    self.m_pNodeMenu  = self.m_pNodeUI:getChildByName("Node_menu")
    self.m_pNodeRoom  = self.m_pNodeUI:getChildByName("Node_room")
    self.m_pNodeUser  = self.m_pNodeUI:getChildByName("Node_user")
    self.m_pNodeGold  = self.m_pNodeUI:getChildByName("Node_gold")
    self.m_pNodeBank  = self.m_pNodeUI:getChildByName("Node_bank")
    self.m_pNodeStart = self.m_pNodeUI:getChildByName("Node_start")
    self.m_pNodeTop   = self.m_pNodeUI:getChildByName("Node_top")

    self.m_pImageLogo  = self.m_pNodeTop:getChildByName("Image_logo")     --0.游戏名
    self.m_pImageLogo:loadTexture("game/lord/gui/title.png")
    self.m_pBtnReturn  = self.m_pNodeMenu:getChildByName("Button_back")   --1.退出按钮
    self.m_pBtnRule    = self.m_pNodeMenu:getChildByName("Button_help")   --2.规则按钮
    self.m_pBtnRecord    = self.m_pNodeMenu:getChildByName("Button_1")   --3.战绩按钮 
    self.m_pRoomView   = self.m_pNodeRoom:getChildByName("Scroll_View")   --3.房间
    self.m_pLabelName  = self.m_pNodeUser:getChildByName("Text_name")     --4.名字
    self.m_pImageLevel = self.m_pNodeUser:getChildByName("Image_vip")     --5.等级
    self.m_pImageHead  = self.m_pNodeUser:getChildByName("Image_head")    --6.头像
    self.m_pImageFrame = self.m_pNodeUser:getChildByName("Image_frame")   --7.头像框
    self.m_pLabelGold  = self.m_pNodeGold:getChildByName("Text_gold")     --8.金币
    self.m_pImageBank  = self.m_pNodeGold:getChildByName("Image_gold")    --9.银行点击
    self.m_pBtnBank = self.m_pNodeGold:getChildByName("Button_bank")      --9.银行点击
 --   self.m_pBtnBank:setVisible(false)
    self.m_pLabelBank  = self.m_pNodeBank:getChildByName("Text_bank")     --9.银行
    self.m_pBtnStart   = self.m_pNodeStart:getChildByName("Button_quick") --10.开始
    self.m_pImage_bar  = self.m_pNodeBg:getChildByName("Image_bg")        --信息底框
    self.m_pImage_bg1  = self.m_pNodeBack:getChildByName("Image_1")       --近景
    self.m_pImage_bg2  = self.m_pNodeBack:getChildByName("Image_2")       --中景
    self.m_pImage_bg3  = self.m_pNodeBack:getChildByName("Image_3")       --远景

    --房间csb
    self.m_pRoomView:removeAllChildren()
    self.m_pRoomView:setBounceEnabled(true)
    self.m_pRoomUI = cc.CSLoader:createNode(PATH_ROOM_UI)
    self.m_pRoomUI:addTo(self.m_pRoomView)
    self.m_pRoomLayer = self.m_pRoomUI:getChildByName("Panel")
    self.m_pBtnRecord:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self.RankLayer = ddzRankLayer.new();
                self:addChild(self.RankLayer)  
            end
    end)
    self.m_pBtnRule:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self.MatchRuleLayer = ddzMatchRuleLayer.new();
                self:addChild(self.MatchRuleLayer)  
            end
    end)
      self.m_pBtnRule:setPositionX( 202 )
     self.m_pBtnRule:setPositionY( 680 )

    --换图
    self.m_pImageLogo:ignoreContentAdaptWithSize(true)
    self.m_pImageLogo:setScale(0.5)
    self.m_pImageLogo:loadTexture("app/game/pdk/res/alter/pdk_logo.png")
end

function LordRoomLayer:initNode()

    --房间
    self.m_pBtnRoom = {}
    self.m_pImageState = {}
    self.m_pNodeRoomList = {}
    for i, v in pairs(CONFIG) do
        
        --房间节点
        local node = self.m_pRoomLayer:getChildByName("Panel_" .. v.RoomScore)
        local node_spine = node:getChildByName("Node_spine")
        local node_name  = node:getChildByName("Image_name")
        local node_score = node:getChildByName("Text_score")
        local node_base  = node:getChildByName("Text_base")
        local node_click = node:getChildByName("Image_click")
        local node_state = node:getChildByName("Image_state")

        self.m_pNodeRoomList[i] = node
        self.m_pNodeRoomList[i]:setTag(v.RoomScore)
        self.m_pImageState[i] = node_state
        self.m_pImageState[i]:setTag(v.RoomScore)

        --动画节点
        local skeNode = sp.SkeletonAnimation:createWithBinaryFile(v.AnimName .. ".skel", v.AnimName .. ".atlas", 1)
        if skeNode then
            skeNode:setPosition(cc.p(0 ,0))
            skeNode:setAnimation(0, "animation", true)
            skeNode:addTo(node_spine)
        end

        --按钮节点
        local size_click = node_click:getContentSize()
        local pos_click = cc.p(node_click:getPosition())

        --使用ControlButton
        local pSprite = cc.Sprite:createWithSpriteFrameName("hall/plist/hall/gui-texture-null.png")
        local pSpriteNormal = ccui.Scale9Sprite:createWithSpriteFrame(pSprite:getSpriteFrame())
        local pSpriteSelect = ccui.Scale9Sprite:createWithSpriteFrame(pSprite:getSpriteFrame())
        local pButtonClick = cc.ControlButton:create(pSpriteNormal)
        pSpriteNormal:setContentSize(size_click)
        pSpriteSelect:setContentSize(size_click)
        --pButtonClick:setBackgroundSpriteForState(pSpriteSelect, cc.CONTROL_STATE_HIGH_LIGHTED)
        pButtonClick:setSwallowsTouches(false)
        pButtonClick:setContentSize(size_click)
        pButtonClick:setAnchorPoint(0.5, 0.5)
        pButtonClick:setPosition(pos_click)
        pButtonClick:setTag(i)
        pButtonClick:addTo(node, 999)
        table.insert(self.m_pBtnRoom, pButtonClick)

        --记录点击放大的节点
        pButtonClick.nodeClick = node
    end

    --灯笼特效
    local bgSpine = "game/lord/effect/325ddz_beijing_donghua/325ddz_beijing_donghua"
    local skeNode = sp.SkeletonAnimation:createWithBinaryFile(bgSpine .. ".skel", bgSpine .. ".atlas", 1)
    local sizeBg1 = self.m_pImage_bg1:getContentSize()
    if skeNode then
        skeNode:setPosition(cc.p(sizeBg1.width * 0.5, 375))
        skeNode:setAnimation(0, "animation", true)
        skeNode:addTo(self.m_pImage_bg1)
    end

    --马车特效
    local bgSpine = "game/lord/effect/325ddz_beijing_ma/325ddz_beijing_ma"
    local skeNode = sp.SkeletonAnimation:createWithBinaryFile(bgSpine .. ".skel", bgSpine .. ".atlas", 1)
    local sizeBg2 = self.m_pImage_bg2:getContentSize()
    if skeNode then
        skeNode:setPosition(cc.p(sizeBg2.width * 0.6, 375))
        skeNode:setAnimation(0, "animation", true)
        skeNode:addTo(self.m_pImage_bg2)
    end

    --背景位置调整
    --[[local diffX = (1334 - display.width) / 2
    self.m_pImage_bg1:setPositionX(diffX)
    self.m_pImage_bg2:setPositionX(diffX)
    self.m_pImage_bg3:setPositionX(diffX)]]--

    --监听scrollview
    --self.m_pRoomView:addEventListener(handler(self, self.scrollViewDidScroll))
end

function LordRoomLayer:initCommonRoom()

    --绑定4个button
    self:setButtonReturn(self.m_pBtnReturn)
    
 --   self:setButtonRule(self.m_pBtnRule) 
    self:setButtonStart(self.m_pBtnStart)
    self:setButtonRoom2(self.m_pBtnRoom)
    self:setButtonBank(self.m_pImageBank)
    self:setButtonBank(self.m_pBtnBank)

    --绑定4个image
    self:setImageLevel(self.m_pImageLevel)
    self:setImageHead(self.m_pImageHead)
    self:setImageFrame(self.m_pImageFrame)
    --self:setImageState(self.m_pImageState)

    --绑定3个label
    self:setLabelName(self.m_pLabelName)
    self:setLabelGold(self.m_pLabelGold)
    self:setLabelBank(self.m_pLabelBank)

    --列表
    --self:setScrollView(self.m_pRoomView, self.m_pRoomLayer)

    --箭头
    --self:createArrow(self.m_pRoomView, self.m_pRoomLayer, self.m_pNodeRoom, handler(self, self.moveView))

    --位置
--    self:adaptInfoTop({self.m_pBtnReturn, self.m_pBtnRule,self.m_pBtnRecord }, {self.m_pImageLogo, })
--    self:adaptInfoBar({self.m_pNodeUser, self.m_pNodeGold, self.m_pNodeStart, })

    --入场动画
    self:playActionTop({self.m_pBtnReturn, self.m_pBtnRule,self.m_pBtnRecord, self.m_pImageLogo, })
    self:playActionBar({self.m_pNodeUser, self.m_pNodeGold, self.m_pNodeBank, self.m_pNodeStart, self.m_pImage_bar, })
    self:playActionList2(self.m_pNodeRoomList)

    --背景音乐
    --self:playBGMusic(MUSIC)
end

function LordRoomLayer:scrollViewDidScroll(pView)

    local offset = pView:getInnerContainerPosition()
    print("scorll view offset", offset.x)

    self:moveView(offset.x)
end

function LordRoomLayer:moveView(offsetX)
    
    local posX = (1334 - display.width) / 2
    local diffX_2 = offsetX
    local diffX_4 = offsetX / 5
    local diffX_8 = offsetX / 10

    if offsetX == 0 then
        self.m_pImage_bg1:setPositionX(posX)
        self.m_pImage_bg2:setPositionX(posX)
        self.m_pImage_bg3:setPositionX(posX)
    else
        self.m_pImage_bg1:setPositionX(posX + diffX_2)
        self.m_pImage_bg2:setPositionX(posX + diffX_4)
        self.m_pImage_bg3:setPositionX(posX + diffX_8)
    end
end

return LordRoomLayer
-- endregion
