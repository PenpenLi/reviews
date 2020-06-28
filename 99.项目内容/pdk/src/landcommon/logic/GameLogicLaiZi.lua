------------------------------------------------------------------
--GameLogicLaiZi.lua
-- Version    : 1.0.0.0
-- Description:
------------------------------------------------------------------

--  这些定义都放在GlobalDefine里面，这里复制过来，方便查看程序

----    ST_ORDER =                  0                                   --大小排序
--  ST_COUNT =                  1                                   --数目排序
--  MAX_COUNT =                 20                                  --最大数目
--  FULL_COUNT =                54                                  --全牌数目
--  BACK_COUNT =                3                                   --底牌数目
--  NORMAL_COUNT =              17                                  --常规数目
--
--  --扑克类型
--  CT_ERROR=                   0       --错误类型
--  CT_SINGLE=                  1       --单牌类型
--  CT_DOUBLE=                  2       --对牌类型
--  CT_THREE=                   3       --三条类型
--  CT_SINGLE_LINE  =           4       --单连类型
--  CT_DOUBLE_LINE=             5       --对连类型
--  CT_THREE_LINE=              6       --三连类型
--  CT_THREE_TAKE_ONE=          7       --三带一单
--  CT_THREE_TAKE_TWO=          8       --三带一对
--  CT_FOUR_LINE_TAKE_ONE=      9       --四带两单
--  CT_FOUR_LINE_TAKE_TWO=      10      --四带两对
--  CT_BOMB_CARD=               11      --炸弹类型
--  CT_MISSILE_CARD =           12      --火箭类型
--  CT_FEIJI_TAKE_ONE=          13      --飞机类型
--  CT_FEIJI_TAKE_TWO=          14      --飞机类型
--  CT_LAIZI_BOMB =             15      -- 纯赖子炸弹
--  CT_RUAN_BOMB =              16     -- 软炸
--  CT_COUNT=                   17      --!!牌型总数量

    --底牌扑克类型
--  BCT_ERROR   =               0                                   --错误类型
--  BCT_SINGLE_KING =           1                                   --单王
--  BCT_DOUBLE  =               2                                   --对子
--  BCT_SINGLE_LINE =           3                                   --顺子
--  BCT_SAME_COLOR  =           4                                   --同花
--  BCT_SINGLE_LINE_SAME_COLOR= 5                                   --同花顺
--  BCT_THREE=                  6                                   --三条 
--  BCT_DOUBLE_KING =           7                                   --双王
--  BCT_COUNT   =               8                               --牌底类型数量
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

local s_LaiZiCardData =
{
	0x51,0x52,0x53,0x54,0x55,0x56,0x57,0x58,0x59,0x5A,0x5B,0x5C,0x5D,	--方块 A - K
}

--每种牌型的最少数量
local LOGIC_c_CardTypeCount = 
{ 1 , 2 , 3 , 5 , 6 , 6 , 8 , 10 , 6 , 8 , 4 , 2 , 4 , 5 }

-- 成员变量统一以下划线开始，紧接的首字母要小写

local GameLogicLaiZi = class("GameLogicLaiZi")

GameLogicLaiZi.laiziCardId = 0

function GameLogicLaiZi:ctor()
	self.doubleTable = {}
	self.planeTable = {}

	self.singleCardTableCount = 0
    self.doubleCardTableCount  = 0
    self.threeCardTableCount  = 0
    self.fourCardTableCount  = 0
    self.singleCardTable = { }
    self.doubleCardTable = { }
    self.threeCardTable = { }
    self.fourCardTable = { }

   
    self.doubleIncludeLaiZiCardTableCount  = 0
    self.threeIncludeLaiZiCardTableCount  = 0
    self.fourIncludeLaiZiCardTableCount  = 0
  
    self.doubleIncludeLaiZiCardTable = { }
    self.threeIncludeLaiZiCardTable = { }
    self.fourIncludeLaiZiCardTable = { }
     self.cbLaiZiCardDataTable = {}

    self.bigKing = false
    self.smallKing = false
    --
    self.newLaiZiCardTable = { } -- 赖子要变成的牌
    self.newCardTable = { } -- 赖子变后的牌
	--
	self.allOutCardTable = {}
	self.allOutIdx = 1
    self.laiZiCount = 0
end

-- --获取数值
-- function GetCardValue(cardData)
-- 	if cardData == nil or cardData<0x01 then
-- 		return 0
-- 	end

-- 	local cardValue = cardData % 16

-- 	return cardValue
-- end
---- --获取花色
-- function GetCardColor(cardData) 
-- 	if cardData == nil or cardData<0x01 then
-- 		return 0
-- 	end

-- 	local cardColor = math.floor(cardData / 16)

-- 	return cardColor
-- end
-- --逻辑数值
-- function GetCardLogicValue(cardData)
-- 	if cardData == nil or cardData < 0x01
-- 		or cardData > 0x4F then
-- 		return 0
-- 	end

-- 	--扑克属性
-- 	local cbCardColor=GetCardColor(cardData);
-- 	local cbCardValue=GetCardValue(cardData);

-- 	--转换数值
-- 	if (cbCardColor==4)
-- 		or cardData==0x4E or cardData==0x4F then
-- 		return cbCardValue+2;
-- 	end

-- 	if (cbCardValue<=2 and cbCardValue>0) then
-- 		cbCardValue = cbCardValue+13
-- 	end
	
-- 	return cbCardValue;
-- end

function GetCardFormLogicValue(cardLogic)
    local cbCardLogicValue = GetCardLogicValue(cardLogic)
    if  cbCardLogicValue>15 then
        return 0
    end
    local cbCardValue = cbCardLogicValue
    -- 转换数值
   
    if cbCardValue > 13  then
        cbCardValue = cbCardValue - 13
    end

    return s_LaiZiCardData[cbCardValue]
end

-- --排序算法
-- function SortCardTable(a,b)

-- 	-- 转换数值
--     local cardValueA = GetCardLogicValue(a)

--     -- 转换数值
--     local cardValueB = GetCardLogicValue(b)
--     if m_bShowLaiZiCard then
--         local laiZiValue = GetCardLogicValue(GameLogicLaiZi.laiziCardId)
--         if cardValueA == laiZiValue then
--             cardValueA = cardValueA + 18
--         end

--         if cardValueB == laiZiValue then
--             cardValueB = cardValueA + 18
--         end
--         -- self.GameLogicLaiZi.laiziCardId = 0
--     end

--     local result = cardValueA - cardValueB
--     if result == 0 then
--         result = a - b
--     end
--     if result > 0 then
--         return true
--     end
--     return false


--     --    -- 转换数值
--     --    local cardValueA = GetCardLogicValue(a)

--     --    -- 转换数值
--     --    local cardValueB = GetCardLogicValue(b)

--     --    local result = cardValueA - cardValueB
--     --    if result == 0 then
--     --        result = a - b
--     --    end
--     --    if result > 0 then
--     --        return true
--     --    end
--     --    return false
-- end;


--混乱扑克
function GameLogicLaiZi:RandCardTable()

	local retCardTable = {}

	math.randomseed(os.time())
	local cbCardData = s_CardData
	--混乱扑克
	local cbBufferCount = #s_CardData
	-- for k, v in pairs(s_CardData) do
	-- 	print(k.."...."..v)
	-- end
--	print("start.....")
	local cbRandCount=1
	local cbPosition=1
	while (cbRandCount<=cbBufferCount) do
		cbPosition=math.random(540)%(cbBufferCount-cbRandCount+1) + 1;
--		print("rand:"..cbPosition.."...."..cbBufferCount-cbRandCount+1)
		retCardTable[cbRandCount]=cbCardData[cbPosition];
--		print(cbRandCount.."---"..cbPosition)
--		cbPosition = cbPosition + 1
		cbCardData[cbPosition]=cbCardData[cbBufferCount-cbRandCount+1];
		cbRandCount = cbRandCount + 1
	end

	-- for k, v in pairs(retCardTable) do
	-- 	print(k.."...."..v)
	-- end
	return retCardTable
end
-- 排序算法，赖子排序，把赖子牌放到最左边,
function LaiZiSortCardTable(a, b)
    local tempa = clone(a)
    local tempb = clone(b)
    -- 转换数值
    local cardValueA = GetCardLogicValue(tempa)

    -- 转换数值
    local cardValueB = GetCardLogicValue(tempb)
    if GameLogicLaiZi.laiziCardId > 0 then
        local laiZiValue = GetCardLogicValue(GameLogicLaiZi.laiziCardId)
        if cardValueA == laiZiValue or a>80  then
            cardValueA = cardValueA + 18
        end

        if cardValueB == laiZiValue or b>80 then
            cardValueB = cardValueB + 18
        end
        -- self.GameLogicLaiZi.laiziCardId = 0
    end

    local result = cardValueA - cardValueB
    if result == 0 then
        result = tempa - tempb
    end
    if result > 0 then
        return true
    end
    return false
end

--赖子排序，把赖子牌放到最右边, 逻辑值大的牌放左边
function LaiZiSortCardTableRight(a, b)

    -- 转换数值
    local cardValueA = GetCardLogicValue(a)

    -- 转换数值
    local cardValueB = GetCardLogicValue(b)
    if GameLogicLaiZi.laiziCardId > 0 then
        local laiZiValue = GetCardLogicValue(GameLogicLaiZi.laiziCardId)
        if cardValueA == laiZiValue or a>80 then
            cardValueA = 0
        end

        if cardValueB == laiZiValue or b>80 then
            cardValueB = 0
        end
        -- self.GameLogicLaiZi.laiziCardId = 0
    end

    local result = cardValueA - cardValueB
    if result == 0 then
        result = a - b
    end
    if result > 0 then
        return true
    end
    return false
end;

--赖子排序，把赖子牌放到最右边,
function LaiZiSortCardTableRightB(a, b)

    -- 转换数值
    local cardValueA = GetCardLogicValue(a)

    -- 转换数值
    local cardValueB = GetCardLogicValue(b)
    if GameLogicLaiZi.laiziCardId > 0 then
        --local laiZiValue = GetCardLogicValue(laiziCardId)
        if  a>80 then
            cardValueA = 0
        end

        if  b>80 then
            cardValueB = 0
        end
        -- self.GameLogicLaiZi.laiziCardId = 0
    end

    local result = cardValueA - cardValueB
    if result == 0 then
        result = a - b
    end
    if result > 0 then
        return true
    end
    return false
end


-- 产生赖子牌
function GameLogicLaiZi:RandLaiZiCard()
    local cbPosition = math.random(1, 13)
    GameLogicLaiZi.laiziCardId = s_laiziCardData[cbPosition]
    return GameLogicLaiZi.laiziCardId
end

function GameLogicLaiZi:SetLaiZiCard(cbLaiZiCard)
    GameLogicLaiZi.laiziCardId = cbLaiZiCard
end

function GameLogicLaiZi:GetLaiZiCardId()
    return GameLogicLaiZi.laiziCardId 
end

-- 获取赖子数目
function GameLogicLaiZi:GetLaiZiCount(cardTable)
    self.laiZiCount= 0
    local laiZiValue = GetCardLogicValue(GameLogicLaiZi.laiziCardId)
    for k, v in pairs(cardTable) do
        local cardValue = GetCardLogicValue(v)
        if cardValue == laiZiValue or v > 0x50 then
            self.laiZiCount = self.laiZiCount + 1
        --elseif self.laiZiCount>0 then
            -- break
        end
    end
    print("self.laiZiCount = " .. self.laiZiCount)
    return self.laiZiCount
end
-- 获取赖子数据
function GameLogicLaiZi:GetLaiZiData(cardTable)
   self.cbLaiZiCardDataTable = {}
    local laiZiCount = 0
    local laiZiValue = GetCardLogicValue(GameLogicLaiZi.laiziCardId)
    for k, v in pairs(cardTable) do
        
        if GetCardLogicValue(v) == laiZiValue or v > 0x50 then
            laiZiCount = laiZiCount + 1
            table.insert(self.cbLaiZiCardDataTable,v)
        --elseif laiZiCount>0 then
            -- break
        end
    end
    print("laiZiCount = " .. laiZiCount)
    return laiZiCount
end


function GameLogicLaiZi:GetCurrentLaiZiCount()
    print("laiziNum = " .. self.laiZiCount)
    return self.laiZiCount
end

--删除扑克
--删除扑克
function GameLogicLaiZi:RemoveCard(removeCardTable,cardTable, Count)
	--定义变量
	--table.num()
	local deleteCount = 0
    local removeCount = #removeCardTable
    if Count ~= nil then
        removeCount = Count
    end

	local  laiZiLogicValue = GetCardLogicValue(GameLogicLaiZi.laiziCardId);
	-- local cardCount = #cardTable
	--置零扑克
	-- local rmTable = {}
	for k, v in pairs(removeCardTable) do
		for m, n in pairs(cardTable) do

        local  removeCardLogic = GetCardLogicValue(n)
			if v == n or (GetCardColor(v)==5 and removeCardLogic== laiZiLogicValue )then -- or (laiZiLogicValue == GetCardLogicValue(v) and removeCardLogic== laiZiLogicValue ) 
				-- table.insert(rmTable, m)
				deleteCount = deleteCount + 1
                break
			end
		end
        if Count and k == Count then
            break
        end 
	end

	if deleteCount ~= removeCount then
		print("删除扑克数量不对?", deleteCount, removeCount)
		return cardTable or {}
	end
    -- table.sort(removeCardTable ,LaiZiSortCardTableRightB) -- 赖子放在最右边,为了先删没变过的赖子，最后删变过的赖子牌
	--清理扑克
	for k, v in pairs(removeCardTable) do
		for m, n in pairs(cardTable) do
            local  removeCardLogic = GetCardLogicValue(n)
			if v == n or (GetCardColor(v)==5 and removeCardLogic== GetCardLogicValue(GameLogicLaiZi.laiziCardId))  then --or (laiZiLogicValue == GetCardLogicValue(v) and removeCardLogic== laiZiLogicValue )
               
				table.remove(cardTable, m)
                break
			end
		end
        if Count and k == Count then
            break
        end 
	end
	-- for k,v in pairs(rmTable) do
	-- 	print(k,v)
	-- 	table.remove(cardTable, v)
	-- end
	return cardTable or {}
end


function GameLogicLaiZi:AnalysebCardDataIncludeLaiZi(cbLaiZiDataTable,laiZiCount)
	--设置结果
    self.doubleIncludeLaiZiCardTable = {}
    self.threeIncludeLaiZiCardTable = {}
    self.fourIncludeLaiZiCardTable = {}
    if (laiZiCount< 1) then
		return false
	end
	----------------二张-----------------------------------
	self.doubleIncludeCardTableCount = self.singleCardTableCount;

     local temTable = {}
    for k, v in pairs(self.singleCardTable) do
       if k<16 then
          temTable = clone(v)
        table.insert(temTable, cbLaiZiDataTable[1])
        
        self.doubleIncludeLaiZiCardTable[k] = {}
       -- table.insert(self.doubleIncludeLaiZiCardTable[k],temTable)
        self.doubleIncludeLaiZiCardTable[k]=temTable
       end
       
    end
     dump(self.doubleIncludeLaiZiCardTable,"self.doubleIncludeLaiZiCardTable")
	
	-----------------三张-----------------------------


   
self.threeIncludeLaiZiCardTableCount = self.doubleCardTableCount;
for k, v in pairs(self.doubleCardTable) do
    if k < 16 then


        temTable = { }
        temTable = clone(v)
        table.insert(temTable, cbLaiZiDataTable[1])
        self.threeIncludeLaiZiCardTable[k] = { }
        -- table.insert(self.threeIncludeLaiZiCardTable[k], temTable)
        self.threeIncludeLaiZiCardTable[k] = temTable
    end
end

	--赖子数是2的情况
	if (laiZiCount > 1) then
	
--		for i = 1,self.singleCardTableCount*3 do

--			temIndex = ((i-1)/3)*1+1;
--			if ((i-1)%3 == 0) then

--				self.threeIncludeLaiZiCardTable[i] = self.singleCardTable[temIndex];

--			elseif((i-1)%3 == 1)then

--				self.threeIncludeLaiZiCardTable[i] = cbLaiZiDataTable[1];

--			else 

--				self.threeIncludeLaiZiCardTable[i] = cbLaiZiDataTable[2];
--			end

-- 	end
    self.threeIncludeLaiZiCardTableCount = self.threeIncludeLaiZiCardTableCount + self.singleCardTableCount;
    for k, v in pairs(self.singleCardTable) do
        if k < 16 then
            temTable = { }
            temTable = clone(v)
            table.insert(temTable, cbLaiZiDataTable[1])
            table.insert(temTable, cbLaiZiDataTable[2])
            self.threeIncludeLaiZiCardTable[k] = { }
            -- table.insert(self.threeIncludeLaiZiCardTable[k],temTable)
            self.threeIncludeLaiZiCardTable[k] = temTable
        end
    end
      
end


	----------------------------四张------------------------
	

self.fourIncludeLaiZiCardTableCount = self.threeCardTableCount;
for k, v in pairs(self.threeCardTable) do
    if k < 16 then
        temTable = { }
        temTable = clone(v)
        table.insert(temTable, cbLaiZiDataTable[1])
        self.fourIncludeLaiZiCardTable[k] = { }
        -- table.insert(self.fourIncludeLaiZiCardTable[k],temTable)
        self.fourIncludeLaiZiCardTable[k] = temTable
    end
end

 
-- 赖子数是2的情况
if (laiZiCount > 1) then
    self.fourIncludeLaiZiCardTableCount = self.fourIncludeLaiZiCardTableCount + self.doubleCardTableCount;
    for k, v in pairs(self.doubleCardTable) do
        if k < 16 then
            temTable = { }
            temTable = clone(v)
            table.insert(temTable, cbLaiZiDataTable[1])
            table.insert(temTable, cbLaiZiDataTable[2])
            self.fourIncludeLaiZiCardTable[k] = { }
            -- table.insert(self.fourIncludeLaiZiCardTable[k],temTable)
            self.fourIncludeLaiZiCardTable[k] = temTable
        end
    end
end
dump(self.doubleIncludeLaiZiCardTable, "self.doubleIncludeLaiZiCardTable")
dump(self.threeIncludeLaiZiCardTable, "self.threeIncludeLaiZiCardTable")
dump(self.fourIncludeLaiZiCardTable, "self.fourIncludeLaiZiCardTableCount")

-- 赖子数是3的情况
if (laiZiCount > 2) then


    self.fourIncludeLaiZiCardTableCount = self.fourIncludeLaiZiCardTableCount + self.singleCardTableCount;
    for k, v in pairs(self.singleCardTable) do
        if k < 16 then
            temTable = { }
            temTable = clone(v)
            table.insert(temTable, cbLaiZiDataTable[1])
            table.insert(temTable, cbLaiZiDataTable[2])
            table.insert(temTable, cbLaiZiDataTable[3])
            self.fourIncludeLaiZiCardTable[k] = { }
            -- table.insert(self.fourIncludeLaiZiCardTable[k],temTable)
            self.fourIncludeLaiZiCardTable[k] = temTable
        end
    end
end
    dump(self.doubleIncludeLaiZiCardTable,"self.doubleIncludeLaiZiCardTable")
	 dump(self.threeIncludeLaiZiCardTable,"self.threeIncludeLaiZiCardTable")
     dump(self.fourIncludeLaiZiCardTable,"self.fourIncludeLaiZiCardTableCount")
     
	return true;
end




-- 分析扑克
function GameLogicLaiZi:AnalysebCardData(cardTable,bNeedLaiZi)
    if cardTable == nil then
        return
    end
    
    for k, v in pairs(self.singleCardTable) do
        table.remove(self.singleCardTable, k)
    end
    self.singleCardTable = { }
    for k, v in pairs(self.doubleCardTable) do
        table.remove(self.doubleCardTable, k)
    end
    self.doubleCardTable = { }
    for k, v in pairs(self.threeCardTable) do
        table.remove(self.threeCardTable, k)
    end
    self.threeCardTable = { }
    for k, v in pairs(self.fourCardTable) do
        table.remove(self.fourCardTable, k)
    end
    self.fourCardTable = { }
    --
    for k, v in pairs(self.doubleTable) do
        table.remove(self.doubleTable, k)
    end
    self.doubleTable = { }
    for k, v in pairs(self.planeTable) do
        table.remove(self.planeTable, k)
    end
    self.planeTable = { }
     self.singleCardTableCount = 0
    self.doubleCardTableCount  = 0
    self.threeCardTableCount  = 0
    self.fourCardTableCount  = 0
    self.bigKing = false
    self.smallKing = false
    --
    --table.sort(cardTable, SortCardTable)
    local analyseTable = { }

    for k =1,  #cardTable do
        local cardData = cardTable[k]
        local index = GetCardLogicValue(cardData)
        if cardData == 0x4E then
           self.smallKing = true
        end
        if cardData == 0x4F then
           self.bigKing = true
        end
       
        -- 	print(cardData.."----"..index)
        if bNeedLaiZi==nil then --默认加多一个条件
           
           if index ~=  GetCardLogicValue(GameLogicLaiZi.laiziCardId) and cardData < 80 then--把赖子值排除掉
                 if analyseTable[index] == nil then
                    analyseTable[index] = { }
                 end
                 table.insert(analyseTable[index], cardData)
                  print("不相等：index == "..index.."GameLogicLaiZi.laiziCardId  == "..GameLogicLaiZi.laiziCardId)
             else
                  print("与赖子值相等：index == "..index.."GameLogicLaiZi.laiziCardId  == "..GameLogicLaiZi.laiziCardId)
              end
         

        else --对比牌分析时，不用加多个条件
            -- by dzf 20160119 没必要把0x5x和癞子值区分开来，这里都算进去
                 if analyseTable[index] == nil then
                    analyseTable[index] = { }
                 end
                 table.insert(analyseTable[index], cardData)

                 --[[--
             if index ~=  GetCardLogicValue(GameLogicLaiZi.laiziCardId) then--把赖子值排除掉
                 if analyseTable[index] == nil then
                    analyseTable[index] = { }
                 end
                 table.insert(analyseTable[index], cardData)
                  print("不相等：index == "..index.."GameLogicLaiZi.laiziCardId  == "..GameLogicLaiZi.laiziCardId)
             else
                  print("与赖子值相等：index == "..index.."GameLogicLaiZi.laiziCardId  == "..GameLogicLaiZi.laiziCardId)
              end
              ]]

        end
       
        
    end
    for k, v in pairs(analyseTable) do
        -- 	print(k.."----"..#v)
        if #v > 3 then
            self.fourCardTable[k] = v
            self.planeTable[k] = v
            self.fourCardTableCount = self.fourCardTableCount+1
        elseif #v > 2 then
            self.threeCardTable[k] = v
            self.doubleTable[k] = v
            self.planeTable[k] = v
             self.threeCardTableCount = self.threeCardTableCount+1
        elseif #v > 1 then
            self.doubleCardTable[k] = v
            self.doubleTable[k] = v
            self.doubleCardTableCount = self.doubleCardTableCount+1
        else
            self.singleCardTable[k] = v
            self.singleCardTableCount = self.singleCardTableCount+1
        end
    end
    
   --  print(table.getn(doubleCardTable))
     for k, v in pairs(self.threeCardTable) do
     	print("analyze:"..k.."----"..#v)
     end

     for k, v in pairs(self.threeCardTable) do
     	print("analyze:"..k.."----"..#v)
     end
     for k, v in pairs(self.doubleCardTable) do
     	print("analyze:"..k.."----"..#v)
     end
     for k, v in pairs(self.singleCardTable) do
     	print("analyze:"..k.."----"..#v)
     end



     print("fourCardTableCount == :"..self.fourCardTableCount)
     print("threeCardTableCount == :"..self.threeCardTableCount)
     print("doubleCardTableCount == :"..self.doubleCardTableCount)
     print("singleCardTableCount == :"..self.singleCardTableCount)

    print("---------------- dump analyseTable -------------------------")
--  dump(analyseTable)
--  dump(self.singleCardTable)
--  dump(self.doubleCardTable)
--  dump(self.threeCardTable)
--   --------------------  这些表都是从小到大排序的 ----------------------------
end

--cardValue的顺序是从小到大的，里面不能有赖子牌
function JugeBeLine( cardValue)
      
            -- 变量定义
        local cbCardData = cardValue[1]
    
        local cbFirstLogicValue =(cbCardData)
    
            -- 错误过虑
        if (cbFirstLogicValue >= 15) then
            return false
        end
    
        -- 连牌判断
           for i = 2, #cardValue do
            local cbCardData = cardValue[i]
            local cbNextLogicValue =(cbCardData)
            if (cbNextLogicValue >= 15) then
                return false
            end
            if (cbFirstLogicValue ~=(cbNextLogicValue - i + 1))then
                return false
            end
        end
     return true 
end 

function GameLogicLaiZi:JugeDoubleLineType(cardTable,nLaiZiCount)
     
     if self.singleCardTableCount > nLaiZiCount then
        return false
     end

     if self.singleCardTableCount%2 == 0 then --单牌数量是偶数
        if self:JugeSingleLine(cardTable,(nLaiZiCount - self.singleCardTableCoun)+ (nLaiZiCount - self.singleCardTableCoun)/2) then          
           return true
        end
    
     end

     return false

 end

function GameLogicLaiZi:JugeDoubleType(cardTable,begintCardIndex,endCardIndex,leftLaiZiCount,maxCardCount)
     
     local  cbCardCount = maxCardCount
     
      local cardIndex = 1;
      local needLaiZiCount = 0;
      local myLeftLaiZiCount = leftLaiZiCount;
      local cbFirstLogicValue = GetCardLogicValue(cardTable[1])
      local cbNextLogicValue  = GetCardLogicValue(cardTable[2])
      local  bFishTurn = false;
          while true do 
                 --cardIndex = cardIndex+1
                 if bFishTurn == false then
                    if cardIndex >= begintCardIndex  then
                       cardIndex = endCardIndex+1
                       bFishTurn = true
                       cbFirstLogicValue = GetCardLogicValue(cardTable[cardIndex])
                    end
                 end
                 
                 if cardIndex > cbCardCount then 
                    return true
                 end
                 
                cbNextLogicValue  = GetCardLogicValue(cardTable[cardIndex+1])
                if cbFirstLogicValue ~=  cbNextLogicValue or cbNextLogicValue==nil  then
                   if myLeftLaiZiCount>0 then
                      myLeftLaiZiCount = myLeftLaiZiCount-1 -- 用掉一张赖子
                      table.insert(self.newLaiZiCardTable,GetCardFormLogicValue(cbFirstLogicValue))  
                   else
                      return false
                   end                
                   
                end
               cardIndex = cardIndex + 2-- 跳过一张
               cbFirstLogicValue = GetCardLogicValue(cardTable[cardIndex])

           end
     
     return false

 end
function GameLogicLaiZi:JugeFeiJiTakeTwoType(cardTable,nLaiZiCount)
 
    local  cbCardCount = #cardTable
    if (cbCardCount % 5 == 0 and cbCardCount > 9) then
        local feijiLen = cbCardCount/5

        local cardValue = {}
        for k, v in pairs(self.singleCardTable) do
            table.insert(cardValue, k)                          
        end
        for k, v in pairs(self.threeCardTable) do
            table.insert(cardValue, k)                          
        end
        for k, v in pairs(self.doubleCardTable) do
            table.insert(cardValue, k)                          
        end
        for k, v in pairs(self.fourCardTable) do
            table.insert(cardValue, k)                
        end          
        table.sort(cardValue, function(a, b) return a > b end)
        print("----------------GameLogicLaiZi:JugeFeiJiTakeTwoType------------------")
        dump(cardValue)
        -- 二维数组
        local getValueCntInTb = function (table, val)
            local tb = table[val]
            if tb ~= nil then
                return #tb
            else
                return 0
            end
        end

        local findCardCnt = function (v) 
            local totalCnt = getValueCntInTb(self.singleCardTable, v) 
                            + getValueCntInTb(self.doubleCardTable, v) 
                            + getValueCntInTb(self.threeCardTable, v) 
                            + getValueCntInTb(self.fourCardTable, v)
            return totalCnt
        end

        local findMissingCardCnt = function (v) -- 找一下这个牌凑三个，差几个
            local totalCnt = findCardCnt(v)
            if totalCnt < 3 then
                return (3 - totalCnt) 
            else
                return 0
            end
        end
        local tempTb = {}
        tempTb[1] = {}

        local makeEnoughDoubleCard = function (startVal, restLaiziCnt)
            if (restLaiziCnt <= 0) then
                return
            end
            local tempCardValue = clone(cardValue)
            local usedLaiziCnt = nLaiZiCount - restLaiziCnt
            for k, v in pairs(tempCardValue) do
                if v < startVal or v >= (startVal + feijiLen) then
                    if (findCardCnt(v) % 2) ~= 0 then
                        tempTb[1][1] = v
                        self:InsertChangeLaiZiCard(tempTb, cbCardCount - usedLaiziCnt, 1)
                        usedLaiziCnt = usedLaiziCnt + 1
                    end
                end
            end
        end

        local inserNewCardTableFromVal = function (val)
            local usedLaiziCnt = 0
            for i = 1, feijiLen do
                local laiziCnt = findMissingCardCnt(val + i - 1) 
                if laiziCnt > 0 then
                    tempTb[1][1] = val + i - 1
                    self:InsertChangeLaiZiCard(tempTb, cbCardCount - usedLaiziCnt, laiziCnt)
                end
                usedLaiziCnt = usedLaiziCnt + laiziCnt
            end
            makeEnoughDoubleCard(val, nLaiZiCount - usedLaiziCnt)
        end

        local judgeEnoughDoubleCard = function (startVal, restLaiziCnt)
            local tempCardValue = clone(cardValue)
            local usedLaizi = 0
            for k, v in pairs(tempCardValue) do
                if (v < startVal) or (v >= startVal +  feijiLen) then
                    if (findCardCnt(v) % 2) ~= 0 then
                        usedLaizi = usedLaizi + 1
                    end
                end
            end
            if (restLaiziCnt - usedLaizi >= 0) and (((restLaiziCnt - usedLaizi) % 2) == 0) then
                return true
            else
                return false
            end
        end

        -- 判断每一个值处于飞机中的不同位置时所需要填充的癞子
        -- 我们考虑7时要同时考虑 ---  555666777和666777888和777888999三种可能
        for k, v in pairs(cardValue)  do
            local needLaiziCnt = 0
            for pos = 1, feijiLen do  -- 当前card值处于飞机的不同pos（位置）时所需要填充的癞子
                for i = 1, feijiLen do
                    needLaiziCnt = needLaiziCnt + findMissingCardCnt(v - pos + i) 
                end
                if (needLaiziCnt <= nLaiZiCount ) 
                    and (v - pos + feijiLen <= 14)
                    and (v - pos + 1 >= 3) then -- 最大<=A, 最小>=3
                    
                    if judgeEnoughDoubleCard(v - pos + 1, nLaiZiCount - needLaiziCnt) then
                        inserNewCardTableFromVal(v - pos + 1) 
                        return true
                    end
                end
            end
        end

        return false



    end
    
--[[--
         local  cbCardCount = #cardTable
         if cbCardCount%5 ==0 and cbCardCount > 9 then
            local threeCardCount = cbCardCount/5
            local cbFirstLogicValue = GetCardLogicValue(cardTable[1])
            local cbNextLogicValue  = GetCardLogicValue(cardTable[2])
           
            local sameValueCount = 1
            local cardIndex = 2
            local leftLaiZiCount = nLaiZiCount;
            local temThreeCardCount = 0;
            local beginIndex = 1;
            local endIndex = 1;
            local usedLaiZiCount =0;
            local resetIndex = 1
            self.newLaiZiCardTable = {}
            local nIndex = 0;
            function reset()
                   
                   leftLaiZiCount = nLaiZiCount;-- 重新开始计剩余赖子
                   temThreeCardCount = 0;       -- 重新计3连牌的个数 
                   
                   --beginIndex = cardIndex - 0 
                   if nIndex ==  endIndex then
                     endIndex = endIndex + 1
                   end
                   cardIndex = endIndex
                   nIndex =  endIndex
                   cbFirstLogicValue =  GetCardLogicValue(cardTable[cardIndex]) 
                   sameValueCount = 0  
                   resetIndex = resetIndex +1;  
                   self.newLaiZiCardTable = {}   
                     
            end

            while true do  
                
                if cardIndex > cbCardCount  then
                   return false
                end 
                cbNextLogicValue = GetCardLogicValue(cardTable[cardIndex])              
                if cbFirstLogicValue == cbNextLogicValue  then --第一个数与下面的数是否相等
                   sameValueCount = sameValueCount+1 
                   if sameValueCount==3 then 
                       cbFirstLogicValue = cbFirstLogicValue - 1
                       sameValueCount = 0
                       temThreeCardCount = temThreeCardCount+1
                       -----7.16----
                       endIndex = cardIndex
                    end 
                   cardIndex = cardIndex+1       
                else        
                   if sameValueCount < 3 then 
                          usedLaiZiCount =  3 - sameValueCount
                          leftLaiZiCount = leftLaiZiCount - usedLaiZiCount
                          if leftLaiZiCount<0 then -- 表示赖子数不够填充3张数
                             reset()
                          else --够填充,则用赖子填充 cardIndex不变
                               
                              for  i = 1,usedLaiZiCount do
                                   table.insert(self.newLaiZiCardTable,GetCardFormLogicValue(cbFirstLogicValue))                                  
                              end                 
                              cbFirstLogicValue = cbFirstLogicValue - 1
                              sameValueCount =0 
                              temThreeCardCount = temThreeCardCount+1                           
                               -----7.16----
                               endIndex = cardIndex
                          end

                   end

                    
                end -- if cbFirstLogicValue == cbNextLogicValue 
            
                if(temThreeCardCount==threeCardCount) then
                   --endIndex = beginIndex+(threeCardCount*3 - ( nLaiZiCount-leftLaiZiCount)) -1
                   beginIndex = endIndex - (threeCardCount*3 - ( nLaiZiCount-leftLaiZiCount)) -- -1
                   endIndex = endIndex -1
                   local endCardCount = cbCardCount - (nLaiZiCount-leftLaiZiCount);
                   

                   if(self:JugeDoubleType(cardTable,beginIndex,endIndex,leftLaiZiCount,endCardCount)) then 
                    for k,v in pairs(self.newLaiZiCardTable) do
                          self.newCardTable[cbCardCount- (k-1)] = GetCardFormLogicValue(v)
                      end                             
                      return true
                   end
                      
                end
                
                
            end--while true do 
        end

    ]]
end

-- cardTable要从大到小排列好
function GameLogicLaiZi:JugeFeiJiType(cardTable,nLaiZiCount)

    local  cbCardCount = #cardTable
    if (cbCardCount % 4 == 0 and cbCardCount > 7) then
        local feijiLen = cbCardCount/4

        local cardValue = {}
        for k, v in pairs(self.singleCardTable) do
            table.insert(cardValue, k)                          
        end
        for k, v in pairs(self.threeCardTable) do
            table.insert(cardValue, k)                          
        end
        for k, v in pairs(self.doubleCardTable) do
            table.insert(cardValue, k)                          
        end
        for k, v in pairs(self.fourCardTable) do
            table.insert(cardValue, k)                
        end          
        table.sort(cardValue, function(a, b) return a > b end)
        print("----------------GameLogicLaiZi:JugeFeiJiType------------------")
        dump(cardValue)
        -- 二维数组
        local getValueCntInTb = function (table, val)
            local tb = table[val]
            if tb ~= nil then
                return #tb
            else
                return 0
            end
        end

        local findMissingCardCnt = function (v) -- 找一下这个牌凑三个，差几个

            local totalCnt = getValueCntInTb(self.singleCardTable, v) 
                            + getValueCntInTb(self.doubleCardTable, v) 
                            + getValueCntInTb(self.threeCardTable, v) 
                            + getValueCntInTb(self.fourCardTable, v)
            if totalCnt < 3 then
                return (3 - totalCnt) 
            else
                return 0
            end
        end
        local tempTb = {}
        tempTb[1] = {}
        local inserNewCardTableFromVal = function (val) -- 从小填到大,从第一个填到最后一个
            local usedLaiziCnt = 0
            for i = 1, feijiLen do
                local laiziCnt = findMissingCardCnt(val + i - 1) 
                if laiziCnt > 0 then
                    tempTb[1][1] = val + i - 1
                    self:InsertChangeLaiZiCard(tempTb, cbCardCount - usedLaiziCnt, laiziCnt)
                end
                usedLaiziCnt = usedLaiziCnt + laiziCnt
            end
        end

        -- 判断每一个值处于飞机中的不同位置时所需要填充的癞子
        -- 我们考虑7时要同时考虑 ---  555666777和666777888和777888999三种可能
        for k, v in pairs(cardValue)  do
            local needLaiziCnt = 0
            for pos = 1, feijiLen do  -- 当前card值处于飞机的不同pos（位置）时所需要填充的癞子
                for i = 1, feijiLen do
                    needLaiziCnt = needLaiziCnt + findMissingCardCnt(v - pos + i) 
                end
                if (needLaiziCnt <= nLaiZiCount ) 
                    and (v - pos + feijiLen <= 14)
                    and (v - pos + 1 >= 3) then -- 最大<=A, 最小>=3

                    inserNewCardTableFromVal(v - pos + 1)
                    return true
                end
            end
        end

        return false
    end
    --[[--
          local  cbCardCount = #cardTable
         if cbCardCount%4 ==0 and cbCardCount > 7 then
            local threeCardCount = cbCardCount/4
            local cbFirstLogicValue = GetCardLogicValue(cardTable[1])
            local cbNextLogicValue  = GetCardLogicValue(cardTable[2])
           
            local sameValueCount = 1
            local cardIndex = 2
            local leftLaiZiCount = nLaiZiCount;
            local temThreeCardCount = 0;
            local beginIndex = 1;
            local endIndex = 1;
            local usedLaiZiCount =0;
            local resetIndex = 1;
            self.newLaiZiCardTable = {}
            function reset()
                   
                   leftLaiZiCount = nLaiZiCount;-- 重新开始计剩余赖子
                   temThreeCardCount = 0       -- 重新计3连牌的个数 
                    sameValueCount = 0  
                   beginIndex = cardIndex - sameValueCount  
                   cardIndex = beginIndex
                   cbFirstLogicValue =  GetCardLogicValue(cardTable[cardIndex]) 
                   resetIndex = resetIndex + 1
                   self.newLaiZiCardTable = {}   
                     
            end

            while true do  
                
                if cardIndex > cbCardCount - nLaiZiCount  then
                   return false
                end 
                cbNextLogicValue = GetCardLogicValue(cardTable[cardIndex])              
                if cbFirstLogicValue == cbNextLogicValue  then --第一个数与下面的数是否相等
                   sameValueCount = sameValueCount+1 
                   if sameValueCount==3 then 
                       cbFirstLogicValue = cbFirstLogicValue - 1
                       sameValueCount = 0
                       temThreeCardCount = temThreeCardCount+1
                    end 
                   cardIndex = cardIndex+1       
                else        
                   if sameValueCount < 3 then 
                          usedLaiZiCount =  3 - sameValueCount
                          leftLaiZiCount = leftLaiZiCount - usedLaiZiCount
                          if leftLaiZiCount<0 then -- 表示赖子数不够填充3张数
                             reset()
                          else --够填充,则用赖子填充 cardIndex不变
                               
                              for  i = 1,usedLaiZiCount do
                                   table.insert(self.newLaiZiCardTable,GetCardFormLogicValue(cbFirstLogicValue))                                  
                              end                 
                              cbFirstLogicValue = cbFirstLogicValue - 1
                              sameValueCount =0 
                              temThreeCardCount = temThreeCardCount+1                           
                               
                          end

                   end

                    
                end -- if cbFirstLogicValue == cbNextLogicValue 
            
                if(temThreeCardCount==threeCardCount) then
                   endIndex = beginIndex+(threeCardCount*3 - ( nLaiZiCount-leftLaiZiCount)) -1
                   local endCardCount = cbCardCount - (nLaiZiCount-leftLaiZiCount);
                   

                   --if(self:JugeDoubleType(cardTable,beginIndex,endIndex,leftLaiZiCount,endCardCount)) then 
                    for k,v in pairs(self.newLaiZiCardTable) do
                          self.newCardTable[cbCardCount- (k-1)] = GetCardFormLogicValue(v)
                      end                             
                      return true
                   --end
                      
                end
                
                
            end--while true do 
        end
        ]]
end



-- 注意cardTable 是已经排列好了的牌，顺序是从大到小，赖子在最右边
function GameLogicLaiZi:JugeSingleLine(cardTable,nLaiZiCount,allCardCount)
    
local cbFirstLogicValue = GetCardLogicValue(cardTable[1])
local cbNextLogicValue = GetCardLogicValue(cardTable[2])
local cbNextCardData = cardTable[2]
local nCardCount = 0
if allCardCount == nil then
    nCardCount = #cardTable 
 else
   nCardCount = allCardCount
end

--if (cbNextLogicValue==cbFirstLogicValue) or (GetCardLogicValue(cardTable[nCardCount - nLaiZiCount]) - cbFirstLogicValue)> (nLaiZiCount + nCardCount) then
--     return false;
--end
local temLogicValue = cbFirstLogicValue
local temCard = cardTable[1]
local nLaiziValue = GetCardLogicValue(GameLogicLaiZi.laiziCardId)

if (cbFirstLogicValue >= 15 or cbFirstLogicValue <= 0) then
    return false;
 end
if (cbNextLogicValue >= 15 or cbNextLogicValue <= 0) then
    return false;
end
local sum = 0
local cardIndex = 2

  
 self.newLaiZiCardTable = {}
  local bLaiZi = false;

while true do
  
    if (cbNextLogicValue >= 15 and (nLaiziValue~= cbNextLogicValue and cbNextCardData<80) ) then
        return false
    end
    temLogicValue = temLogicValue - 1
    
    if temLogicValue ~= cbNextLogicValue then -- 如果上一个值和一个值不相等
      
        if nLaiziValue~= cbNextLogicValue and cbNextCardData<80  then--下一个值不为赖子
           sum = sum + 1
           print("a顺子中的赖子变成："..temLogicValue)
           print("GetCardFormLogicValue(temLogicValue)："..GetCardFormLogicValue(temLogicValue))
           
          table.insert(self.newLaiZiCardTable, GetCardFormLogicValue(temLogicValue))  
         else
           bLaiZi = true
        end
    else
          cardIndex = cardIndex+1
          if nLaiziValue ~=cbNextLogicValue and cbNextCardData<80  then
             cbNextLogicValue = GetCardLogicValue(cardTable[cardIndex])
             cbNextCardData = cardTable[cardIndex]
           else
             bLaiZi = true
          end           

    end
    if sum > nLaiZiCount  then  
     
        return false
    end

        if cardIndex > nCardCount or bLaiZi then
           local temIndex = 0
           local temCount = nLaiZiCount - sum;
           local temValue = 1;
           if bLaiZi then
              print("true顺子中的赖子数目："..nLaiZiCount)
           else
              print("false顺子中的赖子数目："..nLaiZiCount)
           end
           
           if temCount>0 then          
           for i = 1,temCount do
           temValue =  GetCardLogicValue(cardTable[1])+i;
    
             if temValue>14 then
              temIndex=temIndex+1           
             
             
             print("b顺子中的赖子cardIndex："..cardIndex)
              table.insert(self.newLaiZiCardTable, GetCardFormLogicValue(cardTable[nCardCount - nLaiZiCount]-temIndex))
            
             print("GetCardFormLogicValue(temLogicValue)："..GetCardFormLogicValue(cardTable[nCardCount - nLaiZiCount]-temIndex))
              else        
           
              table.insert(self.newLaiZiCardTable, GetCardFormLogicValue(temValue))
               print("c顺子中的赖子变成："..GetCardFormLogicValue(temValue))
             
              end   
            end
        end 
           
          return true
       end

end


        return false-- 未知牌型
end

-- 把表中所有的key组成新表, 所有的key都必须是数字
function GameLogicLaiZi:getTableKeyTb(countTab, bigAhead)
     local tmpTable={}                       
     for k, v in pairs(countTab) do
         table.insert(tmpTable,k)
     end   
     if (bigAhead == nil or bigAhead == false) then
        table.sort(tmpTable, function (a, b) return a > b end)
     else
        table.sort(tmpTable, function (a, b) return a < b end)
     end

    return tmpTable    
end

function GameLogicLaiZi:InsertChangeLaiZiCard(cardTypeTable,allCardCount,nLaiZiCount,nOtherIndex)
     if cardTypeTable == nil then
        return 
     end
     if nOtherIndex == nil then
        nOtherIndex = 1
     end
     local tmpTable={}                       
     for k, v in pairs(cardTypeTable) do
         if #v > 0 then
            table.insert(tmpTable,v)
         end
     end

     -- 小的放前面
     table.sort(tmpTable, function (a, b)
         return GetCardLogicValue(a[1]) < GetCardLogicValue(b[1]) 
     end)   
     print("------------------InsertChangeLaiZiCard-----------------------")
     dump(tmpTable)
    -- table.sort(tmpTable,function(a,b) return a>b end)
     for i = 1,nLaiZiCount do
        self.newCardTable[allCardCount - (i-1)] = GetCardFormLogicValue(tmpTable[nOtherIndex][1])
     end
end

function GameLogicLaiZi:InsertChangeLaiZiCardB(cardTypeTable,allCardCount,nLaiZiCount,nOtherIndex)
     if cardTypeTable == nil then
        return 
     end
     if nOtherIndex == nil then
        nOtherIndex = 1
     end
     local tmpTable={}                       
     for k, v in pairs(cardTypeTable) do
         table.insert(tmpTable,v)
     end   
     
     
     for i = 1,nLaiZiCount do
        self.newCardTable[allCardCount - (i-1)] = GetCardFormLogicValue(tmpTable[nOtherIndex])
     end     
     
end

function GameLogicLaiZi:getNewCardTable()
    return self.newCardTable
end

function GameLogicLaiZi:resetNewCardTable(currentTable, laiziVal)
    self.newCardTable  = {}
    self.newCardTable = clone(currentTable )--复制扑克列表
    
    for k = 1, #self.newCardTable  do
       if(GetCardLogicValue(self.newCardTable[k]) ==  laiziVal) then
          self.newCardTable[k] = GameLogicLaiZi.laiziCardId
       end
    end
    
    for k, v in pairs(self.newCardTable) do
        print("string-------"..k)   
        print("string-------"..v)
        print("self.newCardTable的个数是-------"..#self.newCardTable)       
    end
end

function GameLogicLaiZi:findValInTable(table, val)
    for k, v in pairs(table) do
        if v == val then
            return true
        end
    end

    return false
end

-- 获取类型
function GameLogicLaiZi:GetCardType(cardTable, AnotherCardType)
    if cardTable == nil then
        return LandGlobalDefine.CT_ERROR
    end
    local bLaiZiCount = 0
    bLaiZiCount = self:GetLaiZiCount(cardTable)
    local m_bLaiZiValue = GetCardLogicValue(GameLogicLaiZi.laiziCardId)
    local temCurrentCardTable = {}
    temCurrentCardTable= clone(cardTable)--复制扑克列表
    table.sort(temCurrentCardTable ,LaiZiSortCardTableRight) -- 赖子放在最右边
    local cbCardCount = #temCurrentCardTable 
  
    self:resetNewCardTable(temCurrentCardTable, m_bLaiZiValue)

    --- 方便插入新表newCardTable使用
    local tempTb = {}
    local clearTempTb = function ()
        tempTb = {}
        tempTb[1] = {}
        tempTb[2] = {}
    end
    clearTempTb()
    

    if cbCardCount > 4 and bLaiZiCount == 4 then
        return LandGlobalDefine.CT_ERROR
    end


    -----------------------------------------------------BEGIN------简单牌型----------------------------------------------------
    -- 简单牌型
    if 0 == cbCardCount then
        return LandGlobalDefine.CT_ERROR
    elseif 1 == cbCardCount then
        return LandGlobalDefine.CT_SINGLE
    elseif 2 == cbCardCount then
        -- 对牌火箭
        -- 牌型判断
        if ((temCurrentCardTable [1] == 0x4F) and(temCurrentCardTable [2] == 0x4E)) then
            return LandGlobalDefine.CT_MISSILE_CARD
        end
        -- 当两张牌值相同时
         if (GetCardLogicValue(temCurrentCardTable [1]) == GetCardLogicValue(temCurrentCardTable [2])) then
            return LandGlobalDefine.CT_DOUBLE
        end
        -- 赖子牌判断，当两张牌值不相同时
        if (GetCardLogicValue(temCurrentCardTable [1]) ~= GetCardLogicValue(temCurrentCardTable [2])) then
            if bLaiZiCount == 1 then
                if (temCurrentCardTable [1] ~= 0x4F and (temCurrentCardTable [1] ~= 0x4E)) then
                    self.newCardTable[cbCardCount] =  GetCardFormLogicValue(temCurrentCardTable[1])
                    return LandGlobalDefine.CT_DOUBLE
                end
            end
        end
        return LandGlobalDefine.CT_ERROR
    end
    ---------------------------------------------------------END--------简单牌型----------------------------------------------




    -- 分析扑克
    self:AnalysebCardData(temCurrentCardTable)



    -------------------------------------------------------BEGIN-------- 炸弹牌型 -------------------------------------------------------
    
    if cbCardCount == 4 then
        -- 纯赖子炸弹
        if bLaiZiCount == 4 then
            for k =1, 4  do
                self.newCardTable[k] = GetCardFormLogicValue(temCurrentCardTable[1])
            end
            return LandGlobalDefine.CT_LAIZI_BOMB 
        end

        --硬炸
        if self.fourCardTableCount == 1 then
            -- 为毛还要做这么多废判断 !!!, 本来self.fourCardTable就不可能包括癞子
            --[[--
            if bLaiZiCount > 0  then
                print("这是一个软炸")
                return CT_RUAN_BOMB
            end

            local bChangedLaiZiCard = false
            for k, v in pairs(temCurrentCardTable) do
                if v > 0x50 then
                    bChangedLaiZiCard = true
                    break
                end 
            end

            if bChangedLaiZiCard then
                print("这是一个软炸")
                return CT_RUAN_BOMB
            end
            ]]

            print("这是一个硬炸")
            return LandGlobalDefine.CT_BOMB_CARD
        end
    end
      --从这里开始加入条件
    local  bJugeCardType = true
    if AnotherCardType ~= nil then
       if AnotherCardType ~= 0 then
           bJugeCardType = false
       end
    end


    if cbCardCount == 4 then
        if AnotherCardType == LandGlobalDefine.CT_RUAN_BOMB or bJugeCardType then
             --软炸
            print("这是一个软炸22")
            if (bLaiZiCount == 1 ) then
                if  self.threeCardTableCount == 1 then
                    self.newCardTable[cbCardCount] = GetCardFormLogicValue(temCurrentCardTable [1])
                    return LandGlobalDefine.CT_RUAN_BOMB
                end
            elseif (bLaiZiCount == 2 ) then
                if  self.doubleCardTableCount == 1 then
                    self.newCardTable[cbCardCount] = GetCardFormLogicValue(temCurrentCardTable [1])
                    self.newCardTable[cbCardCount - 1] = GetCardFormLogicValue(temCurrentCardTable [1])
                    return LandGlobalDefine.CT_RUAN_BOMB
                end
            elseif   bLaiZiCount == 3  and GetCardLogicValue(temCurrentCardTable[1])<16 then   
                self.newCardTable[cbCardCount] = GetCardFormLogicValue(temCurrentCardTable [1])
                self.newCardTable[cbCardCount - 1] = GetCardFormLogicValue(temCurrentCardTable [1]) 
                self.newCardTable[cbCardCount - 2] = GetCardFormLogicValue(temCurrentCardTable [1]) 
                       
                return LandGlobalDefine.CT_RUAN_BOMB
            end
        end  
    end

    -------------------------------------------------------END-------- 炸弹牌型 -------------------------------------------------------



    clearTempTb()


     
        ----------------------------------------------------BEGIN------ 四带两单--------------------------------------------------
    if AnotherCardType == LandGlobalDefine.CT_FOUR_LINE_TAKE_ONE or bJugeCardType then
        if self.bigKing and self.smallKing then
            --------- 双王都有，不刁他 ------------------------------
        else

        if cbCardCount == 6  then
           if bLaiZiCount == 0 then 
              if  self.fourCardTableCount == 1 and (self.singleCardTableCount == 2  or self. doubleCardTableCount == 1) then
                   return LandGlobalDefine.CT_FOUR_LINE_TAKE_ONE
              end
           elseif  bLaiZiCount == 1 then
                if(self.fourCardTableCount == 1 ) then  --有4条，赖子变成单牌的值，其实赖子值不用变
                   return LandGlobalDefine.CT_FOUR_LINE_TAKE_ONE 
                elseif (self.threeCardTableCount == 1 --有3条，加赖子凑成四条(注意，单张不包括赖子在内的）
                        and (self.singleCardTableCount == 2 or self.doubleCardTableCount == 1)) then
                   self:InsertChangeLaiZiCard(self.threeCardTable,cbCardCount,bLaiZiCount)
                   return LandGlobalDefine.CT_FOUR_LINE_TAKE_ONE 
                end
           elseif  bLaiZiCount == 2 then
                if self.threeCardTableCount == 1  then--有3条，加赖子凑成四条,另外一个赖子不变，再加另外一个单张                     
                   self:InsertChangeLaiZiCard(self.threeCardTable, cbCardCount, 1) 
                   return LandGlobalDefine.CT_FOUR_LINE_TAKE_ONE 
                 end
                 if (self.doubleCardTableCount == 1 ) then -- 除赖子外，另外两个是单张 
                     self:InsertChangeLaiZiCard(self.doubleCardTable, cbCardCount, bLaiZiCount)
                     return LandGlobalDefine.CT_FOUR_LINE_TAKE_ONE
                 elseif (self.doubleCardTableCount == 2) then -- 两对, 选择大的那一对
                     self:InsertChangeLaiZiCard(self.doubleCardTable, cbCardCount, bLaiZiCount, 2)
                     return LandGlobalDefine.CT_FOUR_LINE_TAKE_ONE
                 end
           elseif  bLaiZiCount == 3 then
                 if (self.singleCardTableCount == 3) then -- 除赖子除，另外3个是单, 选最大的
                     if self.bigKing or self.smallKing then -- 大小王中有一个存在，就用倒数第二大的配
                        self:InsertChangeLaiZiCard(self.singleCardTable, cbCardCount, bLaiZiCount, 2)
                     else
                        self:InsertChangeLaiZiCard(self.singleCardTable, cbCardCount, bLaiZiCount, 3)
                     end
                     return LandGlobalDefine.CT_FOUR_LINE_TAKE_ONE 
                 end
                 if (self.doubleCardTableCount == 1) then 
                    local doubleKeyTb = self:getTableKeyTb(self.doubleCardTable)
                    local singleValTb = self:getTableKeyTb(self.singleCardTable)
                    if (doubleKeyTb[1] > singleValTb[1]) or self.bigKing or self.smallKing then
                        self:InsertChangeLaiZiCard(self.doubleCardTable, cbCardCount, 2) -- 按大的来
                        return LandGlobalDefine.CT_FOUR_LINE_TAKE_ONE
                    else
                        self:InsertChangeLaiZiCard(self.singleCardTable, cbCardCount, bLaiZiCount) -- 按大的来
                        return LandGlobalDefine.CT_FOUR_LINE_TAKE_ONE 
                    end
                 end
                 if (self.threeCardTableCount == 1) then
                    self:InsertChangeLaiZiCard(self.threeCardTable, cbCardCount, 1)
                    return LandGlobalDefine.CT_FOUR_LINE_TAKE_ONE
                 end
              
           elseif  bLaiZiCount == 4 then
                if self.singleCardTableCount == 2 or self.doubleCardTableCount == 1 then
                   return LandGlobalDefine.CT_FOUR_LINE_TAKE_ONE  
                end
           end

        end

        end -- big king, small king

        self:resetNewCardTable(temCurrentCardTable, m_bLaiZiValue) -- 结束的时候恢复一下newcardtable,以防数据被改
   end -- if AnotherCardType ==

----------------------------------------------------BEGIN------ 四带两单------------------------------------------------------


    clearTempTb()

    ------------------------------------------------BEGIN---------------四带两对--------------------------------------------------
    if AnotherCardType == LandGlobalDefine.CT_FOUR_LINE_TAKE_TWO or bJugeCardType then
        if self.bigKing or self.smallKing then
            --大小王存在？滚粗
        else


       if cbCardCount == 8  then
           if bLaiZiCount == 0  then
              if  self.fourCardTableCount == 1 and self.doubleCardTableCount == 2  then
                  return LandGlobalDefine.CT_FOUR_LINE_TAKE_TWO  
              end
           elseif bLaiZiCount == 1 then
              if(self.fourCardTableCount == 1 and self.doubleCardTableCount == 1 ) then  
                 --有4条，赖子变成单牌的值
                   self:InsertChangeLaiZiCard(self.singleCardTable, cbCardCount, bLaiZiCount)
                   return LandGlobalDefine.CT_FOUR_LINE_TAKE_TWO 
               elseif (self.threeCardTableCount == 1 and self.doubleCardTableCount == 2) then--有3条，加赖子凑成四条
                   self:InsertChangeLaiZiCard(self.threeCardTable,cbCardCount,bLaiZiCount)
                   return LandGlobalDefine.CT_FOUR_LINE_TAKE_TWO
               end 
           elseif bLaiZiCount == 2 then
               if (self.fourCardTableCount == 1) then--有4条，赖子可变，可不变，???????
                    if self.singleCardTableCount == 2 then
                        self:InsertChangeLaiZiCard(self.singleCardTable, cbCardCount, bLaiZiCount)
                    end 
                return LandGlobalDefine.CT_FOUR_LINE_TAKE_TWO 
               end
               if (self.threeCardTableCount == 1 and self.doubleCardTableCount == 1) then--有3条，加赖子凑成四条，另外一个赖子变成单张的一个
                  self:InsertChangeLaiZiCard(self.threeCardTable,cbCardCount,1)
                   self:InsertChangeLaiZiCard(self.singleCardTable,cbCardCount-1,1)
                   return LandGlobalDefine.CT_FOUR_LINE_TAKE_TWO 
               end
               if (self.doubleCardTableCount == 3) then --
                  self.newCardTable[cbCardCount] = GetCardFormLogicValue(temCurrentCardTable[1])
                  self.newCardTable[cbCardCount - 1] = GetCardFormLogicValue(temCurrentCardTable[1])
                  return LandGlobalDefine.CT_FOUR_LINE_TAKE_TWO 
               end
           elseif bLaiZiCount == 3 then
               if (self.fourCardTableCount == 1 and self.singleCardTableCount == 1) then--有4条，赖子不变值
                   self:InsertChangeLaiZiCard(self.singleCardTable, cbCardCount, 1)
                   return LandGlobalDefine.CT_FOUR_LINE_TAKE_TWO 
               end
               if (self.threeCardTableCount == 1 and self.doubleCardTableCount == 1) then--只有3个赖子的3条，加赖子凑成四条，另外两个赖子变成一对，值不变
                  self:InsertChangeLaiZiCard(self.threeCardTable,cbCardCount,1)
                   return LandGlobalDefine.CT_FOUR_LINE_TAKE_TWO 
               end
               if (self.threeCardTableCount == 1 and self.singleCardTableCount == 2) then--只有3个赖子的3条，赖子要变成另外两个单牌
                    self:InsertChangeLaiZiCard(self.threeCardTable,cbCardCount,1)
                    self:InsertChangeLaiZiCard(self.singleCardTable,cbCardCount - 1, 1, 1)
                    self:InsertChangeLaiZiCard(self.singleCardTable,cbCardCount - 2, 1, 2)
                   return LandGlobalDefine.CT_FOUR_LINE_TAKE_TWO
               end
               if (self.doubleCardTableCount == 2) then--
                    local doubleKeyTb = self:getTableKeyTb(self.doubleCardTable)
                    local singleKeyTb = self:getTableKeyTb(self.singleCardTable)
                    if doubleKeyTb[1] > singleKeyTb[1] then
                        self:InsertChangeLaiZiCard(self.singleCardTable, cbCardCount, 1)
                        self:InsertChangeLaiZiCard(self.doubleCardTable, cbCardCount - 1, 2, 2)
                    else
                        self:InsertChangeLaiZiCard(self.singleCardTable, cbCardCount, 3)
                    end
                   return LandGlobalDefine.CT_FOUR_LINE_TAKE_TWO 
               end

           elseif bLaiZiCount == 4 then
                local doubleKeyTb = self:getTableKeyTb(self.doubleCardTable)
                local singleKeyTb = self:getTableKeyTb(self.singleCardTable)
                print("--------------laizi == 4----------- CT_FOUR_LINE_TAKE_TWO--")
                if (self.doubleCardTableCount == 1) and (self.singleCardTableCount == 2) then
                    if doubleKeyTb[1] > singleKeyTb[1] then -- 对子大，填对子成为4个
                        self:InsertChangeLaiZiCard(self.doubleCardTable, cbCardCount, 2)
                        self:InsertChangeLaiZiCard(self.singleCardTable, cbCardCount - 2, 1)
                        self:InsertChangeLaiZiCard(self.singleCardTable, cbCardCount - 3, 1, 2)
                    else --大的单牌填三个，小的填一个
                        self:InsertChangeLaiZiCard(self.singleCardTable, cbCardCount, 3, 2)
                        self:InsertChangeLaiZiCard(self.singleCardTable, cbCardCount - 3, 1, 1)
                    end
                    return LandGlobalDefine.CT_FOUR_LINE_TAKE_TWO
                end
                if (self.doubleCardTableCount == 2) then
                    --if doubleKeyTb[1] > GetCardLogicValue(GameLogicLaiZi.laiziCardId) then
                        self:InsertChangeLaiZiCard(self.doubleCardTable, cbCardCount, 2, 2)
                    --end
                    return LandGlobalDefine.CT_FOUR_LINE_TAKE_TWO
                end

                if (self.threeCardTableCount == 1) then
                    self:InsertChangeLaiZiCard(self.threeCardTable, cbCardCount, 1)
                    self:InsertChangeLaiZiCard(self.singleCardTable, cbCardCount - 1, 1)
                    return LandGlobalDefine.CT_FOUR_LINE_TAKE_TWO
                end
           end

        end --if cbCardCount == 8  


        end -- if self.bigKing or self.smallKing
        self:resetNewCardTable(temCurrentCardTable, m_bLaiZiValue) -- 结束的时候恢复一下newcardtable,以防数据被改
    end -- if AnotherCardType


------------------------------------------------END---------------四带两对--------------------------------------------------

    clearTempTb()

-------------------------------------------------BEGIN--------------三条类型-----------------------------------------------------

    if AnotherCardType == LandGlobalDefine.CT_THREE or bJugeCardType then
        if cbCardCount == 3  then
            if (self.bigKing or self.smallKing ) then
                return LandGlobalDefine.CT_ERROR
            end

           if bLaiZiCount == 0 and self.threeCardTableCount == 1 then
                return LandGlobalDefine.CT_THREE  
           end
            if  bLaiZiCount == 1 and self.doubleCardTableCount == 1 then
                self.newCardTable[cbCardCount] = GetCardFormLogicValue(temCurrentCardTable [1])
                return LandGlobalDefine.CT_THREE                
             end

             if  bLaiZiCount == 2 then 
                 self.newCardTable[cbCardCount] = GetCardFormLogicValue(temCurrentCardTable [1])
                 self.newCardTable[cbCardCount - 1] = GetCardFormLogicValue(temCurrentCardTable [1])                  
                  return LandGlobalDefine.CT_THREE                
             end
             if  bLaiZiCount == 3 then 
                return LandGlobalDefine.CT_THREE               
             end
        end
end -- if AnotherCardType

-------------------------------------------------END--------------三条类型-----------------------------------------------------




    clearTempTb()




-------------------------------------------------BEGIN------------ 3张连牌类型 判断 --------------------------------

if AnotherCardType == LandGlobalDefine.CT_THREE_LINE or bJugeCardType then

if (cbCardCount % 3 == 0 and cbCardCount>3 ) then
    print("--------- CT_THREE_LINE -------laiZiCount------", bLaiZiCount)
      if self.bigKing == false and self.smallKing == false then



        -----------------------------------------------------------------------------------------------------------------
--      
--      
--    if bLaiZiCount == 0 then -------------------赖子等于0
--       if (self.threeCardTableCount *3==cbCardCount) then
--           local cardValue = { }
--           for k, v in pairs(self.threeCardTable) do
--              table.insert(cardValue, k)
--            end
--           table.sort(cardValue, function(a, b) return a > b end)
--            if self:JugeSingleLine(cardValue,0)==true then   
--              print("三连类型")
--              return CT_THREE_LINE           
--            end 
--       end  
--   elseif bLaiZiCount == 1 then ---------------------赖子等于1
--          if (self.threeCardTableCount*3 + 2 + 1) == cbCardCount and (self.doubleCardTableCount == 1) then
--              local cardValue = { }
--              for k, v in pairs(self.threeCardTable) do
--                table.insert(cardValue, k)
--              end
--              for k, v in pairs(self.doubleCardTable) do
--                 table.insert(cardValue, k)
--              end
--
--              table.sort(cardValue, function(a, b) return a > b end)
--               if self:JugeSingleLine(cardValue,0)==true then   
--                  print("三连类型")
--                  self:InsertChangeLaiZiCard(self.doubleCardTable,cbCardCount,bLaiZiCount)
--                  return CT_THREE_LINE                           
--               end
--          end
--   elseif bLaiZiCount == 2 then ---------------------赖子等于2
--          if self.singleCardTableCount==1 and (self.threeCardTableCount*3 + 3) == cbCardCount then --赖子要变成这张单牌的同类
--             local cardValue = { }
--             for k, v in pairs(self.threeCardTable) do
--                table.insert(cardValue, k)
--             end
--             for k, v in pairs(self.singleCardTable) do
--                table.insert(cardValue, k)
--             end
--               table.sort(cardValue, function(a, b) return a > b end)
--              if self:JugeSingleLine(cardValue,0)==true then   
--                  print("三连类型")
--                 
--                  self:InsertChangeLaiZiCard(self.singleCardTable,cbCardCount,bLaiZiCount)
--                  return CT_THREE_LINE;                           
--               end
--         end
--         if self.singleCardTableCount==0 and self.doubleCardTableCount==2 and (self.threeCardTableCount*3 + 6) == cbCardCount then --赖子要变成对牌的同类
--           local cardValue = { }
--           for k, v in pairs(self.threeCardTable) do
--              table.insert(cardValue, k)
--           end
--           for k, v in pairs(self.doubleCardTable) do
--            table.insert(cardValue, k)
--           end
--            table.sort(cardValue, function(a, b) return a > b end)
--            if self:JugeSingleLine(cardValue,0)==true then   
--               print("三连类型")
--               self:InsertChangeLaiZiCard(self.doubleCardTable,cbCardCount,1)
--               self:InsertChangeLaiZiCard(self.doubleCardTable,cbCardCount - 1,1,2)
--               return CT_THREE_LINE;                           
--            end
--
--         end
--
--   elseif bLaiZiCount == 3 then ---------------------赖子等于3
--          if self.singleCardTableCount==0 then
--             if self.doubleCardTableCount == 3 and (self.threeCardTableCount*3 + 9 == cbCardCount) then
--                local cardValue = { }
--                for k, v in pairs(self.threeCardTable) do
--                    table.insert(cardValue, k)
--                end
--                for k, v in pairs(self.doubleCardTable) do
--                    table.insert(cardValue, k)
--                 end
--                table.sort(cardValue, function(a, b) return a > b end)
--                if self:JugeSingleLine(cardValue,0)==true then   
--                   print("三连类型")
--                 self:InsertChangeLaiZiCard(self.doubleCardTable,cbCardCount,1)
--                 self:InsertChangeLaiZiCard(self.doubleCardTable,cbCardCount -1,1,2)
--                 self:InsertChangeLaiZiCard(self.doubleCardTable,cbCardCount -2,1,3)
--                 return CT_THREE_LINE                           
--                end
--             elseif  self.threeCardTableCount*3  + 3 == cbCardCount then
--                print("---------sanlian-------------", cbCardCount)
--                 local cardValue = {}
--                  for k, v in pairs(self.threeCardTable) do
--                     table.insert(cardValue, k)
--                   end
--                   table.sort(cardValue, function(a, b) return a > b end)
--                   dump(cardValue)
--                   if cardValue[1] - cardValue[#cardValue] == (#cardValue - 1) then
--                        print("------------------sanlian----------------------前后添加")
--                        if cardValue[1] >= 14 then
--                            tempTb[1][1] = cardValue[#cardValue] - 1
--                            self:InsertChangeLaiZiCard(tempTb, cbCardCount, 3)
--                            return CT_THREE_LINE
--                        else
--                            tempTb[1][1] = cardValue[1] + 1
--                            self:InsertChangeLaiZiCard(tempTb, cbCardCount, 3)
--                            return CT_THREE_LINE
--                        end
--                    elseif cardValue[1] - cardValue[#cardValue] == #cardValue then
--                        for k, v in pairs(cardValue) do
--                            if (cardValue[1] - v)  ~= (k - 1) then
--                                tempTb[1][1] = v + 1
--                                self:InsertChangeLaiZiCard(tempTb, cbCardCount, 3)
--                                return CT_THREE_LINE
--                            end
--                        end
--                    end
--
--                   --[[--
--                  if self:JugeSingleLine(cardValue,0) == true then   
--                    if cardValue
--                      print("三连类型")
--                    return CT_THREE_LINE                          
--                  end
--                  ]]
--             end
--          elseif self.singleCardTableCount==1  then
--                if self.doubleCardTableCount==1 and (self.threeCardTableCount*3 + 3 == cbCardCount) then
--                   local cardValue = { }
--                    for k, v in pairs(self.threeCardTable) do
--                     table.insert(cardValue, k)
--                    end
--                    for k, v in pairs(self.doubleCardTable) do
--                     table.insert(cardValue, k)
--                    end
--                    for k, v in pairs(self.singleCardTable) do
--                     table.insert(cardValue, k)
--                    end
--                   
--                    table.sort(cardValue, function(a, b) return a > b end)
--                    if self:JugeSingleLine(cardValue,0)==true then   
--                        print("三连类型")
--                        self:InsertChangeLaiZiCard(self.doubleCardTable,cbCardCount,1)
--                        self:InsertChangeLaiZiCard(self.singleCardTable,cbCardCount - 1,2)
--                        return CT_THREE_LINE                        
--                    end
--                end
--          end
--
--   elseif bLaiZiCount == 4 then ---------------------赖子等于4
--    print("----------------CT_THREE_LINE-----------------start-----------")
--    --[[--
--    if self.doubleCardTableCount == 4 then
--        cardValue = {}
--        for k, v in pairs(self.doubleCardTable) do
--            table.insert(cardValue, k)                          
--        end
--        table.sort(cardValue, function(a, b) return a > b end)
--        if self:JugeSingleLine(cardValue, 0)==true then
--            for i = 1, 4 do
--                self:InsertChangeLaiZiCard(self.doubleCardTable, cbCardCount + 1 - i, 1, i)
--            end
--            return CT_THREE_LINE
--        end
--    end
--    ]]
--    if  self.fourCardTableCount == 0 then 
--        print("------------------ tempCnt == cbCardCount ---------------------")
--        local cardValue = {}
--        for k, v in pairs(self.singleCardTable) do
--            table.insert(cardValue, k)                          
--        end
--        for k, v in pairs(self.threeCardTable) do
--            table.insert(cardValue, k)                          
--        end
--        for k, v in pairs(self.doubleCardTable) do
--            table.insert(cardValue, k)                          
--        end
--        table.sort(cardValue, function(a, b) return a > b end)
--        local needLaiZiCount = self.singleCardTableCount*2 + self.doubleCardTableCount
--        needLaiZiCount = needLaiZiCount + (cardValue[1] - cardValue[#cardValue] - 1)*3
--        local usedLaiziCnt = 0
--        for i = 1, self.singleCardTableCount do
--            self:InsertChangeLaiZiCard(self.singleCardTable, cbCardCount + (1 - i)*2, 2, i) 
--        end 
--        usedLaiziCnt = self.singleCardTableCount*2
--        for i = 1, self.doubleCardTableCount do
--            self:InsertChangeLaiZiCard(self.doubleCardTable, cbCardCount - usedLaiziCnt + 1 - i, 1, i) 
--        end
--       usedLaiziCnt = usedLaiziCnt + self.doubleCardTableCount
--        if self:JugeSingleLine(cardValue, 0) == true then
--           if usedLaiziCnt == 1 then -- 填完癞子还有3个癞子，这三个癞子就要放到首尾去了
--                if cardValue[1] >= 14 then -- 只能填尾端
--                    tempTb[1][1] = cardValue[#cardValue] - 1
--                else
--                    tempTb[1][1] = cardValue[1] + 1
--                end
--                self:InsertChangeLaiZiCard(tempTb, cbCardCount - 1, 3)
--                return CT_THREE_LINE
--           elseif usedLaiziCnt == 4 then -- 刚好填完
--                return CT_THREE_LINE
--           end
--        elseif (cardValue[1] - cardValue[#cardValue]) == (#cardValue) then
--             if usedLaiziCnt == 1 then
--                for k, v in pairs(cardValue) do
--                    if (cardValue[1] - v)  ~= (k - 1) then
--                        tempTb[1][1] = v + 1
--                        self:InsertChangeLaiZiCard(tempTb, cbCardCount - 1, 3)
--                        return CT_THREE_LINE
--                    end
--                end
--             end
--        end
--
--
--    end
--
--   end


    print("----------------CT_THREE_LINE-----------------start-----------")
    --[[--
    if self.doubleCardTableCount == 4 then
        cardValue = {}
        for k, v in pairs(self.doubleCardTable) do
            table.insert(cardValue, k)                          
        end
        table.sort(cardValue, function(a, b) return a > b end)
        if self:JugeSingleLine(cardValue, 0)==true then
            for i = 1, 4 do
                self:InsertChangeLaiZiCard(self.doubleCardTable, cbCardCount + 1 - i, 1, i)
            end
            return CT_THREE_LINE
        end
    end
    ]]

    if  self.fourCardTableCount == 0 then 



        ---------------------------------------------------------------------------------------------
        print("------------------ tempCnt == cbCardCount ---------------------")
        local cardValue = {}
        for k, v in pairs(self.singleCardTable) do
            table.insert(cardValue, k)                          
        end
        for k, v in pairs(self.threeCardTable) do
            table.insert(cardValue, k)                          
        end
        for k, v in pairs(self.doubleCardTable) do
            table.insert(cardValue, k)                          
        end
        table.sort(cardValue, function(a, b) return a > b end)
        local needLaiZiCount = self.singleCardTableCount*2 + self.doubleCardTableCount
        needLaiZiCount = needLaiZiCount + (cardValue[1] - cardValue[#cardValue] - 1)*3
        local usedLaiziCnt = 0
        for i = 1, self.singleCardTableCount do
            self:InsertChangeLaiZiCard(self.singleCardTable, cbCardCount + (1 - i)*2, 2, i) 
        end 
        usedLaiziCnt = self.singleCardTableCount*2
        for i = 1, self.doubleCardTableCount do
            self:InsertChangeLaiZiCard(self.doubleCardTable, cbCardCount - usedLaiziCnt + 1 - i, 1, i) 
        end
        usedLaiziCnt = usedLaiziCnt + self.doubleCardTableCount
        local restLaiziCnt = bLaiZiCount - usedLaiziCnt

        if cardValue[1] <= 14 then -- 最大的牌不能大于A
        -----------------------------------------------------------------------------------------------------------
            if restLaiziCnt >= 0 and (restLaiziCnt % 3 == 0) then  -- 填完单牌跟对子后，还有0个或3的整数个癞子
                if (cardValue[1] - cardValue[#cardValue]) == #cardValue - 1 then
                    if restLaiziCnt == 0 then -- 填完了单双一个都不剩
                        return LandGlobalDefine.CT_THREE_LINE
                    end
                    if restLaiziCnt == 3 then -- 填完癞子还有3个癞子，这三个癞子就要放到首尾去了
                        if cardValue[1] > 14 then
                        else
                            if cardValue[1] == 14 then -- 只能填尾端
                                tempTb[1][1] = cardValue[#cardValue] - 1
                            else
                                tempTb[1][1] = cardValue[1] + 1
                            end
                            self:InsertChangeLaiZiCard(tempTb, cbCardCount - usedLaiziCnt, 3)
                            return LandGlobalDefine.CT_THREE_LINE
                        end
                    end
                elseif (cardValue[1] - cardValue[#cardValue]) == (#cardValue) then -- 中间刚好差一个癞子
                    if restLaiziCnt == 3 then
                        for k, v in pairs(cardValue) do
                            if (cardValue[1] - v)  ~= (k - 1) then
                                tempTb[1][1] = v + 1
                                self:InsertChangeLaiZiCard(tempTb, cbCardCount - usedLaiziCnt, 3)
                                return LandGlobalDefine.CT_THREE_LINE
                            end
                        end
                    end
                end
            end
        ------------------------------------------------------------------------------------------------------
        end






        --------------------------------------------------------------------------------------------------

    end       ---if  self.fourCardTableCount == 0

        -----------------------------------------------------------------------------------------------------------------




    end
    end -- 

    self:resetNewCardTable(temCurrentCardTable, m_bLaiZiValue) -- 结束的时候恢复一下newcardtable,以防数据被改
end -- if AnotherCardType ==
   
-------------------------------------------------END------------- 3张连牌类型 判断 --------------------------------

    clearTempTb()

------------------------------------------------BEGIN--------------------三带一 -------------------------------------------------
 if AnotherCardType == LandGlobalDefine.CT_THREE_TAKE_ONE or bJugeCardType then

 if  cbCardCount== 4 then
     if bLaiZiCount == 0 and self.threeCardTableCount==1  then
        print("三带一")    
       return LandGlobalDefine.CT_THREE_TAKE_ONE
     end
     if bLaiZiCount == 1 then    
       if  self.threeCardTableCount==1   then -- 赖子不变值，单牌
           print("三带一")  
           return LandGlobalDefine.CT_THREE_TAKE_ONE
       end
       if  self.doubleCardTableCount ==1   then -- 赖子变成对牌，构成3条
          print("三带一")
          self:InsertChangeLaiZiCard(self.doubleCardTable,cbCardCount,1)  
           return LandGlobalDefine.CT_THREE_TAKE_ONE
       end
       
     end
     if bLaiZiCount == 2  then 
          print("三带一") 
          if self.bigKing and self.smallKing then
              return LandGlobalDefine.CT_ERROR
          end
          if (self.singleCardTableCount == 2) then
            if (self.bigKing or self.smallKing) then
                self:InsertChangeLaiZiCard(self.singleCardTable, cbCardCount, bLaiZiCount, 1)     
            else
                self:InsertChangeLaiZiCard(self.singleCardTable, cbCardCount, bLaiZiCount, 2)     
            end

            return LandGlobalDefine.CT_THREE_TAKE_ONE
          end
          if (self.doubleCardTableCount == 1) then
            self:InsertChangeLaiZiCard(self.doubleCardTable, cbCardCount, 1)     
            return LandGlobalDefine.CT_THREE_TAKE_ONE
          end

     end
     if bLaiZiCount == 3  then  --这个是软炸了  
            return LandGlobalDefine.CT_THREE_TAKE_ONE
     end
 
 end
 end -- if AnotherCardType ==

------------------------------------------------END--------------------三带一 -------------------------------------------------


    clearTempTb()

------------------- 三带二 ---------------------
    if AnotherCardType == LandGlobalDefine.CT_THREE_TAKE_TWO or bJugeCardType then
 if  cbCardCount== 5 then

    if self.bigKing or self.smallKing then
        -- 三带二没戏了
    else

     if bLaiZiCount == 0   then  
        if  self.threeCardTableCount==1 and self.doubleCardTableCount == 1 then
            return LandGlobalDefine.CT_THREE_TAKE_TWO
        end  
     elseif  bLaiZiCount == 1  then 
            if  self.threeCardTableCount==1 then --赖子要变成对牌

               --self:InsertChangeLaiZiCard(self.singleCardTable,cbCardCount,bLaiZiCount)  
               
               if GetCardLogicValue(temCurrentCardTable [1]) == GetCardLogicValue(temCurrentCardTable [2])  then
                  self.newCardTable[cbCardCount] = GetCardFormLogicValue(temCurrentCardTable[4])
               else
                   self.newCardTable[cbCardCount] = GetCardFormLogicValue(temCurrentCardTable[1])
               end
                return LandGlobalDefine.CT_THREE_TAKE_TWO
            elseif  self.doubleCardTableCount==2   then --赖子要变成最大的那对
               self:InsertChangeLaiZiCard(self.doubleCardTable,cbCardCount,bLaiZiCount, 2)  
                return LandGlobalDefine.CT_THREE_TAKE_TWO
            end 

     elseif  bLaiZiCount == 2  then
             if  self.threeCardTableCount==1  then -- 赖子不用变，原始值
                 return LandGlobalDefine.CT_THREE_TAKE_TWO
             elseif self.doubleCardTableCount==1  then -- 一个赖子变成对牌，别一个变成单牌
                 self:InsertChangeLaiZiCard(self.singleCardTable,cbCardCount,bLaiZiCount) 
                  if GetCardLogicValue(temCurrentCardTable[1])== GetCardLogicValue(temCurrentCardTable[2]) then -- 对牌大的情况
                      self.newCardTable[cbCardCount] = GetCardFormLogicValue(temCurrentCardTable[1])
                      self.newCardTable[cbCardCount - 1] = GetCardFormLogicValue(temCurrentCardTable[3])
                   else -- 单牌大的情况
                      self.newCardTable[cbCardCount] = GetCardFormLogicValue(temCurrentCardTable[1])
                      self.newCardTable[cbCardCount - 1] = GetCardFormLogicValue(temCurrentCardTable[1])
                  end
                 return LandGlobalDefine.CT_THREE_TAKE_TWO
            
             end  
     elseif  bLaiZiCount == 3  then 
             if self.doubleCardTableCount==1  then -- 注意：这里要比较一下谁对牌和赖子牌谁大，
                if GetCardLogicValue(temCurrentCardTable[1]) > m_bLaiZiValue then
                   self:InsertChangeLaiZiCard(self.doubleCardTable,cbCardCount,1) 
                end
                 return LandGlobalDefine.CT_THREE_TAKE_TWO
             end  
             if self.singleCardTableCount == 2 then
                self:InsertChangeLaiZiCard(self.singleCardTable, cbCardCount, 2)
                self:InsertChangeLaiZiCard(self.singleCardTable, cbCardCount - 2, 1, 2)
                return LandGlobalDefine.CT_THREE_TAKE_TWO
            end

     elseif  bLaiZiCount == 4  then  -- 注意：这里也要比较一下赖子牌和单张谁大
             
             
             if self.bigKing or self.smallKing then
                return LandGlobalDefine.CT_ERROR
             end
            if GetCardLogicValue(temCurrentCardTable[1]) > m_bLaiZiValue then
               self.newCardTable[cbCardCount] = GetCardFormLogicValue(temCurrentCardTable[1])
               self.newCardTable[cbCardCount - 1] = GetCardFormLogicValue(temCurrentCardTable[1])
               else
               self.newCardTable[cbCardCount] = GetCardFormLogicValue(temCurrentCardTable[1])
            end
       
             return LandGlobalDefine.CT_THREE_TAKE_TWO
     end


    end -- bigKing smallking

    self:resetNewCardTable(temCurrentCardTable, bLaiZiCount)
    end -- cbCardCount == 5
 end -- if AnotherCardType ==

 ---------------------------------------------------


    clearTempTb()

 ------------------- -------------飞机带一 ---------------------

     if AnotherCardType == LandGlobalDefine.CT_FEIJI_TAKE_ONE or bJugeCardType then

 if cbCardCount%4 == 0 and cbCardCount> 7 then

            if (self.smallKing == true and self.bigKing == true) then
               return LandGlobalDefine.CT_ERROR
            end
                ---------------------赖子等于0和赖子不用变的情况
  --  if bLaiZiCount == 0  then  
           local cardValue = {}
            if (self.threeCardTableCount * 4 == cbCardCount) then
               for k, v in pairs(self.threeCardTable) do
                   table.insert(cardValue, k)
               end               
               table.sort(cardValue, function(a, b) return a > b end)

               if self:JugeSingleLine(cardValue,0)==true then    
--                       local tmpTable={}                       
--                       for k, v in pairs(self.threeCardTable) do
--                       table.insert(tmpTable,v)
--                       end   

--                      self.newCardTable[cbCardCount] = tmpTable[1][1] 
                    
                      print("飞机带一")
                    return LandGlobalDefine.CT_FEIJI_TAKE_ONE
               end
          
            end  
    if bLaiZiCount >0 and self.fourCardTableCount == 0  then  ---------------------赖子大于0,而且不能有四张
         if(self:JugeFeiJiType(temCurrentCardTable, bLaiZiCount)) then
             
            return LandGlobalDefine.CT_FEIJI_TAKE_ONE 
         end
     end    
   --  end
--       if bLaiZiCount == 1  then  ---------------------赖子等于1  
--           if (self.threeCardTableCount * 4 + 4) == cbCardCount and self.doubleCardTableCount ==1 then --(赖子变成对牌的牌值）

--               for k, v in pairs(self.threeCardTable) do
--                   table.insert(cardValue, k)
--               end
--               for k, v in pairs(self.doubleCardTable) do
--                   table.insert(cardValue, k)
--               end
--                 table.sort(cardValue, function(a, b) return a > b end)

--               if self:JugeSingleLine(cardValue,0)==true then    
--                       local tmpTable={}                       
--                       for k, v in pairs(self.doubleCardTable) do
--                       table.insert(tmpTable,v)
--                       end   

--                      self.newCardTable[cbCardCount] = tmpTable[1][1] 


--                    return CT_FEIJI_TAKE_ONE;
--               end

--         end
--      end
     
 end--飞机带一 
 end -- if AnotherCardType ==

    clearTempTb()
    
-----------------------------飞机带二 ------------------------------------------
        if AnotherCardType == LandGlobalDefine.CT_FEIJI_TAKE_TWO or bJugeCardType then

   if cbCardCount%5 == 0 and cbCardCount> 9 then
      if bLaiZiCount == 0 then
         if self.threeCardTableCount*5 == cbCardCount and (self.threeCardTableCount == self.doubleCardTableCount) then
            local cardValue = {}
            for k, v in pairs(self.threeCardTable) do
                table.insert(cardValue, k)
            end        
            table.sort(cardValue, function(a, b) return a > b end)
             if self:JugeSingleLine(cardValue,0) == true then 
                return LandGlobalDefine.CT_FEIJI_TAKE_TWO 
             end         
         end   
      elseif  self.fourCardTableCount == 0  then
         if(self:JugeFeiJiTakeTwoType(temCurrentCardTable ,bLaiZiCount) ==true) then
            print("----------------return ---CT_FEIJI_TAKE_TWO-------------------------", LandGlobalDefine.CT_FEIJI_TAKE_TWO)
           return LandGlobalDefine.CT_FEIJI_TAKE_TWO 
         end
      end
      

   end


   end -- if AnotherCardType ==


    clearTempTb()

  ---------------------  二连类型  -----------------------
   if AnotherCardType == LandGlobalDefine.CT_DOUBLE_LINE or bJugeCardType then

    if cbCardCount%2 == 0 and cbCardCount > 5 
        and (not (self.bigKing or self.smallKing)) then -- 大小王都不存在

        if self.threeCardTableCount + self.fourCardTableCount == 0 then 
            local cardValue = {}
            for k, v in pairs(self.singleCardTable) do
                table.insert(cardValue, k)                          
            end
            for k, v in pairs(self.doubleCardTable) do
                table.insert(cardValue, k)                          
            end
            local usedLaiziCnt = self.singleCardTableCount -- 填单牌要用掉的癞子
            table.sort(cardValue, function(a, b) return a > b end)

            if (cardValue[1] <= 14) then -- 最大的不能大于A
            ------------------------------------------------------------------------------------------------------------
                if (cardValue[1] - cardValue[#cardValue]) == #cardValue - 1 then -- 是连牌 
                    print("------------- 是连牌 ----------------------------")
    
                    local restLaiziCnt = bLaiZiCount - usedLaiziCnt
                    if (restLaiziCnt >= 0) and ((restLaiziCnt % 2) == 0) then -- 刚好填完单牌或填完后还剩整数个牌
                        for i = 1, self.singleCardTableCount do
                            self:InsertChangeLaiZiCard(self.singleCardTable, cbCardCount - i + 1, 1, i)
                        end
                        if restLaiziCnt == 4 then
                            if cardValue[1] <= 12 then -- 都填大头
                                tempTb[1][1] = cardValue[1] + 1
                                tempTb[2][1] = cardValue[1] + 2
                            elseif cardValue[1] >= 14 then -- 都填小头
                                tempTb[1][1] = cardValue[#cardValue] - 1
                                tempTb[2][1] = cardValue[#cardValue] - 2
                            else -- 两个填大头，两个填小头
                                tempTb[1][1] = cardValue[#cardValue] - 1
                                tempTb[2][1] = cardValue[1] + 1
                            end
                            self:InsertChangeLaiZiCard(tempTb, cbCardCount - usedLaiziCnt, 2, 1)
                            self:InsertChangeLaiZiCard(tempTb, cbCardCount - usedLaiziCnt - 2, 2, 2)
                            return LandGlobalDefine.CT_DOUBLE_LINE
                        elseif restLaiziCnt == 2 then
                            if cardValue[1] >= 14 then -- 只能填小头
                                tempTb[1][1] = cardValue[#cardValue] - 1
                            else
                                tempTb[1][1] = cardValue[1] + 1
                            end
                            self:InsertChangeLaiZiCard(tempTb, cbCardCount - usedLaiziCnt, 2)
                            return LandGlobalDefine.CT_DOUBLE_LINE
                        elseif restLaiziCnt == 0 then
                            return LandGlobalDefine.CT_DOUBLE_LINE
                        end
                    end
    
    
                else --中间有缺的
                    print("------------- 中间有缺的 ----------------------------")
                    local restLaiziCnt = bLaiZiCount - usedLaiziCnt
                    local missingCnt = (cardValue[1] - cardValue[#cardValue] - #cardValue + 1)*2
                    if ((restLaiziCnt - missingCnt) >= 0) and (((restLaiziCnt - missingCnt) % 2) == 0) then --刚好够用
                        for i = 1, self.singleCardTableCount do
                            self:InsertChangeLaiZiCard(self.singleCardTable, cbCardCount - i + 1, 1, i)
                        end
                        local index = 1
                        tempTb = {}
    
                        for i = cardValue[1], cardValue[#cardValue], -1 do
                            if not self:findValInTable(cardValue, i) then
                                tempTb[index] = {}
                                tempTb[index][1] = i
                                index = index + 1
                            end
                        end
                        for i = 1, #tempTb do -- 先把漏的补上
                            self:InsertChangeLaiZiCard(tempTb, cbCardCount - usedLaiziCnt - (i - 1)*2, 2, i)                        
                        end
                        usedLaiziCnt = usedLaiziCnt + missingCnt
                        restLaiziCnt = restLaiziCnt - missingCnt ---- 尼玛，还剩吗,我要吐了
                        if restLaiziCnt == 2 then -- 这里只可能是2了,既然漏了中间至少填2个癞子
                            if cardValue[1] >= 14 then -- 只能填小端
                                tempTb[1][1] = cardValue[#cardValue] - 1
                            else
                                tempTb[1][1] = cardValue[1] + 1
                            end
                            self:InsertChangeLaiZiCard(tempTb, cbCardCount - usedLaiziCnt, 2)
                        end
    
                        return LandGlobalDefine.CT_DOUBLE_LINE
                    end
                end 

            --------------------------------------------------------------------------------------------------
            end 



        end
    end


--[[--
    if cbCardCount%2 == 0 and cbCardCount >5 then
      local cardValue = {}
       if bLaiZiCount == 0 then
          if self.doubleCardTableCount *2 == cbCardCount then
              for k, v in pairs(self.doubleCardTable) do
                  table.insert(cardValue, k)                          
              end
              table.sort(cardValue, function(a, b) return a > b end)
              if self:JugeSingleLine(cardValue,0)==true then
                 return CT_DOUBLE_LINE
              end
                       
          end
      elseif  bLaiZiCount > 0 and self.doubleCardTableCount > 0 then 
            local cardValue = {}
             if self.singleCardTableCount > bLaiZiCount then --单张数比赖子数大则不构成连对
                return CT_ERROR
             end
             if (self.doubleCardTableCount *2 + self.singleCardTableCount +bLaiZiCount) == cbCardCount then
                 for k, v in pairs(self.doubleCardTable) do
                    table.insert(cardValue, k)
                 end
                 local temSingleValueTable = {};
                 for k, v in pairs(self.singleCardTable) do
                     table.insert(cardValue, k)
                     table.insert(temSingleValueTable, k)
                    
                 end
                 table.sort(cardValue, function(a, b) return a > b end) 
                 local temCount= (bLaiZiCount - self.singleCardTableCount)/2 ; -- 要变成两张的赖子数目
                 dump(cardValue,"二连类型--cardValue--")
                for i = 1, temCount do
                    table.insert(cardValue, laiziCardId)         
                end 
                -- if self:JugeSingleLine(cardValue,(bLaiZiCount - self.singleCardTableCount)+ (bLaiZiCount - self.singleCardTableCount)/2) then 
                if self:JugeSingleLine(cardValue,temCount,#cardValue) then           
                   
                   
                    for i=1, self.singleCardTableCount do
                       self.newCardTable[(cbCardCount  - (i-1))] =GetCardFormLogicValue(temSingleValueTable[i])
                    end
                   
                    if temCount == 1 then
                     print("temCount = "..temCount)

                       for i = 1, 2 do
                          self.newCardTable[(cbCardCount -self.singleCardTableCount) - (i-1)]= GetCardFormLogicValue(self.newLaiZiCardTable[1])           
                       end  
                       dump(self.newCardTable,"---21788self.newCardTable---")
                         print("self.singleCardTableCount = "..self.singleCardTableCount)
                         print("self.newLaiZiCardTable[1] = "..self.newLaiZiCardTable[1])
                         
                    elseif temCount == 2 then 
                         for i = 1, 4 do
                           self.newCardTable[(cbCardCount -self.singleCardTableCount)  - (i-1)]= GetCardFormLogicValue(self.newLaiZiCardTable[1])
                         if i>2 then
                            self.newCardTable[(cbCardCount -self.singleCardTableCount)  - (i-1)]= GetCardFormLogicValue(self.newLaiZiCardTable[2])
                         end
                          
                       end   
                    end
                   
                     return CT_DOUBLE_LINE
                 end
                 
                 

             end --if (self.doubleCardTableCount *2 + self.singleCardTableCount +bLaiZiCount) == cbCardCount

      end -- bLaiZiCount == 0
     
    end--if cbCardCount/2 == 0 
      ------end 二连类型 --------------
]]

    self:resetNewCardTable(temCurrentCardTable, m_bLaiZiValue) -- 结束的时候恢复一下newcardtable,以防数据被改

end -- if AnotherCardType ==

    clearTempTb()
----------------------------------------------
 -----------------  单连顺子类型  -------------------
    if AnotherCardType == LandGlobalDefine.CT_SINGLE_LINE or bJugeCardType then

        if cbCardCount>4 then
            if (self.singleCardTableCount +bLaiZiCount) == cbCardCount then

                if self:JugeSingleLine(temCurrentCardTable ,bLaiZiCount) == true  then
                    for i = 1, bLaiZiCount do
                        self:InsertChangeLaiZiCardB(self.newLaiZiCardTable,cbCardCount - (i-1),1,i) -- 最后两张变成间隔对子
                    end   
                 
                    return LandGlobalDefine.CT_SINGLE_LINE
                end
            end
        end
    end -- if AnotherCardType ==





    return LandGlobalDefine.CT_ERROR
end

-- 对比扑克
-- next 压 first 如果打得起，就返回正确的牌型，打不起就返回CT_ERROR, 而且保证self.newCardTable中放的是
-- 变后的牌
function GameLogicLaiZi:CompareCard(firstCardTable, nextCardTable, firstCardType, nextCardType)
    -- 获取类型
    
     local cbFirstType = firstCardType
     self:GetCardType(firstCardTable, firstCardType)
     local newFirstCardTable = clone(self.newCardTable)
     local cbNextType =  nextCardType
     self:GetCardType(nextCardTable, nextCardType)
     local newNextCardTable = clone(self.newCardTable)
     table.sort(newFirstCardTable,SortCardTable) -- 赖子放在最右边
     table.sort(newNextCardTable,SortCardTable) -- 赖子放在最右边
    
    local anotherCardType = self:GetCardType(nextCardTable) 
    if (cbNextType == LandGlobalDefine.CT_ERROR) then -- 虽然类型不同，再找找是否可能为炸弹类型
        cbNextType = anotherCardType
    end

    if (cbNextType == LandGlobalDefine.CT_ERROR) then
        return LandGlobalDefine.CT_ERROR
    end

    --判断上下家分别是火箭的情况
    if (cbNextType == LandGlobalDefine.CT_MISSILE_CARD) then
        return LandGlobalDefine.CT_MISSILE_CARD
    end
    if (cbFirstType == LandGlobalDefine.CT_MISSILE_CARD) then
        return LandGlobalDefine.CT_ERROR
    end
   
    -- --判断上下家分别是赖子炸的情况
    if (cbNextType == LandGlobalDefine.CT_LAIZI_BOMB) then
        return LandGlobalDefine.CT_LAIZI_BOMB
    end
    if (cbFirstType == LandGlobalDefine.CT_LAIZI_BOMB) then
        return LandGlobalDefine.CT_ERROR
    end
   --------------------------------------
 --判断上下家分别是硬炸的情况
    if ( cbFirstType ~= LandGlobalDefine.CT_BOMB_CARD) and(cbNextType == LandGlobalDefine.CT_BOMB_CARD) then     
        return LandGlobalDefine.CT_BOMB_CARD
    end
    if ( cbFirstType == LandGlobalDefine.CT_BOMB_CARD) and(cbNextType ~= LandGlobalDefine.CT_BOMB_CARD) then
        return LandGlobalDefine.CT_ERROR
    end

 --判断上下家分别是软炸的情况
    if (cbFirstType ~= LandGlobalDefine.CT_RUAN_BOMB and 
        ((cbNextType == LandGlobalDefine.CT_RUAN_BOMB) or (anotherCardType == LandGlobalDefine.CT_RUAN_BOMB))) then 
        return LandGlobalDefine.CT_RUAN_BOMB
    end
    if (cbFirstType == LandGlobalDefine.CT_RUAN_BOMB and cbNextType ~= LandGlobalDefine.CT_RUAN_BOMB) then
        return LandGlobalDefine.CT_ERROR
    end

    -- 规则判断类型不相同或者数目不相同的，都返回FALSE
    if (cbFirstType ~= cbNextType or #firstCardTable ~= #nextCardTable) then
        return LandGlobalDefine.CT_ERROR
    end


    -- 开始对比
    if cbNextType == LandGlobalDefine.CT_SINGLE
        or cbNextType == LandGlobalDefine.CT_DOUBLE
        or cbNextType == LandGlobalDefine.CT_THREE
        or cbNextType == LandGlobalDefine.CT_SINGLE_LINE
        or cbNextType == LandGlobalDefine.CT_DOUBLE_LINE
        or cbNextType == LandGlobalDefine.CT_THREE_LINE
        or cbNextType == LandGlobalDefine.CT_BOMB_CARD
        or cbNextType == LandGlobalDefine.CT_RUAN_BOMB then
        -- 获取数值
        local cbNextLogicValue = GetCardLogicValue(newNextCardTable[1])
        local cbFirstLogicValue = GetCardLogicValue(newFirstCardTable[1])

        -- 对比扑克
        if cbNextLogicValue > cbFirstLogicValue then
            return cbNextType
        else
            return LandGlobalDefine.CT_ERROR
        end

    elseif cbNextType == LandGlobalDefine.CT_THREE_TAKE_ONE
        or cbNextType == LandGlobalDefine.CT_THREE_TAKE_TWO
        or cbNextType == LandGlobalDefine.CT_FEIJI_TAKE_ONE
        or cbNextType == LandGlobalDefine.CT_FEIJI_TAKE_TWO then
        -- 分析扑克
        self:AnalysebCardData(newNextCardTable, true)
        local nextCardValue = { }
        for k, v in pairs(self.threeCardTable) do
            table.insert(nextCardValue, k)
        end
        table.sort(nextCardValue, function(a, b) return a < b end)

        self:AnalysebCardData(newFirstCardTable,true)
        local firstCardValue = { }
        for k, v in pairs(self.threeCardTable) do
            table.insert(firstCardValue, k)
        end
        table.sort(firstCardValue, function(a, b) return a < b end)

        -- 获取数值
        local cbNextLogicValue = GetCardLogicValue(nextCardValue[1])
        local cbFirstLogicValue = GetCardLogicValue(firstCardValue[1])

        -- 对比扑克
        if cbNextLogicValue > cbFirstLogicValue then
            return cbNextType
        else
            return LandGlobalDefine.CT_ERROR
        end

    elseif cbNextType == LandGlobalDefine.CT_FOUR_LINE_TAKE_ONE
        or cbNextType == LandGlobalDefine.CT_FOUR_LINE_TAKE_TWO
    then
        -- 分析扑克
        self:AnalysebCardData(newNextCardTable,true)
        local nextCardValue = { }
        for k, v in pairs(self.fourCardTable) do
            table.insert(nextCardValue, k)
        end
        table.sort(nextCardValue, function(a, b) return a < b end)

        self:AnalysebCardData(newFirstCardTable,true)
        local firstCardValue = { }
        for k, v in pairs(self.fourCardTable) do
            table.insert(firstCardValue, k)
        end
        table.sort(firstCardValue, function(a, b) return a < b end)

        -- 获取数值
        local cbNextLogicValue =(nextCardValue[1])
        local cbFirstLogicValue =(firstCardValue[1])

        -- 对比扑克
        if cbNextLogicValue > cbFirstLogicValue then
            return cbNextType
        else
            return LandGlobalDefine.CT_ERROR
        end
    end

    return LandGlobalDefine.CT_ERROR
end

---------------

function GameLogicLaiZi:ClearOutCard()

	for k, v in pairs(self.allOutCardTable) do
		table.remove(self.allOutCardTable, k)
	end

	self.allOutCardTable = {}
	self.allOutIdx = 1
end

function GameLogicLaiZi:SortCardList( cbCardData, cbCardCount, cbSortType )
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
function GameLogicLaiZi:AndroidSelectCard(turnCardTable,handCardTable,selectCardTable)

	local resultTable = {}
	--分析出牌牌型
	table.sort(turnCardTable, SortCardTable)
	local cbOutCardType = self:GetCardType(turnCardTable)
    print("选中的牌")
    dump(turnCardTable)
    print("智能选牌 cbOutCardType = ",cbOutCardType )
	--
    if ( cbOutCardType == LandGlobalDefine.CT_ERROR ) then
		if ( #selectCardTable > 5 ) then
            print("大于5张")
			resultTable = self:SearchMostOutCard(selectCardTable)
			return resultTable or {}
		end
	else
    	resultTable = self:SearchOutCard(selectCardTable,turnCardTable)
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
function GameLogicLaiZi:SearchMostOutCard(cardTable) 

	for i,v in ipairs(cardTable) do
		print(i,GetCardLogicValue(v))
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
                local laiZiCount = self:GetLaiZiData(cardTable)
                if laiZiCount>0 then
                  self: AnalysebCardDataIncludeLaiZi(self.cbLaiZiCardDataTable,laiZiCount)
                end
                
                 
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
			   	self:AnalysebCardData(cardTable);
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
				   	self:AnalysebCardData(cardTable);
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

function GameLogicLaiZi:splitOneCards(cardTable)
	--分析扑克
   	self:AnalysebCardData(cardTable);
	--
	local retCards = {}

   	--寻找单牌
   	local tmpTable = {}
	for k, v in pairs(self.singleCardTable) do
		table.insert(tmpTable, k)
	end
	table.sort(tmpTable, function(a,b) return a<b end)
	for k,v in pairs(tmpTable) do
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

   	--寻找对牌
   	local tmpTable2 = {}
	for k, v in pairs(self.doubleCardTable) do
		table.insert(tmpTable2, k)
	end
	table.sort(tmpTable2, function(a,b) return a<b end)
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
	table.sort(tmpTable3, function(a,b) return a<b end)
	for k,v in pairs(tmpTable3) do
		local card = self.threeCardTable[v]
		if card then
			table.insert(retCards, card[1])
		end
	end

	return retCards or {}
end

function GameLogicLaiZi:splitTwoCards(cardTable)
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
function GameLogicLaiZi:SearchOutCard(handCardTable,turnCardTable, turnCardType)

	local returnTable={}
	dump(handCardTable,"11 handCardTable = ")
    dump(turnCardTable,"2429 turnCardTable = ")
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
		cbTurnOutType = self:GetCardType(turnCardTable)
	end

    if #turnCardTable > 0 and  turnCardType ~= nil then
        cbTurnOutType = turnCardType
    end

	--
	self:AnalysebCardData(cbCardData)
    local laiZiCount = self:GetLaiZiData(cbCardData)
    self: AnalysebCardDataIncludeLaiZi(self.cbLaiZiCardDataTable,laiZiCount)
      
	--
	if turnCardTable == nil or #turnCardTable == 0 then

		local cbLogicValue = 0  --GetCardLogicValue(cbCardData[cbCardCount]);
        for i = 0, cbCardCount -1 do
			if GetCardLogicValue(cbCardData[cbCardCount-i]) ~= GetCardLogicValue(GameLogicLaiZi.laiziCardId)  then
			   cbLogicValue = GetCardLogicValue(cbCardData[cbCardCount-i])
               break
            else
               cbLogicValue = GetCardLogicValue(cbCardData[cbCardCount-i])
			end
		end


		--table.insert(returnTable, cbCardData[cbCardCount])
        local  num = 0;
		for i = 0, cbCardCount-1 do
			if (cbLogicValue==GetCardLogicValue(cbCardData[cbCardCount-i])) then
				table.insert(returnTable, cbCardData[cbCardCount-i])
                num = num+1
			elseif num>0 then
				break
			end
		end
		return returnTable or {}

	elseif cbTurnOutType == LandGlobalDefine.CT_SINGLE then
		print("--单牌")
		value = turnCardTable[1]
		self:getOneCards(value)
        if laiZiCount>0  then
           if GetCardLogicValue(GameLogicLaiZi.laiziCardId)>GetCardLogicValue(value) then
              table.insert(returnTable, self.cbLaiZiCardDataTable[1])
           end
        end
	elseif cbTurnOutType == LandGlobalDefine.CT_DOUBLE then
		print("--对牌")
		value = turnCardTable[1]
		self:getDoubleCards(value)

	elseif cbTurnOutType == LandGlobalDefine.CT_THREE then
		print("--三张")
		value = turnCardTable[1]
		self:getThreeCards(value)

	elseif cbTurnOutType == LandGlobalDefine.CT_SINGLE_LINE then
		--if #cbCardData >= #turnCardTable then			
			self:getSingleLineCards(cbCardData,turnCardTable)
		--end

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
			   cbTurnOutType = LandGlobalDefine.CT_THREE_TAKE_TWO
			end
		   	--
			local tmpTable={}
			for k, v in pairs(self.planeTable) do
				table.insert(tmpTable,k)
			end
            ------------
            for k, v in pairs(self.threeIncludeLaiZiCardTable) do
				table.insert(tmpTable,k)
			end
            --------------
			table.sort(tmpTable,function(a,b) return a<b end)
			--
            local needLaiZiCount = 0
			local logicTurnValue=0;
            local laiZiIndx = 1;
			for i=1, #turnCardTable-2 do
				local cbLogicValue=GetCardLogicValue(turnCardTable[i]);
				if (GetCardLogicValue(turnCardTable[i+1])==cbLogicValue)
					and (GetCardLogicValue(turnCardTable[i+2])==cbLogicValue) then
					logicTurnValue = GetCardLogicValue(turnCardTable[i])
					break
				end
			end
			--属性数值
			local cbTurnLineCount=0;
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
					local lineCount=0
                     needLaiZiCount = 0
                     laiZiIndx = 1;
					for j=i, #tmpTable do
						local nextLogicValue = tmpTable[j]
						if (cbTurnLineCount>1 and nextLogicValue>=15) then
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
                             else
                                   if self.threeIncludeLaiZiCardTable[nextLogicValue] and needLaiZiCount < laiZiCount then
  
                                      local index=1
                                      for m, n in pairs(self.threeIncludeLaiZiCardTable[nextLogicValue]) do
									     if index<=3 then
                                            if GetCardLogicValue(n) == GetCardLogicValue(GameLogicLaiZi.laiziCardId)  then -- 如果是赖子
                                               table.insert(cards, self.cbLaiZiCardDataTable[laiZiIndx])
                                               laiZiIndx = laiZiIndx + 1
                                               needLaiZiCount= needLaiZiCount + 1
                                            else
                                               table.insert(cards, n)
                                            end
										    
										    index=index+1
										    print("55-1:",m,",",GetCardLogicValue(n))
									     end
								       end
                                       lineCount = lineCount + 1
								
								     if #cards == cbTurnLineCount*3 then
								       	break
                                      end
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
                           -- if needLaiZiCount< laiZiCount then
                               table.insert(self.allOutCardTable, cards)
                           -- end	
						end
                      
					end
                    
				end
			end
		end

	end

	--搜索炸弹
	if cbCardCount >= 4 then

        self:AnalysebCardData(cbCardData)
		local cbLogicValue = 0
        local laiZiCount = self:GetLaiZiData(cbCardData)
        self: AnalysebCardDataIncludeLaiZi(self.cbLaiZiCardDataTable,laiZiCount)

        print("cbTurnOutType:"..cbTurnOutType)
       if cbTurnOutType ~= LandGlobalDefine.CT_MISSILE_CARD and cbTurnOutType ~= LandGlobalDefine.CT_LAIZI_BOMB  then

		   if cbTurnOutType==LandGlobalDefine.CT_BOMB_CARD then
			  cbLogicValue = GetCardLogicValue(turnCardTable[1])

		   end

		  --搜索硬炸
           for k, v in pairs(self.fourCardTable) do
               if k > cbLogicValue  then
                  table.insert(self.allOutCardTable, v)
               end
            end
       end

       if cbTurnOutType ~= LandGlobalDefine.CT_MISSILE_CARD and cbTurnOutType ~= LandGlobalDefine.CT_LAIZI_BOMB and cbTurnOutType ~= LandGlobalDefine.CT_BOMB_CARD  then
		   -----------yu add---------
           --搜索软炸
          cbLogicValue = 0
           if cbTurnOutType==LandGlobalDefine.CT_RUAN_BOMB then
              cbLogicValue = GetCardLogicValue(turnCardTable[1])
           end
          print("cbLogicValue:"..cbLogicValue)
          print("cbLogicValue:"..cbLogicValue)

         -- local tmpTable={}
			
--            for k, v in pairs(self.fourIncludeLaiZiCardTable) do
--				table.insert(tmpTable,k)
--			end


           for k, v in pairs(self.fourIncludeLaiZiCardTable) do
        	   if k > cbLogicValue  then
	              table.insert(self.allOutCardTable, v)
        	   end
           end
           

       end
		
        --搜索赖子炸
        if cbTurnOutType ~= LandGlobalDefine.CT_MISSILE_CARD  then 
           if laiZiCount == 4 then
              table.insert(self.allOutCardTable, self.cbLaiZiCardDataTable) 
           end
        end
           
        
        
        -------------------
	end

	--搜索火箭
	if ((cbCardCount>=2) and self.bigKing and self.smallKing) then
		--设置结果
		local cards = {}
		cards[1] = 0x4E;
		cards[2] = 0x4F;

		table.insert(self.allOutCardTable, cards)
	end

	--判断是否已经存有搜索结果
	self.allOutIdx = 1
	allCanOutCount = #self.allOutCardTable
	if allCanOutCount > 0 then
		if self.allOutIdx > allCanOutCount or self.allOutIdx < 1 then
			self.allOutIdx = 1
		end

		returnTable = self.allOutCardTable[self.allOutIdx]
		self.allOutIdx = self.allOutIdx + 1
	end

	return returnTable or {}
end

--获取单张大牌
function GameLogicLaiZi:getOneCards(cardValue)
	--
	local logicValue = GetCardLogicValue(cardValue)
    --local laiZiCount = self.GetLaiZiData(
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

function GameLogicLaiZi:getDoubleCards(cardValue)
   	-- 要修改 先对,后拆三
	local logicValue = GetCardLogicValue(cardValue)

   	--寻找对牌
   	local tmpTable2 = {}
	for k, v in pairs(self.doubleCardTable) do
		table.insert(tmpTable2, k)
	end
--    for k, v in pairs(self.doubleIncludeLaiZiCardTable) do
--        table.insert(tmpTable2, k)
--    end

	table.sort(tmpTable2, function(a,b) return a<b end)
	for k,v in pairs(tmpTable2) do
		if v > logicValue then
			local card = self.doubleCardTable[v]
			if card then
				table.insert(self.allOutCardTable, card)
--            else
--                 card = self.doubleIncludeLaiZiCardTable[v]
--                 if card then
--                 table.insert(self.allOutCardTable, card)
--                 end
			end
		end
	end


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
            if self.threeCardTable[v] then
                
               for m, n in pairs(self.threeCardTable[v]) do
				   if index<=2 then
					  table.insert(cards, n)
					   index=index+1
				   end				
			    end
--            else

--               for m, n in pairs(self.threeIncludeLaiZiCardTable[v]) do
--				   if index<=2 then
--					  table.insert(cards, n)
--					   index=index+1
--				   end				
--			   end

            end
			

			if #cards == 2 then
				table.insert(self.allOutCardTable, cards)		
			end
		end
	end	
    --赖子的情况

    	--寻找对牌
   	tmpTable2 = {}
	
    for k, v in pairs(self.doubleIncludeLaiZiCardTable) do
        table.insert(tmpTable2, k)
    end
    table.sort(tmpTable2, function(a,b) return a<b end)
	for k,v in pairs(tmpTable2) do
		if v > logicValue then
           card = self.doubleIncludeLaiZiCardTable[v]
           if card then
              table.insert(self.allOutCardTable, card)
           end
			
		end
	end


end

function GameLogicLaiZi:getThreeCards(cardValue)

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
            else
                card = self.threeIncludeLaiZiCardTable[v]
                if card then
				   table.insert(self.allOutCardTable, card)
                end
			end
		end
	end

    --赖子牌
    -- yu add
    tmpTable3 = {}
    for k, v in pairs(self.threeIncludeLaiZiCardTable) do
		table.insert(tmpTable3, k)
	end

    table.sort(tmpTable3, function(a,b) return a<b end)
	for k,v in pairs(tmpTable3) do
       if v > logicValue then
         local  card = self.threeIncludeLaiZiCardTable[v]
          if card then
			 table.insert(self.allOutCardTable, card)
          end
       end			
	end

end

function GameLogicLaiZi:getSingleLineCards(cardTable,turnCardTable)  
    local turnCardCount = #turnCardTable
     local cbCardCount = #cardTable
     if turnCardCount > cbCardCount then
        return LandGlobalDefine.CT_ERROR
     end
     print("--顺子")
     -------先获取单张牌值----
     
     local nextCardValue = 0
     local temSigleTable = {}
     local temLaiZiCardDataTable = {};
     local temGoodTable = {};
     local laiZiLogicValue = GetCardLogicValue(GameLogicLaiZi.laiziCardId) ;
     local laiZiCount = 0
     local firsCardValue = GetCardLogicValue(cardTable[1])--拿自己手上最大牌，即最左边牌
     local minTurnCardLogicValue = GetCardLogicValue(turnCardTable[turnCardCount]) ;--获取对方牌的最小值
     local maxTurnCardLogicValue = GetCardLogicValue(turnCardTable[1]) ;--获取对方牌的最大值
	if (maxTurnCardLogicValue == 14) then--	如果是最大A值了，就没有必要再比较了
        return LandGlobalDefine.CT_ERROR
     end
			
     if firsCardValue == laiZiLogicValue then
        table.insert(temLaiZiCardDataTable, cardTable[1])
        laiZiCount = laiZiCount+1  
     elseif firsCardValue > minTurnCardLogicValue and  firsCardValue <15 then
        table.insert(temSigleTable, cardTable[1])
     elseif firsCardValue <= minTurnCardLogicValue then
        return LandGlobalDefine.CT_ERROR
     end
     --从大到小比较牌值
       for i = 2 , cbCardCount do
           
           nextCardValue = GetCardLogicValue(cardTable[i])
           --如果是赖子牌，加入赖子表中
           if nextCardValue == laiZiLogicValue then
              table.insert(temLaiZiCardDataTable, cardTable[i])
              laiZiCount = laiZiCount+1
           else
               if nextCardValue<= minTurnCardLogicValue then
                  break
               end
              if firsCardValue ~= nextCardValue   then
                 if nextCardValue <15 then
                    table.insert(temSigleTable, cardTable[i])
                 end
                 firsCardValue = GetCardLogicValue(cardTable[i])
              end  

           end
   
      end
        local temSigleCardCount = #temSigleTable;
        if (temSigleCardCount +laiZiCount)<turnCardCount then
            return LandGlobalDefine.CT_ERROR
        end
 --------- 比较不用赖子时是否有顺子的情况----
         local temNextIndex = 0;
         local temNextValue = 0 
         --从小到大拿牌
    for i=temSigleCardCount, 1, -1 do 
		--获取数值
		local logicValue = GetCardLogicValue(temSigleTable[i])
          temNextIndex = i +1- turnCardCount ;
          
         if temNextIndex<1 then
            break
         end
		--判断
		if (logicValue>=15) then
			break
		end
        temNextValue = GetCardLogicValue(temSigleTable[temNextIndex]);
		--搜索连牌
        
		if temNextValue == (logicValue +turnCardCount- 1) then
            temGoodTable = {};
           for j= i, temNextIndex, -1 do
           table.insert(temGoodTable, temSigleTable[j])   
           end 
           table.insert(self.allOutCardTable, temGoodTable)
        end
   end
   ---------用到赖子的情况------
   if laiZiCount < 1 then
      return LandGlobalDefine.CT_ERROR
   end
   ------------------赖子是1的情况-----------------------
  
        --从小到大拿牌
    for i=temSigleCardCount, 1, -1 do 
		--获取数值
		local logicValue = GetCardLogicValue(temSigleTable[i])
          temNextIndex = (i +1- turnCardCount)+1 ;
          
         if temNextIndex<1 then
            break
         end
		--判断
		if (logicValue>=15) then
			break
		end
        temNextValue = GetCardLogicValue(temSigleTable[temNextIndex]);
		--搜索连牌
        local temNeedValue1 = logicValue +turnCardCount- 1;
       -- local temNeedValue2 = logicValue +turnCardCount- 2;
		if temNextValue <=temNeedValue1 then
        temGoodTable = {};
           for j= i, temNextIndex, -1 do
               table.insert(temGoodTable, temSigleTable[j])
           end 
           table.insert(temGoodTable, temLaiZiCardDataTable[1])

           table.insert(self.allOutCardTable, temGoodTable)
        end
   end


----------------------赖子是2的情况-------------------------------
if laiZiCount < 2 then
      return LandGlobalDefine.CT_ERROR
   end
    --从小到大拿牌
    for i=temSigleCardCount, 1, -1 do 
		--获取数值
		local logicValue = GetCardLogicValue(temSigleTable[i])
          temNextIndex = (i +1- turnCardCount)+2 ;
          
         if temNextIndex<1 then
            break
         end
		--判断
		if (logicValue>=15) then
			break
		end
        temNextValue = GetCardLogicValue(temSigleTable[temNextIndex]);
		--搜索连牌
        local temNeedValue1 = logicValue +turnCardCount- 1;       
		if temNextValue <=temNeedValue1 then
        temGoodTable = {};
           for j= i, temNextIndex, -1 do
               table.insert(temGoodTable, temSigleTable[j])
           end 
           table.insert(temGoodTable, temLaiZiCardDataTable[1])
           table.insert(temGoodTable, temLaiZiCardDataTable[2])

           table.insert(self.allOutCardTable, temGoodTable)
        end
   end
--赖子是3的情况，可变成炸弹，不理它了
  


--	local turnCardCount = #turnCardTable
--	local logicTurnValue = GetCardLogicValue(turnCardTable[turnCardCount])

--	for i=#cardTable, turnCardCount-1, -1 do
--		--获取数值
--		local logicValue=GetCardLogicValue(cardTable[i])
--		--构造判断
--		if (logicValue>=15) then
--			break
--		end
--		--搜索连牌
--		if logicValue > logicTurnValue then
--			local cards = {}
--			local lineCount=0
--			for j=i, 1, -1 do
--				local nextLogicValue = GetCardLogicValue(cardTable[j])
--				if (nextLogicValue>=15) then
--					break
--				end
--				if nextLogicValue==logicValue+lineCount then
--					table.insert(cards, cardTable[j])
--					lineCount = lineCount + 1
--				end

--				--完成判断
--				if (#cards == turnCardCount) then
--				   table.insert(self.allOutCardTable, cards)
--				   break
--				end					
--			end
--		end
--	end
end

function GameLogicLaiZi:getDoubleLineCards(cardTable,turnCardTable)

	local tmpTable={}
	for k, v in pairs(self.doubleTable) do
		table.insert(tmpTable,k)
	end

    for k, v in pairs(self.doubleIncludeLaiZiCardTable) do
		table.insert(tmpTable,k)
	end

	table.sort(tmpTable,function(a,b) return a<b end)
    local LaiZiCount = self:GetLaiZiData(cardTable);
	--
	local turnCardCount = #turnCardTable
	local logicTurnValue = GetCardLogicValue(turnCardTable[turnCardCount])
    local needLaiZiCount = 0 --组成连对时，所须的赖子数
    local  laiZiIndx = 1
	for i=1, #tmpTable-2 do
		local cards = {}
        
		--获取数值
		local logicValue=tmpTable[i]
		--构造判断
		if (logicValue>=15) then
			break
		end
		--搜索连牌
		if logicValue > logicTurnValue then
			local lineCount=0
            needLaiZiCount = 0 --组成连对时，所须的赖子数
            laiZiIndx = 1
			for j=i, #tmpTable do
				local nextLogicValue = tmpTable[j]
				if (nextLogicValue>=15) then
					break
				end
				if nextLogicValue == logicValue+lineCount then
					if self.doubleTable[nextLogicValue] then
						local index=1
						for m, n in pairs(self.doubleTable[nextLogicValue]) do
							if index<=2 then
								table.insert(cards, n)
								index=index+1
							end				
						end
						lineCount = lineCount + 1
                    elseif  self.doubleIncludeLaiZiCardTable[nextLogicValue] and needLaiZiCount < LaiZiCount then
                        needLaiZiCount = needLaiZiCount + 1
                        local index=1
						for m, n in pairs(self.doubleIncludeLaiZiCardTable[nextLogicValue]) do
							if index<=2 then
								
                                if GetCardLogicValue(n) == GetCardLogicValue(GameLogicLaiZi.laiziCardId)   then
                                   table.insert(cards, self.cbLaiZiCardDataTable[laiZiIndx])
                                   laiZiIndx = laiZiIndx + 1
                                  else
                                   table.insert(cards, n)
                                end
								index = index+1
							end				
						end
						lineCount = lineCount + 1
                     else if LaiZiCount >1 and (needLaiZiCount+1) < LaiZiCount then
                          needLaiZiCount = needLaiZiCount + 2
                          table.insert(cards, self.cbLaiZiCardDataTable[laiZiIndx])
                          laiZiIndx = laiZiIndx + 1
                          table.insert(cards, self.cbLaiZiCardDataTable[laiZiIndx])
                          laiZiIndx = laiZiIndx + 1
                          lineCount = lineCount + 1
                     end

					end -- if nextLogicValue == logicValue+lineCount then
				else
					break
				end
                --完成判断
			   if (#cards == turnCardCount)   then
			       table.insert(self.allOutCardTable, cards) 
			       break
			   end	
			end
				
            		
		end				 
    end
    

end


----

--!!获取底牌类型
function GameLogicLaiZi:GetBackCardType(backCardTable) 
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
		if KingCnt == 1 then
			return LandGlobalDefine.BCT_SINGLE_KING
		end

		return LandGlobalDefine.BCT_DOUBLE_KING
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
			print(k,v)
			for i,j in ipairs(v) do
				print(i,j)
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
				return LandGlobalDefine.BCT_SINGLE_LINE_SAME_COLOR ;--同花顺
			end

			if ( cbColorValue >= 3 ) then
				return LandGlobalDefine.BCT_SAME_COLOR ;--同花
			end

			if ( cbSameValue >= 3 ) then
				return LandGlobalDefine.BCT_SINGLE_LINE ;--顺子
			end			
		end
	end


	return LandGlobalDefine.BCT_ERROR
end

return GameLogicLaiZi