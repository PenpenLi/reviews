--------------------------------------------------------
-- Author: xiewenfu
-- Date: 2017-05-20
-- 定点赛每轮结束
--------------------------------------------------------
local DingDianSaiRoomController =  require("src.app.game.pdk.src.classicland.contorller.DingDianSaiRoomController")
local LandAnimationManager = require("src.app.game.pdk.src.landcommon.animation.LandAnimationManager")
local LandArmatureResource = require("src.app.game.pdk.src.landcommon.animation.LandArmatureResource")
local EnjoyableMomentConfig = require("src.app.game.pdk.src.landcommon.view.match.EnjoyableMomentConfig")
local JumpLabel                = require("src.app.game.pdk.src.landcommon.view.JumpLabel")
local LandDDSRoundEndLayer = class("LandDDSRoundEndLayer", function()
    return display.newLayer()
end)

function LandDDSRoundEndLayer:ctor( landMainScene )
    self.m_landMainScene = landMainScene
    self:initData()
    self:initUI()
    self:initScrollView()
end 

function LandDDSRoundEndLayer:initData()

    self.m_enum = {
        BLANK = 20,
        NUM_EVERY_PAGE = 5, --一页显示多少个段子
    }
    
    self.m_pMainNode = nil
    self.m_pScrollView = nil

    self.m_labelWidth = nil
    self.m_labelX = nil
    
    self.m_JokeTable = {}
    self.isCanTouch = true
    self.isBottom = false
    self.isTop = false
    -- by dzf, 三小时内仍然显示同一页笑话
    self.m_nJokeIndex = self:getJokeIndexAndPosition() - self.m_enum.NUM_EVERY_PAGE
end
function LandDDSRoundEndLayer:initUI()
 
    self.m_pMainNode = cc.CSLoader:createNode("src/app/game/pdk/res/csb/land_match_cs/land_match_wait.csb")
    self:addChild( self.m_pMainNode )
    UIAdapter:adapter( self.m_pMainNode , handler(self, self.onTouchCallback) )
    local layout_hall_bg = self.m_pMainNode:getChildByName("layout_hall_bg") 

    -- if self.m_landMainScene.getGameAtom and IS_HAPPY_LAND( self.m_landMainScene:getGameAtom()) then
    --     local bg_left_spr = self.m_pMainNode:getChildByName("bg_left_spr")
    --     local bg_right_spr = self.m_pMainNode:getChildByName("bg_right_spr")
    --     bg_right_spr:setVisible(false)
    --     bg_left_spr:setVisible(false)
        
    --     local sprite = cc.Sprite:create("big_pic/hldz_bg_background2.png")
    --     sprite:setAnchorPoint(cc.p(0,0))

    --     layout_hall_bg:addChild(sprite)
    -- end
    self:initGPS()
    self:addWaitingOtherPlayerLabel()
    self.my_rank_label = self.m_pMainNode:getChildByName("text_ju_count_1")
    self.player_count_label = self.m_pMainNode:getChildByName("text_ju_count_2")
    self.table_label   = self.m_pMainNode:getChildByName("text_ju_count_3")
    self.my_rank_label:setVisible(false)
    self.player_count_label:setVisible(false)
    self.table_label:setVisible(false)
    self.layout_win = self.m_pMainNode:getChildByName("animation_node_win")
    self.animation_node = self.m_pMainNode:getChildByName("animation_node")
    self.animation_node:setVisible(false)
end

function LandDDSRoundEndLayer:initGPS()
    self.layout_lu = self.m_pMainNode:getChildByName("layout_lu")
    self.layout_lu:setVisible( false )
end

function LandDDSRoundEndLayer:initScrollView()
    self.m_pScrollView = self.m_pMainNode:getChildByName("ScrollView_1")

    self.btn_lastpage = self.m_pMainNode:getChildByName("btn_lastpage")

    local function onClick1( sender, eventType )
        if eventType ~= ccui.TouchEventType.ended then return end
        if self.isCanTouch == false  then return end
        self:showJoke(false)
    end
    self.btn_lastpage:addTouchEventListener( onClick1 )



    self.btn_nextPage = self.m_pMainNode:getChildByName("btn_nextpage")
    
    local function onClick2( sender, eventType )
        if eventType ~= ccui.TouchEventType.ended then return end
        if self.isCanTouch == false  then return end
        self:showJoke(true)
    end
    self.btn_nextPage:addTouchEventListener( onClick2 )



    local content = self.m_pScrollView:getChildByName("text_context")
    content:setVisible(false)
    self.m_labelWidth = content:getContentSize().width
    self.m_labelX = content:getPositionX()

    self.m_pScrollView:addEventListener(handler(self, self.scrollviewEvent))
    self.m_pScrollView:addTouchEventListener(handler(self, self.scrollviewTouchEvent))
    
    self:showJoke()
end

function LandDDSRoundEndLayer:removeAllJoke()

     self.m_pScrollView:removeAllChildren()
end

function LandDDSRoundEndLayer:addWaitingOtherPlayerLabel()
    self.jumpLabel = JumpLabel.new("刷新中．．．", 25, cc.c3b(179, 114, 69))
    self.jumpLabel:setPositionWithMidAnchor( cc.p(display.cx, display.cy-200) )
    local panel_bg = self.m_pMainNode:getChildByName("panel_bg")
    panel_bg:addChild( self.jumpLabel , 999)
    self.jumpLabel:setPosition(cc.p(panel_bg:getContentSize().width/2-80, panel_bg:getContentSize().height/2))
    self.jumpLabel:setVisible(false)
end

function LandDDSRoundEndLayer:showJumpLabel()
    self.jumpLabel:setVisible(true)
end

function LandDDSRoundEndLayer:hideJumpLabel()
    self.jumpLabel:setVisible(false)
end

function LandDDSRoundEndLayer:getOnePageJoke()
    local tbl = {}
    self.m_nJokeIndex = math.abs(self.m_nJokeIndex )
    if self.ret == false then
        self.m_nJokeIndex = self.m_nJokeIndex - 2*self.m_enum.NUM_EVERY_PAGE
        if self.m_nJokeIndex < 0 then
            self.m_nJokeIndex = math.abs(#EnjoyableMomentConfig + self.m_nJokeIndex)
        end
    end

    for i = 1, self.m_enum.NUM_EVERY_PAGE do
        table.insert(tbl, EnjoyableMomentConfig[self.m_nJokeIndex])
        print("<<<<<<<<<<<<<<<<<<<<<<<<",self.m_nJokeIndex)
        self.m_nJokeIndex = self.m_nJokeIndex + 1
        
        if self.m_nJokeIndex > #EnjoyableMomentConfig then
            self.m_nJokeIndex = self.m_nJokeIndex - #EnjoyableMomentConfig
        end
    end

    return tbl
end

function LandDDSRoundEndLayer:createJoke()
   local jokeTable = self:getOnePageJoke()
    local jokeLabelTable = {}
    local jokeLabelTable1 = {}
    local totalHeight = self.m_enum.BLANK
    local scrollViewS = self.m_pScrollView:getContentSize()

    for i = 1, #jokeTable do
        jokeLabelTable[i] = display.newTTFLabel( {
            text = jokeTable[i].title,
            font = "font/jcy.TTF", 
            size = 26, 
            color = cc.c3b(179, 114, 69),
            dimensions = cc.size(self.m_labelWidth, 0),
        } )

        jokeLabelTable[i]:setAnchorPoint(cc.p(0, 1))
        self.m_pScrollView:addChild(jokeLabelTable[i])

        jokeLabelTable1[i] = display.newTTFLabel( {
            text =  jokeTable[i].content, 
            font = "font/jcy.TTF", 
            size = 25, 
            color = cc.c3b(110, 76, 46),
            dimensions = cc.size(self.m_labelWidth, 0),
        } )

        jokeLabelTable1[i]:setAnchorPoint(cc.p(0, 1))
        self.m_pScrollView:addChild(jokeLabelTable1[i])


        local label_jokeS = jokeLabelTable[i]:getContentSize()
        local label_jokeS1 = jokeLabelTable1[i]:getContentSize()
        totalHeight = totalHeight + label_jokeS.height + label_jokeS1.height + self.m_enum.BLANK
    end
    --
    local now_y
    if scrollViewS.height > totalHeight then
        self.m_pScrollView:setInnerContainerSize(cc.size(scrollViewS.width, scrollViewS.height))
        now_y = scrollViewS.height - 10
    else
        self.m_pScrollView:setInnerContainerSize(cc.size(scrollViewS.width, totalHeight))
        now_y = totalHeight - 10
    end

    local first = display.newTTFLabel( {
            text = "上一页",
            font = "font/jcy.TTF", 
            size = 26, 
            color = cc.c3b(179, 114, 69),
            dimensions = cc.size(self.m_labelWidth, 0),
        } )
    first:setAnchorPoint(cc.p(0, 1))
    first:setTag(258147)
    self.m_pScrollView:addChild(first)
    first:setPosition(cc.p(self.m_labelX, now_y+150))
    for i = 1, #jokeLabelTable do
        jokeLabelTable[i]:setPosition(cc.p(self.m_labelX, now_y))

        now_y = now_y - jokeLabelTable[i]:getContentSize().height

        jokeLabelTable1[i]:setPosition(cc.p(self.m_labelX, now_y))
        now_y = now_y - jokeLabelTable1[i]:getContentSize().height - self.m_enum.BLANK
    end

    local last = display.newTTFLabel( {
            text = "下一页",
            font = "font/jcy.TTF", 
            size = 26, 
            color = cc.c3b(179, 114, 69),
            dimensions = cc.size(self.m_labelWidth, 0),
        } )
    last:setAnchorPoint(cc.p(0, 1))
    last:setTag(147258)
    self.m_pScrollView:addChild(last)
    last:setPosition(cc.p(self.m_labelX, now_y-130))   

    self.m_pScrollView:jumpToTop()
    
end

function LandDDSRoundEndLayer:showJoke(ret)
    self:removeAllJoke()
    self:showJumpLabel()
    self.ret = ret
    self.isCanTouch = false
    self.m_pScrollView:setTouchEnabled(false)
    local callfun = CALL_FUNC(function ()
        self:hideJumpLabel()
        self:createJoke()
        self.m_pScrollView:setTouchEnabled(true)
        self:setJokeIndexAndPosition()
        self.isCanTouch = true
    end)
    self:runAction(cc.Sequence:create(D(0.5), callfun))
end

function LandDDSRoundEndLayer:checkPos( text1, text2, pos)
    local con1 = text1:getContentSize().width
    local con2 = text2:getContentSize().width
    local con = con1 + con2
    local posX1 = pos - (con/2 - con1/2) - 5
    local posX2 = pos + (con/2 - con2/2) + 5
    return posX1, posX2
end

function LandDDSRoundEndLayer:updateLeftTableUI( leftNum , _rank )

    local myRank = DingDianSaiRoomController:getInstance():getDDSMyRank()
    if _rank and _rank > 0 then
    	myRank = _rank
    end

    local leftPlayer = DingDianSaiRoomController:getInstance():getLeftPlayerNum()

    if self.table_label1 then
        self.table_label1:removeFromParent()
        self.table_label1 = nil
    end
    if self.my_rank_label1 then
        self.my_rank_label1:removeFromParent()
        self.my_rank_label1 = nil
    end
    if self.player_label1 then
        self.player_label1:removeFromParent()
        self.player_label1 = nil
    end
    print("adfaf ", leftNum, myRank, leftPlayer)

    self.lord_match_img_sprit = self.m_pMainNode:getChildByName("lord_match_img_sprit")

    self.my_rank_label1 = cc.LabelAtlas:_create( tostring( myRank ) ,  "number/lord_dds_num_ranking.png",40,48,48)
    self.my_rank_label1:setAnchorPoint(cc.p(1,0.5))
    self.my_rank_label:getParent():addChild( self.my_rank_label1 )
   

    self.player_label1 = cc.LabelAtlas:_create( tostring( leftPlayer ) ,  "number/lord_dds_num_people.png",26,34,48)
    self.player_label1:setAnchorPoint(cc.p(0.5,0.5))
    self.player_count_label:getParent():addChild( self.player_label1 )
    self.player_label1:setPosition( self.player_count_label:getPosition())

    local x1,x2 = self:checkPos( self.lord_match_img_sprit , self.player_label1, 225)

    self.lord_match_img_sprit:setPositionX(x1+self.my_rank_label1:getContentSize().width/2)
    self.player_label1:setPosition(cc.p(x2+self.my_rank_label1:getContentSize().width/2, self.lord_match_img_sprit:getPositionY()))
    self.my_rank_label1:setPosition( cc.p(self.lord_match_img_sprit:getPositionX()-self.lord_match_img_sprit:getContentSize().width/2-10, self.lord_match_img_sprit:getPositionY()))


    self.lord_dds_txt_tablenum = self.m_pMainNode:getChildByName("lord_dds_txt_tablenum")
    self.table_label1 = cc.LabelAtlas:_create( tostring( leftNum ) ,  "number/lord_dds_num_people.png",26,34,48)
    self.table_label1:setAnchorPoint(cc.p(0.5,0.5))
    self.table_label:getParent():addChild( self.table_label1 )

    local x1,x2 = self:checkPos( self.lord_dds_txt_tablenum , self.table_label1, 225)
    self.lord_dds_txt_tablenum:setPositionX(x1)
    self.table_label1:setPosition(cc.p(x2,self.table_label:getPositionY()))
end

function LandDDSRoundEndLayer:showWaitRankAnimation()
	if self.animation_node:isVisible() then return end
    self.layout_win:setVisible(false)
    self.animation_node:setVisible(true)
    self.animation_node:removeAllChildren()
    LandAnimationManager:getInstance():PlayAnimation(LandArmatureResource.ANI_DIZHUSHAOBA, self.animation_node)
end

function LandDDSRoundEndLayer:showJinJiAnimation()
    self.animation_node:setVisible(false)
    self.layout_win:setVisible(true)
    self.layout_win:removeAllChildren()
    local animation = LandAnimationManager:getInstance():getAnimation(LandArmatureResource.ANI_MATCH, self.layout_win, cc.p(0,-200))
    animation:playAnimationByName("lord_match_ani_ranking01")
    animation:setScale(1.1)
end

function LandDDSRoundEndLayer:onTouchCallback( sender )
    local name = sender:getName()
    local tag = sender:getTag()
    print("LandDDSRoundEndLayer name: ", name)
end

function LandDDSRoundEndLayer:getJokeIndexAndPosition()
    local index  = cc.UserDefault:getInstance():getIntegerForKey("landlord_jokecount", 1)

    return index
end

function LandDDSRoundEndLayer:setJokeIndexAndPosition()
    local index = self.m_nJokeIndex
    if index == 0 then
        index = 1
    end
    if index < 0 then
        index = #EnjoyableMomentConfig + index
    end
    index  = cc.UserDefault:getInstance():setIntegerForKey("landlord_jokecount", index)
    return index
end

function LandDDSRoundEndLayer:scrollviewEvent( sender , event )
    if event == ccui.ScrollviewEventType.bounceTop then
        if self.move_offset > 20 then
            print("触发上刷新")
            self.move_offset = 0
            self:showJoke(false)
        end
        print("bounceTop")
    elseif event == ccui.ScrollviewEventType.bounceBottom then
        if self.move_offset > 20 then
            print("触发下刷新")
            self.move_offset = 0
            self:showJoke(true)
        end
        print("bounceBottom")
    elseif event == ccui.ScrollviewEventType.scrollToTop then
        print("scrollToTop")
    elseif event == ccui.ScrollviewEventType.scrollToBottom then
        print("scrollToBottom")
    end
end

function LandDDSRoundEndLayer:scrollviewTouchEvent( sender , event )
    --print("scrollviewTouchEvent", event , ret )
    if event == ccui.TouchEventType.began then
        self.move_offset = 0
    elseif event == ccui.TouchEventType.moved then
        self.move_offset = self.move_offset + 1
        --print("<<", self.move_offset)
    end
end

return LandDDSRoundEndLayer


