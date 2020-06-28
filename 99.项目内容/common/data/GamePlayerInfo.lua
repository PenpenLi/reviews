--
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 玩家数据类

local GamePlayerInfo = class("GamePlayerInfo")

function GamePlayerInfo:ctor()

end

function GamePlayerInfo:myInit()
	self.m_chairId = nil -- 椅子id
	self.m_accountId = nil -- 玩家id
	self.m_faceId = nil -- 头像id
	self.m_goldCoin = nil -- 金币数
	self.m_nickname = nil -- 昵称
	self.m_level = nil -- 等级
	self.m_gameScore = nil -- 积分
end

function GamePlayerInfo:setChairId( __data )
	self.m_chairId = __data
end
function GamePlayerInfo:getChairId()
	return self.m_chairId
end

function GamePlayerInfo:setAccountId( __data )
	self.m_accountId = __data
end
function GamePlayerInfo:getAccountId()
	return self.m_accountId
end

function GamePlayerInfo:setFaceId( __data )
	self.m_faceId = __data
end
function GamePlayerInfo:getFaceId()
	return self.m_faceId
end

function GamePlayerInfo:setGoldCoin( __data )
	self.m_goldCoin = __data
end
function GamePlayerInfo:getGoldCoin()
	return self.m_goldCoin
end

function GamePlayerInfo:setNickname( __data )
	self.m_nickname = __data
end
function GamePlayerInfo:getNickname()
	return self.m_nickname
end

function GamePlayerInfo:setLevel( __data )
	self.m_level = __data
end
function GamePlayerInfo:getLevel()
	return self.m_level
end

function GamePlayerInfo:setGameScore( __gameScore )
	self.m_gameScore = __gameScore
end

function GamePlayerInfo:getGameScore()
	return self.m_gameScore
end


return GamePlayerInfo