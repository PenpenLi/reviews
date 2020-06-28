1.麻将牌值
const BYTE GameLogic::mjData[MAX_NUM] = {
    0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09,		//万
    0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09,		//
    0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09,		//
    0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09,		//
    
    0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19,		//饼
    0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19,		//
    0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19,		//
    0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19,		//
    
    0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29,		//条
    0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29,		//
    0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29,		//
    0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29,		//
    0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,    //红中
    0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
    0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
    0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37
};
isValidCard
switchToCardData
switchToCardIndex
getSort 有小到大排序
getVal 数值
getType 花色

2.胡牌判断调用
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
  -- 去掉财神的手牌，财神数量
  local t_tingarr = GameLogic:getHuGainArr(t_gainarr,par_n_magicdata)
  GameLogic:isHuQidui(par_t_handcard, t_tingarr)
  -- 
  return t_tingarr
end

3.胡牌主要逻辑： 代码中，index索引有问题，注意使用
local MJ_TYPE = {MJ_WAN = 0x01,MJ_BING = 0x02,MJ_TIAO = 0x03,MJ_FENG = 0x04,MJ_MAGIC = 0x05,}
local MAX_HUN_NUM = 0x04
vector<BYTE> GameLogic::getHuGainArr(const vector<BYTE> &mjVec, BYTE hunMj)
{
	vector<BYTE> tingVec;

    --[[
    **vecArr = {[MJ_TYPE.MJ_WAN] = {存放牌值,且有小到大排序}, ... }
    --]]
    auto vecArr = seprateArr(mjVec, hunMj);
    auto parArr = {[MJ_TYPE.MJ_WAN] = {0x01,0x09}, ... }    

    --[[
	**判断MJ_TYPE中，每种类型成扑，需要多少财神.	//成扑需要的癞子
    --]]
    vector<BYTE> ndHunArr;
    for(BYTE i=1; i<5; i++)
    {
        BYTE needHunNum = MAX_HUN_NUM;
        getNeedHunInSub(vecArr[i], needHunNum, 0);
        ndHunArr.push_back(needHunNum);
    }
    
    --[[
	**判断MJ_TYPE中，每种类型成将，需要多少财神.   //含有将成扑需要的癞子
    --]]
    vector<BYTE> jdHunArr;
    for(BYTE i=1; i<5;i++)
    {
        BYTE needHunNum = getJiangNeedHum(vecArr[i]);
        jdHunArr.push_back(needHunNum);
    }

	--[[
	**. //是否为单调将 
	--]]
    BYTE curHunNum = vecArr[MJ_TYPE.MJ_MAGIC].size();
    BYTE needNum = 0;
    for(BYTE i=1;i<5;i++)
    {
        needNum += ndHunArr[i];
    }
    if(curHunNum - needNum == 1)
    {
        for(auto &vec : parArr)
        {
            for(BYTE i = vec[0] ; i< vec[1] ; i++)
            {
                tingVec.push_back(i);
            }
        }
        return tingVec;
    }
    
    --[[
    ** 
    --]]
    for(BYTE i=0 ; i < 4; i++) -- 听牌循环
    {
        //听牌是将
        needNum  = 0; -- 累加成扑需要癞子
        for(BYTE j=0 ; j <4 ; j++)
        {
            if(i != j)
            {
                needNum =  needNum + ndHunArr[j];
            }
        }
        if(needNum <= curHunNum) -- //听牌是将；如果还有财神，则判断i索引类型的牌
        {
            for(BYTE k=parArr[i][0];k <parArr[i][1];k++)
            {
                vector<BYTE> tmpVec{k}; -- 将k插入放在第一个位置，
                tmpVec.insert(tmpVec.begin(), vecArr[i+1].begin(),vecArr[i+1].end());
                sort(tmpVec.begin(), tmpVec.end());
                -- 添加新值k，判断是否可以胡牌。
                if((find(tingVec.begin(),tingVec.end(),k) == tingVec.end()) && canHu(curHunNum - needNum, tmpVec))
                {
                    tingVec.push_back(k);
                }
            }
        }
        //听牌是扑
        for(BYTE j=0 ; j <4 ; j++)
        {
            if(i != j)
            {
                needNum = 0;
                for(BYTE k=0 ; k <4 ; k++)
                {
                    if(k != i)
                    {
                        if(k == j)
                        {
                            needNum += jdHunArr[k];
                        }
                        else
                        {
                            needNum += ndHunArr[k];
                        }
                    }
                }
                
                if(needNum <= curHunNum ) -- //听牌是扑
                {
                    for(BYTE k=parArr[i][0];k <parArr[i][1];k++)
                    {
                        if((find(tingVec.begin(),tingVec.end(),k) == tingVec.end()))
                        {
                            vector<BYTE> tmpVec{k};
                            tmpVec.insert(tmpVec.begin(), vecArr[i+1].begin(),vecArr[i+1].end());
                            sort(tmpVec.begin(), tmpVec.end());
                            BYTE needHunNum = MAX_HUN_NUM;
                            getNeedHunInSub(tmpVec, needHunNum, 0);
                            if(needHunNum <= curHunNum - needNum)
                            {
                                tingVec.push_back(k);
                            }
                        }
                    }
                }
            }
        }
    }
    
    --[[
    ** 如果能听牌，则将财神加入听牌序列
    --]]
    if(tingVec.size() > 0 && (find(tingVec.begin(),tingVec.end(),hunMj) == tingVec.end()))
    {
        tingVec.push_back(hunMj);
    }
    return tingVec;
}

4.判断是否能胡
bool GameLogic::canHu(BYTE hunNum , vector<BYTE> &subArr)
{
    BYTE arrLen = subArr.size();
    if (arrLen <= 0)
    {
        return hunNum >= 2; --添加一个普通麻将，两张财神肯定够用
    }
    if (hunNum < getModNeedNum(arrLen,true)) 
    {
        return false; --判断牌数%3==2，看财神数目是否可以补充全
    }
    -- 逐个判断
    for (BYTE i=0; i<arrLen; i++)
    {
        if(i == arrLen-1) -- 如果是最后一张牌
        {
            if(hunNum > 0) -- 判断是否有财神
            {
                BYTE m0 = subArr[i];
                hunNum = hunNum-1;
                subArr.erase(subArr.begin()+i);
                BYTE needHunNum = MAX_HUN_NUM;
                getNeedHunInSub(subArr, needHunNum, 0); -- 去掉将，判断成扑需要的癞子数目
                if(needHunNum <= hunNum)
                {
                    subArr.push_back(m0);
                    sort(subArr.begin(), subArr.end());
                    return true;
                }
                hunNum = hunNum+1;
                subArr.push_back(m0);
                sort(subArr.begin(), subArr.end());
            }
        }
        else -- 如果不是最后一张牌
        {
            if((i+2) == arrLen || ( getVal(subArr[i]) != getVal(subArr[i+2])))
            { -- 如果最后三张；或者,如果这张和第三张牌不同; ???
                if(test2Combine(subArr[i], subArr[i+1])) -- 判断两个值是否相等
                {
                    BYTE m0 = subArr[i];
                    BYTE m1 = subArr[i+1];
                    subArr.erase(subArr.begin()+i);
                    subArr.erase(subArr.begin()+i);
                    BYTE needHunNum = MAX_HUN_NUM;
                    getNeedHunInSub(subArr, needHunNum, 0); -- 去掉将，判断成扑需要的癞子数目
                    if(needHunNum <= hunNum)
                    {
                        subArr.push_back(m0);
                        subArr.push_back(m1);
                        sort(subArr.begin(), subArr.end());
                        return true;
                    }
                    subArr.push_back(m0);
                    subArr.push_back(m1);
                    sort(subArr.begin(), subArr.end());
                }
            }
            -- 如果两张不同，并且还有财神
            if(hunNum > 0 && (getVal(subArr[i]) != getVal(subArr[i+1])))
            {
                BYTE m0 = subArr[i];
                hunNum = hunNum-1;
                subArr.erase(subArr.begin()+i); 
                BYTE needHunNum = MAX_HUN_NUM;
                getNeedHunInSub(subArr, needHunNum, 0); --财神+这张牌=将去掉，判断成扑需要的癞子数目; 
                if(needHunNum <= hunNum)
                {
                    subArr.push_back(m0);
                    sort(subArr.begin(), subArr.end());
                    return true;
                }
                hunNum = hunNum+1;
                subArr.push_back(m0);
                sort(subArr.begin(), subArr.end());
            }
        }
    }
    
    return false;
}

5.判断需要 组成扑 或 将 需要的财神数目
getNeedHunInSub(vecArr[i], needHunNum, 0);
BYTE needHunNum = getJiangNeedHum(vecArr[i]);
BYTE GameLogic::getJiangNeedHum(vector<BYTE> &subArr)
{
    BYTE minNeedNum = MAX_HUN_NUM;
    BYTE arrLen = subArr.size();
    if(arrLen <= 0)
    {
        return 2; --如果没牌，返回2
    }
    -- 遍历牌
    for(BYTE i=0; i<arrLen ; i++)
    {
        if(i == arrLen-1) -- 最后一张牌
        {
            BYTE m0 = subArr[i];
            subArr.erase(subArr.begin()+i);
            
            BYTE needHunNum = MAX_HUN_NUM;
            getNeedHunInSub(subArr,needHunNum,0); -- 去掉看成扑需要癞子数
            minNeedNum = min(minNeedNum,((BYTE)(needHunNum+1)));
            
            subArr.push_back(m0);
            sort(subArr.begin(), subArr.end());
        }
        else -- 如果不是最后一张牌
        {
            if((i+2) == arrLen || ( getVal(subArr[i]) != getVal(subArr[i+2])))
            {
                if(test2Combine(subArr[i], subArr[i+1])) -- 如果和下一张牌相同
                {
                    BYTE m0 = subArr[i];
                    BYTE m1 = subArr[i+1];
                    subArr.erase(subArr.begin()+i);
                    subArr.erase(subArr.begin()+i);
                    
                    BYTE needHunNum = MAX_HUN_NUM;
                    getNeedHunInSub(subArr,needHunNum,0); -- 去掉看成扑需要癞子数
                    minNeedNum = min(minNeedNum,needHunNum);
                    
                    subArr.push_back(m0);
                    subArr.push_back(m1);
                    sort(subArr.begin(), subArr.end());
                }
            }
            
            if(getVal(subArr[i]) != getVal(subArr[i+1])) -- 如果和下一章牌不同
            {
                BYTE m0 = subArr[i];
                subArr.erase(subArr.begin()+i);
                
                BYTE needHunNum = MAX_HUN_NUM;
                getNeedHunInSub(subArr,needHunNum,0); -- 去掉看成扑需要癞子数
                minNeedNum = min(minNeedNum,((BYTE)(needHunNum+1)));
                
                subArr.push_back(m0);
                sort(subArr.begin(), subArr.end());
            }
            
        }
        
    }   
    return minNeedNum;
}
-- 每种类型成扑，需要多少财神.  subArr一组麻将; needHNum返回需要的值; hNum = 0累加值，递归使用.
void GameLogic::getNeedHunInSub(vector<BYTE> &subArr , BYTE &needHNum , BYTE hNum)
{
    m_callTime++;
    
    if(needHNum == 0) -- 起始传入最大值 MAX_HUN_NUM
    {
        return;
    }
    
    BYTE lArr = subArr.size();
    
    if((hNum + getModNeedNum(lArr,false)) >= needHNum) -- 需要组成扑的数量%3==2，不足用财神补最少需要.
    {
        return;
    }
    
    if(lArr == 0)
    {
        needHNum = min(hNum,needHNum); -- +0
    }
    else if(lArr == 1)
    {
        needHNum = min((BYTE)(hNum+2),needHNum); -- +2
    }
    else if(lArr == 2)
    {
        BYTE t = getType(subArr[0]);
        BYTE v0  = getVal(subArr[0]);
        BYTE v1 = getVal(subArr[1]);
        
        // 东南西北中发白（无顺）
        if(t == MJ_FENG)
        {
            if(v0 == v1)
            {
                needHNum = min((BYTE)(hNum+1), needHNum ); -- peng +1
                return;
            }
        }
        else
        {
            if(v1 - v0 < 3)
            {
                needHNum = min((BYTE)(hNum+1), needHNum ); -- chi,peng +1
                return;
            }
        }
    }
    else if(lArr >=3)
    {
        BYTE t  = getType(subArr[0]);
        BYTE v0 = getVal(subArr[0]);
        
        BYTE modNeed = getModNeedNum(lArr-3, false);
        //第一个和另外两个一铺
        for (BYTE i=1; i< lArr ; i++)
        {
            if(hNum + modNeed>= needHNum)
                break;
            
            BYTE v1 = getVal(subArr[i]);
            //13444   134不可能连一起
            if(v1 - v0 > 1)
            {
                break;
            }
            
            if(i + 2 < lArr && getVal(subArr[i+2]) == v1)
            {
                continue;
            }
            
            if(i + 1 < lArr)
            {
                BYTE m0 = subArr[0];
                BYTE m1 = subArr[i];
                BYTE m2 = subArr[i+1];
                
                if(test3Combine(m0, m1, m2))
                {
                    subArr.erase(subArr.begin());
                    subArr.erase(subArr.begin()+i-1);
                    subArr.erase(subArr.begin()+i-1);
                    getNeedHunInSub(subArr, needHNum, hNum);
                    subArr.push_back(m0);
                    subArr.push_back(m1);
                    subArr.push_back(m2);
                    sort(subArr.begin(), subArr.end());
                }
            }
        }
        
        
        //第一个和第二个一铺
        BYTE v1 = getType(subArr[1]);
        modNeed = getModNeedNum(lArr-2 , false);
        if(hNum + modNeed + 1 < needHNum)
        {
            if(t == MJ_FENG)
            {
                if(v0 == v1)
                {
                    BYTE m0 = subArr[0];
                    BYTE m1 = subArr[1];
                    subArr.erase( subArr.begin());
                    subArr.erase( subArr.begin());
                    getNeedHunInSub(subArr, needHNum, hNum+1);
                    subArr.push_back(m0);
                    subArr.push_back(m1);
                    sort(subArr.begin(), subArr.end());
                }
            }
            else
            {
                for(BYTE i = 1 ; i< lArr ; i++)
                {
                    if(hNum + modNeed + 1 >= needHNum)
                    {
                        break;
                    }
                    
                    BYTE v1 = getVal(subArr[i]);
                    //如果当前的value不等于下一个value则和下一个结合避免重复
                    if((i+1) != lArr)
                    {
                        BYTE v2 = getVal(subArr[i+1]);
                        if (v1 == v2)
                        {
                            continue;
                        }
                    }
                    
                    BYTE mius = v1 - v0;
                    if  (mius < 3)
                    {
                        BYTE m0 = subArr[0];
                        BYTE m1 = subArr[i];
                        subArr.erase( subArr.begin());
                        subArr.erase( subArr.begin()+i-1);
                        getNeedHunInSub(subArr, needHNum, hNum+1);
                        subArr.push_back(m0);
                        subArr.push_back(m1);
                        sort(subArr.begin(), subArr.end());
                        if (mius >= 1)
                        {
                            break;
                        }
                    }
                    else
                    {
                        break;
                    }
                }
            }
        }
        
        //自己一铺
        if  ((hNum + getModNeedNum(lArr-1,false)+2) < needHNum)
        {
            BYTE tmp = subArr[0];
            subArr.erase( subArr.begin() );
            getNeedHunInSub( subArr, needHNum, hNum+2);
            subArr.push_back(tmp);
            sort(subArr.begin(), subArr.end());
        }
    }
}

















