-----------------------------------------
--
-- CardSprite
-- Author: chengzhanming
-- Date:   2016.06.29
--
------------------------------------------

local CardConfig = require("app.game.pdk.src.landcommon.data.CardConfig")
local LandGlobalDefine = require("app.game.pdk.src.landcommon.data.LandGlobalDefine")

local CardSprite = class("CardSprite")

CardSprite.type_cardBack = 101   --牌的背面
CardSprite.type_cardRangPaiBack = 102   --让牌的背面
function CardSprite:ctor( gameKindId )
    self.m_gameKindId = gameKindId
    self.m_laiziCardId = 0
end

function CardSprite:setLaiziCardId( laiziCardId )
    self.m_laiziCardId = laiziCardId
end

--创建单张
function CardSprite:createCard( cardId ,scale)
	local imgPath = ""
	local sprite = nil
	local cardInfo = nil
    if self.m_gameKindId == LandGlobalDefine.LAIZI_LAND_TYPE then  --癞子跑得快
        if GetCardLogicValue(cardId) == GetCardLogicValue( self.m_laiziCardId ) then
            sprite = self:createLaiZiCard( self.m_laiziCardId ,true)
        elseif cardId >= 0x51 and  cardId <= 0x5D then
            sprite = self:createLaiZiCard( cardId ,true)
	    else
		    cardInfo = CardConfig:getCardInfoByid(cardId)
		    if cardInfo then
		        imgPath = string.format("#%s.png",cardInfo.CardIcon)
		        sprite = display.newSprite(imgPath)
	        end
	    end
    else
         cardInfo = CardConfig:getCardInfoByid(cardId)
         if cardInfo then
		    imgPath = string.format("#%s.png",cardInfo.CardIcon)
		    sprite = display.newSprite(imgPath)
	     end
    end
    if sprite and scale then
       sprite:setScale(scale)
    end
	return sprite
end

--生成小牌
function CardSprite:createSmallCard( CardValue , isName)
    local cardPath=nil
    local color = math.floor(CardValue/16)
    local value = CardValue%16
    local function getColorString(color)
        local str
        if color == 0 then
            str="square"
        elseif color == 1 then
            str="club"
        elseif color == 2 then
            str="hearts"
        elseif color == 3 then
            str="spade"
        end
        return str
    end 
    local function getValueString(value)
        local str
        if value >= 2 and value <= 10 then
            str=value
        elseif value == 1 then
            str="a"
        elseif value == 11 then
            str="j"
        elseif value == 12 then
            str="q"
        elseif value == 13 then
            str="k"
        end
        return str
    end 

    --路径
	local Psth = ""
	local isLaizi = false
    if CardValue == 0x4E then
        cardPath="smallking"
		Psth = "lord_poker_"..cardPath..".png"
		isLaizi = false
    elseif CardValue == 0x4F then
        cardPath="bigking"
		Psth = "lord_poker_"..cardPath..".png"
		isLaizi = false
    elseif   CardValue >= 0x01 and  CardValue <= 0x3D then
        local colorStr=getColorString(color)
        local valueStr=getValueString(value)
        cardPath=colorStr.."_"..valueStr
		Psth = "lord_poker_"..cardPath..".png"
		isLaizi = false 
	elseif CardValue >= 0x51 and  CardValue <= 0x5D then
		isLaizi = true
	end
	
	if isLaizi then
        return self:createLaiZiCard(CardValue,false)
	else
	    if isName  then
           return Psth
        else
           Psth = "#"..Psth
           local cardSprite = display.newSprite(Psth)
           return cardSprite
        end  
	end
end


	
function  CardSprite:getCardRect(cardId, isBig)
	local logicValue =  GetCardLogicValue( cardId )
	local cardW, cardH = 0,0
	if isBig then
	   cardW, cardH = 58,70
	   print(" cardW, cardH = 58,70")
	else
       cardW, cardH = 37,39
       print(" cardW, cardH = 37,39")
	end 
	local x = 0
	if logicValue == 14 then
		x = 0
	elseif logicValue == 15 then
		x = cardW * 1
	else
		x = cardW * (logicValue - 1)
	end
	return cc.rect(x, 0, cardW, cardH)
end


--创建癞子牌
function CardSprite:createLaiZiCard( cardId ,isBig)
	local laiziNumPng = "" 
	local laiziBg = ""
	local cardH = 0
    local cardNumSpH = 0
	
	if isBig then
        laiziNumPng = "poker_laizi_num_b.png"
        laiziBg = "poker_laizi_b.png"
        cardNumSpH = CardConfig.CardHeight - 70
	else
        laiziNumPng = "poker_laizi_num_s.png"
        laiziBg = "poker_laizi_s.png"
        cardNumSpH = CardConfig.SmallCardHeight - 37 
	end
	local cardNumSp = cc.Sprite:create(laiziNumPng, self:getCardRect( cardId, isBig ) )
    local cardBg = cc.Sprite:create(laiziBg)
	cardNumSp:setAnchorPoint(0,0)
    cardNumSp:setPosition(0, cardNumSpH)
	cardBg:addChild( cardNumSp )
	return cardBg
end

--创建牌的背面
function CardSprite:createSigleCard(cardBackType, scale)  
	local  imgPath = ""
    if cardBackType == CardSprite.type_cardBack then
       imgPath="#poker_back.png"
    elseif cardBackType == CardSprite.type_cardRangPaiBack then
       imgPath="#poker_RangPaiBack.png"
    end
	local  sprite  = display.newSprite(imgPath)
	if  sprite and scale then
	    sprite:setScale(scale)
	end
    return sprite
end

--判断当前牌是否被选中
function CardSprite:IsTouchSprite()
	
end

return CardSprite