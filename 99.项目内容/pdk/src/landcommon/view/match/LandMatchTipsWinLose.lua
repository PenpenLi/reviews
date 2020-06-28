--------------------------------------------------------
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 超快赛和定点赛中的提示
--------------------------------------------------------
local FastRoomController =  require("src.app.game.pdk.src.classicland.contorller.FastRoomController")
local DingDianSaiRoomController =  require("src.app.game.pdk.src.classicland.contorller.DingDianSaiRoomController")
local LandAnimationManager = require("src.app.game.pdk.src.landcommon.animation.LandAnimationManager")
local LandArmatureResource = require("src.app.game.pdk.src.landcommon.animation.LandArmatureResource")
local LandGlobalDefine = require("app.game.pdk.src.landcommon.data.LandGlobalDefine")
local StringConfig = require("app.game.pdk.src.landcommon.data.StringConfig")

local LandMatchTipsWinLose = class("LandMatchTipsWinLose", function()
    return display.newLayer()
end)

function LandMatchTipsWinLose:ctor( landMainScene )
    self.m_landMainScene = landMainScene
    self:initData()
    self:initUI()
end 

function LandMatchTipsWinLose:initData()
    self.num_tbl = {}
end

function LandMatchTipsWinLose:initUI()
    self.m_pMainNode = cc.CSLoader:createNode("src/app/game/pdk/res/csb/land_match_cs/land_match_tips_winlose.csb")
    UIAdapter:adapter( self.m_pMainNode , handler(self, self.onTouchCallback) )
    self:addChild( self.m_pMainNode)

    self:initUpGradeNode()
end

 -- 每一轮打完的提示
function LandMatchTipsWinLose:initUpGradeNode()

    self.upGradeNode = self.m_pMainNode:getChildByName("upgrade_node")
    local bgNode = self.upGradeNode:getChildByName("layoubg")
    bgNode:setContentSize(display.size)
    self.upGradeNode:setVisible(false)

    self.Node_25 = self.upGradeNode:getChildByName("Node_25")
    -- 第几轮
    self.curRankLabel     =  self.upGradeNode:getChildByName("text_ju_count_1")
    self.totalPlayerLabel = self.upGradeNode:getChildByName("text_ju_count_2")

    self.curRankLabel:setString("")
    self.totalPlayerLabel:setString("")
end

function LandMatchTipsWinLose:resetNumTbl()
	local mBefore = self:getBeforeData()
	local allRoundTbl = self:getAllRoundInfo()

	local NextRound = mBefore.roundIndex + 1
	local tail = math.max(5,math.min(NextRound + 2,#allRoundTbl))

	self.nextround_on_pos = 3
	self.num_tbl = {}

	for i=tail-4,tail do
		table.insert( self.num_tbl , allRoundTbl[i] )
		if i == NextRound then
			self.nextround_on_pos = #self.num_tbl
		end
	end
end

function LandMatchTipsWinLose:resetGPSNode()
	self:resetNumTbl()
    self.layout_lu = self.upGradeNode:getChildByName("layout_lu")
    self.gps_icon = self.upGradeNode:getChildByName("lord_match_icon_gps")
    self.loadingBar_nodes      = {}
    self.node_pos_info  = {}

    for i=1,5 do
        self.loadingBar_nodes[i] = self:updateOneNode(i)
        self.node_pos_info[i] = 16+(i-1)*161
    end
    if #self.num_tbl == 3 then
    	self.layout_lu:setPositionX(100)
    end
end

function LandMatchTipsWinLose:updateGps( _lose )
	self:resetGPSNode()
    self:updateGpsIconPos( self.nextround_on_pos-1 , _lose )
end

function LandMatchTipsWinLose:updateGpsIconPos( _idx , _lose )
	print("updateGpsIconPos",_idx,_lose )
	local idx = math.max(1,_idx)
    local x = self.node_pos_info[ idx ]
    local loadingBar = self.loadingBar_nodes[idx+1]
    local y = 100
    local dis = 161
    if _lose then
        dis = 0
    end
    self.gps_icon:setPosition( cc.p(x,y) )
    
    if dis > 0 then
        local up = cc.JumpBy:create(0.4, cc.p(0,0), 15, 1) 
        local down = up:reverse()
        local rot  = cc.RotateBy:create(0.1, -30)
        local moveTo = cc.MoveTo:create(0.5,cc.p(x+dis, y))
        local jumpB = cc.Repeat:create( cc.Sequence:create(up, down) , 20 )
        local roback = rot:reverse()
        local ac = cc.Sequence:create( D(0.2),rot,moveTo,roback,jumpB)

        self.gps_icon:runAction( ac )

        local gapTime = 1/30
        local val = 0
        local gap = math.ceil(100/30)

        local function update()
            if val >= 100 then return end
            val = val+gap
            if loadingBar then loadingBar:setPercent(val) end
        end

        local a1 = cc.CallFunc:create( update )

        local action = cc.Repeat:create(cc.Sequence:create( a1 , D(gapTime) ), 30)
        local action = cc.Repeat:create(cc.Sequence:create(D(gapTime) ), 30)

        self:runAction(cc.Sequence:create(action, D(0)))--, cc.RemoveSelf:create()))
	end
end

function LandMatchTipsWinLose:updateOneNode( i )
	local gnode     = self.layout_lu:getChildByName("Panel_"..i)
	gnode:setVisible( false )
	local num   = self.num_tbl[i]
	if not num then return end
	gnode:setVisible( true )

	local mBefore = self:getBeforeData()
	local mResult = self:getResultData()
	
	local up    = math.max( mResult.upgradeCnt ,mResult.curRank ) - 1

	local img_ok    = gnode:getChildByName("img_ok")
	local img_dark  = gnode:getChildByName("img_dark")

	local slider_ok   = gnode:getChildByName("slider_ok")
	local slider_dark = gnode:getChildByName("slider_dark")

	img_ok:setVisible( num > up )
	img_dark:setVisible( num <= up )

	if slider_ok and slider_dark then
        slider_ok:setPercent(num > up and 100 or 0)
		--slider_ok:setVisible( num > up )
		slider_dark:setVisible(true)
    end

    gnode.num_label = gnode:getChildByName("text_num")
    gnode.num_label:setString( num )
    return slider_ok
end

function LandMatchTipsWinLose:showUpGradeNode()
	self:setVisible(true)
	self.upGradeNode:setVisible(true)
	self.Node_25:removeAllChildren()
end

function LandMatchTipsWinLose:updateMyRank( _lose )
	self:clearAtlas()
    local mResult = self:getResultData()
    local rank  = mResult.curRank
    local total = mResult.upgradeCnt

    if _lose then
    	local mBefore = self:getBeforeData()
    	total = mBefore.lastUpgradeCnt
    end
    print("LandMatchTipsWinLose:updateMyRank",rank,total)

    self.curRankLabel1 = cc.LabelAtlas:_create(tostring( rank ), "number/ddz_shizi_huang1.png",110,110, 48)
    self.curRankLabel1:setAnchorPoint(cc.p(1, 0.5))
    self.curRankLabel:getParent():addChild(self.curRankLabel1)
    self.curRankLabel1:setPosition(self.curRankLabel:getPosition()) 

    self.totalPlayerLabel1 = cc.LabelAtlas:_create(tostring( total ), "number/ddz_shizi_huang1.png",110,110, 48)
    self.totalPlayerLabel1:setAnchorPoint(cc.p(0, 0.5))

    self.totalPlayerLabel:getParent():addChild(self.totalPlayerLabel1)
    self.totalPlayerLabel1:setPosition(self.totalPlayerLabel:getPosition())
    self.totalPlayerLabel1:setPositionY(self.totalPlayerLabel:getPositionY())
end

function LandMatchTipsWinLose:showRoundLose()
   -- LogINFO("播放 超快赛 淘汰 动画")
    self:showUpGradeNode()
   -- LandAnimationManager:getInstance():PlayAnimation(LandArmatureResource.ANI_TAOTAI, self.Node_25, cc.p(0,0))

    self.upGradeNode:getChildByName("lose_node"):setVisible(true)
    self.upGradeNode:getChildByName("win_node"):setVisible(false)

    self:updateMyRank( true )
    self:updateGps( true )
end

function LandMatchTipsWinLose:showRoundWin()
    --LogINFO("播放 超快赛 晋级 动画")
    self:showUpGradeNode()
    --local animation = LandAnimationManager:getInstance():getAnimation(LandArmatureResource.ANI_MATCH, self.Node_25, cc.p(0,0))
    --animation:playAnimationByName("lord_match_ani_ranking02")

    self.upGradeNode:getChildByName("lose_node"):setVisible(false)
    self.upGradeNode:getChildByName("win_node"):setVisible(true)
    self:updateMyRank( false )
    self:updateGps( false )
end

function LandMatchTipsWinLose:clearAtlas()
	if self.curRankLabel1 then
        self.curRankLabel1:removeFromParent()
        self.curRankLabel1 = nil
    end

    if self.totalPlayerLabel1 then
        self.totalPlayerLabel1:removeFromParent()
        self.totalPlayerLabel1 = nil
    end
end

function LandMatchTipsWinLose:getAllRoundInfo()
	local data = FastRoomController:getInstance():getFastGameRoundConfig()
	return data
end
function LandMatchTipsWinLose:getBeforeData()
	local data = FastRoomController:getInstance():getMatchBeforeGameInfo()
	return data
end

function LandMatchTipsWinLose:getResultData()
	local data = FastRoomController:getInstance():getMatchGameResultInfo()
	return data
end

function LandMatchTipsWinLose:onTouchCallback( sender )
    local name = sender:getName()
    local tag = sender:getTag()
    print("LandMatchTipsWinLose name: ", name)
end

return LandMatchTipsWinLose


