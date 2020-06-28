-- HandCardLayout
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 跑得快手牌UI
local CardConfig     = require("app.game.pdk.src.landcommon.data.CardConfig")
local HandCardLayout = class("HandCardLayout", function ()
	return ccui.Layout:create()
end)

function HandCardLayout:ctor( cardTBL )
	self:myInit() 
	self:addCardSprite( cardTBL )
	self:initTouch()
end

function HandCardLayout:myInit()
	local size = cc.Director:getInstance():getWinSize()
	self:setAnchorPoint(0.5,0)
	self:setPositionX( size.width/2 )
end

function HandCardLayout:addCardSprite( cardTBL )
	local width,cardSpace = self:calLayoutWidth( #cardTBL )
	for k,v in ipairs( cardTBL ) do
		local sprite  = CREATE_CLASSIC_CARD( v )
		sprite:setAnchorPoint(cc.p(0,0))
		sprite:setPositionX((k-1)*cardSpace)
		self:addChild( sprite )
	end
	self:setContentSize( cc.size(width, CardConfig.CardHeight) )
end

function HandCardLayout:calLayoutWidth( num )
	local cardSpace = 0
	local oneCardWidth = CardConfig.CardWidth
	if num <= 1 then return oneCardWidth , cardSpace end
	local size = cc.Director:getInstance():getWinSize()
	local spaceCount = math.max(1,num-1)
	cardSpace = (size.width - oneCardWidth)/spaceCount
	cardSpace = math.min(CardConfig.CardSpace,cardSpace)
	local ret = spaceCount*cardSpace+oneCardWidth
	return ret,cardSpace
end

function HandCardLayout:initTouch()
	local  listenner = cc.EventListenerTouchOneByOne:create()
	local  function onTouchBegan( touch, event )
		print( "onTouchBegan" )
		local touchPoint = touch:getLocation()
		dump( touchPoint )
		if self:getCascadeBoundingBox():containsPoint( touchPoint ) then
			print("111在手牌UI内")
		end
		return true
	end

	local  function onTouchMove( touch, event )
		print( "onTouchMove" )
		local touchPoint = touch:getLocation()
		dump( touchPoint )
		if self:getCascadeBoundingBox():containsPoint( touchPoint ) then
			print("222在手牌UI内")
		end
	end

	local  function onTouchEnd( touch, event )
		local touchPoint = touch:getLocation()
		dump( touchPoint )
		if self:getCascadeBoundingBox():containsPoint( touchPoint ) then
			print("333在手牌UI内")
		end
	end

	listenner:registerScriptHandler(onTouchBegan , cc.Handler.EVENT_TOUCH_BEGAN )
	listenner:registerScriptHandler(onTouchMove  , cc.Handler.EVENT_TOUCH_MOVED )
	listenner:registerScriptHandler(onTouchEnd   , cc.Handler.EVENT_TOUCH_ENDED )
	
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)
end

return HandCardLayout