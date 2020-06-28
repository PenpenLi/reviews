--
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 跑得快牌局玩家数据类

local LandGamePlayer = class("LandGamePlayer")

function LandGamePlayer:ctor( chair ,  account )
	self.chair    = chair
	self.account  = account
end

function LandGamePlayer:getChair()
	return self.chair
end

function LandGamePlayer:getAccount()
	return self.account
end

function LandGamePlayer:setFace( face )
	self.face = face
end

function LandGamePlayer:getFace()
	return self.face
end

function LandGamePlayer:setLevel( num )
	self.level = num
end

function LandGamePlayer:getLevel()
	return self.level
end

function LandGamePlayer:setPoint( num )
	self.point = num
end

function LandGamePlayer:getPoint()
	return self.point
end


function LandGamePlayer:setNickName( str )
	self.nick_name = str
end

function LandGamePlayer:getNickName()
	return self.nick_name
end

function LandGamePlayer:setCSBName( this_phone_chair )
	local gap = self:getChair() - this_phone_chair
	if gap == 0 then
		self.csb_name = "self"
	elseif gap == 1 or gap == -2 then
		self.csb_name = "right" 
	else
		self.csb_name = "left"
	end
end

function LandGamePlayer:getCSBName()
	return self.csb_name
end


function LandGamePlayer:setCard( client_tbl )
	self.card = clone( client_tbl )
	table.sort( self.card , SortCardTable )
end

function LandGamePlayer:getCard()
	return self.card
end

function LandGamePlayer:addCard( client_tbl )
	--防止重复插入
	local temp = {}
	for k,v in pairs( self.card ) do
		temp[v] = 1
	end
	for k,v in pairs( client_tbl ) do
		temp[v] = 1
	end

	local ret = {}
	for k,v in pairs( temp ) do
		table.insert( ret , k )
	end
	self:setCard( ret )
end

return LandGamePlayer