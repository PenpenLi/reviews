-- -----------------------------------------
local MASK_VALUE = 0x0f
local MASK_COLOR = 0xf0
local VALID_CARD = 0xff
local MAX_WEAVE = 5
local MAX_WEAVECARDCOUNT = 4
local INDEX_REPLACE_CARD = VALID_CARD
local MAX_HUA_CARD = 0
local MAX_HUN_NUM = 0x06
local MAX_INDEX = 0xff
--
local WIK_NULL = 0x0000                
local WIK_LEFT = 0x0001             
local WIK_CENTER = 0x0002   
local WIK_RIGHT = 0x0004             
local WIK_PENG = 0x0008             
local WIK_MING = 0x0010             
local WIK_AN = 0x0020             
local WIK_JIA = 0x0040   
local WIK_LISTEN = 0x0080   
local WIK_HU = 0x0100             
local WIK_FANG = 0x0200   
--
local tagAnalyseItem = 
{
  cbCardEye = 0,
  bMagicEye = false,
  cbWeaveKind = {},
  cbCenterCard = {},
  cbCardData = {{}, {}, {}, {}, {}},
}
local MJ_WeaveItem = 
{
  wWeaveKind = 0,
  cbCenterCard = 0,
  wProvideUser = 0,
  wGangProvideUser = 0,
  cbCardCount = 0,
  cbCardData = {},
}
local MJ_TYPE =
{
    MJ_WAN = 0x01,
    MJ_BING = 0x02,
    MJ_TIAO = 0x03,
    MJ_FENG = 0x04,
    MJ_MAGIC = 0x05,
}

local getIntPart = function (x)
    if x<= 0 then
        return math.ceil(x)
    end
    if math.ceil(x) == x then
        x = math.ceil(x)
    else
        x = math.ceil(x)-1
    end
    return x
end

local GetCardCount = function (par_t_cardidx)
  local n_count = 0
  for i=1,table.maxn(par_t_cardidx) do
    if (par_t_cardidx[i]) then
      n_count = n_count + par_t_cardidx[i]
    end
  end
  return n_count
end

local GetWeaveCard = function (par_n_weavetype, par_n_centercard, par_t_carddata)
  local switch = {
    [WIK_LEFT] = function ()
      par_t_carddata[1] = par_n_centercard
      par_t_carddata[2] = par_n_centercard+1
      par_t_carddata[3] = par_n_centercard+2
      return 3
    end,
    [WIK_RIGHT] = function ()
      par_t_carddata[1] = par_n_centercard-2
      par_t_carddata[2] = par_n_centercard-1
      par_t_carddata[3] = par_n_centercard
      return 3
    end,
    [WIK_CENTER] = function ()
      par_t_carddata[1] = par_n_centercard-1
      par_t_carddata[2] = par_n_centercard
      par_t_carddata[3] = par_n_centercard+1
      return 3
    end,
    [WIK_PENG] = function ()
      par_t_carddata[1] = par_n_centercard
      par_t_carddata[2] = par_n_centercard
      par_t_carddata[3] = par_n_centercard
      return 3
    end,
    [WIK_MING] = function ()
      par_t_carddata[1] = par_n_centercard
      par_t_carddata[2] = par_n_centercard
      par_t_carddata[3] = par_n_centercard
      par_t_carddata[4] = par_n_centercard
      return 4
    end,
    [WIK_AN] = function ()
      par_t_carddata[1] = par_n_centercard
      par_t_carddata[2] = par_n_centercard
      par_t_carddata[3] = par_n_centercard
      par_t_carddata[4] = par_n_centercard
      return 4
    end,
    [WIK_JIA] = function ()
      par_t_carddata[1] = par_n_centercard
      par_t_carddata[2] = par_n_centercard
      par_t_carddata[3] = par_n_centercard
      par_t_carddata[4] = par_n_centercard
      return 4
    end,
  }
  local func_ = switch[par_n_weavetype]
  if (func_) then

  end
end

local getVal = function(par_n_mj)
  return bit.band(par_n_mj,MASK_VALUE)
end

local getType = function(par_n_mj)
  local n_temp = bit.band(par_n_mj, MASK_COLOR) 
  return bit.rshift(n_temp, 4) + 1 
end

local getFind = function(par_t_, par_x_vale)
  -- body
  local b_find = false
  for k,v in pairs(par_t_) do
    if (v == par_x_vale) then
      b_find = true
      break
    end
  end
  return b_find
end

local getConcat = function(par_t_proto, par_t_add)
  -- body
  for i,v in pairs(par_t_add) do
    par_t_proto[#par_t_proto + 1] = v
  end
end

local getModNeedNum = function(par_n_arrlen, par_b_isjiang)
  --
  if (par_n_arrlen < 0) then
    return 0
  end
  local modNum = par_n_arrlen%3
  local needNumArr = {0, 2, 1}
  if (par_b_isjiang) then
    needNumArr[1] = 2
    needNumArr[2] = 1
    needNumArr[3] = 0
  end
  return needNumArr[modNum+1]
end

local test3Combine = function(par_n_m1, par_n_m2, par_n_m3)
  -- body
  local t1 = getType(par_n_m1)
  local t2 = getType(par_n_m2)
  local t3 = getType(par_n_m3)
  if (t1 ~= t2 or t1 ~= t3) then
    return false
  end
  -- madan
  local v1 = getVal(par_n_m1)
  local v2 = getVal(par_n_m2)
  local v3 = getVal(par_n_m3)
  if (v1 == v2 and v1 == v3) then
    return true
  end
  if (t3 == MJ_TYPE.MJ_FENG) then
    return false
  end
  if (v1+1 == v2 and v1+2 == v3) then
    return true
  end
  return false
end

local test2Combine = function(par_n_m1, par_n_m2)
  --
  local t1 = getType(par_n_m1)
  local t2 = getType(par_n_m2)
  local v1 = getVal(par_n_m1)
  local v2 = getVal(par_n_m2)
  if (t1 == t2 and v1 == v2) then
    return true
  end
  return false;
end

local isPingHu = function (par_t_cardidx, par_n_maxidx)
  -- body
  local n_tempindexj = nil
  local t_tempidx = {}
  for i=1,par_n_maxidx do
    if (nil == par_t_cardidx[i]) then return end
    if (par_t_cardidx[i] > 1) then
      for j=1,par_n_maxidx do
        t_tempidx[j] = par_t_cardidx[j]
      end
      t_tempidx[i] = t_tempidx[i] - 2
      local isHu = true
      for j=1,par_n_maxidx do
        if (t_tempidx[j] == 0) then
        elseif (t_tempidx[j] == 1) then 
              n_tempindexj = j - 1
              if (n_tempindexj%9>6 or n_tempindexj>3*9-1) then 
                isHu = false
                break
              elseif (t_tempidx[j+1]>0 and t_tempidx[j+2]>0) then
                t_tempidx[j] = t_tempidx[j] - 1
                t_tempidx[j+1] = t_tempidx[j+1] - 1
                t_tempidx[j+2] = t_tempidx[j+2] - 1
              else
                isHu = false
                break
              end
        elseif (t_tempidx[j] == 2) then
              n_tempindexj = j - 1
              if (n_tempindexj%9>6 or n_tempindexj>3*9-1) then 
                isHu = false
                break
              elseif (t_tempidx[j+1]>1 and t_tempidx[j+2]>1) then
                t_tempidx[j] = t_tempidx[j] - 2
                t_tempidx[j+1] = t_tempidx[j+1] - 2
                t_tempidx[j+2] = t_tempidx[j+2] - 2
              else
                isHu = false
                break
              end
        elseif (t_tempidx[j] == 3) then
              t_tempidx[j] = t_tempidx[j]  - 3
        elseif (t_tempidx[j] == 4) then
              n_tempindexj = j - 1
              if (n_tempindexj%9>6 or n_tempindexj>3*9-1) then 
                isHu = false
                break
              elseif (t_tempidx[j+1]>0 and t_tempidx[j+2]>0) then
                t_tempidx[j] = t_tempidx[j] - 4
                t_tempidx[j+1] = t_tempidx[j+1] - 1
                t_tempidx[j+2] = t_tempidx[j+2] - 1
              else
                isHu = false
                break
              end
        end
        if (t_tempidx[j] ~= 0 and isHu) then return true end
      end
    end
  end
end

local isCardHu = function (par_t_cardidx, par_n_maxidx)
  -- body
  return isPingHu(par_t_cardidx, par_n_maxidx)
end

-- -------------------------------------------------------------------------
local GameLogic = class("GameLogic")

function GameLogic:getSort(par_t_data)
    -- cc.exports.myutils.sortTable(par_t_data, nil, true)
    return table.sort(par_t_data, function(first, second)
      if first < second then
        return true
      end
      if first > second then
        return false
      end
      return false
    end)
end

function GameLogic:seprateArr(par_t_mjvec, par_n_hunmj)
  -- body
  local retArr = {}
  local ht = getType(par_n_hunmj)
  local hv = getVal(par_n_hunmj)

  -- heihei -------------------
  for i,value in ipairs(par_t_mjvec) do
    local t = getType(value)
    local v = getVal(value)
    if (ht == t and hv == v) then 
      -- caishen
      t = 5
    end 
    -- save --------
    if (nil == retArr[t]) then
      retArr[t] = {}
    end
    retArr[t][#retArr[t]+1] = value
    -- sort -------
    self:getSort(retArr[t])
  end
  -- return
  return retArr
end

function GameLogic:isValidCard(par_n_carddata)
  if (par_n_carddata == nil or type(par_n_carddata) ~= "number") then 
    return false
  end
  local n_value = bit.band(par_n_carddata, MASK_VALUE)
  local n_temp = bit.band(par_n_carddata, MASK_COLOR) 
  local n_color = bit.rshift(n_temp, 4)
  local b_return = (n_value >= 1 and n_value <= 9 and n_color <= 2) 
                or (n_value >= 1 and n_value <= 7 and n_color == 3) 
                or (n_value >= 1 and n_value <= 8 and n_color == 4) 
  return b_return
end

function GameLogic:switchToCardIndex(par_n_carddata)
  if (self:isValidCard(par_n_carddata)) then
    local n_value = bit.band(par_n_carddata, MASK_VALUE)
    local n_temp = bit.band(par_n_carddata, MASK_COLOR) 
    return bit.rshift(n_temp, 4) * 9 + n_value - 1
  end
  return VALID_CARD
end

function GameLogic:switchToCardData(par_n_cardindex)
  local n_result = VALID_CARD
  if (27 > par_n_cardindex) then
    local n_temp1 = (par_n_cardindex%9 + 1)
    local n_temp2 = bit.lshift(getIntPart(par_n_cardindex/9), 4) 
    n_result = bit.bor(n_temp1, n_temp2)
    return n_result
  end
  if (34 > par_n_cardindex) then
    local n_temp1 = (par_n_cardindex - 27 + 1)
    n_result = bit.bor(n_temp1, (0x30) )
    return n_result
  end
  if (42 > par_n_cardindex) then --34 ->0x38
    -- n_result =  bit.bor(par_n_cardindex - 34 + 1, 0x40)
    local n_value = bit.lshift( getIntPart(par_n_cardindex / 9), 4)
    local temp = par_n_cardindex % 9 + 1
    n_result = bit.bor(temp, n_value)
    return n_result
  end
  return n_result
end

----------------------------------
function GameLogic:AnalyseChiHuCard(par_t_cardidx, par_n_maxidx, par_t_weaveitem, par_n_weavecount, par_n_currentcard, par_n_magicidx)
  -- body
  local wChiHuKind = nil
  local AnalyseItemArray = {}

  local cbCardIndexTemp = {}
  for i=1,par_n_maxidx do
    cbCardIndexTemp[i] = par_t_cardidx[i]
  end

  if (par_n_currentcard == 0) then
    return false
  end
  -- charu, add 1 ,then save
  local n_currentcardindex = self:switchToCardIndex(par_n_currentcard) 
  cbCardIndexTemp[n_currentcardindex + 1] = cbCardIndexTemp[n_currentcardindex + 1] + 1
  self:AnalyseCard(cbCardIndexTemp, par_n_maxidx, par_t_weaveitem, par_n_weavecount, AnalyseItemArray, true, par_n_magicidx)

  -- daye
  if(#AnalyseItemArray==0)then
    return false
  end
  return true
end

function GameLogic:AnalyseCard(par_t_cardidx, par_n_maxidx, par_t_weaveitem, par_n_weavecount, par_yt_analysearray, par_b_tingchanel, par_n_magicidx)
  -- count 
  local cbCardCount = GetCardCount(par_t_cardidx)
  -- check count
  if (cbCardCount<2 or cbCardCount>par_n_maxidx or (par_n_maxidx-2)%3~=0) then
    return false
  end
  -- define variable
  local cbKindItemCount = 0
  local KindItem = {}
  -- judge demand 
  local cbLessKindItem = getIntPart((cbCardCount-2)/3)
  local n_tempindexi = nil
  -- dandiao
  if (0 == cbLessKindItem) then
    -- card eye
    for i=1,par_n_maxidx do
      n_tempindexi = i - 1
      if ((par_n_magicidx ~= par_n_maxidx and par_n_magicidx ~= n_tempindexi and par_t_cardidx[par_n_maxidx+1]+par_t_cardidx[i]==2)
        or(par_t_cardidx[i] == 2)) then
        -- define variable
        local tagAnalyseItem = {}
        tagAnalyseItem.cbWeaveKind = {}
        tagAnalyseItem.cbCenterCard = {}
        tagAnalyseItem.cbCardData = {}
        -- setting result
        for j=1,par_n_weavecount do
          tagAnalyseItem.cbWeaveKind[j] = par_t_weaveitem[i].cbWeaveKind
          tagAnalyseItem.cbCenterCard[j] = par_t_weaveitem[j].cbCenterCard
          tagAnalyseItem.cbCardData[j] = {}
          for k=1,MAX_WEAVECARDCOUNT do
            tagAnalyseItem.cbCardData[j][k] = par_t_weaveitem[j].cbCenterCard[k]
          end
        end
        tagAnalyseItem.cbCardEye = switchToCardData(n_tempindexi)
        if (par_t_cardidx[i] == 2 or n_tempindexi == par_n_magicidx) then
          tagAnalyseItem.bMagicEye = true
        else
          tagAnalyseItem.bMagicEye = false
        end
        -- insert result
        par_yt_analysearray[#par_yt_analysearray + 1] = tagAnalyseItem
        return true
      end
    end
    return false
  end
  -- split analyse
  local cbMagicCardIndex = {}
  for i=1,par_n_maxidx do
    cbMagicCardIndex[i] = par_t_cardidx[i]
  end
  -- have magic card 
  local cbMagicCardCount = 0
  if (par_n_magicidx ~= par_n_maxidx) then
    cbMagicCardCount = par_t_cardidx[par_n_magicidx+1]
    if (INDEX_REPLACE_CARD ~= par_n_maxidx and INDEX_REPLACE_CARD ~= INVLIAD_CARD) then
      cbMagicCardIndex[par_n_maxidx+1] = cbMagicCardIndex[INDEX_REPLACE_CARD]
      cbMagicCardIndex[INDEX_REPLACE_CARD] = cbMagicCardCount
    end
  end
  -- what 
  if (cbCardCount >= 3) then
    for i=1,par_n_maxidx-MAX_HUA_CARD do
      n_tempindexi = i - 1
      if (cbMagicCardIndex[i] >= 3 or (cbMagicCardIndex[i]+cbMagicCardCount >= 3 and 
        ( (INDEX_REPLACE_CARD~=par_n_maxidx and n_tempindexi~=INDEX_REPLACE_CARD) or 
          (INDEX_REPLACE_CARD==par_n_maxidx) and n_tempindexi~=par_n_magicidx ) )) then
        -- miaomiaomia
        local nTempIndex = cbMagicCardIndex[i]
        while (nTempIndex+cbMagicCardCount >= 3) do
          local cbIndex = i - 1
          local cbCenterCard = switchToCardData(n_tempindexi)
          -- caishen replace
          if (n_tempindexi == par_n_magicidx and INDEX_REPLACE_CARD ~= par_n_maxidx and INDEX_REPLACE_CARD ~= INVALID_CARD) then
             cbIndex = INDEX_REPLACE_CARD
             cbCenterCard = switchToCardData(INDEX_REPLACE_CARD)
          end
          KindItem[cbKindItemCount].cbWeaveKind=WIK_PENG
          KindItem[cbKindItemCount].cbCenterCard=cbCenterCard
          KindItem[cbKindItemCount].cbValidIndex[1]=cbIndex
          KindItem[cbKindItemCount].cbValidIndex[2]=cbIndex
          KindItem[cbKindItemCount].cbValidIndex[3]=cbIndex
          if (nTempIndex > 0) then
            KindItem[cbKindItemCount].cbValidIndex[1]=nTempIndex
            KindItem[cbKindItemCount].cbValidIndex[2]=nTempIndex
            KindItem[cbKindItemCount].cbValidIndex[3]=nTempIndex
          end
          cbKindItemCount = cbKindItemCount + 1
          -- if magic exit
          if (n_tempindexi == INDEX_REPLACE_CARD or (n_tempindexi == par_n_magicidx 
            and (INDEX_REPLACE_CARD == par_n_maxidx or INDEX_REPLACE_CARD == INVALID_CARD) )) then
            break
          end
          nTempIndex = nTempIndex - 3
          if (nTempIndex == 0) then
            break
          end
        end
        -- lianpai judge
        if ((i<(par_n_magicidx-MAX_HUA_CARD-9))and((n_tempindexi%9)<7)) then 
          -- wo qu nidaye de 
          if (cbMagicCardCount+cbMagicIndex[i]+cbMagicIndex[i+1]+cbMagicIndex[i+2]>=3) then
            local cbIndex = {cbMagicIndex[i], cbMagicIndex[i+1], cbMagicIndex[i+2]}
            local cbMagicCountTemp = cbMagicCardCount
            local cbValidIndex = {0, 0, 0}
            while (cbMagicCountTemp+cbIndex[1]+cbIndex[2]+cbIndex[3]>=3) do
              for j=1,#cbIndex do
                local n_tempindexj = j-1
                if (cbIndex[j]>0) then
                  cbIndex[j] = cbIndex[j] - 1
                  cbValidIndex[j] = n_tempindexi+n_tempindexj
                  if (n_tempindexi+n_tempindexj==par_n_maxidx and INDEX_REPLACE_CARD~=par_n_maxidx and INDEX_REPLACE_CARD ~= INVALID_CARD) then
                    cbValidIndex[j] = INDEX_REPLACE_CARD
                  end
                else
                  nMagicCountTemp = nMagicCountTemp - 1
                  cbValidIndex[j] = par_n_magicidx
                end
              end
              -- 
              if (nMagicCountTemp >= 0) then
                KindItem[cbKindItemCount] = {}
                KindItem[cbKindItemCount].cbWeaveKind=WIK_LEFT
                KindItem[cbKindItemCount].cbCenterCard=switchToCardData(n_tempindexi)
                KindItem[cbKindItemCount].cbValidIndex = {}
                for j=1,3 do
                  KindItem[cbKindItemCount].cbValidIndex[j] = cbValidIndex[j]
                end
                cbKindItemCount = cbKindItemCount + 1
              else
                break
              end
            end
          end
        end
      end
    end
  end
  -- combination analyse
  if (cbKindItemCount>=cbLessKindItem) then
    -- define variable
    local cbCardIndexTemp = {}
    local cbIndex = {} -- max_weave
    for i=1,MAX_WEAVE do
      cbIndex[i] = i - 1
    end
    local pKindItem = {} 
    local n_kinditem = #KindItem
    local KindItemTemp = {}
    if (par_n_magicidx ~= par_n_maxidx) then
      for k,v in pairs(KindItem) do
        KindItemTemp[k] = v
      end
    end
    -- start combination
    while (true) do 
      for k,v in pairs(par_t_cardidx) do
        cbCardIndexTemp[k] = v
      end
      cbMagicIndex = 0
      if (par_n_magicidx ~= par_n_maxidx) then
        for k,v in pairs(KindItemTemp) do
          KindItem[k] = v
        end
      end
      for i=1,cbLessKindItem do         -- yin yong
        pKindItem[i] = KindItem[cbIndex[i]]
      end
      --judge number 
      local bEnoughCard = true
      for i=1,cbLessKindItem*3 do
        local n_tempindexi = i - 1
        local cbCardIndex = pKindItem[getIntPart(n_tempindexi/3)].cbValidIndex[n_tempindexi%3]
        if (cbCardIndexTemp[cbCardIndex]==0) then
          if (par_n_magicidx~=par_n_maxidx and cbCardIndexTemp[par_n_maxidx]>0) then
            cbCardIndexTemp[par_n_magicidx] = cbCardIndexTemp[par_n_magicidx] - 1
            pKindItem[getIntPart(n_tempindexi/3)].cbValidIndex[n_tempindexi%3] = par_n_magicidx
          else
            bEnoughCard = false
            break
          end
        else
          cbCardIndexTemp[cbCardIndex] = cbCardIndexTemp[cbCardIndex] - 1
        end
      end
      --judge hu
      if (true == bEnoughCard) then
        -- judge card eye
        local cbCardEye = 0
        local bMagicEye = false
        if (GetCardCount(cbCardIndexTemp) == 2) then
          for i=1,par_n_maxidx-MAX_HUA_CARD do
            local n_tempindexi = i - 1
            if (cbCardIndexTemp[i]==2) then
              cbCardEye = switchToCardData(n_tempindexi)
              if (par_n_magicidx ~= par_n_maxidx and par_n_magicidx == n_tempindexi) then
                bMagicEye = true
              end
              break
            elseif (n_tempindexi ~= par_n_magicidx and par_n_magicidx ~= par_n_maxidx
              and cbCardIndexTemp[i]+cbCardIndexTemp[par_n_magicidx] == 2) then
              cbCardEye = switchToCardData(n_tempindexi)
              bMagicEye = true
            end
          end
        end
        -- combination type
        if (cbCardEye ~= 0) then
          local AnalyseItem = {}
          AnalyseItem.cbWeaveKind = {}
          AnalyseItem.cbCenterCard = {}
          AnalyseItem.cbCardData = {}
          for i=1,par_n_weavecount do
            AnalyseItem.cbWeaveKind[i]=WeaveItem[i].wWeaveKind
            AnalyseItem.cbCenterCard[i]=WeaveItem[i].cbCenterCard
            AnalyseItem.cbCardData[i] = {}
            GetWeaveCard(WeaveItem[i].wWeaveKind,WeaveItem[i].cbCenterCard,AnalyseItem.cbCardData[i])
          end
          -- setting cardtype
          for i=1,cbLessKindItem do
            AnalyseItem.cbWeaveKind[i+cbWeaveCount]=pKindItem[i].cbWeaveKind
            AnalyseItem.cbCenterCard[i+cbWeaveCount]=pKindItem[i].cbCenterCard
            AnalyseItem.cbCardData[i+cbWeaveCount] = {}
            AnalyseItem.cbCardData[i+cbWeaveCount][1] = switchToCardData(pKindItem[i].cbValidIndex[1])
            AnalyseItem.cbCardData[i+cbWeaveCount][2] = switchToCardData(pKindItem[i].cbValidIndex[2])
            AnalyseItem.cbCardData[i+cbWeaveCount][3] = switchToCardData(pKindItem[i].cbValidIndex[3]) 
          end
          -- setting cardeye
          AnalyseItem.cbCardEye = cbCardEye
          AnalyseItem.bMagicEye = bMagicEye
          -- insert result
          par_yt_analysearray[#AnalyseItemArray+1] = AnalyseItem
          if (par_b_tingchanel) then
            return true
          end
        end
      end
      -- set index
      if (cbIndex[cbLessKindItem-1]==cbKindItemCount-1) then
        local b_exist = false
        if (cbLessKindItem > 0) then
          for i=cbLessKindItem,2,-1 do
            if (cbIndex[i-1]+1 ~= cbIndex[i]) then
              local cbNewIndex = cbIndex[i-1]
              for j=i-1,cbLessKindItem do
                cbIndex[j] = cbNewIndex+j-i+2
              end
              b_exist = true
              break
            end
          end
          if (false == b_exist) then
            break
          end
        else
          cbIndex[cbLessKindItem-1] = bIndex[cbLessKindItem-1] + 1
        end
      end
    end
  end
  -- return
  return #par_yt_analysearray > 0
end

function GameLogic:getHuGainArr(par_t_mjvec, par_n_hunmj)
  -- body
  local tingVec = {}
  local vecArr = self:seprateArr(par_t_mjvec, par_n_hunmj)
  -- for k,v in pairs(vecArr) do
  --   print(k,v)
  --   for kk,vv in pairs(v) do
  --     print(kk,vv)
  --   end
  -- end
  -- magic 
  local ndHunArr = {}
  for i=1,4 do
    local needHunNum = MAX_HUN_NUM
    if (nil == vecArr[i]) then
      vecArr[i] = {}
    end
    needHunNum = self:getNeedHunInSub(vecArr[i], needHunNum, 0)
    ndHunArr[#ndHunArr+1] = needHunNum
  end
  -- for k,v in pairs(ndHunArr) do
  --   print(k,v)
  -- end
  -- printInfo("XXXXXXXXXXX-HEHE--------------began")
  -- for k,v in pairs(vecArr) do
  --   print(k,v)
  --   for kk,vv in pairs(v) do
  --     print(kk,vv)
  --   end
  -- end
  -- cheng pu magic
  local jdHunArr = {}
  for i=1,4 do
    local needHunNum = MAX_HUN_NUM
    needHunNum = self:getJiangNeedHum(vecArr[i])
    jdHunArr[#jdHunArr+1] = needHunNum
  end
  -- for k,v in pairs(jdHunArr) do
  --   print(k,v)
  -- end
  -- printInfo("XXXXXXXXXXX---------------began")
  -- for k,v in pairs(vecArr) do
  --   print(k,v)
  --   for kk,vv in pairs(v) do
  --     print(kk,vv)
  --   end
  -- end
  -- wtf
  local parArr = {}
  local wan = {0x01, 0x09}
  local bing = {0x11, 0x19}
  local tiao = {0x21, 0x29}
  local feng = {0x31, 0x37}
  parArr[#parArr+1] = wan
  parArr[#parArr+1] = bing
  parArr[#parArr+1] = tiao
  parArr[#parArr+1] = feng
  -- if dandiao
  local curHunNum = 0
  if (vecArr[MJ_TYPE.MJ_MAGIC]) then
    curHunNum = #vecArr[MJ_TYPE.MJ_MAGIC]
  end
  local needNum = 0x00
  for i=1,4 do
    needNum = needNum + ndHunArr[i]
  end
  if (curHunNum - needNum == 1) then
    for k,v in pairs(parArr) do
      for i=v[1],v[2] do
        tingVec[#tingVec+1] = i
      end
    end
    return tingVec
  end
  -- gouride
  for i=1,4 do
    needNum = 0
    for j=1,4 do
      if (i~=j) then
        needNum = needNum + ndHunArr[j]
      end
    end
    -- 
    if (needNum <= curHunNum) then
      for k=parArr[i][1],parArr[i][2] do
        local tmpVec = {}
        tmpVec[1] = k
        getConcat(tmpVec, vecArr[i])
        self:getSort(tmpVec)
        -- for kx,v in pairs(tingVec) do
        --   print(kx,v)
        -- end
        -- print(string.format("injiangdex-------heheda,%d,%d,%d", k, curHunNum, needNum))
        if (false == getFind(tingVec, k) and self:canHu(curHunNum-needNum,tmpVec)) then
          tingVec[#tingVec+1] = k
        end
      end
    end
    -- ting pu
    for j=1,4 do
      if (i ~= j) then
        needNum = 0
        for k=1,4 do
          if (i ~= k) then
            if (k == j) then
              needNum = needNum + jdHunArr[k]
            else
              needNum = needNum + ndHunArr[k]
            end
          end
        end
        -- printInfo(string.format("INGDESX-------------%d, %d", curHunNum, needNum));
        if (needNum <= curHunNum) then
          for k=parArr[i][1],parArr[i][2] do
            -- for kx,v in pairs(tingVec) do
            --   print(kx,v)
            -- end
            -- print("index-------heheda" .. tostring(k))

            if (false == getFind(tingVec, k)) then
              local tmpVec = {}
              tmpVec[1] = k
              getConcat(tmpVec, vecArr[i])
              self:getSort(tmpVec)
              local needHunNum = MAX_HUN_NUM
              needHunNum = self:getNeedHunInSub(tmpVec, needHunNum, 0)
              -- printInfo(string.format("tingpu-------------%d, %d", needHunNum, curHunNum-needNum))

              if (needHunNum <= curHunNum-needNum) then
                tingVec[#tingVec+1] = k
              end
            end
          end
        end
      end
    end
  end
  -- malege goubide 
  if (#tingVec > 0 and (false == getFind(tingVec, par_n_hunmj)) ) then
    tingVec[#tingVec+1] = par_n_hunmj
  end
  return tingVec
end

function GameLogic:getNeedHunInSub(par_yt_subarr, par_yn_needhnum, par_n_hnum)
  --   local par_yt_subarr = {}
  -- for k,v in pairs(par_yt_subarr_const) do
  --   par_yt_subarr[k] = v
  -- end
  -- ss
  if (par_yn_needhnum == 0) then
    return par_yn_needhnum
  end
  local lArr = #par_yt_subarr
  if ((par_n_hnum+getModNeedNum(lArr,false))>=par_yn_needhnum) then
    return par_yn_needhnum
  end
  -- judging -------------------------------------
  if (lArr == 0) then
    par_yn_needhnum = math.min(par_n_hnum, par_yn_needhnum)
  elseif (lArr == 1) then
    par_yn_needhnum = math.min(par_n_hnum+2, par_yn_needhnum)
  elseif (lArr == 2) then
    local t = getType(par_yt_subarr[1])
    local v0 = getVal(par_yt_subarr[1])
    local v1 = getVal(par_yt_subarr[2])
    -- 
    if (t == MJ_TYPE.MJ_FENG) then
      if (v0 == v1) then
        par_yn_needhnum = math.min(par_n_hnum+1, par_yn_needhnum)
        return par_yn_needhnum
      end
    else
      if (v1-v0 < 3) then
        par_yn_needhnum = math.min(par_n_hnum+1, par_yn_needhnum)
        return par_yn_needhnum
      end
    end
  elseif (lArr >= 3) then
    local t = getType(par_yt_subarr[1])
    local v0 = getVal(par_yt_subarr[1])
    local modNeed = getModNeedNum(lArr-3,false)
    -- first & othertwo
    for i=2,lArr do
      if (par_n_hnum + modNeed >= par_yn_needhnum) then
        break
      end
      -- 
      local v1 = getVal(par_yt_subarr[i])
      if (v1 - v0 > 1) then
        break
      end 
      if (i+2 < lArr + 1 and getVal(par_yt_subarr[i+2]) == v1) then
        -- continue
      elseif (i + 1 < lArr + 1) then
        local m0 = par_yt_subarr[1]
        local m1 = par_yt_subarr[i]
        local m2 = par_yt_subarr[i+1]
        if (test3Combine(m0, m1, m2)) then
          table.remove(par_yt_subarr, 1)
          table.remove(par_yt_subarr, i-1)
          table.remove(par_yt_subarr, i-1)
          par_yn_needhnum = self:getNeedHunInSub(par_yt_subarr, par_yn_needhnum, par_n_hnum)
          par_yt_subarr[#par_yt_subarr+1] = m0
          par_yt_subarr[#par_yt_subarr+1] = m1
          par_yt_subarr[#par_yt_subarr+1] = m2
          self:getSort(par_yt_subarr)
        end
      end
    end -- for end
    -- first & second
    local v1 = getType(par_yt_subarr[2])
    modNeed = getModNeedNum(lArr-2, false)
    if (par_n_hnum + modNeed + 1 < par_yn_needhnum) then
      if (t == MJ_TYPE.MJ_FENG) then
        if (v0 == v1) then
          local m0 = par_yt_subarr[1]
          local m1 = par_yt_subarr[2]
          table.remove(par_yt_subarr, 1)
          table.remove(par_yt_subarr, 1)
          par_yn_needhnum = self:getNeedHunInSub(par_yt_subarr, par_yn_needhnum, par_n_hnum+1)
          par_yt_subarr[#par_yt_subarr+1] = m0
          par_yt_subarr[#par_yt_subarr+1] = m1
          self:getSort(par_yt_subarr)
        end
      else 
        for i=2,lArr do
          if (par_n_hnum+modNeed+1 >= par_yn_needhnum) then
            break
          end
          local v1 = getVal(par_yt_subarr[i])
          -- if .. miaomiaomi de
          local b_continue = false
          if (i+1 ~= lArr + 1) then
            local v2 = getVal(par_yt_subarr[i+1])
            if (v1 == v2) then
              -- continue;
              b_continue = true
            end
          end
          -- 
          if (b_continue) then
          else
            local minus = v1-v0
            if (minus < 3) then
              local m0 = par_yt_subarr[1]
              local m1 = par_yt_subarr[i]
              table.remove(par_yt_subarr, 1)
              table.remove(par_yt_subarr, i-1)
              par_yn_needhnum = self:getNeedHunInSub(par_yt_subarr, par_yn_needhnum, par_n_hnum+1)
              par_yt_subarr[#par_yt_subarr+1] = m0
              par_yt_subarr[#par_yt_subarr+1] = m1
              self:getSort(par_yt_subarr)
              if (minus >= 1) then
                break
              end
            else
              break
            end
          end
        end
      end
    end
    -- self pu
    if ((par_n_hnum+getModNeedNum(lArr-1,false)+2) < par_yn_needhnum) then
      local tmp = par_yt_subarr[1]
      table.remove(par_yt_subarr, 1)
      par_yn_needhnum = self:getNeedHunInSub(par_yt_subarr, par_yn_needhnum, par_n_hnum+2)
      par_yt_subarr[#par_yt_subarr+1] = tmp
      self:getSort(par_yt_subarr)
    end
  end
  return par_yn_needhnum
end

function GameLogic:getJiangNeedHum(par_yt_subarr)
  -- local par_yt_subarr = {}
  -- for k,v in pairs(par_yt_subarr_const) do
  --   par_yt_subarr[k] = v
  -- end
  -- 
  local minNeedNum = MAX_HUN_NUM
  local arrLen = #par_yt_subarr
  if (arrLen <= 0) then
    return 2
  end
  -- ririri
  for i=1,arrLen do
    -- if last 
    if (i == arrLen) then
      local m0 = par_yt_subarr[i]
      table.remove(par_yt_subarr, i)
      local needHunNum = MAX_HUN_NUM
      needHunNum = self:getNeedHunInSub(par_yt_subarr, needHunNum, 0)
      minNeedNum = math.min(minNeedNum, needHunNum+1)
      par_yt_subarr[#par_yt_subarr+1] = m0
      self:getSort(par_yt_subarr)
    else
      -- not last ---------------------------
      if ((i+2)==(arrLen+1) or (getVal(par_yt_subarr[i])~=getVal(par_yt_subarr[i+2]))) then
        if (test2Combine(par_yt_subarr[i], par_yt_subarr[i+1])) then
          local m0 = par_yt_subarr[i]
          local m1 = par_yt_subarr[i+1]
          table.remove(par_yt_subarr, i)
          table.remove(par_yt_subarr, i)
          local needHunNum = MAX_HUN_NUM
          needHunNum = self:getNeedHunInSub(par_yt_subarr, needHunNum, 0)
          minNeedNum = math.min(minNeedNum, needHunNum)
          par_yt_subarr[#par_yt_subarr+1] = m0
          par_yt_subarr[#par_yt_subarr+1] = m1
          self:getSort(par_yt_subarr)
        end
      end
      if (getVal(par_yt_subarr[i]) ~= getVal(par_yt_subarr[i+1])) then
        local m0 = par_yt_subarr[i]
        table.remove(par_yt_subarr, i)
        local needHunNum = MAX_HUN_NUM
        needHunNum = self:getNeedHunInSub(par_yt_subarr, needHunNum, 0)
        minNeedNum = math.min(minNeedNum, needHunNum+1)
        par_yt_subarr[#par_yt_subarr+1] = m0
        self:getSort(par_yt_subarr)
      end
    end
  end -- for end
  return minNeedNum
end

function GameLogic:canHu(par_n_hunnum, par_yt_subarr)
  -- body
  local arrLen = #par_yt_subarr
  if (arrLen <= 0) then
      return par_n_hunnum >= 2;
  end
  if (par_n_hunnum < getModNeedNum(arrLen,true)) then
      return false
  end
  -- for ni daye
  for i=1,arrLen do
    if (i == arrLen) then
      if (par_n_hunnum > 0) then
        local m0 = par_yt_subarr[i]
        par_n_hunnum = par_n_hunnum-1
        table.remove(par_yt_subarr, i)
        local needHunNum = MAX_HUN_NUM
        needHunNum = self:getNeedHunInSub(par_yt_subarr, needHunNum, 0)
        if (needHunNum <= par_n_hunnum) then
          par_yt_subarr[#par_yt_subarr+1] = m0
          self:getSort(par_yt_subarr)
          return true
        end
        par_n_hunnum = par_n_hunnum+1
        par_yt_subarr[#par_yt_subarr+1] = m0
        self:getSort(par_yt_subarr)
      end
    else
      -- else ni daye
      if (((i+1)==arrLen or (getVal(par_yt_subarr[i])~=getVal(par_yt_subarr[i+2]))) ) then
        if (test2Combine(par_yt_subarr[i], par_yt_subarr[i+1])) then
          local m0 = par_yt_subarr[i]
          local m1 = par_yt_subarr[i+1]
          table.remove(par_yt_subarr, i)
          table.remove(par_yt_subarr, i)
          local needHunNum = MAX_HUN_NUM
          needHunNum = self:getNeedHunInSub(par_yt_subarr, needHunNum, 0)
          if (needHunNum <= par_n_hunnum) then
            par_yt_subarr[#par_yt_subarr+1] = m0
            par_yt_subarr[#par_yt_subarr+1] = m1
            self:getSort(par_yt_subarr)
            return true
          end
          par_yt_subarr[#par_yt_subarr+1] = m0
          par_yt_subarr[#par_yt_subarr+1] = m1
          self:getSort(par_yt_subarr)
        end
      end
      -- bingle
      if (par_n_hunnum>0 and (getVal(par_yt_subarr[i])~=getVal(par_yt_subarr[i+1])) ) then
        local m0 = par_yt_subarr[i]
        par_n_hunnum = par_n_hunnum-1
        table.remove(par_yt_subarr,i)
        local needHunNum = MAX_HUN_NUM
        needHunNum = self:getNeedHunInSub(par_yt_subarr, needHunNum, 0)
        if (needHunNum <= par_n_hunnum) then
          par_yt_subarr[#par_yt_subarr+1] = m0
          self:getSort(par_yt_subarr)
          return true
        end
        par_n_hunnum = par_n_hunnum + 1
        par_yt_subarr[#par_yt_subarr+1] = m0
        self:getSort(par_yt_subarr)
      end
    end
  end -- for end
  --
  return false
end

function GameLogic:getHuData(par_t_handcard, par_n_magicdata, par_t_stype)
  local t_tempsortcard = {}
  for k,v in pairs(par_t_handcard) do
    t_tempsortcard[k] = v
  end
  GameLogic:getSort(t_tempsortcard)
  -- normal
  local t_gainarr = {}
  for i=1,#t_tempsortcard do
    local v = t_tempsortcard[i]
    if (GameLogic:isValidCard(v)) then
      t_gainarr[#t_gainarr+1] = v
    end
  end
  -- -------------------------------------------------------------------
  local t_tingarr = GameLogic:getHuGainArr(t_gainarr,par_n_magicdata)
  GameLogic:isHuQidui(par_t_handcard, t_tingarr)
  
  -- 
  return t_tingarr
end

function GameLogic:isHuQidui( par_t_handcard , par_t_tingarr)
  if (par_t_handcard and #par_t_handcard ~= 13) then
    return false
  end
  -- 
  local t_handcardidx = {}
  for k,v in pairs(par_t_handcard) do
      local n_tempindex = v --GameLogic:switchToCardIndex(v) + 1
      if not t_handcardidx[n_tempindex] then 
        t_handcardidx[n_tempindex] = 0
      end
      t_handcardidx[n_tempindex] = t_handcardidx[n_tempindex] + 1
  end
  --
  local t_index = {}
  for k,v in pairs(t_handcardidx) do
    if v and (v == 1 or v == 3) then
      table.insert(t_index, k)
    end
  end
  if #t_index > 1 then
    return false
  end
  --
  table.insert(par_t_tingarr, t_index[1])
end

return GameLogic





















































