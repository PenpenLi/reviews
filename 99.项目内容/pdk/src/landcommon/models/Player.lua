-- Player
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 玩家类型

local CardConfig = require("app.game.pdk.src.landcommon.data.CardConfig")

local Player = class("Player")

function Player:ctor( landMainScene )

    print("Player:ctor()")
    
    self.m_isDiZhu = false           --是否为地主
    self.m_isCall = false            --是否已叫地主
    self.m_iCallNum = 0              --叫地主的分数
    self.m_point = cc.p(0,0)         --牌在桌面的初始位置
    self.m_iPlayerClass = 0
    self.m_isOutPk = false           --玩家是否出牌true:出 false:不出
    self.m_ptClock = cc.p(0,0)  
    self.m_ptCardNum = cc.p(0,0)
    self.m_ptOutCard = cc.p(0,0)     --牌在桌面的初始位置
    self.m_ptHeadImg = cc.p(0,0)     --头像
    self.m_nScoreTime = 15           -- 叫分时间
	self.m_nOutCardTime = 15	     --出牌总时间
    self.m_nOutCardChenTime = 15     -- 惩罚之后的出牌时间
    self.m_nCardCount = 0
    self.m_bCardData = {}
    self.m_landMainScene = landMainScene
    self.m_RightHandCardTab = {}
end

--创建单张
function Player:createSigleCard(cardId, scale, cardBack, bRangPai)  
    --print("------Player:createSigleCard----", cardId,scale,cardBack, bRangPai) 
    local cardInfo = CardConfig.CardInfos[cardId]
    local  sprite = nil
    if cardInfo then
        local imgPath = string.format("#%s.png",cardInfo.CardIcon)
        if cardBack then
            imgPath="#poker_back.png"
        end
        if bRangPai then
            imgPath="#poker_back_rang.png"
        end
        sprite = display.newSprite(imgPath)
        if  sprite and scale then
            sprite:setScale(scale)
        end
    end
    return sprite
end

function Player:DrawOutCardTP(pSender, bCardData, nCardCount, bIsDiZhu)
    print("----Player:DrawOutCardTP---", pSender, bCardData, nCardCount, bIsDiZhu)
    self:ClearOutCard(pSender)
    
    self.m_nCardCount = nCardCount
    
    for i=1,nCardCount do
        self.m_bCardData[i] = bCardData[i]
    end
    table.sort(self.m_bCardData, SortCardTable)
    
    local fscale = 0.62    
    local distX = CardConfig.CardSpace*fscale
    local ToPoint =  self.m_landMainScene.m_landMainLayer:getRightOutCardPos()
    local size = cc.Director:getInstance():getWinSize()    
    local leftPosX = size.width/2 - (nCardCount-1)/2 * distX

    for i=1,nCardCount do
        local nIndex = self.m_bCardData[i]

        print("牌的下标 nIndex = "..nIndex)
        if nIndex then
            local pBackSprite = self:RemoveRightHandBackCard(nIndex)
            local pSprite = self:createSigleCard(nIndex)
            if  pSprite then 
                pSender:addChild(pSprite, 2, nIndex)
                if pBackSprite then 
                    pSprite:setPosition(pBackSprite:getPosition()) 
                    pBackSprite:removeFromParent(true)
                else          
                    pSprite:setPosition(cc.p(leftPosX,ToPoint.y))
                end
                if bIsDiZhu then
                    local isDiZhuPrite = display.newSprite("#land_icon_lord.png")
                    if isDiZhuPrite then
                        pSprite:addChild(isDiZhuPrite)
                        isDiZhuPrite:setScale(1.5)
                        isDiZhuPrite:setAnchorPoint(1,1)
                        isDiZhuPrite:setPosition(pSprite:getContentSize().width - 10, pSprite:getContentSize().height - 7)
                    end
                end
                local pMoveAct = cc.MoveTo:create(0, cc.p(leftPosX,ToPoint.y))
                local pScaleAct = cc.ScaleTo:create(0, fscale)
                pSprite:runAction(cc.Spawn:create(pMoveAct, pScaleAct))
                leftPosX = leftPosX + distX
            end
        end
    end

end

function Player:DrawRightHandBackCard(pSender, bCardData, nCardCount, rangPaiCount, dizhuCard)
    if not nCardCount or nCardCount <= 0 then
       return
    end
    self:RemoveAllRightHandBackCard()
    if not self.m_pRightHand then
        self.m_pRightHand = display.newNode()
        pSender:addChild(self.m_pRightHand, 2)
    end
    
    for i = 1, nCardCount do
        self.m_RightHandCardTab[i] = bCardData[i]
    end

    local fscale = 0.39    
    local distX = CardConfig.CardSpace*fscale
    local ToPoint = self.m_landMainScene.m_landMainLayer:getRightBackCardPos()
    local size = cc.Director:getInstance():getWinSize()    
    local leftPosX = 1280/2 - (nCardCount-1)/2 * distX

    if not rangPaiCount then rangPaiCount = 0 end
    local toCardNum = nCardCount - rangPaiCount
    if toCardNum < 0 then 
        toCardNum = 0 
        rangPaiCount = nCardCount
    end
    for i=1,toCardNum do
        local nIndex = self.m_RightHandCardTab[i]
        local pSprite = nil
        if nIndex then
            if dizhuCard and dizhuCard==nIndex then --是否名牌
                pSprite = self:createSigleCard(nIndex, 0, false)
            else
                pSprite = self:createSigleCard(nIndex, 0, true)
            end
        end
        print("<<牌的下标 nIndex = ",nIndex, pSprite)

        if pSprite and nIndex then
            pSprite:setPosition(cc.p(leftPosX,ToPoint.y))
            self.m_pRightHand:addChild(pSprite, 2, nIndex)
            
            pSprite:runAction(cc.ScaleTo:create(0, fscale))
            leftPosX = leftPosX + distX;
        end
    end
    print("-------让牌-------", rangPaiCount)
    for i=1,rangPaiCount do
        local nIndex = self.m_RightHandCardTab[toCardNum+i]
        local pSprite = nil
        if nIndex then
            if dizhuCard and dizhuCard==nIndex then
                pSprite = self:createSigleCard(nIndex, 0, false)
            else
                pSprite = self:createSigleCard(nIndex, 0, false, true)
            end
        end
        print(">>让牌的下标 nIndex = ", nIndex, pSprite)

        if pSprite and nIndex then
            pSprite:setPosition(cc.p(leftPosX,ToPoint.y))
            self.m_pRightHand:addChild(pSprite, 2, nIndex)
            
            pSprite:runAction(cc.ScaleTo:create(0, fscale))
            leftPosX = leftPosX + distX;
        end
    end
end
function Player:RemoveAllRightHandBackCard()
    if self.m_pRightHand then 
        self.m_pRightHand:removeAllChildren(true)
    end
    self.m_RightHandCardTab = {}
end
function Player:RemoveRightHandBackCard(nIndex)
    local pBackSprite = nil
    if self.m_pRightHand then 
       pBackSprite = self.m_pRightHand:getChildByTag(nIndex)
       for i, v in ipairs(self.m_RightHandCardTab) do
            if v==nIndex then
               table.remove(self.m_RightHandCardTab, i)
              break
           end
        end
    end
    return pBackSprite
end

function Player:AddRightHandBackCard(nIndex, dizhuIndex)
    local tabCount = #self.m_RightHandCardTab
    for i=1,tabCount do
        if self.m_RightHandCardTab[i]==nIndex then
            tabCount = -1
            break
        end
    end
    print("------AddRightHandBackCard-----", tabCount, nIndex, tabCount)
    if tabCount>=0 then
        self.m_RightHandCardTab[tabCount+1] = nIndex
        self:DrawRightHandBackCard(self.m_landMainScene.m_landMainLayer, self.m_RightHandCardTab, tabCount+1, 0, dizhuIndex)
    end
end

--
function Player:DrawOutCard(pSender, bCardData, nCardCount, bIsDiZhu)
    self:ClearOutCard(pSender)
    self.m_nCardCount = nCardCount    
    for i=1,nCardCount do
        self.m_bCardData[i] = bCardData[i]
    end
    local size = cc.Director:getInstance():getWinSize()
    local fscale = CardConfig.OutCardScale
    local ptCardStartx = self:getPoint2OutCard().x
    local ptCardStarty = self:getPoint2OutCard().y
    if 1 == self.m_iPlayerClass then
        if nCardCount > 8 then
            ptCardStartx = ptCardStartx - 10*CardConfig.CardSpace*fscale+CardConfig.CardWidth*fscale/2
        else
            ptCardStartx = ptCardStartx - nCardCount*CardConfig.CardSpace*fscale+CardConfig.CardWidth*fscale/2
        end
    end

    local nowCount = 0
    for i=1,nCardCount do
        --如果牌超过10张，则换行显示
        nowCount = nowCount + 1
        if self.m_landMainScene.gameKind ~= 1015 then
            if nowCount == 9 then
                print("self:getPoint2OutCard()",self:getPoint2OutCard().x,self:getPoint2OutCard().y)
                ptCardStartx = self:getPoint2OutCard().x
                ptCardStarty = self:getPoint2OutCard().y
                if 1 == self.m_iPlayerClass then
                    ptCardStartx = ptCardStartx - 10*CardConfig.CardSpace*fscale+ CardConfig.CardWidth*fscale/2
                end
                ptCardStarty = ptCardStarty-40
            elseif nowCount == 17 then
                print("self:getPoint2OutCard()",self:getPoint2OutCard().x,self:getPoint2OutCard().y)
                ptCardStartx = self:getPoint2OutCard().x
                ptCardStarty = self:getPoint2OutCard().y
                if 1 == self.m_iPlayerClass then
                    ptCardStartx = ptCardStartx - 10*CardConfig.CardSpace*fscale+ CardConfig.CardWidth*fscale/2
                end
                ptCardStarty = ptCardStarty-80
            end
        end
        

        local nIndex = bCardData[i]
        
        local pSprite = self.m_landMainScene.m_landMainLayer.m_cardSprite:createCard(nIndex, fscale)
        if pSprite then
            --print("创建一个出的片 nIndex为: "..nIndex)
            pSprite:setPosition(cc.p(ptCardStartx,ptCardStarty))
            pSender:addChild(pSprite, 2, nIndex)
            if bIsDiZhu then
                local isDiZhuPrite = display.newSprite("#land_icon_lord.png")
                if isDiZhuPrite then
                    pSprite:addChild(isDiZhuPrite)
                    isDiZhuPrite:setScale(1.5)
                    isDiZhuPrite:setAnchorPoint(1,1)
                    isDiZhuPrite:setPosition(pSprite:getContentSize().width - 10, pSprite:getContentSize().height - 7)
                end
            end
            --pSprite:runAction(cc.ScaleTo:create(0, fscale))
            --pSprite:setScale(fscale)
            ptCardStartx = ptCardStartx + CardConfig.CardSpace*fscale;
        end

    end
end

function Player:ClearOutCard(pSender)

    for i=1,self.m_nCardCount do
        local nIndex = self.m_bCardData[i]
        pSender:removeChildByTag(nIndex,true)
    end
    for k,v in pairs(self.m_bCardData) do
        table.remove(self.m_bCardData,k)
    end
    self.m_bCardData = {}
    self.m_nCardCount = 0
end

--是否为地主
function Player:setIsDiZhu(IsDiZhu)
    self.m_isDiZhu = IsDiZhu
end

function Player:getIsDiZhu()
    return self.m_isDiZhu
end

--是否已叫地主
function Player:setCall(Call)
    self.m_isCall = Call
end

function Player:getCall()
    return self.m_isCall
end

--叫地主的分数
function Player:setCallNum(CallNum)
    self.m_iCallNum = CallNum
end

function Player:getCallNum()
    return self.m_iCallNum
end

--牌在桌面的初始位置
function Player:setPoint(Point)
    self.m_point = Point
end

function Player:getPoint()
    return self.m_point
end

--玩家种类
function Player:setPlayerClass(PlayerClass)
    self.m_iPlayerClass = PlayerClass
end

function Player:getPlayerClass()
    return self.m_iPlayerClass
end

--玩家是否出牌
function Player:setIsOutPk(IsOutPk)
    self.m_isOutPk = IsOutPk
end

function Player:getIsOutPk()
    return self.m_isOutPk
end

--牌在桌面的初始位置
function Player:setPoint2Clock(Point2ClockX, Point2ClockY)
    self.m_ptClock = cc.p(Point2ClockX,Point2ClockY)
end

function Player:getPoint2Clock()
    return self.m_ptClock
end

--牌在桌面的初始位置
function Player:setPoint2CardNum(Point2CardNum)
    self.m_ptCardNum = Point2CardNum
end

function Player:getPoint2CardNum()
    return self.m_ptCardNum
end

--牌在桌面的初始位置
function Player:setPoint2OutCard(Point2OutCard)
    self.m_ptOutCard = Point2OutCard
end

function Player:getPoint2OutCard()
    return self.m_ptOutCard
end

--牌在桌面的初始位置
function Player:setPoint2HeadImg(Point2HeadImg)
    self.m_ptHeadImg = Point2HeadImg
end

function Player:getPoint2HeadImg()
    return self.m_ptHeadImg
end

--玩家是否出牌
function Player:setScoreTime(ScoreTime)
    self.m_nScoreTime = ScoreTime
end

function Player:getScoreTime()
    return self.m_nScoreTime
end

--设置玩家可用出牌时间
function Player:setOutCardTime(outCardTime)
    self.m_nOutCardTime = outCardTime
end

function Player:getOutCardTime()
    return self.m_nOutCardTime
end

--设置玩家可用出牌时间
function Player:setOutCardChenTime(outCardTime)
    self.m_nOutCardChenTime = outCardTime
end

function Player:getOutCardChenTime()
    return self.m_nOutCardChenTime
end

return Player