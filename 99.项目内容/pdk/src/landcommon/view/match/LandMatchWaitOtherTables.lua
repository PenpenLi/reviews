---------------------------------------------------
-- LandMatchWaitOtherTables
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 类 LandMatchWaitOtherTables : 比赛中等待其他桌
-----------------------------------------------------
require "app.landlords.landcommon.data.StringConfig"
local MatchConfig = require("app.landlords.landcommon.view.match.MatchConfig")
local CMD_GR = require("app.landlords.landcommon.data.CMD_GR")

local LandMatchWaitOtherTables = class("LandMatchWaitOtherTables", function()
    return display.newLayer()
end)

-------------------------------------------------
-- stageCount        格子的数量
-- progressScale     进度条的长度与屏幕宽度的比例
-- longAndShortRatio 格子之间长距离与短距离的比例
-- peopleNum         每个格子上人数
-- 设置这些参数就可以动态的改变进度条
--------------------------------------------------     
LandMatchWaitOtherTables.progress_3_TypeId = 1001 --3个格子
LandMatchWaitOtherTables.progress_4_TypeId = 1002 --4个格子
LandMatchWaitOtherTables.progress_5_TypeId = 1003 --5个格子
LandMatchWaitOtherTables.progress_6_TypeId = 1004 --6个格子
LandMatchWaitOtherTables.progress_9_TypeId = 1005 --9个格子

LandMatchWaitOtherTables.progressDatas = {}

LandMatchWaitOtherTables.progressDatas[LandMatchWaitOtherTables.progress_3_TypeId]={satgeCount = 3, scaleSet = {progressScale = 0.6,longAndShortRatio = 1.5  },peopleNums ={ {6,3} } }
LandMatchWaitOtherTables.progressDatas[LandMatchWaitOtherTables.progress_4_TypeId]={satgeCount = 4, scaleSet = {progressScale = 0.58,longAndShortRatio = 1.8  },peopleNum ={ {12,6,3},{9,6,3} } }
LandMatchWaitOtherTables.progressDatas[LandMatchWaitOtherTables.progress_5_TypeId]={satgeCount = 5, scaleSet = {progressScale = 0.6,longAndShortRatio = 2.0  },peopleNums ={ {24, 12, 6, 3} } }
LandMatchWaitOtherTables.progressDatas[LandMatchWaitOtherTables.progress_6_TypeId]={satgeCount = 6, scaleSet = {progressScale = 0.8,longAndShortRatio = 3.5  },peopleNums ={ {24,18,12,6,3} } }
LandMatchWaitOtherTables.progressDatas[LandMatchWaitOtherTables.progress_9_TypeId]={satgeCount = 9, scaleSet = {progressScale = 0.9,longAndShortRatio = 6  },peopleNums ={ {96, 72, 54, 36, 24, 12, 6, 3} } }


function LandMatchWaitOtherTables:ctor( landMainScene )
	print("------------LandMatchWaitOtherTables : ctor-----------")
		
	self.STAGE = {
		YUSAI = 1, 
		CHUSAI = 2,
		FUSAI = 3,
		JUESAI = 4,
	}
	
	self.m_landMainScene = landMainScene
	self.m_pMainNode = nil
	self.gameType = self.m_landMainScene:getGameType()
    self.progressStages = {}
	self.progressBgWith = 230
	self.circleWith = 99
    self:init()
	self:initButton()
	self:initProgress()
    self.isHaveStage = false
end

function LandMatchWaitOtherTables:init()
	self.m_pMainNode = cc.CSLoader:createNode("src/app/game/pdk/res/csb/land_match_wait_other_table.csb")
    self:addChild(self.m_pMainNode)
    self.m_pMainNode:getChildByName("bg_image"):setScaleY(display.standardScale)
    local temp = self.m_pMainNode:getChildren()
    for i=1,#temp do
        temp[i]:setPositionY(temp[i]:getPositionY()*display.standardScale)
    end
    --比赛名称
    self.mathNameLabel = self.m_pMainNode:getChildByName("match_naml_label")
    tolua.cast(self.mathNameLabel,"ccui.Text") 
    --返回按钮
    self.backButton = self.m_pMainNode:getChildByName("back_button")
    tolua.cast(self.backButton,"ccui.Button")
    
    local fastRankingNode = self.m_pMainNode:getChildByName("fast_rangking_node")
    local rankingNode = self.m_pMainNode:getChildByName("ranging_node")
    local buttonsNode = self.m_pMainNode:getChildByName("buttons_node")


    if self:isFastMatchGame() then
    	fastRankingNode:setVisible(true)
		rankingNode:setVisible(false)
		buttonsNode:setVisible(false)
        local  fastRankNumLabel = fastRankingNode:getChildByName("now_rang_num")
        fastRankNumLabel:setVisible(false)
        self.fastRankNumLabelAtlas = cc.LabelAtlas:_create(0,"number/ddz_num_ranking_b.png",27,40,48)
        self.fastRankNumLabelAtlas:setVisible(true)
        self.fastRankNumLabelAtlas:setPosition(cc.p(fastRankNumLabel.getPositionX(),fastRankNumLabel.getPositionY()))
        fastRankingNode:addChild(self.fastRankNumLabelAtlas)
        local fastTotalRankLabel = fastRankingNode:getChildByName("total_rang_num")
        fastTotalRankLabel:setVisible(false)
        self.fastTotalRankLabelAtlas = cc.LabelAtlas:_create(0,"number/ddz_num_ranking_y.png",27,40,48)
        self.fastTotalRankLabelAtlas:setVisible(true)
        self.fastTotalRankLabelAtlas:setPosition(cc.p(fastTotalRankLabel.getPositionX(),fastTotalRankLabel.getPositionY()))
        fastRankingNode:addChild(self.fastTotalRankLabelAtlas)
	else
		fastRankingNode:setVisible(false)
		rankingNode:setVisible(true)
		buttonsNode:setVisible(true)
		buttonsNode:setPositionY(buttonsNode:getPositionY()/display.standardScale)
	    --当前排名
        self.rankNumLabel = rankingNode:getChildByName("label_ranking_now")
	    --总人数
        self.totalRankLabel = rankingNode:getChildByName("label_ranking_all")
	    --积分
        self.scoreLabel = rankingNode:getChildByName("label_score")
        --开心一刻
	    self.happyButton = buttonsNode:getChildByName("btn_happy")
	    tolua.cast(self.backButton,"ccui.Button")
	    --奖励方案
	    self.rewardButton = buttonsNode:getChildByName("btn_reward")
	    tolua.cast(self.rewardButton,"ccui.Button")
	end
end

function LandMatchWaitOtherTables:initButton()
	local function onButtonCallBack(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			 if self:isFastMatchGame() then
				if sender == self.backButton then
					--返回按钮
					self.m_landMainScene:showExitGameLayer()
				end
			 else
                 if sender == self.backButton then
					--返回按钮
					self.m_landMainScene:showExitGameLayer()
				elseif sender == self.happyButton then
					--欢乐一刻按钮
					self.m_landMainScene:showEnjoyableMoment()
				elseif sender == self.rewardButton then
					--奖励方案按钮
					self.m_landMainScene:showRuleLayer(true)
				end
			 end
		end
	end
	self.backButton:addTouchEventListener(onButtonCallBack)
	if not self:isFastMatchGame() then
		self.happyButton:addTouchEventListener(onButtonCallBack)
		self.rewardButton:addTouchEventListener(onButtonCallBack)
	end
end

--设置比赛名字
function LandMatchWaitOtherTables:setMatchName(matchName)
	self.mathNameLabel:setString( matchName )
end

function LandMatchWaitOtherTables:setScore()
	self.scoreLabel:setString( self.m_landMainScene:getMyScore() or 0 )
end

--设置排名和积分
function LandMatchWaitOtherTables:setRanking()
	if self:isFastMatchGame() then
		 self.fastRankNumLabelAtlas:setString(CMD_GR and CMD_GR.Match_Info.iCurNo or 0)
		 self.fastTotalRankLabelAtlas:setString( CMD_GR and CMD_GR.Match_Info.iTotalPlayersCount or 0 )
	else
		self.rankNumLabel:setString( CMD_GR and CMD_GR.Match_Info.iCurNo or 0 )
	    self.totalRankLabel:setString( CMD_GR and CMD_GR.Match_Info.iTotalPlayersCount or 0 )
	    self.scoreLabel:setString( self.m_landMainScene:getMyScore() or 0 )
	end
end


--初始化进度条
function LandMatchWaitOtherTables:initProgress()
    self.progressNode = self.m_pMainNode:getChildByName("progress_node")
    self.progressNode:setPositionY(self.progressNode:getPositionY()/display.standardScale)
	self.progressBg = self.progressNode:getChildByName("progress_bg")
	self.loadingbar = self.progressNode:getChildByName("loadingbar")
	self.runPerson = self.progressNode:getChildByName("run_person")
    --剩余桌数
    self.letfTableNode = self.progressNode:getChildByName("letf_table_node")
    if self:isFastMatchGame() then
    	self.letfTableNode:setVisible(false)
    else
    	self.letfTableNode:setVisible(true)
    	self.leftTableNum = self.letfTableNode:getChildByName("left_table_num")   
    end
     --小人
    self.waitingAni = self.progressNode:getChildByName("run_person")

    --动画添加
	local run_animation = cc.Animation:create()
	for i = 1, 8 do
		run_animation:addSpriteFrame( display.newSpriteFrame("lord_running" .. i .. ".png") )
	end
	run_animation:setDelayPerUnit(0.1)
	run_animation:setRestoreOriginalFrame(true)
	local run_animate = cc.Animate:create(run_animation)
    local animate_forever = cc.RepeatForever:create(run_animate)
    self.waitingAni:runAction(animate_forever)
	self.waitingAni:setFlippedX(true)
end

function LandMatchWaitOtherTables:initProgressStages( progressTypeId )
	if self.isHaveStage then
	   return
	end
    self.isHaveStage = true
	self.m_progressTypeId = progressTypeId
	local progressData = LandMatchWaitOtherTables.progressDatas[ self.m_progressTypeId ]
	local size = cc.Director:getInstance():getWinSize()
    self.progressWidth = size.width * progressData.scaleSet.progressScale
    self.progressBg:setScaleX(self.progressWidth / self.progressBgWith)
    self.loadingbar:setScaleX(self.progressWidth / self.progressBgWith)
    self.shortDistance = self.progressWidth/((progressData.satgeCount -2) + progressData.scaleSet.longAndShortRatio)
    self.longDistance = progressData.scaleSet.longAndShortRatio * self.shortDistance
    self.progressNode:setPositionX((size.width - self.progressWidth)/2)
	for i=1,progressData.satgeCount do
		 self.progressStages[i] = {}
		 self.progressStages[i].statgeNode = display.newNode()
		 self.progressNode:addChild(self.progressStages[i].statgeNode)
         
         local bgCircle = display.newSprite("ddz_bg_circle.png")
         self.progressStages[i].statgeNode:addChild(bgCircle)

         self.progressStages[i].bgCircleYellow = display.newSprite("ddz_bg_circle_yellow.png")
         self.progressStages[i].statgeNode:addChild(self.progressStages[i].bgCircleYellow)

         self.progressStages[i].bgCircleBlue = display.newSprite("ddz_bg_circle_blue.png")
         self.progressStages[i].statgeNode:addChild(self.progressStages[i].bgCircleBlue )
         
         local renLabel = display.newTTFLabel(
         {
			text = "180人", 
			font = "黑体", 
			color = cc.c3b(255, 255, 255),
			x = 0.00, y = 20.00,
			size = 30,
		  })
         self.progressStages[i].statgeNode:addChild( renLabel )
         self.progressStages[i].renLabel = renLabel
         local stageText = "晋级"
         if i == 1 then
         	stageText = "开赛"
         end
         local stageLabel = display.newTTFLabel(
         {
			text = stageText, 
			font = "黑体", 
			color = cc.c3b(255, 255, 255),
			x = -1.47, y = -13.41,
			size = 30,
		 })
         self.progressStages[i].statgeNode:addChild( stageLabel )
         self.progressStages[i].stageLabel = stageLabel 
         if i == progressData.satgeCount then
            local bgCircleBlue = display.newSprite("ddz_image_crown.png")
            bgCircleBlue:setPosition(cc.p(2.50,62.50))
            self.progressStages[i].statgeNode:addChild( bgCircleBlue )
         end
	end
end

--设置每个阶段的人数
function LandMatchWaitOtherTables:setStagePersonNum( peopleNumIndex )
	local progressData = LandMatchWaitOtherTables.progressDatas[ self.m_progressTypeId ]
	for i=1,progressData.satgeCount do
		local personNum = 0
		if i == 1 then
		    personNum =  CMD_GR.Match_Info.iTotalMatchCount
		else
            personNum =  progressData.peopleNums[peopleNumIndex][i-1]
		end
		local personNUmString = string.format("%d人", personNum)
		self.progressStages[i].renLabel:setString( personNUmString )
	end
end

--调整阶段之间的位置
function LandMatchWaitOtherTables:setProgressStagePos( index )
   local startX = 0
   local progressData = LandMatchWaitOtherTables.progressDatas[ self.m_progressTypeId ]
   for i=1,progressData.satgeCount-1 do
   	    if i <= index then
            self.progressStages[i].bgCircleBlue:setVisible(false)
            self.progressStages[i].bgCircleYellow:setVisible(true)
            self.progressStages[i].renLabel:setColor(cc.c3b(106, 57, 13))
            self.progressStages[i].stageLabel:setColor(cc.c3b(106, 57, 13))
        else
        	self.progressStages[i].bgCircleBlue:setVisible(true)
            self.progressStages[i].bgCircleYellow:setVisible(false)
            self.progressStages[i].renLabel:setColor(cc.c3b(10,58, 86))
            self.progressStages[i].stageLabel:setColor(cc.c3b(10,58, 86))
   	    end
   	    if i == index then
   	    	startX = startX + self.longDistance
   	    else
   	    	startX = startX + self.shortDistance
   	    end
        self.progressStages[i+1].statgeNode:setPositionX(startX)
   end
   local personPosX = (self.shortDistance * (index-1))+self.longDistance/2
   self.waitingAni:setPositionX( personPosX )
end

function LandMatchWaitOtherTables:isFastMatchGame()
	if self.gameType == 102 then
		return true
	end

	return false
end


--设置比赛的进度
function LandMatchWaitOtherTables:setLeftTablesProgress( leftTableNum )
	if not self:isFastMatchGame()  then
       self.leftTableNum:setString( tostring(leftTableNum) )
    end
	if not CMD_GR then
		return
	end
	local stage = CMD_GR.Match_Info.iMatchSection
	local round = CMD_GR.Match_Info.iCurRoundCount
	local allTableNum = CMD_GR.Match_Info.iTotalPlayersCount / 3
    local  nowProgressWith = self.shortDistance * (self.m_index-1) + (math.max(allTableNum-leftTableNum,0)/allTableNum)*(self.longDistance-self.circleWith)+self.circleWith/2
    local progressCen = nowProgressWith/self.progressWidth*100
    self.loadingbar:setPercent(progressCen)
end

--根据比赛类型，设置比赛各个阶段人数和显示状态
function LandMatchWaitOtherTables:setMatchPeopleNum()
    local progressTypeId = LandMatchWaitOtherTables.progress_3_TypeId
    local peopleNumIndex = 1
    local stage = CMD_GR.Match_Info.iMatchSection
	local round = CMD_GR.Match_Info.iCurRoundCount
	self.m_index = 1
	local canSet = false
	if self.gameType == 54 then 
		--(5个格子)
		progressTypeId = LandMatchWaitOtherTables.progress_5_TypeId
	    self.m_index =  round 
	    canSet = true
	elseif self.gameType == 102 then
		--(6个格子)
		progressTypeId = LandMatchWaitOtherTables.progress_6_TypeId
		self.m_index = round
		canSet = true
	elseif self.gameType == 59 or self.gameType == 24 or self.gameType == 50 or self.gameType == 64 then
		-- (4个格子)1元话费, 跑得快大奖门票赛,闯关赛第一关
		progressTypeId = LandMatchWaitOtherTables.progress_4_TypeId
        self.m_index = round
        canSet = true
	elseif (self.gameType >= 51 and self.gameType <= 65) or self.gameType == 100 then
		local chuangguansaiCount = MatchConfig.getChuangguansaiNum()
		if chuangguansaiCount == 12 then
			-- (3个格子)
			progressTypeId = LandMatchWaitOtherTables.progress_3_TypeId
			self.m_index = round 
			canSet = true
		elseif chuangguansaiCount == 24 then
			-- (4个格子)
			progressTypeId = LandMatchWaitOtherTables.progress_4_TypeId
			self.m_index = round 
			canSet = true
		end
	elseif self.gameType == 79 or self.gameType == 20  or self.gameType == 14  then
		-- (4个格子) 10元餐券, 突围赛
		progressTypeId = LandMatchWaitOtherTables.progress_4_TypeId
		if stage == 1 then
		    --预赛(没有预赛)
		elseif stage == 2 then
			--初赛
			self.m_index = 1
			canSet = true
		elseif stage == 3 then
			--复赛(没有复赛)
		elseif stage == 4 then
			self.m_index = round 
			canSet = true
		end
	elseif self.gameType == 101 then
		progressTypeId = LandMatchWaitOtherTables.progress_4_TypeId
		peopleNumIndex = 2
		self.index = round 
		canSet = true
	elseif self.gameType == 15 or self.gameType == 5 or self.gameType == 6 or self.gameType == 78 or self.gameType == 19 or self.gameType == 16 then
		-- (5个格子) 100元餐券, 5元话费, 海选赛, 20元餐券
		progressTypeId = LandMatchWaitOtherTables.progress_5_TypeId
		if stage == 1 then
			--预赛(没有预赛)
		elseif stage == 2 then
			--初赛
			self.m_index = 1
			canSet = true
		elseif stage == 3 then
			--复赛(没有复赛)
		elseif stage == 4 then
			--决赛（取第1,2,3,4,9个图标, 分别是 开赛人数X，24人，12人，6人，3人 ）
			self.m_index = round 
			canSet = true
		end
	elseif self.gameType == 8 or self.gameType == 9 or self.gameType == 13 then
		-- (9个格子) 50元话费
		progressTypeId = LandMatchWaitOtherTables.progress_9_TypeId
		if stage == 1 then
		   --预赛(没有预赛)
		elseif stage == 2 then
			--初赛
			self.m_index = 1
			canSet = true
		elseif stage == 3 then
			--复赛
			self.m_index = 1 + round
			canSet = true
		elseif stage == 4 then
			--决赛
			self.m_index =5 + round
			canSet = true
		end
	end
	if canSet then 
	   self:initProgressStages( progressTypeId )
	   self:setStagePersonNum( peopleNumIndex )
       self:setProgressStagePos( self.m_index )
    end
end

--刷新界面
function LandMatchWaitOtherTables:updateShowData(matchName,leftTables)
	self:setMatchName(matchName)
	self:setRanking()
	self:setMatchPeopleNum()
    self:setLeftTablesProgress(leftTables)
end


return LandMatchWaitOtherTables










