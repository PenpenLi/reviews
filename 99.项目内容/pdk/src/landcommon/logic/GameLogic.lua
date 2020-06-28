------------------------------------------------------------------
--GameLogic.lua
-- Description:
------------------------------------------------------------------

--  这些定义都放在GlobalDefine里面，这里复制过来，方便查看程序

----	ST_ORDER =					0									--大小排序
--	ST_COUNT =					1									--数目排序
--	MAX_COUNT =					20									--最大数目
--	FULL_COUNT =				54									--全牌数目
--	BACK_COUNT =				3									--底牌数目
--	NORMAL_COUNT =				17									--常规数目
--
--	--扑克类型
--	CT_ERROR=					0		--错误类型
--	CT_SINGLE=					1		--单牌类型
--	CT_DOUBLE=					2		--对牌类型
--	CT_THREE=					3		--三条类型
--	CT_SINGLE_LINE	=			4		--单连类型
--	CT_DOUBLE_LINE=				5		--对连类型
--	CT_THREE_LINE=				6		--三连类型
--	CT_THREE_TAKE_ONE=		    7		--三带一单
--	CT_THREE_TAKE_TWO=		    8		--三带一对
--	CT_FOUR_LINE_TAKE_ONE=		9		--四带两单
--	CT_FOUR_LINE_TAKE_TWO=		10		--四带两对
--	CT_BOMB_CARD=				11		--炸弹类型
--	CT_MISSILE_CARD	=			12		--火箭类型
--	CT_FEIJI_TAKE_ONE=          13      --飞机类型
--	CT_FEIJI_TAKE_TWO=          14      --飞机类型
--	CT_LAIZI_BOMB =             15      -- 纯赖子炸弹
--	CT_RUAN_BOMB =              16     -- 软炸
--	CT_COUNT=					17	    --!!牌型总数量

	--底牌扑克类型
--	BCT_ERROR	=				0									--错误类型
--	BCT_SINGLE_KING	=			1									--单王
--	BCT_DOUBLE	=				2									--对子
--	BCT_SINGLE_LINE	=			3									--顺子
--	BCT_SAME_COLOR	=			4									--同花
--	BCT_SINGLE_LINE_SAME_COLOR=	5									--同花顺
--	BCT_THREE=					6									--三条 
--	BCT_DOUBLE_KING	=			7									--双王
--	BCT_COUNT	=				8								--牌底类型数量
local LandGlobalDefine = require("app.game.pdk.src.landcommon.data.LandGlobalDefine")
--扑克数据
local s_CardData =
{
	0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,	--方块 A - K
	0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,	--梅花 A - K
	0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,	--红桃 A - K
	0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,	--黑桃 A - K
	0x4E,0x4F,
}

--每种牌型的最少数量
local LOGIC_c_CardTypeCount = 
{ 1 , 2 , 3 , 5 , 6 , 6 , 8 , 10 , 6 , 8 , 4 , 2 , 4 , 5 }

-- 成员变量统一以下划线开始，紧接的首字母要小写

local GameLogic = class("GameLogic")

function GameLogic:ctor()
	self.doubleTable = {}
	self.planeTable = {}

	self.singleCardTable={}
	self.doubleCardTable={}
	self.threeCardTable={}
	self.fourCardTable={}
	--
	self.allOutCardTable = {}
	self.allOutIdx = 1
end

--获取数值，这里的数值是 1 - 15
function GetCardValue(cardData)
	if cardData == nil or cardData<0x01 then
		return 0
	end

	local cardValue = cardData % 16

	return cardValue
end

--获取花色, 0 - 4
function GetCardColor(cardData) 
	if cardData == nil or cardData<0x01 then
		return 0
	end

	local cardColor = math.floor(cardData / 16)

	return cardColor
end

--逻辑数值, 逻辑数值用来比较大小, 
function GetCardLogicValue(cardData)
	if cardData == nil or cardData < 0x01
		or cardData > 0x5F then
		return 0
	end
 
	--扑克属性
	local cbCardColor=GetCardColor(cardData)
	local cbCardValue=GetCardValue(cardData)

	--转换数值, 大小王为16, 17
	if (cbCardColor==4)
		or cardData==0x4E or cardData==0x4F then
		return cbCardValue+2
	end

	-- 1, 2 (A, 2) 的逻辑数值为 14, 15
	if (cbCardValue<=2 and cbCardValue>0) then
		cbCardValue = cbCardValue+13
	end
	
	return cbCardValue
end

--排序算法
function SortCardTable(a,b)
	--转换数值
	local cardValueA = GetCardLogicValue(a)
	local cardValueB = GetCardLogicValue(b)

	local  result = cardValueA - cardValueB
	if result == 0 then
		-- 逻辑值一样大，就按花色比较，黑红梅方
		result = a - b
	end	

	if result > 0 then
		return true
	end

	return false
end

--排序算法
function SortCardTableLittle(a, b)
	--转换数值
	local cardValueA = GetCardLogicValue(a)
	local cardValueB = GetCardLogicValue(b)

	local  result = cardValueA - cardValueB
	if result == 0 then
		-- 逻辑值一样大，就按花色比较，黑红梅方
		result = b - a
	end	

	if result < 0 then
		return true
	end
	return false
end

--混乱扑克
function GameLogic:RandCardTable()
	local retCardTable = {}
	math.randomseed(os.time())
	local cbCardData = {}
	for k, v in pairs(s_CardData) do
		cbCardData[k] = v
	end

	--混乱扑克
	local cbBufferCount = #s_CardData
	local cbRandCount = 1
	local cbPosition = 1
	while (cbRandCount <= cbBufferCount) do
		cbPosition = math.random(540)%(cbBufferCount - cbRandCount + 1) + 1
		retCardTable[cbRandCount] = cbCardData[cbPosition]
		cbCardData[cbPosition] = cbCardData[cbBufferCount - cbRandCount + 1]
		cbRandCount = cbRandCount + 1
	end

	-- for k, v in pairs(retCardTable) do
	-- 	print(k.."...."..v)
	-- end
	return retCardTable
end

-- 删除扑克
function GameLogic:RemoveCard(removeCardTable, cardTable)
	local deleteCount = 0
	local removeCount = #removeCardTable

	for k, v in pairs(removeCardTable) do
		for m, n in pairs(cardTable) do
			if v == n then
				deleteCount = deleteCount + 1
			end
		end
	end

	if deleteCount ~= removeCount then
		print("删除扑克数量不对?", deleteCount, removeCount)
		return cardTable or {}
	end

	--清理扑克
	for k, v in pairs(removeCardTable) do
		for m, n in pairs(cardTable) do
			if v == n then
				table.remove(cardTable, m)
				break
			end
		end
	end

	return cardTable or {}
end

--分析扑克
function GameLogic:AnalysebCardData(cardTable)
	if cardTable == nil then
		return
	end
	
	self.singleCardTable = {}	-- 仅有一张X
	self.doubleCardTable = {}	-- 仅有两张X
	self.threeCardTable = {}	-- 仅有三张X
	self.fourCardTable = {}		-- 四张X
	self.doubleTable = {}		-- 有两张或三张X
	self.planeTable = {}		-- 至少有三张X
	self.sum123Table = {}		-- 有一张或两张或三张X
	self.sum12Table = {}		-- 有一张或两张或三张X

	self.singleCardCnt = 0		
	self.doubleCardCnt = 0
	self.threeCardCnt = 0
	self.fourCardCnt = 0
	self.doubleCnt = 0
	self.planeCnt = 0
	self.sum123Cnt = 0
	self.sum12Cnt = 0


	table.sort(cardTable, SortCardTable)
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

	for k, v in pairs(analyseTable) do
--		print(k.."----"..#v)
		if #v > 3 then
			self.fourCardTable[k] = v
			self.planeTable[k] = v

			self.fourCardCnt = self.fourCardCnt + 1
			self.planeCnt = self.planeCnt + 1
		elseif #v > 2 then
			self.threeCardTable[k] = v
			self.doubleTable[k] = v
			self.planeTable[k] = v

			self.threeCardCnt = self.threeCardCnt + 1
			self.doubleCnt = self.doubleCnt + 1
			self.planeCnt = self.planeCnt + 1
		elseif #v > 1 then
			self.doubleCardTable[k] = v
			self.doubleTable[k] = v

			self.doubleCardCnt = self.doubleCardCnt + 1
			self.doubleCnt = self.doubleCnt + 1
		else
			self.singleCardTable[k] = v
			self.singleCardCnt = self.singleCardCnt + 1
		end
		-- 
		if #v <= 3 and #v >= 1 then
			self.sum123Table[k] = v
			self.sum123Cnt = self.sum123Cnt + 1
		end
		--
		if #v <= 2 and #v >= 1 then
			self.sum12Table[k] = v
			self.sum12Cnt = self.sum12Cnt + 1
		end
	end	


end

function GameLogic:isContainBomb(cardTable)
	self:AnalysebCardData(cardTable)
	return self.fourCardCnt > 0	
end

-- 判断表中是否同时包含大小王（天王炸弹）
function GameLogic:isContainMissileCard(cardTable)
	local bRedJoker = false
	local bBlackJoker = false
	for k, v in pairs(cardTable) do
		if v == 0x4E then
			bBlackJoker = true
		end
		if v == 0x4F then
			bRedJoker = true
		end
	end

	if bRedJoker and bBlackJoker then
		return true
	end

	return false
end

-- 牌的数量小于3时，属于简单的牌型
function GameLogic:GetSimpleCardType(cardTable)
	--简单牌型
	local cbCardCount = #cardTable
	if 0 == cbCardCount then
        return LandGlobalDefine.CT_ERROR
	elseif 1 == cbCardCount then --单牌
		print("单牌:"..GetCardLogicValue(cardTable[1]))
        return LandGlobalDefine.CT_SINGLE
	elseif 2 == cbCardCount then --对牌火箭
		--牌型判断
		if ((cardTable[1]==0x4F) and (cardTable[2]==0x4E)) then
			print("火箭:"..GetCardLogicValue(cardTable[1])..","..GetCardLogicValue(cardTable[2]))
            return LandGlobalDefine.CT_MISSILE_CARD
		end
		if (GetCardLogicValue(cardTable[1])==GetCardLogicValue(cardTable[2])) then
			print("对牌:"..GetCardLogicValue(cardTable[1])..","..GetCardLogicValue(cardTable[2]))
        return LandGlobalDefine.CT_DOUBLE
		end

    return LandGlobalDefine.CT_ERROR
	end
end
local funcSIJOIJO = nil
function GameLogic:setXXDelegate(xxdelegate)
	funcSIJOIJO = xxdelegate
end
--获取牌型
function GameLogic:GetCardTypeEX(cardTable, defaultType)
	if cardTable == nil then
        return LandGlobalDefine.CT_ERROR
	end

	table.sort(cardTable, SortCardTable)
	local cbCardCount = #cardTable

	--分析扑克
	self:AnalysebCardData(cardTable)
	
	--
	local function analyseXXX ( parTable, nNeedCount )
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
			return tReturnCards
	end

	--
	local tReturnCards1 = analyseXXX(self.sum123Table, 1)
	local tReturnCards2 = analyseXXX(self.doubleCardTable, 2)
	if #tReturnCards2 > 4 then
		return tReturnCards2
	end
	if #tReturnCards1 >= 5 then
		return tReturnCards1
	end
end

--获取牌型
function GameLogic:GetCardType(cardTable, sumHandCount)
	if cardTable == nil then
        return LandGlobalDefine.CT_ERROR
	end

	table.sort(cardTable, SortCardTable)
	local cbCardCount = #cardTable

	-- 要么是一对，要么是单牌, 要么是错误
	if cbCardCount < 3 then
		return self:GetSimpleCardType(cardTable)
	end

	--分析扑克
	self:AnalysebCardData(cardTable)
	
	-- 三带二判断，飞机判断，拆炸弹，拆三
	-- 牌数判断，三带数目判断； 然后判断三带和连牌数量是否足够 ;
	local function funcTemp( ... )
			local tThreeMoreCount = {}
			local nThreeMoreCount = 0
			local tMaxValue = {}
			local nMaxValue = 0
			for i=1,16 do
			    local tempCount = self.planeTable[i] or {}
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

	--四牌判断
	local cardCount = self.fourCardCnt
	if (cardCount > 0) then 
		--牌型判断
		if ((cardCount == 1) and (cbCardCount == 4)) then
			print("炸弹")
			return LandGlobalDefine.CT_BOMB_CARD
		end

		-- if ((cardCount == 1) and (cbCardCount == 6)) then
		-- 	if self.singleCardCnt == 2 or self.doubleCardCnt == 1 then
		-- 		print("四带两单")
		-- 		return LandGlobalDefine.CT_FOUR_LINE_TAKE_ONE
		-- 	end
		-- end
		-- if ((cardCount == 1) and (cbCardCount == 8)) then
		-- 	if self.doubleCardCnt == 2 then
		-- 		print("四带两对")
		-- 		return LandGlobalDefine.CT_FOUR_LINE_TAKE_TWO
		-- 	end
		-- end

		-- 四带三
		if ((cardCount == 1) and (cbCardCount == 7)) then
			if self.singleCardCnt + self.doubleCardCnt * 2 + self.threeCardCnt * 3 == 3 then
				print("四带三")
				return LandGlobalDefine.CT_FOUR_TAKE_THREE
			end
		end

		-- 三带二判断，飞机判断，拆炸弹，拆三
		-- 牌数判断，三带数目判断； 然后判断三带和连牌数量是否足够 ;
		if (cbCardCount % 5 == 0) and (cardCount + self.threeCardCnt) >= cbCardCount / 5 then
			local nDefineType = funcTemp()
			if nDefineType then return nDefineType end
		end

		-- 这里不要返回错误类型，还有一种飞机里面包含炸弹的情况，比如333444455567,
		-- 这种牌型应该是合理的, 所以要让接下来飞机的代码继续判断, by dzf
		return LandGlobalDefine.CT_ERROR
	end

	--三牌判断
	local cardValue = {}
	for k, v in pairs(self.planeTable) do
		table.insert(cardValue, k)
	end
	table.sort(cardValue, function(a,b) return a<b end)
	cardCount = #cardValue

	local sumHandCount = funcSIJOIJO()
	print("cardCount__xx__cardCount", cardCount, cbCardCount, sumHandCount)
	if (cardCount > 0) then
		-- --三条类型
		if (cardCount == 1 and cbCardCount == 3 and sumHandCount and sumHandCount == cbCardCount) then
			print("三张")
			return LandGlobalDefine.CT_THREE
		end
		--三带一
		if (cardCount == 1 and cbCardCount == 4 and sumHandCount and sumHandCount == cbCardCount) then
			print("三带一")
			return LandGlobalDefine.CT_THREE_TAKE_ONE
		end
		-- 三带二判断，飞机判断，拆三, 拆炸弹，上面已经把炸弹情况去掉
		-- 牌数判断，三带数目判断； 然后判断三带和连牌数量是否足够 ;
		if (cbCardCount % 5 == 0) and (self.threeCardCnt) >= cbCardCount / 5 then
			local nDefineType = funcTemp()
			if nDefineType then return nDefineType end
		end

		return LandGlobalDefine.CT_ERROR
	end

	--两张类型
	local cardValue={}
	for k, v in pairs(self.doubleCardTable) do
		table.insert(cardValue,k)
	end
	table.sort(cardValue, function(a, b) return a < b end)

	local cardCount = #cardValue
	if (cardCount >= 2) then
		--变量定义
		local cbCardData = cardValue[1]
		local cbFirstLogicValue = (cbCardData)

		--错误过虑
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

	--单张判断
	local cardValue = {}
	for k, v in pairs(self.singleCardTable) do
		table.insert(cardValue, k)
	end
	table.sort(cardValue,function(a,b) return a<b end)

	local cardCount = #cardValue

	if ((cardCount >= 5) and (cardCount == cbCardCount)) then
		--变量定义
		local cbCardData = cardValue[1]
		local cbFirstLogicValue = (cbCardData)

		--错误过虑
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

	return LandGlobalDefine.CT_ERROR
end


--对比扑克
function GameLogic:CompareCard(firstCardTable, nextCardTable)
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
end


---------------

function GameLogic:ClearOutCard()

	self.allOutCardTable = {}
	self.allOutIdx = 1
end

function GameLogic:SortCardList( cbCardData, cbCardCount, cbSortType )
	--数目过虑
	if cbCardCount == 0 then
		return
	end

    if cbCardCount > LandGlobalDefine.MAX_COUNT then
		return
	end

	--转换数值
	local cbSortValue = {}
	for i=1,cbCardCount do
		cbSortValue[i] = GetCardLogicValue(cbCardData[i]);
	end

	--排序操作
    local bSorted = true;
    local cbThreeCount = cbCardCount - 1
    local cbLast = cbCardCount - 1
    repeat
    	bSorted = true
    	for i=1,cbLast do
    		if ( (cbSortValue[i]<cbSortValue[i+1]) or
                 ((cbSortValue[i]==cbSortValue[i+1]) and
                 (cbCardData[i]<cbCardData[i+1]))   )
    		 then
    			--交换位置
                cbThreeCount = cbCardData[i];
                cbCardData[i] = cbCardData[i+1];
                cbCardData[i+1] = cbThreeCount;
                cbThreeCount = cbSortValue[i];
                cbSortValue[i] = cbSortValue[i+1];
                cbSortValue[i+1] = cbThreeCount;
                bSorted = false;
    		end
    	end
    	cbLast = cbLast - 1
    until(bSorted == false)

    --数目排序
    if cbSortType == LandGlobalDefine.ST_COUNT then
    	local bTemp = 0;
    	for i=1,cbCardCount-1 do
    		if i >= cbCardCount-i-1 then
    			break
    		end
    		bTemp = cbCardData[i];
            cbCardData[i] = cbCardData[cbCardCount-i-1];
            cbCardData[cbCardCount-i-1] = bTemp;
    	end
    end

    return
end


--智能选牌功能
function GameLogic:AndroidSelectCard(turnCardTable, handCardTable, selectCardTable)
	if true then
		return selectCardTable or {}
	end
	
	local resultTable = {}
	--分析出牌牌型
	table.sort(turnCardTable, SortCardTable)
	local cbOutCardType = self:GetCardType(turnCardTable)
	print("选中的牌")
    dump(turnCardTable)
    print("智能选牌 cbOutCardType = ", cbOutCardType)

    if (cbOutCardType == LandGlobalDefine.CT_ERROR) then
		if ( #selectCardTable > 5 ) then
			print("大于5张")
			resultTable = self:SearchMostOutCard(selectCardTable)
			return resultTable or {}
		end
	else
    	resultTable = self:SearchOutCard(selectCardTable, turnCardTable)
		self:ClearOutCard()
		if #resultTable > 0 then
			return resultTable or {}

		elseif #selectCardTable >= 5 then
			resultTable = self:SearchMostOutCard(selectCardTable)
			return resultTable or {}
		
		elseif (#selectCardTable < #turnCardTable) then
			--搜索剩余牌
			-- resultTable = self:SearchRemainOutCard( cbHandleCardData , cbHandleCardCount , cbTurnCardData , 
			-- 	cbTurnCardCount , cbSelectCardData , cbSelectCardCount , pOutCardResult ) ;
			return resultTable or {}
		end
	end
	print("智能选牌后")
    dump(resultTable)
	return resultTable or {}
end

--!!搜索尽量多牌的一手
function GameLogic:SearchMostOutCard(cardTable) 

	for i,v in ipairs(cardTable) do
		print("SearchMostOutCard",i,GetCardLogicValue(v))
	end
	--设置结果, 二维表
	local resultTable = {}

	local cbTurnCardCount= 0
	 
	--构造扑克
	local cbCardCount = #cardTable
	--排列扑克
	table.sort(cardTable, SortCardTable);
	local cbCardData = cardTable

	--获取类型
    local cbTurnOutType = LandGlobalDefine.CT_ERROR
	local cbHandleType = self:GetCardType(cardTable) ;
	--查看是否最后一手牌
    if cbHandleType ~= LandGlobalDefine.CT_ERROR then
		return cardTable or {}
	end
	--

	--出牌分析
    for iCardTypeIndex=1, LandGlobalDefine.CT_FEIJI_TAKE_TWO do

	   cbTurnOutType = iCardTypeIndex
	   -- print(cbTurnOutType,",",LOGIC_c_CardTypeCount[cbTurnOutType])
	   --长度判断
	   if LOGIC_c_CardTypeCount[cbTurnOutType]~=nil 
	   	and cbCardCount>=LOGIC_c_CardTypeCount[cbTurnOutType] then
		   	cbTurnCardCount = cbCardCount

            if cbTurnOutType==LandGlobalDefine.CT_SINGLE 
                or cbTurnOutType==LandGlobalDefine.CT_DOUBLE
                or cbTurnOutType==LandGlobalDefine.CT_THREE then

			   	--分析扑克
			   	self:AnalysebCardData(cardTable);

			   	--寻找单牌
			   	cbTurnCardCount = 1
			   	local tmpTable = {}
				for k, v in pairs(self.singleCardTable) do
					table.insert(tmpTable, k)
				end
				table.sort(tmpTable, function(a,b) return a<b end)
				for k,v in pairs(tmpTable) do
					local card = self.singleCardTable[v]
					if card then
						table.insert(resultTable, card)
						print("1:",card)
					end
				end

			   	--寻找对牌
			   	cbTurnCardCount = 2
			   	local tmpTable2 = {}
				for k, v in pairs(self.doubleCardTable) do
					table.insert(tmpTable2, k)
				end
				table.sort(tmpTable2, function(a,b) return a<b end)
				for k,v in pairs(tmpTable2) do
					local card = self.doubleCardTable[v]
					if card then
						table.insert(resultTable, card)
						print("2:",card)
					end
				end

			   	--寻找三牌
			   	cbTurnCardCount = 3
			   	local tmpTable3 = {}
				for k, v in pairs(self.threeCardTable) do
					table.insert(tmpTable3, k)
				end
				table.sort(tmpTable3, function(a,b) return a<b end)
				for k,v in pairs(tmpTable3) do
					local card = self.threeCardTable[v]
					if card then
						table.insert(resultTable, card)
						print("3:",card)
					end
				end
	   		end

	   		--
	   		if cbTurnOutType==LandGlobalDefine.CT_SINGLE_LINE then
	   			for i=#cardTable, 5, -1 do
	   				-- print("44-0:",i)
	   				local cards = {}
					--获取数值
					local logicValue=GetCardLogicValue(cardTable[i])
					--构造判断
					if (logicValue>=15) then
						break
					end
					--搜索连牌
					local lineCount=0
					for j=i, 1, -1 do
						local nextLogicValue = GetCardLogicValue(cardTable[j])
						if (nextLogicValue>=15) then
							break
						end
						if nextLogicValue==logicValue+lineCount then
							table.insert(cards, cardTable[j])
							lineCount = lineCount + 1
							-- print("44:",cardTable[j])
						-- else
						-- 	print("44-1:",nextLogicValue,logicValue,lineCount)
						-- 	break
						end
					end
					--完成判断
					if (#cards>=5) then
					   table.insert(resultTable, cards)
					end					
	   			end
	   		end

	   		--
	   		if cbTurnOutType==LandGlobalDefine.CT_DOUBLE_LINE then
			   	--分析扑克
			   	self:AnalysebCardData(cardTable)
			   	--
				local tmpTable={}
				for k, v in pairs(self.doubleTable) do
					table.insert(tmpTable,k)
				end
				table.sort(tmpTable,function(a,b) return a<b end)
				--
	   			for i=1, #tmpTable-2 do
	   				local cards = {}
					--获取数值
					local logicValue=tmpTable[i]
					--构造判断
					if (logicValue>=15) then
						break
					end
					--搜索连牌
					local lineCount=0
					for j=i, #tmpTable do
						local nextLogicValue = tmpTable[j]
						if (nextLogicValue>=15) then
							break
						end
						if nextLogicValue==logicValue+lineCount then
							if self.doubleTable[nextLogicValue] then
								local index=1
								for m, n in pairs(self.doubleTable[nextLogicValue]) do
									if index<=2 then
										table.insert(cards, n)
										index=index+1
									end				
								end
								lineCount = lineCount + 1
							end
						else
							break
						end
					end
					--完成判断
					if (#cards>=6) then
					   table.insert(resultTable, cards)
					end					
	   			end
	   		end

	   		--
	   		if cbTurnOutType==LandGlobalDefine.CT_THREE_LINE 
	   			or cbTurnOutType==LandGlobalDefine.CT_THREE_TAKE_ONE
	   			or cbTurnOutType==LandGlobalDefine.CT_THREE_TAKE_TWO
	   			or cbTurnOutType==LandGlobalDefine.CT_FEIJI_TAKE_ONE
	   			or cbTurnOutType==LandGlobalDefine.CT_FEIJI_TAKE_TWO then

					if cbTurnOutType==LandGlobalDefine.CT_FEIJI_TAKE_ONE then
					   cbTurnOutType = LandGlobalDefine.CT_THREE_TAKE_ONE

					elseif cbTurnOutType == LandGlobalDefine.CT_FEIJI_TAKE_TWO then
					   cbTurnOutType = LandGlobalDefine.CT_THREE_TAKE_TWO
					end
					--分析扑克
				   	self:AnalysebCardData(cardTable)
				   	--
					local tmpTable={}
					for k, v in pairs(self.planeTable) do
						table.insert(tmpTable,k)
					end
					table.sort(tmpTable,function(a,b) return a<b end)
					--
					--遍历牌型
					local maxIdx = math.floor(cbCardCount/LOGIC_c_CardTypeCount[iCardTypeIndex])
					print("55-0:",maxIdx)
					for idx=1, maxIdx+1 do
						cbTurnCardCount = LOGIC_c_CardTypeCount[iCardTypeIndex]*idx
						--属性数值
						local cbTurnLineCount=0
						if (cbTurnOutType==LandGlobalDefine.CT_THREE_TAKE_ONE) then
							cbTurnLineCount=math.floor(cbTurnCardCount/4)
						elseif (cbTurnOutType==LandGlobalDefine.CT_THREE_TAKE_TWO) then
							cbTurnLineCount=math.floor(cbTurnCardCount/5)
						else 
							cbTurnLineCount=math.floor(cbTurnCardCount/3)
						end

						if cbTurnLineCount == 0 then
							break
						end
						-- print("55-1:",cbTurnLineCount)
						--搜索连牌
						for i=1, #tmpTable-cbTurnLineCount+1 do
			   				local cards = {}
							--获取数值
							local logicValue=tmpTable[i]
							--构造判断
							if (cbTurnLineCount>1 and logicValue>=15) then
								break
							end
							--搜索连牌
							local lineCount=0
							for j=i, #tmpTable do
								local nextLogicValue = tmpTable[j]
								if (nextLogicValue>=15) then
									break
								end
								if nextLogicValue==logicValue+lineCount then
									if self.planeTable[nextLogicValue] then
										local index=1
										for m, n in pairs(self.planeTable[nextLogicValue]) do
											if index<=3 then
												table.insert(cards, n)
												index=index+1
												print("55-1:",m,",",GetCardLogicValue(n))
											end
										end
										lineCount = lineCount + 1
										--
										if #cards == cbTurnLineCount*3 then
											break
										end
									end
								else
									break
								end
							end
							--完成判断
							print("55-2:",#cards,"=",cbTurnLineCount*3)
							if #cards == cbTurnLineCount*3 then
								--
								local leftCardTable = {}
								for i,v in ipairs(cbCardData) do
									table.insert(leftCardTable, v)
								end

								leftCardTable = self:RemoveCard(cards, leftCardTable)
								print("55-3:",#leftCardTable,",",cbTurnOutType)
								--分析扑克
				   				--self:AnalysebCardData(leftCardTable)
								--单牌处理
                            if cbTurnOutType==LandGlobalDefine.CT_THREE_TAKE_ONE then
									print("55-4:")
									local oneCards = self:splitOneCards(leftCardTable)
									if #oneCards >= cbTurnLineCount then
										for j=1,cbTurnLineCount do
											table.insert(cards, oneCards[j])
										end
									end
                            elseif cbTurnOutType==LandGlobalDefine.CT_THREE_TAKE_TWO then
									print("55-5:")
									local twoCards = self:splitTwoCards(leftCardTable)
									for k,v in pairs(twoCards) do
										print(k,v)
									end
									if #twoCards >= cbTurnLineCount*2 then
										for j=1,cbTurnLineCount*2 do
											table.insert(cards, twoCards[j])
										end
									end
								end
								--完成判断
								if (#cards==cbTurnCardCount) then
									table.insert(resultTable, cards)
								end
							end
						end
					end
		   	end
	   end
	end
	
	--搜索炸弹
	if cbCardCount >= 4 then
		self:AnalysebCardData(cardTable)
		--搜索炸弹
        for k, v in pairs(self.fourCardTable) do
            table.insert(resultTable, v)
        end
	end

	--搜索火箭
	if ((cbCardCount>=2) and (cbCardData[1]==0x4F) and (cbCardData[2]==0x4E)) then
		--设置结果
		local cards = {}
		cards[1] = cbCardData[1];
		cards[2] = cbCardData[2];

		table.insert(resultTable, cards)
	end
    
    local retCardTable = {}
	--判断搜索结果,找出包含数量最多的一手牌
	print("搜索结果:",#resultTable)
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

	if retCardTable~=nil then
		for k,v in pairs(retCardTable) do
			print("===",k,",",v,"================")
		end		
	end

	return retCardTable or {}
end

function GameLogic:splitOneCards(cardTable, bOnly)
	--分析扑克
   	self:AnalysebCardData(cardTable);
	--
	local retCards = {}

   	--寻找单牌
   	local tmpTable = {}
	for k, v in pairs(self.singleCardTable) do
		table.insert(tmpTable, k)
	end
	-- table.sort(tmpTable, function(a,b) return a<b end)
	table.sort(tmpTable, SortCardTableLittle)
	for i=1,15 do
		local v = tmpTable[i]

	-- end
	-- for k,v in pairs(tmpTable) do
		-- 这里不需要做限制
		--[[--
		if (v >= 15) then
			break
		end
		]]

		local card = self.singleCardTable[v]
		if card then
			table.insert(retCards, card[1])
		end
	end
	if bOnly then return retCards or {} end

   	--寻找对牌
   	local tmpTable2 = {}
	for k, v in pairs(self.doubleCardTable) do
		table.insert(tmpTable2, k)
	end
	-- table.sort(tmpTable2, function(a,b) return a<b end)
	table.sort(tmpTable2, SortCardTable)
	for k,v in pairs(tmpTable2) do
		local card = self.doubleCardTable[v]
		if card then
			table.insert(retCards, card[1])
		end
	end

   	--寻找三牌
   	local tmpTable3 = {}
	for k, v in pairs(self.threeCardTable) do
		table.insert(tmpTable3, k)
	end
	-- table.sort(tmpTable3, function(a,b) return a<b end)
	table.sort(tmpTable3, SortCardTable)
	for k,v in pairs(tmpTable3) do
		local card = self.threeCardTable[v]
		if card then
			table.insert(retCards, card[1])
		end
	end

	return retCards or {}
end

function GameLogic:splitTwoCards(cardTable)
   	--分析扑克
   	self:AnalysebCardData(cardTable);
   	--
	local tmpTable={}
	for k, v in pairs(self.doubleTable) do
		table.insert(tmpTable,k)
	end
	table.sort(tmpTable,function(a,b) return a<b end)
	--
	local cards = {}
	for k,v in pairs(tmpTable) do
	-- for i=1, #tmpTable do
		--获取数值
		-- local logicValue=tmpTable[i]
		--构造判断
		-- if (v>=15) then
		-- 	break
		-- end
		--
		local index=1
		for m, n in pairs(self.doubleTable[v]) do
			if index<=2 then
				table.insert(cards, n)
				index=index+1
			end				
		end
	end

	return cards or {}
end


--出牌
function GameLogic:SearchOutCard(handCardTable,turnCardTable, isIgnore)
	--
	-- if isIgnore then
	-- 	self.allOutCardTable = {}
	-- 	self.allOutIdx = 1
	-- end

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

	if handCardTable==nil or #handCardTable<1 then
		return returnTable or {}
	end

	--构造扑克
	local cbCardData = handCardTable
	local cbCardCount = #handCardTable
	--排列扑克
	table.sort(cbCardData, SortCardTable)
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
	self:AnalysebCardData(cbCardData)
	--
	-- 三带二判断，飞机判断，拆炸弹，拆三
	-- 牌数判断，三带数目判断； 然后判断三带和连牌数量是否足够 ;
	local function funcTemp( ... )
			local tThreeMoreCount = {}
			local nThreeMoreCount = 0
			local tMaxValue = {}
			local nMaxValue = 0
			for i=1,15 do
			    local tempCount = self.planeTable[i] or {}
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
    if cbTurnOutType == LandGlobalDefine.CT_ERROR then
    	print("--无类型")
		-- 先判断三带，一手是否能打出
    	if cbCardCount == 4 or cbCardCount == 5 then
    		if self.threeCardCnt == 1 then
    			return handCardTable or {}
    		end
    	end
    	-- 判断是否可以全都打出去
    	if self:GetCardType(cbCardData, cbCardCount) ~= LandGlobalDefine.CT_ERROR then
    		return handCardTable or {}
    	end

    	-- 最小牌值
    	local cbLogicValue=GetCardLogicValue(cbCardData[cbCardCount]);
		table.insert(returnTable, cbCardData[cbCardCount])
		for i = 1, cbCardCount-1 do
			if (cbLogicValue==GetCardLogicValue(cbCardData[cbCardCount-i])) then
				table.insert(returnTable, cbCardData[cbCardCount-i])
			else 
				-- break
			end
		end
			
			dump(cbCardData, "cbCardData" .. cbCardCount)
		print("cbLogicValue", cbLogicValue)
			dump(self.singleCardTable, "self.singleCardTable")
			dump(self.doubleCardTable, "self.doubleCardTable")
			dump(self.threeCardTable, "self.threeCardTable")
			dump(returnTable, "returnTable")
			
		local function analyseXXX ( parTable, nNeedCount, nMinCount )
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
			return analyseXXX(self.sum123Table, 1, 5) or returnTable
		elseif #returnTable == 2 then
			-- 判断连牌
			return analyseXXX(self.doubleCardTable, 2, 2) or returnTable
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

	elseif cbTurnOutType == LandGlobalDefine.CT_SINGLE then
		print("--单牌")
		value = turnCardTable[1]
		-- 去掉连牌部分
		local bFind, funcFind = onDelLine( self.sum12Table, 1, 5 )
		local bFind2, funcFind2 = onDelLine( self.doubleCardTable, 2, 2)
		if bFind then
			local tmpTable = {}
			for i=1,#cbCardData do
				if not funcFind(cbCardData[i]) and not funcFind2(cbCardData[i]) then
					table.insert(tmpTable, cbCardData[i])
				end
			end
			-- dump(tmpTable, "tmpTable")
			self:AnalysebCardData(tmpTable)
			local bFound = self:getOneCards(value)
			self:AnalysebCardData(cbCardData)
			-- 正常
			if not bFound then
				self:getOneCards(value)
			end
		else
			self:getOneCards(value)
		end

	elseif cbTurnOutType == LandGlobalDefine.CT_DOUBLE then
		print("--对牌")
		value = turnCardTable[1]
		-- 判断，不要拆连牌，如果是四张单牌
		local bFind, funcFind =  onDelLine( self.doubleCardTable, 2, 2 )
		local bFind2, funcFind2 = onDelLine( self.sum12Table, 1, 5 )
		if bFind or bFind2 then
			local tmpTable = {}
			for i=1,#cbCardData do
				if not funcFind(cbCardData[i]) and not funcFind2(cbCardData[i]) then
					table.insert(tmpTable, cbCardData[i])
				end
			end
			-- dump(tmpTable, "tmpTable")
			self:AnalysebCardData(tmpTable)
			local bFound = self:getDoubleCards(value)
			self:AnalysebCardData(cbCardData)
			-- 找对
			if not bFound then
				self:getDoubleCards(value)
			end
		else
			self:getDoubleCards(value)
		end

	elseif cbTurnOutType == LandGlobalDefine.CT_THREE then
		print("--三张")
		value = turnCardTable[1]
		self:getThreeCards(value)

	elseif cbTurnOutType == LandGlobalDefine.CT_SINGLE_LINE then
		if #cbCardData >= #turnCardTable then
			print("--顺子")
			self:getSingleLineCards(cbCardData,turnCardTable)
		end

    elseif cbTurnOutType == LandGlobalDefine.CT_DOUBLE_LINE then
		if #cbCardData >= #turnCardTable then
			print("--连对")
			self:getDoubleLineCards(cbCardData,turnCardTable)
		end

	elseif cbTurnOutType == LandGlobalDefine.CT_THREE_LINE
		or cbTurnOutType == LandGlobalDefine.CT_THREE_TAKE_ONE
		or cbTurnOutType == LandGlobalDefine.CT_THREE_TAKE_TWO
		or cbTurnOutType == LandGlobalDefine.CT_FEIJI_TAKE_ONE
		or cbTurnOutType == LandGlobalDefine.CT_FEIJI_TAKE_TWO then

		local cbTurnCardCount = #turnCardTable
		if #cbCardData >= cbTurnCardCount then

			if cbTurnOutType==LandGlobalDefine.CT_FEIJI_TAKE_ONE then
			   cbTurnOutType = LandGlobalDefine.CT_THREE_TAKE_ONE

			elseif cbTurnOutType == LandGlobalDefine.CT_FEIJI_TAKE_TWO then
			   cbTurnOutType =LandGlobalDefine.CT_THREE_TAKE_TWO
			end
		   	--
			local tmpTable={}
			for k, v in pairs(self.planeTable) do
				table.insert(tmpTable,k)
			end
			table.sort(tmpTable,function(a,b) return a<b end)
			--
			local logicTurnValue=0;
			for i=1, #turnCardTable-2 do
				local cbLogicValue=GetCardLogicValue(turnCardTable[i])
				if (GetCardLogicValue(turnCardTable[i+1])==cbLogicValue)
					and (GetCardLogicValue(turnCardTable[i+2])==cbLogicValue) then
					logicTurnValue = GetCardLogicValue(turnCardTable[i])
					break
				end
			end
			--属性数值
			local cbTurnLineCount=0
			if (cbTurnOutType==LandGlobalDefine.CT_THREE_TAKE_ONE) then
				cbTurnLineCount=math.floor(cbTurnCardCount/4)
			elseif (cbTurnOutType==LandGlobalDefine.CT_THREE_TAKE_TWO) then
				cbTurnLineCount=math.floor(cbTurnCardCount/5)
			else 
				cbTurnLineCount=math.floor(cbTurnCardCount/3)
			end
			-- print("55-1:",cbTurnLineCount)
			--搜索连牌
			for i=1, #tmpTable-cbTurnLineCount+1 do
   				local cards = {}
				--获取数值
				local logicValue=tmpTable[i]
				--构造判断
				if (cbTurnLineCount>1 and logicValue>=15) then
					break
				end
				--搜索连牌
				if logicValue > logicTurnValue then
					local funcXXX = function ( tTypeTable )
						-- body
					local lineCount=0
					for j=i, #tmpTable do
						local nextLogicValue = tmpTable[j]
						if (cbTurnLineCount>1 and nextLogicValue>=15) then
							break
						end
						if nextLogicValue==logicValue+lineCount then
							if tTypeTable[nextLogicValue] then
								local index=1
								for m, n in pairs(tTypeTable[nextLogicValue]) do
									if index<=3 then
										table.insert(cards, n)
										index=index+1
										print("55-1:",m,",",GetCardLogicValue(n))
									end
								end
								lineCount = lineCount + 1
								--
								if #cards == cbTurnLineCount*3 then
									break
								end
							end
						else
							break
						end
					end
					if #cards == cbTurnLineCount*3 then
						return true
					end
					cards = {}
					end
					-- 仅三张，不拆四; 拆四
					local bXXX = funcXXX(self.threeCardTable)
					-- if not bXXX then
					-- 	bXXX = funcXXX(self.planeTable)
					-- end
					--完成判断
					print("55-2:",#cards,"=",cbTurnLineCount*3)
					if #cards == cbTurnLineCount*3 then
						--
						local leftCardTable = {}
						for i,v in ipairs(cbCardData) do
							table.insert(leftCardTable, v)
						end
						leftCardTable = self:RemoveCard(cards, leftCardTable)
						print("55-3:",#leftCardTable,",",cbTurnOutType)

						dump(leftCardTable, "leftCardTableleftCardTable")

						--分析扑克
		   				--self:AnalysebCardData(leftCardTable)
		   				-- 如果手牌为四张, 可以处理三带一
		   				if cbTurnOutType == LandGlobalDefine.CT_THREE_TAKE_TWO and 4 == cbCardCount then 
		   					cbTurnOutType = LandGlobalDefine.CT_THREE_TAKE_ONE
		   				end
						--单牌处理
						if cbTurnOutType==LandGlobalDefine.CT_THREE_TAKE_ONE then
							print("55-4:")
							local oneCards = self:splitOneCards(leftCardTable, true)
							if #oneCards >= cbTurnLineCount then
								for j=1,cbTurnLineCount do
									table.insert(cards, oneCards[j])
								end
							end
						elseif cbTurnOutType==LandGlobalDefine.CT_THREE_TAKE_TWO then
							print("55-5:")
							local oneCards = self:splitOneCards(leftCardTable, true)

							dump(oneCards, "oneCards")

							if #oneCards >= cbTurnLineCount*2 then
								for j=1,cbTurnLineCount*2 do
									table.insert(cards, oneCards[j])
								end
							else
								-- duizi
								local twoCards = self:splitTwoCards(leftCardTable)
								for k,v in pairs(twoCards) do
									print(k,v)
								end
								if #twoCards >= cbTurnLineCount*2 then
									for j=1,cbTurnLineCount*2 do
										table.insert(cards, twoCards[j])
									end
								end
							end
						end
						--完成判断
						if (#cards==cbTurnCardCount) then
							table.insert(self.allOutCardTable, cards)
						end
					end
				end
			end
		end

	end

	--搜索炸弹
	if cbCardCount >= 4 and cbTurnOutType ~= LandGlobalDefine.CT_MISSILE_CARD then
		self:AnalysebCardData(cbCardData)
		local cbLogicValue = 0
		if cbTurnOutType==LandGlobalDefine.CT_BOMB_CARD then
			cbLogicValue = GetCardLogicValue(turnCardTable[1])
		end
		--搜索炸弹
        for k, v in pairs(self.fourCardTable) do
        	if k > cbLogicValue then
	            table.insert(self.allOutCardTable, v)
        	end
        end
	end

	--搜索火箭
	if ((cbCardCount>=2) and (cbCardData[1]==0x4F) and (cbCardData[2]==0x4E)) then
		--设置结果
		local cards = {}
		cards[1] = cbCardData[1];
		cards[2] = cbCardData[2];

		table.insert(self.allOutCardTable, cards)
	end

	--判断是否已经存有搜索结果
	-- self.allOutIdx = 1
	allCanOutCount = #self.allOutCardTable
	if allCanOutCount > 0 then
		if self.allOutIdx > allCanOutCount or self.allOutIdx < 1 then
			self.allOutIdx = 1
		end

		returnTable = self.allOutCardTable[self.allOutIdx]
		self.allOutIdx = self.allOutIdx + 1
	end
	dump(self.allOutIdx, "self.allOutIdx")
	dump(self.allOutCardTable, "self.allOutCardTable")

	return returnTable or {}
end

--获取单张大牌
function GameLogic:getOneCards(cardValue, parBInsteadData)
	--
	local logicValue = GetCardLogicValue(cardValue)
	local nSumOutCard = table.maxn(self.allOutCardTable)

	--搜索单牌
	local tmpTable = {}
	for k, v in pairs(self.singleCardTable) do
		table.insert(tmpTable, k)
	end
	table.sort(tmpTable, function(a,b) return a<b end)
	for k,v in pairs(tmpTable) do
		if v > logicValue then
			local card = self.singleCardTable[v]	--返回table
			if card then
				local tmpCardTable = {}
				table.insert(tmpCardTable, card[1])
				table.insert(self.allOutCardTable, tmpCardTable)
			end
		end
	end

   	--寻找对牌
   	local tmpTable2 = {}
	for k, v in pairs(self.doubleCardTable) do
		table.insert(tmpTable2, k)
	end
	table.sort(tmpTable2, function(a,b) return a<b end)
	for k,v in pairs(tmpTable2) do
		if v > logicValue then
			local card = self.doubleCardTable[v]
			if card then
				local tmpCardTable = {}
				table.insert(tmpCardTable, card[1])
				table.insert(self.allOutCardTable, tmpCardTable)
			end
		end
	end

	local nSumOutCard2 = table.maxn(self.allOutCardTable)
	if parBInsteadData and nSumOutCard2 == parDoubleInstead then 
		return false
	end

   	--寻找三牌
   	local tmpTable3 = {}
	for k, v in pairs(self.threeCardTable) do
		table.insert(tmpTable3, k)
	end
	table.sort(tmpTable3, function(a,b) return a<b end)
	for k,v in pairs(tmpTable3) do
		if v > logicValue then
			local card = self.threeCardTable[v]
			if card then
				local tmpCardTable = {}
				table.insert(tmpCardTable, card[1])
				table.insert(self.allOutCardTable, tmpCardTable)
			end
		end
	end
end

function GameLogic:getDoubleCards(cardValue, parBInsteadData)
   	-- 要修改 先对,后拆三
	local logicValue = GetCardLogicValue(cardValue)
	local nSumOutCard = table.maxn(self.allOutCardTable)

   	--寻找对牌
   	local tmpTable2 = {}
	for k, v in pairs(self.doubleCardTable) do
		table.insert(tmpTable2, k)
	end
	table.sort(tmpTable2, function(a,b) return a<b end)
	for k,v in pairs(tmpTable2) do
		if v > logicValue then
			local card = self.doubleCardTable[v]
			if card then
				table.insert(self.allOutCardTable, card)
			end
		end
	end

	local nSumOutCard2 = table.maxn(self.allOutCardTable)
	if parBInsteadData and nSumOutCard2 == parDoubleInstead then 
		return false
	end

	-- 三张
	local tmpTable={}
	for k, v in pairs(self.threeCardTable) do
		table.insert(tmpTable,k)
	end
	table.sort(tmpTable,function(a,b) return a<b end)
	--
	for k,v in pairs(tmpTable) do
		--判断
		if (v > logicValue) then
			local cards = {}
			local index=1
			for m, n in pairs(self.threeCardTable[v]) do
				if index<=2 then
					table.insert(cards, n)
					index=index+1
				end				
			end

			if #cards == 2 then
				table.insert(self.allOutCardTable, cards)		
			end
		end
	end	
end

function GameLogic:getThreeCards(cardValue)

	local logicValue = GetCardLogicValue(cardValue)

   	--寻找三牌
   	local tmpTable3 = {}
	for k, v in pairs(self.threeCardTable) do
		table.insert(tmpTable3, k)
	end
	table.sort(tmpTable3, function(a,b) return a<b end)
	for k,v in pairs(tmpTable3) do
		if v > logicValue then
			local card = self.threeCardTable[v]
			if card then
				table.insert(self.allOutCardTable, card)
			end
		end
	end
end

function GameLogic:getSingleLineCards(cardTable,turnCardTable)

	local tmpTable={}
	for i=15,1,-1 do
		local v = self.sum123Table[i]
		if v then
			table.insert(tmpTable,v[1])
		end
	end
	cardTable = tmpTable

	local turnCardCount = #turnCardTable
	local logicTurnValue = GetCardLogicValue(turnCardTable[turnCardCount])

	local lastFirstCard = nil
	for i=#cardTable, turnCardCount-1, -1 do
		--获取数值
		local logicValue=GetCardLogicValue(cardTable[i])
		--构造判断
		if (logicValue>=15) then
			break
		end

		if not lastFirstCard or lastFirstCard ~= logicValue then
			lastFirstCard = logicValue
			--搜索连牌
			if logicValue > logicTurnValue then
				local cards = {}
				local lineCount=0
				for j=i, 1, -1 do
					local nextLogicValue = GetCardLogicValue(cardTable[j])
					if (nextLogicValue>=15) then
						break
					end
					if nextLogicValue==logicValue+lineCount then
						table.insert(cards, cardTable[j])
						lineCount = lineCount + 1
					end

					--完成判断
					if (#cards == turnCardCount) then
					   table.insert(self.allOutCardTable, cards)
					   break
					end					
				end
			end
		end
	end
end

function GameLogic:getDoubleLineCards(cardTable,turnCardTable)
	dump(self.allOutCardTable, "getDoubleLineCards_44444allOutCardTable")
	dump(cardTable, "getDoubleLineCards_cardTable")
	dump(turnCardTable, "getDoubleLineCards_turnCardTable")
	dump(self.doubleTable, "getDoubleLineCards_doubleTablee")

	local tmpTable={}
	for k, v in pairs(self.doubleTable) do
		table.insert(tmpTable,k)
	end
	table.sort(tmpTable,function(a,b) return a<b end)
	dump(tmpTable, "getDoubleLineCards_tmpTable")

	--
	local turnCardCount = #turnCardTable
	local logicTurnValue = GetCardLogicValue(turnCardTable[turnCardCount])

	for i=1, #tmpTable do
		local cards = {}
		--获取数值
		local logicValue=tmpTable[i]
		--构造判断
		if (logicValue>=15) then
			break
		end
		--搜索连牌
		print("getDoubleLineCards_111", logicValue, logicTurnValue)
		if logicValue > logicTurnValue then
			local lineCount=0
			for j=i, #tmpTable do
				local nextLogicValue = tmpTable[j]
				if (nextLogicValue>=15) then
					break
				end
				print("getDoubleLineCards_222", logicValue, nextLogicValue, lineCount, self.doubleTable[nextLogicValue])
				if nextLogicValue==logicValue+lineCount then
					if self.doubleTable[nextLogicValue] then
						local index=1
						for m, n in pairs(self.doubleTable[nextLogicValue]) do
							if index<=2 then
								table.insert(cards, n)
								index=index+1
							end				
						end
						lineCount = lineCount + 1
					end
				else
					break
				end
				print(#cards, turnCardCount, "getDoubleLineCards_#cards")
                --完成判断
			    if (#cards == turnCardCount) then
			       table.insert(self.allOutCardTable, cards)
			       break
			    end	
			end
							
		end				
	end
	dump(self.allOutCardTable, "getDoubleLineCards_55555allOutCardTable")
end

----

--!!获取底牌类型
function GameLogic:GetBackCardType(backCardTable) 
	print("GetBackCardType")
	--排序
	table.sort(backCardTable, SortCardTable)

	--分析扑克
	self:AnalysebCardData(backCardTable)

	--单王判断
	local KingCnt = 0
	for i=1, 3 do
		if backCardTable[i]==0x4E or backCardTable[i]==0x4F then
			KingCnt = KingCnt + 1
		end
	end

	if  KingCnt > 0 then 
		print("king")
		--查看单王的时候是否有对子
	-- 	if KingCnt == 1 then
	-- 		return LandGlobalDefine.BCT_SINGLE_KING
	-- 	end
	-- 	return LandGlobalDefine.BCT_DOUBLE_KING
		--新版本欢乐跑得快没有单王的判定,双王 要么对子
  		if KingCnt == 2 then
   		 	return LandGlobalDefine.BCT_DOUBLE_KING
		end
	end

	--三张判断
	local threeType = false
	for k, v in pairs(self.threeCardTable) do
		print(k,v)
		threeType = true
	end
	if threeType then
		--三条类型
		print("three")
        return LandGlobalDefine.BCT_THREE
	end

	--一对判断
	local twoType = false
	for k, v in pairs(self.doubleCardTable) do
		print(k,v)
		twoType = true
	end
	if twoType then
		print("double")
		return LandGlobalDefine.BCT_DOUBLE
	else
		print("single")
	--单张判断
		--变量定义
		local cardValue={}
		for k, v in pairs(self.singleCardTable) do
			for i,j in ipairs(v) do
				table.insert(cardValue,j)
			end
		end
		table.sort(cardValue, SortCardTable)
		
		if #cardValue == 3 then
			local cbCardData_1=cardValue[1];
			local cbFirstLogicValue=GetCardLogicValue(cbCardData_1);
			--花色值
			local cbColorValue = 1
			local cbSameValue = 1
			--错误过虑
			if (cbFirstLogicValue>15) then
                return LandGlobalDefine.BCT_ERROR
			end

			--花色判断 
			local cbFirstColor = GetCardColor( cbCardData_1 ) ;
			for i = 2, 3 do
				local cbCardValue = cardValue[i]
				if cbFirstColor == GetCardColor(cbCardValue) then
					cbColorValue = cbColorValue + 1
				end
			end

			--连牌判断
			for i=1, 2 do
				local cbCardValue = cardValue[i+1]
				if (cbFirstLogicValue==(GetCardLogicValue(cbCardValue)+i)) then
					cbSameValue = cbSameValue + 1
				end
			end

			if ( cbColorValue >= 3 and cbSameValue >= 3 ) then
                return LandGlobalDefine.BCT_SINGLE_LINE_SAME_COLOR --同花顺
			end

			if ( cbColorValue >= 3 ) then
                return LandGlobalDefine.BCT_SAME_COLOR --同花
			end

			if ( cbSameValue >= 3 ) then
                return LandGlobalDefine.BCT_SINGLE_LINE --顺子
			end			
		end
	end

	return LandGlobalDefine.BCT_ERROR
end

-- 获取三带一飞机头 飞机尾
function GameLogic:getPlanHeadAndTail(tbl) 
	if #tbl ~= 4 then
		return 
	end
	local head = {}
	for k,v in pairs(tbl) do
		local index = GetCardLogicValue(v)
		if head[index] == nil then
			head[index] = {}
		end
		table.insert(head[index], v)	
	end
	local _head = nil
	local _tail = nil
	for k,v in pairs(head) do
		if #v == 3 then
			_head = v
		else
			_tail = v
		end
	end
	return _head, _tail
end

return GameLogic