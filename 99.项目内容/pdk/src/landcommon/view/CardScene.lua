-- CardScene
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 牌的事件


local CardSprite = require("app.game.pdk.src.landcommon.models.CardSprite")
local CardConfig = require("app.game.pdk.src.landcommon.data.CardConfig")
local scheduler = require("framework.scheduler")
local LandGlobalDefine = require("app.game.pdk.src.landcommon.data.LandGlobalDefine")

local CardScene = class("CardScene", function()
    return display.newLayer()
end)

CardScene.cardCountLimt = 14

local DispathcModel = {
	L_TO_R = 1,
	CENTER = 2,
	R_TO_L = 3,
}

function CardScene:ctor( landMainScene, outCardBtnsPanel )
	self.m_vecCardData = {}
    self.m_vecBackCard = {}
    self.m_vecOutCard = {}

    self.m_vecDispatchedCard = {}
    self.m_CardSize = cc.size(0,0)
    self.m_ptTouchBegan = cc.p(0,0)
    --基准位置
    self.m_ptBenchmarkPos = cc.p(0,0)
    --回调方法
    self.m_callbackListener = nil
    self.m_callback = nil

    self.mTouchCCPointBegin = cc.p(0,0)

    self.m_nDispatchNum = 0
    self.m_nCardCount = 0
	
	self.m_bIsDisplayCard = true

	self.m_dispatchCardModel = DispathcModel.CENTER

    self.m_vecLaiZiCard = {}
    self.cardConfig_ = CardConfig:new()
	
	--记录一次点击事件之前的弹出卡牌， 处理完一次点击事件清空
	self.m_lastOutCards = {}

	self.m_DispatchCardTime = 0.1
	self.m_PlaySoundTime = 0.35
	self.m_DispatchCardTab = {}
	self.m_MeHandCardNode = display.newNode()
	self:addChild(self.m_MeHandCardNode, 2)
	self.m_LaiZiOutCardNode = display.newNode()
	self:addChild(self.m_LaiZiOutCardNode)
	self.m_landMainScene = landMainScene
	self.m_cardSpace = 40*display.scaleX
	self.isMove = false
	self.isTouchEdCard = false
	self.isTouchEdOutCardPanel = false
	self.outCardBtnsPanel = outCardBtnsPanel
    self:init()
end

function CardScene:setModel(model)
	self.m_dispatchCardModel = model
end

function CardScene:onEnter()
    print("---------------CardScene:onEnter()-------------")
end

function CardScene:onExit()
    print("---------------CardScene:onExit()-------------")
    self:statusTimerEnd()
end

function CardScene:setLaiziCardId( laiziCardId )
	self.m_laiziCardId = laiziCardId
end

function CardScene:init()
	self.m_CardSize.width = LandGlobalDefine.CARDIMAGE_WIDTH / 13
    self.m_CardSize.height = LandGlobalDefine.CARDIMAGE_HEIGHT / 5

    -- cc.Node 的setTouchSwallowEnabled(true) 无法屏蔽listener监听
    local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(false)
    listenner:registerScriptHandler(function(touch, event)
    		self:onTouchBegan(touch:getLocation().x, touch:getLocation().y)
            return true
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    listenner:registerScriptHandler(function(touch, event)
    		self:onTouchMoved(touch:getLocation().x, touch:getLocation().y)
        end,cc.Handler.EVENT_TOUCH_MOVED )
    listenner:registerScriptHandler(function(touch, event)
    		self:onTouchEnded(touch:getLocation().x, touch:getLocation().y)
        end,cc.Handler.EVENT_TOUCH_ENDED )
    listenner:registerScriptHandler(function(touch, event)
    		self:onTouchCancelled(touch:getLocation().x, touch:getLocation().y)
        end,cc.Handler.EVENT_TOUCH_CANCELLED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)

--[[--
	-- 不要使用这个监听，用这个监听有可能偶尔会导致触摸被屏蔽，暂时没有找到屏蔽源
	-- by dzf 20151020
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            return self:onTouchBegan(event.x, event.y)
        elseif event.name == "moved" then
            self:onTouchMoved(event.x, event.y)
        elseif event.name == "ended" then
            self:onTouchEnded(event.x, event.y)
        elseif event.name == "cancel" then
            self:onTouchCancelled(event.x, event.y)
        end
    end)
    self:setTouchEnabled(true)
    --self:setTouchSwallowEnabled(false)
    ]]
end

function CardScene:SetBenchmarkPos( pt )
	self.m_ptBenchmarkPos = pt
end

--计算牌之间的间距
function CardScene:CalculateCardSpace( cardCount )
--	local size = cc.Director:getInstance():getWinSize()
--	if cardCount and cardCount < CardScene.cardCountLimt then
--       cardCount = CardScene.cardCountLimt
--	end
--	if cardCount then
--        self.m_cardSpace = (900 - CardConfig.CardWidth) / (cardCount - 1)
--	else
--		self.m_cardSpace = CardConfig.CardSpace
--	end
 --   self.m_cardSpace= 40
end


--发牌
function CardScene:DispatchCard( cardData )
	self:ClearHandCard()
    local gameKind = self.m_landMainScene:getLandGameType()
    if gameKind == LandGlobalDefine.HAPPLY_LAND_TYPE or gameKind == LandGlobalDefine.TP_LAND_TYPE then 
    	--欢乐跑得快/二人跑得快
	    self.m_DispatchCardTime = 0.5
	elseif gameKind == LandGlobalDefine.CLASSIC_LAND_TYPE or gameKind == LandGlobalDefine.LAIZI_LAND_TYPE then
	    --经典跑得快/癞子跑得快
		self.m_DispatchCardTime = 0.08
	end
	self.m_vecCardData = {}
    self.m_DispatchCardTab = {}
    for i, v in ipairs(cardData) do
    	self.m_DispatchCardTab[i] = v
    end
    table.sort(self.m_DispatchCardTab,SortCardTable)
    self:CalculateCardSpace( table.nums( self.m_DispatchCardTab ) )   
    self.m_nDispatchNum = 0
    --绘制本家的牌
    self:statusTimerBegin()
end

function CardScene:DrawCardEnd()
	self:statusTimerEnd()
	self:setModel(DispathcModel.CENTER) --绘制结束,模式改为中间,不然出牌就乱了
	local landGameType = self.m_landMainScene:getLandGameType()
	if landGameType == LandGlobalDefine.HAPPLY_LAND_TYPE then
		--欢乐跑得快
        self.m_landMainScene.m_landMainLayer:setBrightButtonsVisible(false)
        --隐藏明牌按钮 和 发送发完牌协议
        self.m_landMainScene:OnSendCardFinish()
    elseif landGameType == LandGlobalDefine.CLASSIC_LAND_TYPE or gameKind == LandGlobalDefine.LAIZI_LAND_TYPE then
    	--进入叫分（经典跑得快/癞子跑得快)
		self.m_landMainScene:EnterLandScore()
	elseif landGameType == LandGlobalDefine.TP_LAND_TYPE then
        --二人跑得快
	    self.m_landMainScene:OnSendCardFinish()
    end
end

--动态发(绘制)牌
function CardScene:ActionDrawCard()
	if not self.m_nDispatchNum then return end
	self.m_nDispatchNum = self.m_nDispatchNum + 1
	local cardId = self.m_DispatchCardTab[self.m_nDispatchNum]
	if cardId then
	
		self:AddCardDataInfo(cardId)
		--欢乐跑得快类型
	 	if self.m_landMainScene:getLandGameType() == LandGlobalDefine.HAPPLY_LAND_TYPE then	 		
			self.m_landMainScene.m_landMainLayer:UpdataBrightCardProgress(self.m_nDispatchNum)
	    end
		self.m_landMainScene.m_landMainLayer:UpdataPlayerCardNum(0, self.m_nDispatchNum)
		self.m_landMainScene.m_landMainLayer:UpdataPlayerCardNum(2, self.m_nDispatchNum)
	else
		self.m_nDispatchNum = 0
        --发牌结束
		self:DrawCardEnd()
	end
end

function CardScene:DrawCardPause()
	print("function CardScene:DrawCardPause()")
	self:statusTimerEnd()
end

function CardScene:DrawCardResume()
	print("function CardScene:DrawCardResume()")
	self:statusTimerBegin()
end

function CardScene:statusTimerBegin()
	self.m_bIsDisplayCard = true
	if self.statusTimer_ then
       scheduler.unscheduleGlobal(self.statusTimer_)
       self.statusTimer_ = nil
	end
    self.statusTimer_ = scheduler.scheduleGlobal(handler(self, self.ActionDrawCard), self.m_DispatchCardTime)
end

function CardScene:statusTimerEnd()
	self.m_bIsDisplayCard = false
    if not self.statusTimer_ then
        return
    end

    scheduler.unscheduleGlobal(self.statusTimer_)
    self.statusTimer_ = nil
end

--保存手牌信息
function CardScene:SetCardData( bCardData, dwCardCount, dizhuIndex )
	
	self:SetCardDataInfo(bCardData,dwCardCount,dizhuIndex)

    self.m_vecBackCard = {}

	return dwCardCount
end

function CardScene:SetBackCardData( cardData )
	self.m_vecBackCard = cardData
    return 0
end

--重置手牌信息位置 设置扑克
function CardScene:SetCardDataInfo(info, dwCardCount, dizhuIndex)
	self.m_vecCardData = clone( info )
	self:CalculateCardSpace( dwCardCount )
	--self:setModel(DispathcModel.CENTER) --绘制结束,模式改为中间,不然出牌就乱了
	return self:ShowCardDataInfo(dizhuIndex)
end

function CardScene:AddCardDataInfo(cardId, dizhuIndex)
	local toCount = #self.m_vecCardData
	for i=1,toCount do
		if self.m_vecCardData[i]==cardId then  -- 防止绘制同样的牌
			toCount = nil
			break
		end
	end
	if toCount then
		self.m_vecCardData[toCount+1] = cardId
        table.sort(self.m_vecCardData,SortCardTable)
		self:ShowCardDataInfo(dizhuIndex)
	end
end

function CardScene:ShowCardDataInfo(dizhuIndex)
	local size = cc.Director:getInstance():getWinSize()  
	local nNowCount = table.nums(self.m_vecCardData)

	local allCardsWith = 0
    if nNowCount and nNowCount > 0 then
       allCardsWith = CardConfig.CardWidth + (nNowCount -1) * self.m_cardSpace   
    end
    --print("m_dispatchCardModel", self.m_dispatchCardModel)
    local nXPos = 0
    if self.m_dispatchCardModel == DispathcModel.CENTER then
    	nXPos = (size.width - allCardsWith)/2 + (CardConfig.CardWidth/2 - self.m_cardSpace)   -- 左边第一张牌的起点X位置
    elseif self.m_dispatchCardModel == DispathcModel.L_TO_R then
    	nXPos = CardConfig.CardWidth/2
    elseif self.m_dispatchCardModel == DispathcModel.R_TO_L then
    	nXPos = size.width
    end

	self.m_ptBenchmarkPos.x = nXPos
	for nIndex=1,nNowCount do 
		--获取牌的相关信息
		local reallyNindex = nIndex

		if self.m_dispatchCardModel == DispathcModel.R_TO_L then  -- 从小向大绘制
			reallyNindex = nNowCount - nIndex + 1
        end

        local nOneCard = self.m_vecCardData[reallyNindex]

        local pSprite1 = self.m_MeHandCardNode:getChildByTag(nOneCard)
        local isCreate = false
        if not pSprite1 then
        	isCreate = true
        	pSprite1 = self.m_landMainScene.m_landMainLayer.m_cardSprite:createCard(nOneCard)
        end
       pSprite1:setScale(0.8)
        if pSprite1 then
        	local nOffPos = 0
        	if self.m_dispatchCardModel == DispathcModel.L_TO_R  then
        		nOffPos = self.m_cardSpace * (nIndex-1) -- 向右的偏移量
        	elseif self.m_dispatchCardModel == DispathcModel.R_TO_L then -- 向左的偏移量
        		nOffPos = -nOffPos
        	else
        		nOffPos = self.m_cardSpace * nIndex -- 向右的偏移量
        	end

        	local NowPoint = cc.p(self.m_ptBenchmarkPos.x + nOffPos, self.m_ptBenchmarkPos.y)
        	pSprite1:setAnchorPoint(cc.p(0.5,0.5))
        	pSprite1:setPosition(NowPoint)
        	pSprite1.Value = nOneCard
        	pSprite1:setTag(nOneCard)

        	if isCreate == true then
        		self.m_MeHandCardNode:addChild(pSprite1)
        	end
            
        	--if self.m_dispatchCardModel == DispathcModel.R_TO_L then -- 设置Z轴
        		pSprite1:setLocalZOrder(reallyNindex)
        	--end

            if dizhuIndex and dizhuIndex == nOneCard then
            	pSprite1.IsUp = true
                pSprite1:setPositionY(NowPoint.y + size.height/32)
            end
            for k,v in pairs(self.m_vecBackCard) do
            	--如果当前牌是底牌则弹起
                if v == nOneCard then
                	local function onRunEnd( ... )
                		self.bottom_card_on_action = false
                	end
                	pSprite1.IsUp = true
                    pSprite1:setPositionY(NowPoint.y + size.height/32)

                    local a1 = cc.MoveTo:create(1.2, cc.p(NowPoint.x,NowPoint.y))
                    local a2 = cc.DelayTime:create( 1.2 )
                    local a3 = cc.CallFunc:create( onRunEnd )

					self.bottom_card_on_action = true
					pSprite1:runAction( cc.Sequence:create(a1,a2,a3) )
					pSprite1.IsUp = false
                    break
                end
            end
        end
	end
	return nNowCount
end
--设置弹起扑克
function CardScene:SetShootCard( bCardDataIndex, nCardCount )
	--收起扑克
    self:ResetShootCard()
    local size = cc.Director:getInstance():getWinSize()

    --弹起扑克
    for i=1,nCardCount do
    	--获取牌的相关信息
    	local sprite = self.m_MeHandCardNode:getChildByTag(bCardDataIndex[i])
    	if sprite then
    		sprite.IsUp = true;
            sprite:setPositionY(self.m_ptBenchmarkPos.y + size.height/32)
    	end
    end
end

--收起扑克
function CardScene:ResetShootCard()
	--if self.bottom_card_on_action then return end
	for i,v in ipairs(self.m_vecCardData) do
		--获取牌的相关信息
		if v then
			local sprite = self.m_MeHandCardNode:getChildByTag(v)
	    	if sprite then
	    		sprite.IsUp = false
	    		sprite:stopAllActions()
	            sprite:setPositionY(self.m_ptBenchmarkPos.y)
	    	end
		end
	end
	if self.m_landMainScene.onAllCardDown then
		self.m_landMainScene:onAllCardDown()
	end
end

--取得弹出的牌
function CardScene:GetShootCard()
	local bCardData = {}
	for i,v in ipairs(self.m_vecCardData) do
		--获取牌的相关信息
		if v then
			local sprite = self.m_MeHandCardNode:getChildByTag(v)
			if sprite and sprite.IsUp then
				table.insert(bCardData, sprite.Value)
			end
		end
	end

	return bCardData
end

--清理本家出的牌
function CardScene:ClearOutCard()
	local gameKind = self.m_landMainScene:getLandGameType()	
	if gameKind == LandGlobalDefine.LAIZI_LAND_TYPE then
		self.m_LaiZiOutCardNode:removeAllChildren()
		self.m_vecOutCard = {}
	else
		for k,v in pairs(self.m_vecOutCard) do
	        self.m_MeHandCardNode:removeChildByTag(v,true)
		end
		self.m_vecOutCard = {}
	end
end

function CardScene:OutCardTP(bCardData, nCardCount, bIsDiZhu)
	self:ClearOutCard()

	local fscale = 0.62   
	local distX = CardConfig.CardSpace*fscale
	local ToPoint = self.m_landMainScene.m_landMainLayer:getMeOutCardPos()
	local size = cc.Director:getInstance():getWinSize()    
	local leftPosX = size.width/2 - (nCardCount-1)/2 * distX

	for i=1,nCardCount do
		self.m_vecOutCard[i] = bCardData[i]	
	end
    
	for nIndex=1,nCardCount do
		--获取牌的相关信息
        local nTag = bCardData[nIndex];
        print("牌ID ="..nTag)
        local pSprite = nil
        pSprite = self.m_MeHandCardNode:getChildByTag(nTag)
        if not pSprite then
        	pSprite = self.m_landMainScene.m_landMainLayer.m_cardSprite:createCard( nTag , fscale)
        	self.m_MeHandCardNode:addChild( pSprite,2,nTag)
            pSprite:setPosition(cc.p(leftPosX, ToPoint.y))
        end
        if pSprite then
	        if bIsDiZhu then
	        	local isDiZhuPrite = display.newSprite("#land_icon_lord.png")
	        	if isDiZhuPrite then
	        		pSprite:addChild(isDiZhuPrite)
	        		isDiZhuPrite:setScale(1.5)
	        		isDiZhuPrite:setAnchorPoint(1,1)
	            	isDiZhuPrite:setPosition(pSprite:getContentSize().width - 10, pSprite:getContentSize().height - 7)
	        	end
	        end
	        
	        local pMoveAction = cc.MoveTo:create(0, cc.p(leftPosX, ToPoint.y));
	        local pScaleAction = cc.ScaleTo:create(0, fscale);

	        pSprite:runAction(cc.Spawn:create(pMoveAction,pScaleAction))

	        leftPosX = leftPosX + distX
        end
	end
end

function CardScene:OutCard( bCardData, nCardCount, bIsDiZhu )
	print("---------CardScene:OutCard-----", bCardData, nCardCount, bIsDiZhu)
	self:ClearOutCard()

	for i=1,nCardCount do
		self.m_vecOutCard[i] = bCardData[i]
	end

	local fscale = CardConfig.OutCardScale
	local size = cc.Director:getInstance():getWinSize()  
	local meOutPos =  self.m_landMainScene.m_landMainLayer.m_playerInfos[2]:getPoint2OutCard()
	local statusPosx = (meOutPos.x - ((nCardCount-1)*CardConfig.CardSpace*fscale + CardConfig.CardWidth*fscale)/2) + CardConfig.CardWidth*fscale/2
	local ToPoint = cc.p(statusPosx,meOutPos.y)
	for nIndex=1,nCardCount do
		--获取牌的相关信息
        local nTag = bCardData[nIndex]
        --print("牌ID ="..nTag)
        local pSprite = nil
        pSprite = self.m_MeHandCardNode:getChildByTag(nTag)
        if not pSprite then
           pSprite = self.m_landMainScene.m_landMainLayer.m_cardSprite:createCard(nTag)
           self.m_MeHandCardNode:addChild( pSprite,2,nTag)
           pSprite:setPosition( ToPoint )
        end
        if pSprite then
	        if bIsDiZhu then        	
	        	local isDiZhuPrite = display.newSprite("#land_icon_lord.png")
	        	if isDiZhuPrite then
	        		pSprite:addChild(isDiZhuPrite)
	        		isDiZhuPrite:setScale(1.5)
	        		isDiZhuPrite:setAnchorPoint(1,1)
	          		isDiZhuPrite:setPosition(pSprite:getContentSize().width - 10, pSprite:getContentSize().height - 7)
	        	end
	        end        
	        local pMoveAction = cc.MoveTo:create(0,ToPoint)
	        local pScaleAction = cc.ScaleTo:create(0, fscale)
	        pSprite:setScale( fscale )
	        --pSprite:runAction(cc.Spawn:create(pMoveAction,pScaleAction))
	        pSprite:runAction(cc.Spawn:create(pMoveAction))

	        ToPoint.x = ToPoint.x + CardConfig.CardSpace*fscale
        end
	end
end

function CardScene:ClearHandCard()
	self.m_MeHandCardNode:removeAllChildren(true)

	for i,v in ipairs(self.m_vecCardData) do
		table.remove(self.m_vecCardData, i)
	end
	self.m_vecCardData = {}
end

--判断是否有点击中牌组
function CardScene:isTouchInCard(touchRect,sprite,singleW)
	local ContentSize = sprite:getContentSize()
	local width = (ContentSize.width - 16) * sprite:getScale();
	local height = ContentSize.height * sprite:getScale();

	local x = sprite:getPositionX() - width / 2 + 2
	local y = sprite:getPositionY() - height / 2
	--print(x,y,singleW,ContentSize.height)

	local rc = cc.rect(x, y, singleW - 2, height)
	if cc.rectIntersectsRect(rc, touchRect) then 
		return true
	end
	return false
end

--获取一次点击事件， 弹出卡牌的变化
function CardScene:getLastShootCard()
	return self.m_lastOutCards
end

function CardScene:onTouchBegan( x, y )
	print("CardScene:onTouchBegan")
	self.isTouchEdCard = false
    self.isMove = false
    self.isTouchEdOutCardPanel = false
	--print(x,y)
	self.m_lastOutCards = self:GetShootCard()

	self.mTouchCCPointBegin = cc.p(x,y)
	local rectTouch = cc.rect(x, y, 1, 1)
    
    self.curentValaue = -1

	for i,v in ipairs(self.m_vecCardData) do
		--print(i,v)
		local spaceWidth = self.m_cardSpace
		if i == #self.m_vecCardData then
			--print("#self.m_vecCardData ="..#self.m_vecCardData)
			local sprite = self.m_MeHandCardNode:getChildByTag(v)
			if sprite then
				spaceWidth = sprite:getContentSize().width
				--print("spaceWidth ="..spaceWidth)
			end
			
		end
		if v then
			local sprite = self.m_MeHandCardNode:getChildByTag(v)
			if sprite then
				if self:isTouchInCard(rectTouch, sprite, spaceWidth) then
				 	sprite.IsSelected = true --not v.isChoice
				 	sprite:setColor(cc.c3b(178, 229, 255))
				 	self.isTouchEdCard = true
				 	self.curentValaue = v
				end	
			end
		end
	end

	return true
end

function CardScene:onTouchMoved( x, y )
	local p1 = cc.p(x,y)
	if self.mTouchCCPointBegin.x < x then
		p1 = self.mTouchCCPointBegin
	end

    local width = math.abs(self.mTouchCCPointBegin.x - x)
    local heightMove = math.abs(self.mTouchCCPointBegin.y - y)
    if width > 2 or  heightMove > 2 then
       self.isMove = true
    end 
    local height = 5 
    if math.abs(self.mTouchCCPointBegin.y - y) > 5 then
    	height = math.abs(self.mTouchCCPointBegin.y - y)
    end

    local rectTouch = cc.rect(p1.x, p1.y, width, height)

    for i,v in ipairs(self.m_vecCardData) do
		--print(i,v)
		local spaceWidth = self.m_cardSpace
		if i == #self.m_vecCardData then
			--print("#self.m_vecCardData ="..#self.m_vecCardData)
			local sprite = self.m_MeHandCardNode:getChildByTag(v)
			if sprite then
				spaceWidth = sprite:getContentSize().width
				--print("spaceWidth ="..spaceWidth)
			end
		end
		if v then
			local sprite = self.m_MeHandCardNode:getChildByTag(v)
			if sprite then
				if self:isTouchInCard(rectTouch, sprite, spaceWidth) then
				 	sprite.IsSelected = true --not v.isChoice
				 	sprite:setColor(cc.c3b(178, 229, 255))
				 	self.isTouchEdCard = true
				 else
				 	sprite.IsSelected = false 
				 	sprite:setColor(cc.c3b(255, 255, 255))
				end	
			end
		end
	end


	return true
end

--取得被选择的牌,被选中是否存在已经弹起的牌
function CardScene:getSelectCard()
	local bSelectCardData = {}
	local isUp = false
    for i,v in ipairs(self.m_vecCardData) do
		if v then
			local sprite = self.m_MeHandCardNode:getChildByTag(v)
			if sprite then
				if sprite.IsSelected then
				   table.insert(bSelectCardData, sprite.Value)
				   if sprite.IsUp then
                      isUp = true
				   end
				end
			end
		end
	end
	return bSelectCardData , isUp
end

function CardScene:onTouchEnded( x, y )
	local outCardBtnsPanelSize = self.outCardBtnsPanel:getContentSize()
    local pt = self.outCardBtnsPanel:convertToNodeSpace(cc.p(x, y))
    if cc.rectContainsPoint(cc.rect(0, 0, outCardBtnsPanelSize.width, outCardBtnsPanelSize.height), pt) and 
    	self.outCardBtnsPanel:isVisible() then

       self.isTouchEdOutCardPanel = true
    end
	local size = cc.Director:getInstance():getWinSize()
   
    local  curentValaue = -1
    local selectCards , isUp  = self:getSelectCard()
    -- 判断是否只点击一张牌，且这张牌不是弹起来的
    if not isUp and #selectCards == 1 then
    	if selectCards[1] then
           curentValaue = selectCards[1]
        end
    end


	--划牌回调
    if #selectCards > 1 then
		self.m_landMainScene:OnMoveSelectCard( selectCards ) 
	end

	--对当前牌进行选择与取消操作
	for i,v in ipairs(self.m_vecCardData) do
		--print(i,v)
		--获取牌的相关信息
		local sprite = self.m_MeHandCardNode:getChildByTag(v)
		if sprite then
			local SpritePointx,SpritePointy = sprite:getPosition()
			if sprite.IsSelected then	
				if  #selectCards == 1 then
					if sprite.IsUp then
						sprite:setPosition(cc.p(SpritePointx, SpritePointy - size.height/32))
		                sprite.IsUp = false
					else
						sprite:setPosition(cc.p(SpritePointx, SpritePointy + size.height/32))
		                sprite.IsUp = true
		                --curentValaue = v
					end
				end			

				sprite.IsSelected = false 
				sprite:setColor(cc.c3b(255, 255, 255))
			end
		end
	end

	--点击空白地方,所有牌复位
	if not self.isTouchEdCard and not self.isTouchEdOutCardPanel  then
		self:ResetShootCard()
		if self.m_landMainScene and self.m_landMainScene.onClickEmptySpace then
			self.m_landMainScene:onClickEmptySpace()
		end
	end



    self.isTouchEdCard = false
    self.isMove = false
	--点击单张牌回调	
	if #selectCards == 1 then
		self.m_landMainScene:OnLeftHitCard( curentValaue )  
	end
	
	self.m_lastOutCards = {}
end

function CardScene:onTouchCancelled( x, y )
	
end

function CardScene:setDisplayCardEnd()
	self:statusTimerEnd()
	local gameKind = self.m_landMainScene:getLandGameType()
	if gameKind == LandGlobalDefine.HAPPLY_LAND_TYPE then
		--欢乐跑得快
		self.m_landMainScene.m_landMainLayer:setBrightButtonsVisible(false)
	    --隐藏明牌按钮 和 发送发完牌协议
	    self.m_landMainScene:OnSendCardFinish()
	elseif gameKind == LandGlobalDefine.CLASSIC_LAND_TYPE or gameKind == LandGlobalDefine.LAIZI_LAND_TYPE then
		--进入叫分(经典跑得快/癞子跑得快）

	elseif gameKind == LandGlobalDefine.TP_LAND_TYPE then
	    self.m_landMainScene:OnSendCardFinish()
	end
end

function CardScene:setLaiziCardData( bCardData, nCardCount )
	for k,v in pairs(self.m_vecLaiZiCard) do
		table.remove(self.m_vecLaiZiCard,k)
	end
	self.m_vecLaiZiCard = {}
	local bCardDataNum = table.nums(bCardData)
	for i=1,nCardCount do
		self.m_vecLaiZiCard[i] = bCardData[bCardDataNum+1-i]
	end
end


function CardScene:removeAllHandleCard()
	self:ClearHandCard()
	self.m_LaiZiOutCardNode:removeAllChildren()
end


-- 仅用于癞子
function CardScene:DrawOutCard( bCardData, nCardCount, bIsDiZhu )
	self:ClearOutCard()

	for i=1,nCardCount do
		self.m_vecOutCard[i] = bCardData[i]
	end

	local fscale = CardConfig.OutCardScale
	local size = cc.Director:getInstance():getWinSize()   
	local ToPoint = cc.p(size.width/2 - (nCardCount-1)/2*CardConfig.CardSpace*fscale,size.height/2+20)

	for i=1,nCardCount do
		local nInedx = bCardData[i]
        print("牌的下标 nInedx = "..nInedx)
        local pSprite = self.m_landMainScene.m_landMainLayer.m_cardSprite:createCard(nInedx)
        if GetCardLogicValue(nInedx) == GetCardLogicValue(self.m_landLaiziCardId) then
        	nIndex = 80 + GetCardLogicValue(self.m_landLaiziCardId)
        end
        if pSprite then
        	if nInedx > 80 then
        		pSprite:setPosition(cc.p(self.m_MeHandCardNode:getChildByTag(self.m_vecCardData[1]):getPositionX(),self.m_ptBenchmarkPos.y))
        	else
        		pSprite:setPosition(cc.p(self.m_MeHandCardNode:getChildByTag(nInedx):getPositionX(),self.m_ptBenchmarkPos.y))
        	end
            self.m_LaiZiOutCardNode:addChild(pSprite, 2, nInedx)
	        if bIsDiZhu then
	        	local isDiZhuPrite = display.newSprite("#land_icon_lord.png")
	        	if isDiZhuPrite then
	        		pSprite:addChild(isDiZhuPrite)
	        		isDiZhuPrite:setScale(1.5)
	        		isDiZhuPrite:setAnchorPoint(1,1)
	         		isDiZhuPrite:setPosition(pSprite:getContentSize().width - 10, pSprite:getContentSize().height - 7)
	        	end
	        end
	        
	        local pMoveAction = cc.MoveTo:create(0,ToPoint);
	        local pScaleAction = cc.ScaleTo:create(0, fscale);

	        pSprite:runAction(cc.Spawn:create(pMoveAction,pScaleAction))

	        ToPoint.x = ToPoint.x + CardConfig.CardSpace*fscale;
        end
	end
end


-- 欢乐跑得快 小牌绘制
--发牌
function CardScene:HappyLand_DispatchCard( cardData , parentNode, model)

    local gameKind = self.m_landMainScene:getLandGameType()
    if gameKind == LandGlobalDefine.HAPPLY_LAND_TYPE or gameKind == LandGlobalDefine.TP_LAND_TYPE then 


	end

	local cardGap = 23
    local dispatchCardTable = {}

    for i, v in ipairs(cardData) do
    	dispatchCardTable[i] = v
    end

    table.sort(dispatchCardTable,SortCardTable)
    local width = table.nums(dispatchCardTable) * cardGap
    local dispacthNum = 0
   

    --绘制本家的牌
    self:statusTimerBegin()

end


return CardScene