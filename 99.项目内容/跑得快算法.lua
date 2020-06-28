--[[逻辑类跑得快
创建 self.m_GameLogic     = GameLogic:new()
分析牌型 self.m_GameLogic:GetCardType( CardKit:S2C_CONVERT(tbl) )
搜索提示 self.m_GameLogic:SearchOutCard(myCardsServer, lastCardsServer, true)
比较大小 self.m_GameLogic:CompareCard(enemyCard, curShootCard)
从提示牌中，智能选择牌型. 用于选牌回调
--]]

1.明确规则,确认牌型
LandGlobalDefine.CT_ERROR=					0		                --错误类型
LandGlobalDefine.CT_SINGLE=					1		                --单牌类型
LandGlobalDefine.CT_DOUBLE=					2		                --对牌类型
LandGlobalDefine.CT_THREE=					3		          		--三条类型
LandGlobalDefine.CT_SINGLE_LINE	=			4						--单连类型
LandGlobalDefine.CT_DOUBLE_LINE=			5						--对连类型
LandGlobalDefine.CT_THREE_LINE=				6						--三连类型

-- LandGlobalDefine.CT_THREE_TAKE_ONE=		    7						--三带一单
-- LandGlobalDefine.CT_THREE_TAKE_TWO=		    8						--三带一对
LandGlobalDefine.CT_THREE_TAKE_TT=		    8						--三带两张，可以是两单，也可以是一对
-- LandGlobalDefine.CT_FOUR_LINE_TAKE_ONE=		9						--四带两单
-- LandGlobalDefine.CT_FOUR_LINE_TAKE_TWO=		10						--四带两对
LandGlobalDefine.CT_FOUR_TAKE_THREE	=   	11						--四带三
LandGlobalDefine.CT_FEIJI_TAKE_ONE=         12      				--飞机类型
LandGlobalDefine.CT_FEIJI_TAKE_TWO=         13      				--飞机类型

LandGlobalDefine.CT_BOMB_CARD=				14						--炸弹类型
LandGlobalDefine.CT_COUNT=					15	    				--!!牌型总数量


2.牌: 花色，数值，逻辑数值
N_MAX_LOGICVALUE = 16
local s_CardData =
{
	0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,	--方块 A - K
	0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,	--梅花 A - K
	0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,	--红桃 A - K
	0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,	--黑桃 A - K
	0x4E,0x4F,
}
GetCardColor
GetCardValue
GetCardLogicValue: 3-K, A-2, 小王-大王; 值有小到大(3-13, 14-15, 16-17)
SortCardToLogicBigger(card, cardcount) :逻辑值一样大，就按花色比较，黑红梅方
SortCardToLogicSmaller(card, cardcount)


3.分析牌型
GetCardType(cardTable, sumHandCount)
按照牌数判断：
**0 CT_ERROR；
**AnalysebCardData(cardTable)
{
	self.singleCardTable = {}	-- 仅有一张X
	self.doubleCardTable = {}	-- 仅有两张X
	self.threeCardTable = {}	-- 仅有三张X
	self.fourCardTable = {}		-- 四张X
	self.doubleTable = {}		-- 有两张或三张X
	self.planeTable = {}		-- 至少有三张X
	self.sum123Table = {}		-- 有一张或两张或三张X
	self.sum12Table = {}		-- 有一张或两张或三张X
	self.doubleCardCnt = 0
	self.threeCardCnt = 0
	self.fourCardCnt = 0
	self.doubleCnt = 0
	self.planeCnt = 0
	self.sum123Cnt = 0
	self.sum12Cnt = 0
	SortCardToLogicBigger
	--
	local analyseTable={}
	-- 把所有逻辑值相同的牌存到一个表中，这个表的索引就是这个逻辑值
	for k = #cardTable, 1, -1 do
		local cardData = cardTable[k]
		local index = GetCardLogicValue(cardData)
		if analyseTable[index] == nil then
			analyseTable[index] = {}
		end
		table.insert(analyseTable[index], cardData)	
	end	
}
**
-- 三带二判断，飞机判断，拆炸弹，拆三
-- 牌数判断，三带数目判断； 然后判断三带和连牌数量是否足够 ;
local function funcThreeTakeTwoLine( ... )
	local t_data = self.planeTable
	local tThreeMoreCount = {}
	local nThreeMoreCount = 0
	local tMaxValue = {}
	local nMaxValue = 0
	--
	for i=1,N_MAX_LOGICVALUE do
	    local tempCount = t_data[i] or {}
		if #tempCount >= 3 then 
			nThreeMoreCount = nThreeMoreCount + 1
			nMaxValue = i
		end
		if nThreeMoreCount > 0 and #tempCount < 3 then
			table.insert(tThreeMoreCount, nThreeMoreCount)
			nThreeMoreCount = 0
			table.insert(tMaxValue, nMaxValue)
			nMaxValue = 0
		end
	end
	--
	local nFound = nil
	for k,v in pairs(tThreeMoreCount) do
	 	if v >= cbCardCount / 5 then 
	 		nFound = k
	 	end
	end
	if nFound then
		-- tThreeMoreCount[nFound], tMaxValue[nFound]
		if cbCardCount / 5 == 1 then
			return LandGlobalDefine.CT_THREE_TAKE_TT
		else
			return LandGlobalDefine.CT_FEIJI_TAKE_TWO
		end
	end
end
**四牌判断:
{
	local cardValue = {}
	for k, v in pairs(self.fourCardCnt) do
		table.insert(cardValue, k)
	end
	table.sort(cardValue, function(a,b) return a<b end)
	cardCount = #cardValue
	--
	炸弹，四带三：CT_BOMB_CARD，CT_FOUR_TAKE_THREE
	-- 三带二判断，飞机判断，拆炸弹，拆三
	-- 牌数判断，三带数目判断； 然后判断三带和连牌数量是否足够 ;
	if (cbCardCount % 5 == 0) and (cardCount + self.threeCardCnt) >= cbCardCount / 5 then
		local nDefineType = funcThreeTakeTwoLine()
		if nDefineType then return nDefineType end
	end
	return LandGlobalDefine.CT_ERROR
}
**三牌判断：
{
	local cardValue = {}
	for k, v in pairs(self.planeTable) do
		table.insert(cardValue, k)
	end
	table.sort(cardValue, function(a,b) return a<b end)
	cardCount = #cardValue
	--
	三张，三带一：CT_THREE, CT_THREE_TAKE_ONE
	-- 三带二判断，飞机判断，拆三, 拆炸弹，上面已经把炸弹情况去掉
	-- 牌数判断，三带数目判断； 然后判断三带和连牌数量是否足够 ;
	if (cbCardCount % 5 == 0) and (self.threeCardCnt) >= cbCardCount / 5 then
		local nDefineType = funcThreeTakeTwoLine()
		if nDefineType then return nDefineType end
	end
	return LandGlobalDefine.CT_ERROR
}
**二牌判断：
{
	local cardValue={}
	for k, v in pairs(self.doubleCardTable) do
		table.insert(cardValue,k)
	end
	table.sort(cardValue, function(a, b) return a < b end)
	--
	一对：CT_DOUBLE；
	-- 判断对联
	if (cardCount >= 2) then
		--变量定义
		local cbCardData = cardValue[1]
		local cbFirstLogicValue = (cbCardData)
		if (cbFirstLogicValue >= 15) then
			return LandGlobalDefine.CT_ERROR
		end
		--连牌判断
		for i = 2, cardCount do
			local cbCardData = cardValue[i]
			local cbNextLogicValue = (cbCardData)
			if (cbNextLogicValue >= 15) then
				return LandGlobalDefine.CT_ERROR
			end
			if (cbFirstLogicValue ~= (cbNextLogicValue - i + 1)) then
				return LandGlobalDefine.CT_ERROR
			end
		end
		--二连判断
		if ((cardCount*2) == cbCardCount) then
			print("二连")
			return LandGlobalDefine.CT_DOUBLE_LINE
		end
		return LandGlobalDefine.CT_ERROR
	end
}
**一张判断：
{
	local cardValue={}
	for k, v in pairs(self.singleCardTable) do
		table.insert(cardValue,k)
	end
	table.sort(cardValue, function(a, b) return a < b end)
	--
	一张：CT_SINGLE；
	-- 判断单连
	if ((cardCount >= 5) and (cardCount == cbCardCount)) then
		--变量定义
		local cbCardData = cardValue[1]
		local cbFirstLogicValue = (cbCardData)
		if (cbFirstLogicValue >= 15) then
			return LandGlobalDefine.CT_ERROR
		end
		--连牌判断
		for i = 2, cardCount do
			local cbCardData = cardValue[i]
			local cbNextLogicValue = (cbCardData)
			if (cbNextLogicValue >= 15) then
				return LandGlobalDefine.CT_ERROR
			end
			if (cbFirstLogicValue ~= (cbNextLogicValue - i + 1)) then
				return LandGlobalDefine.CT_ERROR
			end
		end
		print("顺子")
		return LandGlobalDefine.CT_SINGLE_LINE
	end
}


4.搜索提示
SearchOutCard(handCardTable,turnCardTable) --手牌，别人出的牌
** 上次选择的记录
{
	local returnTable={}
	local allCanOutCount = #self.allOutCardTable
	if allCanOutCount > 0 then
		if self.allOutIdx > allCanOutCount or self.allOutIdx < 1 then
			self.allOutIdx = 1
		end
		returnTable = self.allOutCardTable[self.allOutIdx]
		self.allOutIdx = self.allOutIdx + 1
		return returnTable or {}
	end
}
**
{
	if handCardTable==nil or #handCardTable==0 then
		return returnTable or {}
	end
	--构造扑克
	local cbCardCount = #handCardTable
	local cbCardData = handCardTable
	-- table.sort(cbCardData, SortCardTable)
	self:AnalysebCardData(cbCardData)
	--
	local value = 0
    local cbTurnOutType = LandGlobalDefine.CT_ERROR
	if turnCardTable~=nil and #turnCardTable>0 then
		table.sort(turnCardTable, SortCardTable)
		value = turnCardTable[1]
		--获取类型
		cbTurnOutType = self:GetCardType(turnCardTable);
	end
	--
}
** CT_ERROR
{
    -- 判断是否可以全都打出去
    if self:GetCardType(cbCardData, cbCardCount) ~= LandGlobalDefine.CT_ERROR then
    	return handCardTable or {}
    end
    -------------------------------------------------------------
    -- 最小牌值 个数
    local cbLogicValue=GetCardLogicValue(cbCardData[cbCardCount]);
	table.insert(returnTable, cbCardData[cbCardCount])
	for i = 1, cbCardCount-1 do
		local cbCurrentCard = cbCardData[cbCardCount-i]
		if (cbLogicValue==GetCardLogicValue( cbCurrentCard )) then
			table.insert(returnTable, cbCurrentCard)
		else 
			-- break
		end
	end
	-- 
	local function getCardsFromTable( parTable, nNeedCount, nMinCount )
		-- body
		local nMinValue = 0
		local nThreeMoreCount = 0
		local tReturnCards = {}
		for i=1,14 do
		    local tempCount = parTable[i] or {}
			if #tempCount > 0 then 
				if nMinValue == 0 then nMinValue = i end
				nThreeMoreCount = nThreeMoreCount + 1
				for j=1,nNeedCount do
					local v = tempCount[j]
					table.insert(tReturnCards, v)					
				end
			end
			if nThreeMoreCount > 0 and #tempCount <= 0 then
				break;
			end
		end
		if nThreeMoreCount >= nMinCount then
			return tReturnCards
		end
	end
	-- 
	if false then
	elseif #returnTable == 4 then
		return returnTable or {}
	elseif #returnTable == 1 then
		-- 判断连牌
		return getCardsFromTable(self.sum123Table, 1, 5) or returnTable
	elseif #returnTable == 2 then
		-- 判断连牌
		return getCardsFromTable(self.doubleCardTable, 2, 2) or returnTable
	elseif #returnTable == 3 then
			-- -- 判断连牌
			-- local tLineTable = analyseXXX(self.threeCardTable, 3) or {}
			-- local nLineCount = #tLineTable / 3

		-- 三带判断, 判断带牌
		local nTempMaxIndex = 15
		if self.singleCardCnt >= 2 then 
			local nTempCount = 0
			for kk=1,nTempMaxIndex do
				local tempdata = self.singleCardTable[kk]
				if tempdata then
					table.insert(returnTable, tempdata[1])
					nTempCount = nTempCount + 1
					if nTempCount >= 2 then
						break
					end
				end
			end
			return returnTable or {}
		elseif self.doubleCardCnt >= 1 then 
			for kk=1,nTempMaxIndex do
				local tempdata = self.doubleCardTable[kk]
				if tempdata then
					table.insert(returnTable, tempdata[1])
					table.insert(returnTable, tempdata[2])
					break
				end
			end
			return returnTable or {}
		elseif self.threeCardCnt >= 2 then
			local xxxx = {}
			local nIndex1 = nil
			local nIndex2 = nil
			for kk=1,nTempMaxIndex do
				local tempdata = self.threeCardTable[kk]
				if tempdata then
					if not nIndex1 then 
						nIndex1 = tempdata
						table.insert(xxxx, tempdata[1])
						table.insert(xxxx, tempdata[2])
					elseif not nIndex2 then
						nIndex2 = tempdata
						table.insert(xxxx, tempdata[1])
						table.insert(xxxx, tempdata[2])
						table.insert(xxxx, tempdata[3])
						break
					else
						break
					end
				end
			end
			return xxxx or {}
		else
			return returnTable or {}
		end
	end
	return returnTable or {}
}
** 返回连牌组是否找到；返回连牌组表函数（返回是否存在某牌）
{
	-- 暂时删除连，来判断出牌。 双连，单连
	local onDelLine = function ( parTable, nNeedCount, nMinCount )
			local delTable = {}
			--
			local tThreeMoreCount = {}
			local nThreeMoreCount = 0
			local tMaxValue = {}
			local nMaxValue = 0
			local tReturnCards = {}
			-- dump(parTable, "parTable")
			for i=1,14 do
			    local tempCount = parTable[i] or {}
				if #tempCount > 0 then 
					nThreeMoreCount = nThreeMoreCount + 1
					nMaxValue = i
					for j=1,nNeedCount do
						local v = tempCount[j]
						table.insert(tReturnCards, v)					
					end
				end
				-- print("nThreeMoreCount", i, nThreeMoreCount)
				if nThreeMoreCount > 0 and #tempCount <= 0 then
					if nThreeMoreCount >= nMinCount then
						table.insert(delTable, tReturnCards)
					end
					tReturnCards = {}
					table.insert(tThreeMoreCount, nThreeMoreCount)
					nThreeMoreCount = 0
					table.insert(tMaxValue, nMaxValue)
					nMaxValue = 0
				end
			end
			-- dump(delTable, "delTable")
			return #delTable > 0, function ( parNData )
				for k,v in pairs(delTable) do
					for kk,vv in pairs(v) do
						if vv == parNData then
							return true
						end
					end
				end
			end
	end
}
** 根据牌型，从手牌搜索可出牌
CT_SINGLE,CT_DOUBLE,
CT_THREE,CT_SINGLE_LINE,CT_DOUBLE_LINE,
elseif cbTurnOutType == LandGlobalDefine.CT_THREE_LINE
	or cbTurnOutType == LandGlobalDefine.CT_THREE_TAKE_ONE
	or cbTurnOutType == LandGlobalDefine.CT_THREE_TAKE_TWO
	or cbTurnOutType == LandGlobalDefine.CT_FEIJI_TAKE_ONE
	or cbTurnOutType == LandGlobalDefine.CT_FEIJI_TAKE_TWO then
{
}
**
{
	--搜索炸弹
	if cbCardCount >= 4 then
		self:AnalysebCardData(cardTable)
        for k, v in pairs(self.fourCardTable) do
            table.insert(resultTable, v)
        end
	end
	--判断搜索结果,找出包含数量最多的一手牌
	print("搜索结果:",#resultTable)
	local retCardTable = {}
	if ( #resultTable > 0 ) then
		local iTempOutCardIndex = 1 ;
		local iTempSearchOutCardCnt = #resultTable[1]
		for i=2, #resultTable do
			if ( #resultTable[i] > iTempSearchOutCardCnt ) then
				iTempSearchOutCardCnt = #resultTable[i]
				iTempOutCardIndex = i
			end
		end
		retCardTable = resultTable[iTempOutCardIndex]
	end
	-- if retCardTable~=nil then
	-- 	for k,v in pairs(retCardTable) do
	-- 		print("===",k,",",v,"================")
	-- 	end		
	-- end
	return retCardTable or {}
}


4.比较大小
CompareCard(enemyCard, curShootCard)
**
{
	--获取类型
	local cbNextType = self:GetCardType(nextCardTable)
	local cbFirstType = self:GetCardType(firstCardTable)

	--类型判断
	if (cbNextType == LandGlobalDefine.CT_ERROR) then
		return false
	end
	if (cbNextType == LandGlobalDefine.CT_MISSILE_CARD) then
		return true
	end

	--炸弹判断
	if ((cbFirstType ~= LandGlobalDefine.CT_BOMB_CARD) and (cbNextType == LandGlobalDefine.CT_BOMB_CARD)) then
		return true
	end
	if ((cbFirstType == LandGlobalDefine.CT_BOMB_CARD) and (cbNextType ~= LandGlobalDefine.CT_BOMB_CARD)) then
		return false
	end

	--规则判断
	if ((cbFirstType ~= cbNextType) 
		or (#firstCardTable ~= #nextCardTable)) then
		return false
	end

	--开始对比
	if cbNextType == LandGlobalDefine.CT_SINGLE 
		or cbNextType == LandGlobalDefine.CT_DOUBLE
		or cbNextType == LandGlobalDefine.CT_THREE
		or cbNextType == LandGlobalDefine.CT_SINGLE_LINE
		or cbNextType == LandGlobalDefine.CT_DOUBLE_LINE
		or cbNextType == LandGlobalDefine.CT_THREE_LINE
		or cbNextType == LandGlobalDefine.CT_BOMB_CARD then
			--获取数值
			local cbNextLogicValue = GetCardLogicValue(nextCardTable[1])
			local cbFirstLogicValue = GetCardLogicValue(firstCardTable[1])

			--对比扑克
			return cbNextLogicValue > cbFirstLogicValue

	elseif cbNextType == LandGlobalDefine.CT_THREE_TAKE_ONE 
		or cbNextType == LandGlobalDefine.CT_THREE_TAKE_TWO
		or cbNextType == LandGlobalDefine.CT_FEIJI_TAKE_ONE
		or cbNextType == LandGlobalDefine.CT_FEIJI_TAKE_TWO then
			--分析扑克
			self:AnalysebCardData(nextCardTable)
			local nextCardValue = {}
			for k, v in pairs(self.planeTable) do
				table.insert(nextCardValue, k)
			end
			table.sort(nextCardValue, function(a, b) return a < b end)

			self:AnalysebCardData(firstCardTable)
			local firstCardValue = {}
			for k, v in pairs(self.planeTable) do
				table.insert(firstCardValue, k)
			end
			table.sort(firstCardValue, function(a, b) return a < b end)

			--获取数值
			local cbNextLogicValue = (nextCardValue[1])
			local cbFirstLogicValue = (firstCardValue[1])

			--对比扑克
			return cbNextLogicValue > cbFirstLogicValue

	elseif cbNextType == LandGlobalDefine.CT_FOUR_LINE_TAKE_ONE 
		or cbNextType == LandGlobalDefine.CT_FOUR_LINE_TAKE_TWO
		or cbNextType == LandGlobalDefine.CT_FOUR_TAKE_THREE
		then
			--分析扑克
			self:AnalysebCardData(nextCardTable)
			local nextCardValue = {}
			for k, v in pairs(self.fourCardTable) do
				table.insert(nextCardValue, k)
			end
			table.sort(nextCardValue, function(a, b) return a < b end)

			self:AnalysebCardData(firstCardTable)
			local firstCardValue = {}
			for k, v in pairs(self.fourCardTable) do
				table.insert(firstCardValue, k)
			end
			table.sort(firstCardValue, function(a, b) return a < b end)

			--获取数值
			local cbNextLogicValue = (nextCardValue[1])
			local cbFirstLogicValue = (firstCardValue[1])

			--对比扑克
			return cbNextLogicValue > cbFirstLogicValue
	end

	return false
}








