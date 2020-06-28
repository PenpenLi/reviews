--
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 一局跑得快牌局回放数据
local GameLogic = require("app.game.pdk.src.landcommon.logic.GameLogic")
local LandReplayData = class("LandReplayData")


function LandReplayData:ctor()
	self:myInit()
end

function LandReplayData:initGameData( ... )
	-- 当前牌局数据
	self.cur_game_data = {}

	-- 初始手牌数据
	self.vec_17_data   = {}
	
	-- 叫分数据
	-- [座位, 叫分], 
	self.call_score_data = {}

	-- 底牌
	self.bottom_card = {}

	-- 加倍
	self.jiabei_tbl  = {}
	-- 出牌信息
	-- [ 座位, [出牌内容 就是牌id数组] ], 
	-- 有多个，格式同上，出牌内容可能为 null ，表示pass
	self.out_card_data = {}
	-- 某小局结算信息
	--[ 基础分, 是否春天, 总翻倍数, 总炸弹数 ],

	-- 玩家输赢信息
	self.win_lose_data = {} 
end

function LandReplayData:myInit()
	-- 牌局信息
	--[牌局id, 总轮数, 房间id, 最大炸弹],
	self.round_data = {}

	-- 玩家信息 下标就是座位号
	--[ 账号id, 头像, 名字, 地主次数, 分数 ]
	self.player_data = {}

	-- 全部六局牌局数据
	self.all_game_data = {}


	self:initGameData()
	
	self.m_GameLogic = GameLogic:new() 
end

function LandReplayData:setVecData( tbl )
	self.round_data     = tbl[1]
    self:initPlayerData( tbl[2] )
    self.all_game_data  = tbl[3]
    self:initAllWinLose()

end

function LandReplayData:initAllWinLose()
	self.all_game_score = {}
	self.all_win_lose   = {}
	for ju,v in ipairs( self.all_game_data ) do
		self.all_win_lose[ju]   = {}
		self.all_game_score[ju] = {}
		for chair,val in ipairs( v[1] ) do
			if not self.all_game_score[ju-1] then self.all_game_score[ju-1] = {0,0,0} end
			local ret = val[1]
			self.all_win_lose[ju][chair]   = ret
			self.all_game_score[ju][chair] = self.all_game_score[ju-1][chair] + ret
		end
	end
end
function LandReplayData:getJuWinLose( ju )
	return self.all_win_lose[ju]
end

function LandReplayData:getJuGameScore( ju )
	return self.all_game_score[ju-1]
end

function LandReplayData:init_with_txt_file( path )
    local jsonSTR = self:read_file( path )
    local tbl = require("cjson").decode( jsonSTR )
end

function LandReplayData:read_file( fileName )
	local path = device.writablePath .. fileName
    local f = io.open(path,'r')
    local content = f:read("*all")
    f:close()
    return content
end 



function LandReplayData:setCurGameData( key )
	self:initGameData()
	if not self.all_game_data[key] then return end
	self.cur_game_data   = self.all_game_data[key]
	self.ret_and_poker   = self.cur_game_data[1]
	
	self:initBottomCard()
	self:initJiaBei()	
	self:initCallScore()
	self:initVec17Poker()
	self:initOutCardData()
	self:initWinLoseData()
	self:initJieSuanData()
end

function LandReplayData:initPlayerData( tbl )
	local myACC = Player:getAccountID()
    self.player_data    =  tbl
    self.my_nick_name = ""
    self.my_chair_id  = 0 
	for k,v in pairs( self.player_data ) do
		if v[1] == myACC then
		    self.my_nick_name = v[3]
		    self.my_chair_id  = k
		end
	end
end

function LandReplayData:initBottomCard( ... )
	self.bottom_card = {}
	if not self.cur_game_data[3] then return end
	for i,v in ipairs( self.cur_game_data[3] ) do
		self.bottom_card[i] =  v 
	end
end

function LandReplayData:initJiaBei( ... )
	self.jiabei_tbl = {}
	if not self.cur_game_data[4] then return end
	for i,v in ipairs( self.cur_game_data[4] ) do
		self.jiabei_tbl[i] = {}
		self.jiabei_tbl[i].opChair =  v[1] 
		self.jiabei_tbl[i].call    =  v[2] 
		self.jiabei_tbl[i].bei_shu =  {v[3],v[4],v[5]} 
	end
end

function LandReplayData:initCallScore()
	self.call_score_data = {}
	if not self.cur_game_data[2] then return end
	self.call_score_data = self.cur_game_data[2]
	local max        = 0
    self.dizhu_chair = 0
    for i,v in ipairs( self.call_score_data ) do
    	local chairId = v[1]
    	local callScore = v[2]
    	if callScore > max then
    		max = callScore
    		self.dizhu_chair = chairId
    	end 
    end
end

function LandReplayData:initVec17Poker( ... )
	self.vec_17_data = {}
	for chair,tbl in ipairs( self.ret_and_poker ) do
		self.vec_17_data[chair] = {}
		local poker = tbl[2]
		for i,v in ipairs( poker ) do
			self.vec_17_data[chair][i] = v
		end
		--table.sort( self.vec_17_data[chair] ,SortCardTable )
	end
	
end

function LandReplayData:initWinLoseData()
	self.win_lose_data = {}
	for i,v in ipairs( self.ret_and_poker ) do
		self.win_lose_data[i] = v[1]
	end
end

function LandReplayData:initOutCardData( ... )
	self.out_card_data = {}
	if not self.cur_game_data[5] then return end
	self.total_cards = clone( self.vec_17_data )
	
	for step,v in ipairs( self.cur_game_data[5] ) do
		self.out_card_data[step] = {}
		local chair = v[1]
		self.out_card_data[step].chair = chair
		
		self.out_card_data[step].cur_card = {}
		for cc=1,3 do
			self.out_card_data[step].cur_card[cc] = clone(self.total_cards[cc])
		end

		self.out_card_data[step].bei_shu = {v[3],v[4],v[5]}

		if type(v[2]) == "table" then
			self.out_card_data[step].out_card = {}
			for ci,cv in ipairs( v[2] ) do
				self.out_card_data[step].out_card[ci] = cv
			end
			
			local tbl = self.m_GameLogic:RemoveCard( self.out_card_data[step].out_card , self.total_cards[chair] )
			self.out_card_data[step].cur_card[chair] = clone( tbl )
		else
			self.out_card_data[step].out_card = nil
		end
	end
end

function LandReplayData:initJieSuanData( ... )
	self.jiesuan_data = self.cur_game_data[6]
end

function LandReplayData:getDiZhuChair( ... )
	return self.dizhu_chair
end
function LandReplayData:getMy17Poker( ... )
	local meChair = self:getMyChair()
	return self.vec_17_data[meChair]
end

function LandReplayData:getMyChair( ... )
	return self.my_chair_id
end

function LandReplayData:getMyNickName( ... )
	return self.my_nick_name
end
function LandReplayData:getCurGameData( ... )
	return self.cur_game_data
end

function LandReplayData:getAllGameData( ... )
	return self.all_game_data
end

function LandReplayData:getTotalRound( ... )
	return self.round_data[2]
end
function LandReplayData:getRoundData( ... )
	return self.round_data
end

function LandReplayData:getPlayerData( ... )
	return self.player_data
end

function LandReplayData:getBottomCard( ... )
	return self.bottom_card
end

function LandReplayData:getJiaBeiInfo( key )
	if not self.jiabei_tbl then return end
	if key then return self.jiabei_tbl[key] end
	return self.jiabei_tbl
end


function LandReplayData:getCallScore( key )
	if not self.call_score_data then return end
	if key then return self.call_score_data[key] end
	return self.call_score_data
end


function LandReplayData:getWinLoseData()
	return self.win_lose_data
end


function LandReplayData:getOutCardData( key )
	return self.out_card_data[key]
end

function LandReplayData:getAllOutCardData( ... )
	return self.out_card_data
end

function LandReplayData:getJieSuanData( ... )
	return self.jiesuan_data
end

function LandReplayData:getTotalBeiShu( ... )
	return self.jiesuan_data[3]
end




return LandReplayData