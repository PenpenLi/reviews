--------------------------------------------------------
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 每一轮的提示
--------------------------------------------------------
local FastRoomController =  require("src.app.game.pdk.src.classicland.contorller.FastRoomController")

local LandMatchTipsLun = class("LandMatchTipsLun", function()
    return display.newLayer()
end)

function LandMatchTipsLun:ctor( landMainScene )
    self.m_landMainScene = landMainScene
    self:initUI()
end 

function LandMatchTipsLun:initUI()
    self.m_pMainNode = cc.CSLoader:createNode("src/app/game/pdk/res/csb/land_match_cs/land_match_tips_lun.csb")
    UIAdapter:adapter( self.m_pMainNode , handler(self, self.onTouchCallback) )
    self:addChild( self.m_pMainNode)
    self:intiFirstNode()

end

function LandMatchTipsLun:resetFirstNode()
    self:setVisible(true)
    self.firstRoundNode:setVisible(true)
    self.roundNode:setPosition( self.roundNodePos )

end

-- 前多少名晋级 共多少局 提示
function LandMatchTipsLun:intiFirstNode()
    self.firstRoundNode = self.m_pMainNode:getChildByName("first_round_node")
    self.firstRoundNode:setVisible(false)
    self.roundNode = self.firstRoundNode:getChildByName("Panel_4")
    self.roundNodePos = cc.p(self.roundNode:getPosition())

    local layout_bg_1_0 = self.firstRoundNode:getChildByName("layout_bg_1_0")
    layout_bg_1_0:setScaleX(display.width/1280)

    local matchBeforeGameInfo = FastRoomController:getInstance():getMatchBeforeGameInfo()

    --前多少名晋级
    self.rankLabel = self.roundNode:getChildByName("text_ming_count")
    self.rankLabel:setString("")

    self.lord_match_txt_front = self.roundNode:getChildByName("lord_match_txt_front")
    self.lord_match_txt_ranking = self.roundNode:getChildByName("lord_match_txt_ranking")

    local curCnt = matchBeforeGameInfo.upgradeCnt      --本轮多少人晋级
    local lastCnt = matchBeforeGameInfo.lastUpgradeCnt -- 上一轮多少人晋级

    local totalJU = FastRoomController:getInstance().MatchBeforeGameInfo.roundIndex--第几局
    local allJU = FastRoomController:getInstance():getTotalJU() -- 本轮共几局

    local taotaiCnt = (lastCnt-curCnt)   -- 本轮淘汰人数

    local label = cc.LabelAtlas:_create(tostring( curCnt ), "number/ddz_shizi_huang2.png",68,68, 48)
    label:setAnchorPoint(cc.p(0.5, 0.5))

    self.rankLabel:getParent():addChild(label)

    label:setPosition(self.rankLabel:getPosition()) 

    local conSize = label:getContentSize()
    self.lord_match_txt_front:setPositionX(self.rankLabel:getPositionX() - conSize.width/2-20)
    self.lord_match_txt_ranking:setPositionX(self.rankLabel:getPositionX() + conSize.width/2+20)


    local number = self.roundNode:getChildByName("number")
    number:setString("")

    local numberLabel = cc.LabelAtlas:_create(tostring( totalJU ), "number/ddz_shizi_huang2.png",68, 68, 48)
    numberLabel:setAnchorPoint(cc.p(0.5, 0.5))

    number:getParent():addChild(numberLabel)

    numberLabel:setPosition(number:getPosition())

end

function LandMatchTipsLun:showFirstNode(time)
    self:resetFirstNode()

    self.roundNode:setPosition(cc.p(-display.width, self.roundNodePos.y))
    
    local tim = 0.3
    local function moveToMiddle()
        local movetoR = cc.MoveTo:create(tim, cc.p(self.roundNodePos.x, self.roundNodePos.y))
        self.roundNode:runAction(movetoR)
    end

    local function FadeOut()
        local moveto  = cc.ScaleTo:create(tim,2)
        local fadeOut = cc.FadeOut:create(tim)
        self.roundNode:runAction(cc.Spawn:create(moveto, fadeOut))
    end 

    local function onComplete()
        self:setVisible(false)
        self.firstRoundNode:setVisible(false)
    end

    local a1 = cc.CallFunc:create( moveToMiddle )
    local a2 = cc.CallFunc:create( FadeOut )
    local a3 = cc.CallFunc:create( onComplete )
    local actions = cc.Sequence:create( a1, D(time), a2, D(0.4), a3 )
    self.firstRoundNode:runAction( actions )
end


function LandMatchTipsLun:onTouchCallback( sender )
    local name = sender:getName()
    local tag = sender:getTag()
    print("LandMatchTipsLun name: ", name)
    --self:removeFromParent()
end

return LandMatchTipsLun


