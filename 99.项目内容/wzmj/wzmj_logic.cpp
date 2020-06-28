//  GameLogic.cpp
//  Created by imac on 2016-9-12

#include "wzmj_logic.h"
#include "HallManager.h"
#include "wzmj_table.h"
//using namespace std;

WZMJ__NAMESPACE_BEGIN
GameLogic* GameLogic::m_gameInstance = nullptr;

static bool isCardHu(CARD cardIdxs[MAX_INDEX], int cardCount);
static bool isCard7Dui(CARD cardIdxs[MAX_INDEX], int cardCount);
//static bool isCardShiSanYao(CARD cardIdxs[MAX_INDEX], int cardCount);
static bool isPingHu(CARD cardIdxs[MAX_INDEX]);

/*
#define CountArray(Array) (sizeof(Array)/sizeof(Array[0]))
#define MASK_CHI_HU_RIGHT 0x0fffffff
//构造函数
CChiHuRight::CChiHuRight()
{
    memset( m_dwRight, 0, sizeof(m_dwRight) );
    
    if( !m_bInit )
    {
        m_bInit = true;
        for( BYTE i = 0; i < CountArray(m_dwRightMask); i++ )
        {
            if( 0 == i )
                m_dwRightMask[i] = 0;
            else
                m_dwRightMask[i] = (DWORD(pow((double)2, (double)(i - 1)))) << 28;
        }
    }
}

//赋值符重载
CChiHuRight & CChiHuRight::operator = ( DWORD dwRight )
{
    DWORD dwOtherRight = 0;
    //验证权位
    if( !IsValidRight( dwRight ) )
    {
        //验证取反权位
        ////ASSERT( IsValidRight( ~dwRight ) );
        if( !IsValidRight( ~dwRight ) ) return *this;
        dwRight = ~dwRight;
        dwOtherRight = MASK_CHI_HU_RIGHT;
    }
    
    for( BYTE i = 0; i < CountArray(m_dwRightMask); i++ )
    {
        if( (dwRight&m_dwRightMask[i]) || (i==0&&dwRight<0x10000000) )
            m_dwRight[i] = dwRight&MASK_CHI_HU_RIGHT;
        else m_dwRight[i] = dwOtherRight;
    }
    
    return *this;
}

//与等于
CChiHuRight & CChiHuRight::operator &= ( DWORD dwRight )
{
    bool bNavigate = false;
    //验证权位
    if( !IsValidRight( dwRight ) )
    {
        //验证取反权位
        ////ASSERT( IsValidRight( ~dwRight ) );
        if( !IsValidRight( ~dwRight ) ) return *this;
        //调整权位
        DWORD dwHeadRight = (~dwRight)&0xF0000000;
        DWORD dwTailRight = dwRight&MASK_CHI_HU_RIGHT;
        dwRight = dwHeadRight|dwTailRight;
        bNavigate = true;
    }
    
    for( BYTE i = 0; i < CountArray(m_dwRightMask); i++ )
    {
        if( (dwRight&m_dwRightMask[i]) || (i==0&&dwRight<0x10000000) )
        {
            m_dwRight[i] &= (dwRight&MASK_CHI_HU_RIGHT);
        }
        else if( !bNavigate )
            m_dwRight[i] = 0;
    }
    
    return *this;
}

//或等于
CChiHuRight & CChiHuRight::operator |= ( DWORD dwRight )
{
    //验证权位
    if( !IsValidRight( dwRight ) ) return *this;
    
    for( BYTE i = 0; i < CountArray(m_dwRightMask); i++ )
    {
        if( (dwRight&m_dwRightMask[i]) || (i==0&&dwRight<0x10000000) )
        {
            m_dwRight[i] |= (dwRight&MASK_CHI_HU_RIGHT);
            break;
        }
    }
    
    return *this;
}

//与
CChiHuRight CChiHuRight::operator & ( DWORD dwRight )
{
    CChiHuRight chr = *this;
    return (chr &= dwRight);
}

//与
CChiHuRight CChiHuRight::operator & ( DWORD dwRight ) const
{
    CChiHuRight chr = *this;
    return (chr &= dwRight);
}

//或
CChiHuRight CChiHuRight::operator | ( DWORD dwRight )
{
    CChiHuRight chr = *this;
    return chr |= dwRight;
}

//或
CChiHuRight CChiHuRight::operator | ( DWORD dwRight ) const
{
    CChiHuRight chr = *this;
    return chr |= dwRight;
}

//相等
bool CChiHuRight::operator == ( DWORD dwRight ) const
{
    CChiHuRight chr;
    chr = dwRight;
    return (*this)==chr;
}

//相等
bool CChiHuRight::operator == ( const CChiHuRight chr ) const
{
    for( WORD i = 0; i < CountArray( m_dwRight ); i++ )
    {
        if( m_dwRight[i] != chr.m_dwRight[i] ) return false;
    }
    return true;
}

//不相等
bool CChiHuRight::operator != ( DWORD dwRight ) const
{
    CChiHuRight chr;
    chr = dwRight;
    return (*this)!=chr;
}

//不相等
bool CChiHuRight::operator != ( const CChiHuRight chr ) const
{
    return !((*this)==chr);
}

//是否权位为空
bool CChiHuRight::IsEmpty()
{
    for( BYTE i = 0; i < CountArray(m_dwRight); i++ )
        if( m_dwRight[i] ) return false;
    return true;
}

//设置权位为空
void CChiHuRight::SetEmpty()
{
    memset( m_dwRight,0, sizeof(m_dwRight) );
    return;
}

//获取权位数值
BYTE CChiHuRight::GetRightData( DWORD dwRight[], BYTE cbMaxCount )
{
    ////ASSERT( cbMaxCount >= CountArray(m_dwRight) );
    if( cbMaxCount < CountArray(m_dwRight) ) return 0;
    
    memcpy( dwRight,m_dwRight,sizeof(DWORD)*CountArray(m_dwRight) );
    return CountArray(m_dwRight);
}

//设置权位数值
bool CChiHuRight::SetRightData( const DWORD dwRight[], BYTE cbRightCount )
{
    ////ASSERT( cbRightCount <= CountArray(m_dwRight) );
    if( cbRightCount > CountArray(m_dwRight) ) return false;
    
    memset( m_dwRight,0,sizeof(m_dwRight) );
    memcpy( m_dwRight,dwRight,sizeof(DWORD)*cbRightCount );
    
    return true;
}

//检查仅位是否正确
bool CChiHuRight::IsValidRight( DWORD dwRight )
{
    DWORD dwRightHead = dwRight & 0xF0000000;
    for( BYTE i = 0; i < CountArray(m_dwRightMask); i++ )
        if( m_dwRightMask[i] == dwRightHead ) return true;
    return false;
}


*/

GameLogic::GameLogic()
{
}

GameLogic::~GameLogic()
{
}

void GameLogic::resetGameData()
{

}

bool GameLogic::isValidCard(BYTE cbCardData)
{
    BYTE cbValue = (cbCardData&MASK_VALUE);
    BYTE cbColor = (cbCardData&MASK_COLOR) >> 4;
    return (((cbValue >= 1) && (cbValue <= 9) && (cbColor <= 2)) || ((cbValue >= 1) && (cbValue <= 7) && (cbColor == 3)));
}

BYTE GameLogic::switchToCardData(BYTE cbCardIndex)
{
    if (cbCardIndex >= MAX_INDEX) return 0x40;
    if (cbCardIndex < 27)
        return ((cbCardIndex / 9) << 4) | (cbCardIndex % 9 + 1);
    else return (0x30 | (cbCardIndex - 27 + 1));
}

BYTE GameLogic::switchToCardIndex(BYTE cbCardData)
{
    if (isValidCard(cbCardData))
        return ((cbCardData&MASK_COLOR) >> 4) * 9 + (cbCardData&MASK_VALUE) - 1;
    else
        return MAX_INDEX;
}

void GameLogic::onAnalyzeGangCard(const CARD cardData[MAX_COUNT],CARD moCardData,const CPGItem cpgItem[MAX_WEAVE],BYTE cbCPGCount,tagGangCardResult& gangCardResult)
{
    //申明数据
    BYTE gangCount = 0;
    memset(&gangCardResult, 0, sizeof(tagGangCardResult));
    
    //转换数据
    BYTE cbCardindex[MAX_INDEX];
    memset(cbCardindex, 0, MAX_INDEX*sizeof(BYTE));
    for (int i = 0; i < MAX_COUNT; i++)
    {
        if (cardData[i] != INVALID_CARD)
        {
            BYTE index = switchToCardIndex(cardData[i]);
            cbCardindex[index] += 1;
        }
    }
    
    //判断暗杠
    for (int i = 0; i < MAX_INDEX; i++)
    {
        if(cbCardindex[i] == 4)
        {
            gangCount += 1;
            gangCardResult.cbGangCount = gangCount;
            gangCardResult.cbCardData[gangCount-1] = switchToCardData(i);
        }
    }
    
    //判断加杠
    if (moCardData != INVALID_CARD)
    {
        for (int i = 0; i < cbCPGCount; i++)
        {
            CPGItem item = cpgItem[i];
            if (item.wCPGKind == WIK_PENG) {
                if (item.cbCenterCard == moCardData) {
                    gangCount += 1;
                    gangCardResult.cbGangCount = gangCount;
                    gangCardResult.cbCardData[gangCount-1] = moCardData;
                }
            }
        }
    }
}

bool isCard7Dui(CARD cardIdxs[MAX_INDEX], int cardCount)
{
    if (cardCount != 14) return false;
    
    for (int i=0; i<MAX_INDEX; ++i)
    {
        if (cardIdxs[i] != 0 && cardIdxs[i] != 2 && cardIdxs[i] != 4)
        {
            return false;
        }
    }
    
    return true;
}

//bool isCardShiSanYao(CARD cardIdxs[MAX_INDEX], int cardCount)
//{
//    if (cardCount != 14) return false;
//    
//    for (int i=0; i<MAX_INDEX; ++i)
//    {
//        if (i<3*9)
//        {
//            if ((i%9==0 || i%9==8)) // 符合条件
//            {
//                if (cardIdxs[i] == 0 || cardIdxs[i] > 2)
//                    return false;
//            }
//            else
//            {
//                if (cardIdxs[i] != 0)
//                    return false;
//            }
//            
//        }
//        else
//        {
//            if (cardIdxs[i] == 0 || cardIdxs[i] > 2)
//                return false;
//        }
//    }
//    
//    return true;
//}

bool isPingHu(CARD cardIdxs[MAX_INDEX])
{
    CARD tempIdxs[MAX_INDEX];
    for(int i=0;i<MAX_INDEX;i++)
    {
        //出各种对子，依次判断剩下的牌是否成牌
        if (cardIdxs[i] > 1)
        {
            memcpy(tempIdxs, cardIdxs, sizeof(CARD)*MAX_INDEX);
            
            tempIdxs[i] -= 2;
            bool isHu = true;
            for (int j=0; j<MAX_INDEX; ++j)
            {
                if (tempIdxs[j] == 0) continue;
                else if (tempIdxs[j] == 1)
                {
                    if (j%9>6 || j>(3*9-1)) { isHu=false; break;}
                    else if(tempIdxs[j+1]>0 && tempIdxs[j+2]>0)
                    {
                        tempIdxs[j]--;
                        tempIdxs[j+1]--;
                        tempIdxs[j+2]--;
                    }
                    else { isHu=false; break; }
                }
                else if (tempIdxs[j] == 2)
                {
                    if (j%9>6 || j>(3*9-1)) { isHu=false; break;}
                    else if(tempIdxs[j+1]>1 && tempIdxs[j+2]>1)
                    {
                        tempIdxs[j]-=2;
                        tempIdxs[j+1]-=2;
                        tempIdxs[j+2]-=2;
                    }
                    else { isHu=false; break; }
                }
                else if (tempIdxs[j] == 3)
                {
                    tempIdxs[j]-=3;
                }
                else if (tempIdxs[j] == 4)
                {
                    if (j%9>6 || j>(3*9-1)) { isHu=false; break;}
                    else if(tempIdxs[j+1]>0 && tempIdxs[j+2]>0)
                    {
                        tempIdxs[j]-=4;
                        tempIdxs[j+1]--;
                        tempIdxs[j+2]--;
                    }
                    else { isHu=false; break; }
                }
            }
            
            if (isHu) return true;
        }
    }
    
    return false;
}

bool isCardHu(CARD cardIdxs[MAX_INDEX], int cardCount)
{
    // 是否七对胡
//    if (isCard7Dui(cardIdxs, cardCount)) return true;
    
    // 是否十三幺胡
    //if (isCardShiSanYao(cardIdxs, cardCount)) return true;
    
    // 平湖
    if (isPingHu(cardIdxs)) return true;
    
    return false;
}

std::vector<int> GameLogic::getHuCardIdxs(const CARD cardDatas[MAX_COUNT], CARD notContain /* =0xFF*/)
{
    std::vector<int> huCardIdxs;
    
    int cardCount = 0;
    
    CARD cardIdxs[MAX_INDEX];
    memset(cardIdxs, 0, sizeof(cardIdxs));
    
    // 声明数据
    for (int i = 0; i < MAX_COUNT; i++)
    {
        if (cardDatas[i] != INVALID_CARD && cardDatas[i] != notContain)
        {
            BYTE index = switchToCardIndex(cardDatas[i]);
            cardIdxs[index] += 1;
            
            cardCount++;
        }
    }
    
    if (cardCount%3 != 1)
        return huCardIdxs;
    
    for (int i=0; i<MAX_INDEX; ++i)
    {
        if (cardIdxs[i] == 4) continue;
        cardIdxs[i]++;
        
        bool isHu = isCardHu(cardIdxs, cardCount);
        if (isHu)
        {
            huCardIdxs.push_back(i);
        }
        
        cardIdxs[i]--;
    }
    
    return huCardIdxs;
}

//--------------------------------------------------------------
GameLogic* GameLogic::getInstance()
{
    if (m_gameInstance == nullptr) {
        m_gameInstance = new GameLogic();
    }
    return m_gameInstance;
}

void GameLogic::destroy()
{
	delete m_gameInstance;
	m_gameInstance = nullptr;
}

bool GameLogic::isListenCard(const CARD cardDatas[MAX_COUNT], std::unordered_map<int, std::vector<int> >& outListenCard)
{
    bool isListen = false;
    int cardCount = 0;
    
    CARD cardIdxs[MAX_INDEX];
    memset(cardIdxs, 0, sizeof(cardIdxs));
    
    // 声明数据
    for (int i = 0; i < MAX_COUNT; i++)
    {
        if (cardDatas[i] != INVALID_CARD && isValidCard(cardDatas[i]))
        {
            BYTE index = switchToCardIndex(cardDatas[i]);
            cardIdxs[index] += 1;
            
            cardCount++;
        }
    }
    
    cocos2d::log("****** %d", cardCount);
    
    // 判断听牌
    for (int i=0; i<MAX_INDEX; ++i)
    {
        if (cardIdxs[i]==0) continue;
        
        cardIdxs[i]--;
        
        std::vector<int> huCard;
        for (int j=0; j<MAX_INDEX; ++j)
        {
            //过滤 万条筒 < 6
            if (j < 27 && j%9 < 5) continue;
            if (cardIdxs[j] == 4) continue;
            cardIdxs[j]++;
            
            bool isHu = isCardHu(cardIdxs, cardCount);
            
            if (isHu)
            {
                isListen |= true;
                huCard.push_back(j);
            }
            
            cardIdxs[j]--;
        }
        
        if (huCard.size()>0)
            outListenCard.emplace(i, huCard);
        
        cardIdxs[i]++;
    }
    
    return isListen;
}

bool GameLogic::AnalyseChiHuCard(const BYTE cbCardIndex[MAX_INDEX], const MJ_WeaveItem WeaveItem[], BYTE cbWeaveCount, BYTE cbCurrentCard)
{
    //变量定义
    WORD wChiHuKind=WIK_NULL;
    CAnalyseItemArray AnalyseItemArray;
    
    //设置变量
    AnalyseItemArray.RemoveAll();
//    ChiHuRight.SetEmpty();
    
    //构造扑克
    BYTE cbCardIndexTemp[MAX_INDEX];
    memcpy(cbCardIndexTemp,cbCardIndex,sizeof(cbCardIndexTemp));
    
    //cbCurrentCard一定不为0			!!!!!!!!!
    //ASSERT( cbCurrentCard != 0 );
    if( cbCurrentCard == 0 ) return WIK_NULL;
    
    //插入扑克
    if (cbCurrentCard!=0)
        cbCardIndexTemp[switchToCardIndex(cbCurrentCard)]++;
    
//    //判断是否有四个红中
//    if(cbCardIndexTemp[m_cbMagicIndex] == 4)
//    {
//        ChiHuRight |= CHR_FOUR_RED;
//        return WIK_CHI_HU;
//    }
    
//#if 0
//    //七对
//    BYTE cbHaoHua = 0;
//    if(IsQiDui(cbCardIndexTemp, cbHaoHua))
//    {
//        ChiHuRight |= CHR_QI_DUI;
//        return WIK_CHI_HU;
//    }
//#endif
    
    //分析扑克
    AnalyseCard(cbCardIndexTemp,WeaveItem,cbWeaveCount,AnalyseItemArray,true);
    
    //胡牌分析
    if (AnalyseItemArray.GetCount()>0)
    {
        wChiHuKind = WIK_HU;
    }
    
    return wChiHuKind;
}

//扑克数目
BYTE GameLogic::GetCardCount(const BYTE cbCardIndex[MAX_INDEX])
{
    //数目统计
    BYTE cbCardCount=0;
    for (BYTE i=0;i<MAX_INDEX;i++)
        cbCardCount+=cbCardIndex[i];
    return cbCardCount;
}

//分析扑克
bool GameLogic::AnalyseCard(const BYTE cbCardIndex[MAX_INDEX], const MJ_WeaveItem WeaveItem[], BYTE cbWeaveCount, CAnalyseItemArray & AnalyseItemArray,bool bTingChannel/*=false*/)
{
    auto pTempTable = (GameTable*)CHallManager::getInstance()->getBaseTable();
    
    BYTE m_cbMagicIndex = pTempTable->m_table_magicindex;
    //计算数目
    BYTE cbCardCount=GetCardCount(cbCardIndex);
    
    //效验数目
    //ASSERT((cbCardCount>=2)&&(cbCardCount<=MAX_COUNT)&&((cbCardCount-2)%3==0));
    if ((cbCardCount<2)||(cbCardCount>MAX_COUNT)||((cbCardCount-2)%3!=0))
        return false;
    
    //变量定义
    BYTE cbKindItemCount=0;
    tagKindItem KindItem[27*2+28];
    ZeroMemory(KindItem,sizeof(KindItem));
    
    //需求判断
    BYTE cbLessKindItem=(cbCardCount-2)/3;
    //ASSERT((cbLessKindItem+cbWeaveCount)==MAX_WEAVE);
    
    //单吊判断
    if (cbLessKindItem==0)
    {
        //效验参数
        //ASSERT((cbCardCount==2)&&(cbWeaveCount==MAX_WEAVE));
        
        //牌眼判断
        for (BYTE i=0;i<MAX_INDEX;i++)
        {
            if (cbCardIndex[i]==2 ||
                ( m_cbMagicIndex != MAX_INDEX && i != m_cbMagicIndex && cbCardIndex[m_cbMagicIndex]+cbCardIndex[i]==2 ) )
            {
                //变量定义
                tagAnalyseItem AnalyseItem;
                ZeroMemory(&AnalyseItem,sizeof(AnalyseItem));
                
                //设置结果
                for (BYTE j=0;j<cbWeaveCount;j++)
                {
                    AnalyseItem.cbWeaveKind[j]=WeaveItem[j].wWeaveKind;
                    AnalyseItem.cbCenterCard[j]=WeaveItem[j].cbCenterCard;
                    CopyMemory( AnalyseItem.cbCardData[j],WeaveItem[j].cbCardData,sizeof(WeaveItem[j].cbCardData) );
                }
                AnalyseItem.cbCardEye=switchToCardData(i);
                if( cbCardIndex[i] < 2 || i == m_cbMagicIndex )
                    AnalyseItem.bMagicEye = true;
                else AnalyseItem.bMagicEye = false;
                
                //插入结果
                AnalyseItemArray.Add(AnalyseItem);
                
                return true;
            }
        }
        
        return false;
    }
    
    //拆分分析
    BYTE cbMagicCardIndex[MAX_INDEX];
    CopyMemory(cbMagicCardIndex,cbCardIndex,sizeof(cbMagicCardIndex));
    //如果有财神
    BYTE cbMagicCardCount = 0;
    if( m_cbMagicIndex != MAX_INDEX )
    {
        cbMagicCardCount = cbCardIndex[m_cbMagicIndex];
        //如果财神有代替牌，财神与代替牌转换
        if( INDEX_REPLACE_CARD != MAX_INDEX )
        {
            cbMagicCardIndex[m_cbMagicIndex] = cbMagicCardIndex[INDEX_REPLACE_CARD];
            cbMagicCardIndex[INDEX_REPLACE_CARD] = cbMagicCardCount;
        }
    }
    
    if (cbCardCount>=3)
    {
        for (BYTE i=0;i<MAX_INDEX-WZMJ__MAX_HUA_CARD;i++)
        {
            //同牌判断
            //如果是财神,并且财神数小于3,则不进行组合
            if( cbMagicCardIndex[i] >= 3 || ( cbMagicCardIndex[i]+cbMagicCardCount >= 3 &&
                ( ( INDEX_REPLACE_CARD!=MAX_INDEX && i != INDEX_REPLACE_CARD ) || ( INDEX_REPLACE_CARD==MAX_INDEX && i != m_cbMagicIndex ) ) )
               )
            {
                int nTempIndex = cbMagicCardIndex[i];
                do
                {
                    //ASSERT( cbKindItemCount < CountArray(KindItem) );
                    BYTE cbIndex = i;
                    BYTE cbCenterCard = switchToCardData(i);
                    //如果是财神且财神有代替牌,则换成代替牌
                    if( i == m_cbMagicIndex && INDEX_REPLACE_CARD != MAX_INDEX )
                    {
                        cbIndex = INDEX_REPLACE_CARD;
                        cbCenterCard = switchToCardData(INDEX_REPLACE_CARD);
                    }
                    KindItem[cbKindItemCount].cbWeaveKind=WIK_PENG;
                    KindItem[cbKindItemCount].cbCenterCard=cbCenterCard;
                    KindItem[cbKindItemCount].cbValidIndex[0] = nTempIndex>0?cbIndex:m_cbMagicIndex;
                    KindItem[cbKindItemCount].cbValidIndex[1] = nTempIndex>1?cbIndex:m_cbMagicIndex;
                    KindItem[cbKindItemCount].cbValidIndex[2] = nTempIndex>2?cbIndex:m_cbMagicIndex;
                    cbKindItemCount++;
                    
                    //如果是财神,则退出
                    if( i == INDEX_REPLACE_CARD || (i == m_cbMagicIndex && INDEX_REPLACE_CARD == MAX_INDEX) )
                        break;
                    
                    nTempIndex -= 3;
                    //如果刚好搭配全部，则退出
                    if( nTempIndex == 0 ) break;
                    
                }while( nTempIndex+cbMagicCardCount >= 3 );
            }
            
            //连牌判断
            if ((i<(MAX_INDEX-WZMJ__MAX_HUA_CARD-9))&&((i%9)<7))
            {
                //只要财神牌数加上3个顺序索引的牌数大于等于3,则进行组合
                if( cbMagicCardCount+cbMagicCardIndex[i]+cbMagicCardIndex[i+1]+cbMagicCardIndex[i+2] >= 3 )
                {
                    BYTE cbIndex[3] = { cbMagicCardIndex[i],cbMagicCardIndex[i+1],cbMagicCardIndex[i+2] };
                    int nMagicCountTemp = cbMagicCardCount;
                    BYTE cbValidIndex[3];
                    while( nMagicCountTemp+cbIndex[0]+cbIndex[1]+cbIndex[2] >= 3 )
                    {
                        for( BYTE j = 0; j < CountArray(cbIndex); j++ )
                        {
                            if( cbIndex[j] > 0 ) 
                            {
                                cbIndex[j]--;
                                cbValidIndex[j] = (i+j==m_cbMagicIndex&&INDEX_REPLACE_CARD!=MAX_INDEX)?INDEX_REPLACE_CARD:i+j;
                            }
                            else 
                            {
                                nMagicCountTemp--;
                                cbValidIndex[j] = m_cbMagicIndex;
                            }
                        }
                        if( nMagicCountTemp >= 0 )
                        {
                            //ASSERT( cbKindItemCount < CountArray(KindItem) );
                            KindItem[cbKindItemCount].cbWeaveKind=WIK_LEFT;
                            KindItem[cbKindItemCount].cbCenterCard=switchToCardData(i);
                            CopyMemory( KindItem[cbKindItemCount].cbValidIndex,cbValidIndex,sizeof(cbValidIndex) );
                            cbKindItemCount++;
                        }
                        else break;
                    }
                }
            }
        }
    }
    
    //组合分析
    if (cbKindItemCount>=cbLessKindItem)
    {
        //变量定义
        BYTE cbCardIndexTemp[MAX_INDEX];
        ZeroMemory(cbCardIndexTemp,sizeof(cbCardIndexTemp));
        
        //变量定义
        BYTE cbIndex[MAX_WEAVE];
        for( BYTE i = 0; i < CountArray(cbIndex); i++ )
            cbIndex[i] = i;
        tagKindItem * pKindItem[MAX_WEAVE];
        ZeroMemory(&pKindItem,sizeof(pKindItem));
        tagKindItem KindItemTemp[CountArray(KindItem)];
        if( m_cbMagicIndex != MAX_INDEX )
            CopyMemory( KindItemTemp,KindItem,sizeof(KindItem) );
        
        //开始组合
        do
        {
            //设置变量
            CopyMemory(cbCardIndexTemp,cbCardIndex,sizeof(cbCardIndexTemp));
            cbMagicCardCount = 0;
            if( m_cbMagicIndex != MAX_INDEX )
            {
                CopyMemory( KindItem,KindItemTemp,sizeof(KindItem) );
            }
            
            for (BYTE i=0;i<cbLessKindItem;i++)
                pKindItem[i]=&KindItem[cbIndex[i]];
            
            //数量判断
            bool bEnoughCard=true;
            
            for (BYTE i=0;i<cbLessKindItem*3;i++)
            {
                //存在判断
                BYTE cbCardIndex=pKindItem[i/3]->cbValidIndex[i%3];
                if (cbCardIndexTemp[cbCardIndex]==0)
                {
                    if( m_cbMagicIndex != MAX_INDEX && cbCardIndexTemp[m_cbMagicIndex] > 0 )
                    {
                        cbCardIndexTemp[m_cbMagicIndex]--;
                        pKindItem[i/3]->cbValidIndex[i%3] = m_cbMagicIndex;
                    }
                    else
                    {
                        bEnoughCard=false;
                        break;
                    }
                }
                else cbCardIndexTemp[cbCardIndex]--;
            }
            
            //胡牌判断
            if (bEnoughCard==true)
            {
                //牌眼判断
                BYTE cbCardEye=0;
                bool bMagicEye = false;
                if( GetCardCount(cbCardIndexTemp) == 2 )
                {
                    for (BYTE i=0;i<MAX_INDEX-WZMJ__MAX_HUA_CARD;i++)
                    {
                        if (cbCardIndexTemp[i]==2)
                        {
                            cbCardEye=switchToCardData(i);
                            if( m_cbMagicIndex != MAX_INDEX && i == m_cbMagicIndex ) bMagicEye = true;
                            break;
                        }
                        else if( i!=m_cbMagicIndex &&
                                m_cbMagicIndex != MAX_INDEX && cbCardIndexTemp[i]+cbCardIndexTemp[m_cbMagicIndex]==2 )
                        {
                            cbCardEye = switchToCardData(i);
                            bMagicEye = true;
                        }
                    }
                }
                
                //组合类型
                if (cbCardEye!=0)
                {
                    //变量定义
                    tagAnalyseItem AnalyseItem;
                    ZeroMemory(&AnalyseItem,sizeof(AnalyseItem));
                    
                    //设置组合
                    for (BYTE i=0;i<cbWeaveCount;i++)
                    {
                        AnalyseItem.cbWeaveKind[i]=WeaveItem[i].wWeaveKind;
                        AnalyseItem.cbCenterCard[i]=WeaveItem[i].cbCenterCard;
                        GetWeaveCard( WeaveItem[i].wWeaveKind,WeaveItem[i].cbCenterCard,AnalyseItem.cbCardData[i] );
                    }
                    
                    //设置牌型
                    for (BYTE i=0;i<cbLessKindItem;i++) 
                    {
                        AnalyseItem.cbWeaveKind[i+cbWeaveCount]=pKindItem[i]->cbWeaveKind;
                        AnalyseItem.cbCenterCard[i+cbWeaveCount]=pKindItem[i]->cbCenterCard;
                        AnalyseItem.cbCardData[cbWeaveCount+i][0] = switchToCardData(pKindItem[i]->cbValidIndex[0]);
                        AnalyseItem.cbCardData[cbWeaveCount+i][1] = switchToCardData(pKindItem[i]->cbValidIndex[1]);
                        AnalyseItem.cbCardData[cbWeaveCount+i][2] = switchToCardData(pKindItem[i]->cbValidIndex[2]);
                    }
                    
                    //设置牌眼
                    AnalyseItem.cbCardEye=cbCardEye;
                    AnalyseItem.bMagicEye = bMagicEye;
                    
                    //插入结果
                    AnalyseItemArray.Add(AnalyseItem);
                    if(bTingChannel) return true;
                }
            }
            
            //设置索引
            if (cbIndex[cbLessKindItem-1]==(cbKindItemCount-1))
            {
                BYTE i = 0;
                for (i=cbLessKindItem-1;i>0;i--)
                {
                    if ((cbIndex[i-1]+1)!=cbIndex[i])
                    {
                        BYTE cbNewIndex=cbIndex[i-1];
                        for (BYTE j=(i-1);j<cbLessKindItem;j++) 
                            cbIndex[j]=cbNewIndex+j-i+2;
                        break;
                    }
                }
                if (i==0)
                    break;
            }
            else
                cbIndex[cbLessKindItem-1]++;
        } while (true);
        
    }
    
    return (AnalyseItemArray.GetCount()>0);
    
}

//获取组合
BYTE GameLogic::GetWeaveCard(BYTE cbWeaveKind, BYTE cbCenterCard, BYTE cbCardBuffer[4])
{
    //组合扑克
    switch (cbWeaveKind)
    {
        case WIK_LEFT:		//上牌操作 左吃
        {
            //设置变量
            cbCardBuffer[0]=cbCenterCard;
            cbCardBuffer[1]=cbCenterCard+1;
            cbCardBuffer[2]=cbCenterCard+2;
            
            return 3;
        }
        case WIK_RIGHT:		//上牌操作 右吃
        {
            //设置变量
            cbCardBuffer[0]=cbCenterCard-2;
            cbCardBuffer[1]=cbCenterCard-1;
            cbCardBuffer[2]=cbCenterCard;
            
            return 3;
        }
        case WIK_CENTER:	//上牌操作 中吃
        {
            //设置变量
            cbCardBuffer[0]=cbCenterCard-1;
            cbCardBuffer[1]=cbCenterCard;
            cbCardBuffer[2]=cbCenterCard+1;
            
            return 3;
        }
        case WIK_PENG:		//碰牌操作
        {
            //设置变量
            cbCardBuffer[0]=cbCenterCard;
            cbCardBuffer[1]=cbCenterCard;
            cbCardBuffer[2]=cbCenterCard;
            
            return 3;
        }
        case WIK_MING:		//杠牌操作
        case WIK_AN:
        case WIK_JIA:
        {
            //设置变量
            cbCardBuffer[0]=cbCenterCard;
            cbCardBuffer[1]=cbCenterCard;
            cbCardBuffer[2]=cbCenterCard;
            cbCardBuffer[3]=cbCenterCard;
            
            return 4;
        }
        default:
        {
            ////ASSERT(FALSE);
        }
    }
    
    return 0;
}


/////////////////////////////////////////////////////////



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

vector<vector<BYTE>> GameLogic::seprateArr(const vector<BYTE>& mjArr, BYTE hunMj)
{
    vector<vector<BYTE>> retArr;
    retArr.resize(MAX_KIND);
    auto ht = getType(hunMj);
    auto hv = getVal(hunMj);
    
    for (auto& mj : mjArr)
    {
        auto t = getType(mj);
        auto v = getVal(mj);
        
        if (ht == t && hv == v)
        {
            t = 0;
        }
        
        retArr[t].push_back(mj);
        sort(retArr[t].begin(), retArr[t].end());
    }
    
    return retArr;
}


bool GameLogic::test3Combine(BYTE m1,BYTE m2, BYTE m3)
{
    auto t1 = getType(m1);
    auto t2 = getType(m2);
    auto t3 = getType(m3);
    
    if (t1 != t2 || t1 != t3)
    {
        return false;
    }
    
    auto v1 = getVal(m1);
    auto v2 = getVal(m2);
    auto v3 = getVal(m3);
    
    if (v1 == v2 && v1 == v3)
    {
        return true;
    }
    
    if (t3 == MJ_FENG)
    {
        return false;
    }
    
    if (v1 + 1 == v2 && v1 + 2 == v3)
    {
        return true;
    }
    
    return false;
}

bool GameLogic::test2Combine(BYTE m1,BYTE m2)
{
    auto t1 = getType(m1);
    auto t2 = getType(m2);
    
    auto v1 = getVal(m1);
    auto v2 = getVal(m2);
    if (t1 == t2 && v1 == v2)
        return true;
    return false;
}

BYTE GameLogic::getModNeedNum(BYTE arrLen , bool isJiang)
{
    if (arrLen < 0)
    {
        return 0;
    }
    
    auto modNum = arrLen % 3;
    BYTE needNumArr[3] = { 0, 2, 1 };
    if (isJiang)
    {
        needNumArr[0] = 2;
        needNumArr[1] = 1;
        needNumArr[2] = 0;
    }
    return needNumArr[modNum];
}

void GameLogic::getNeedHunInSub(vector<BYTE> &subArr , BYTE &needHNum , BYTE hNum)
{
    m_callTime++;
    
    if(needHNum == 0) 
    {
        return; 
    }
    
    BYTE lArr = subArr.size();
    
    if((hNum + getModNeedNum(lArr,false)) >= needHNum)
    {
        return;
    }
    
    if(lArr == 0)
    {
        needHNum = min(hNum,needHNum);
    }
    else if(lArr == 1)
    {
        needHNum = min((BYTE)(hNum+2),needHNum);
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
                needHNum = min((BYTE)(hNum+1), needHNum );
                return;
            }
        }
        else
        {
            if(v1 - v0 < 3)
            {
                needHNum = min((BYTE)(hNum+1), needHNum );
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


BYTE GameLogic::getJiangNeedHum(vector<BYTE> &subArr)
{
    BYTE minNeedNum = MAX_HUN_NUM;
    BYTE arrLen = subArr.size();
    if(arrLen <= 0)
    {
        return 2;
    }
    
    for(BYTE i=0; i<arrLen ; i++)
    {
        if(i == arrLen-1)
        {
            BYTE m0 = subArr[i];
            subArr.erase(subArr.begin()+i);
            
            BYTE needHunNum = MAX_HUN_NUM;
            getNeedHunInSub(subArr,needHunNum,0);
            minNeedNum = min(minNeedNum,((BYTE)(needHunNum+1)));
            
            subArr.push_back(m0);
            sort(subArr.begin(), subArr.end());
        }
        else
        {
            if((i+2) == arrLen || ( getVal(subArr[i]) != getVal(subArr[i+2])))
            {
                if(test2Combine(subArr[i], subArr[i+1]))
                {
                    BYTE m0 = subArr[i];
                    BYTE m1 = subArr[i+1];
                    subArr.erase(subArr.begin()+i);
                    subArr.erase(subArr.begin()+i);
                    
                    BYTE needHunNum = MAX_HUN_NUM;
                    getNeedHunInSub(subArr,needHunNum,0);
                    minNeedNum = min(minNeedNum,needHunNum);
                    
                    subArr.push_back(m0);
                    subArr.push_back(m1);
                    sort(subArr.begin(), subArr.end());
                }
            }
            
            if(getVal(subArr[i]) != getVal(subArr[i+1]))
            {
                BYTE m0 = subArr[i];
                subArr.erase(subArr.begin()+i);
                
                BYTE needHunNum = MAX_HUN_NUM;
                getNeedHunInSub(subArr,needHunNum,0);
                minNeedNum = min(minNeedNum,((BYTE)(needHunNum+1)));
                
                subArr.push_back(m0);
                sort(subArr.begin(), subArr.end());
            }
            
        }
        
    }
    
    return minNeedNum;
}

bool GameLogic::canHu(BYTE hunNum , vector<BYTE> &subArr)
{
    BYTE arrLen = subArr.size();
    if (arrLen <= 0)
    {
        return hunNum >= 2;
    }
    
    if (hunNum < getModNeedNum(arrLen,true))
    {
        return false;
    }
    
    for (BYTE i=0; i<arrLen; i++)
    {
        if(i == arrLen-1)
        {
            if(hunNum > 0)
            {
                BYTE m0 = subArr[i];
                hunNum = hunNum-1;
                subArr.erase(subArr.begin()+i);
                BYTE needHunNum = MAX_HUN_NUM;
                getNeedHunInSub(subArr, needHunNum, 0);
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
        else
        {
            if((i+2) == arrLen || ( getVal(subArr[i]) != getVal(subArr[i+2])))
            {
                if(test2Combine(subArr[i], subArr[i+1]))
                {
                    BYTE m0 = subArr[i];
                    BYTE m1 = subArr[i+1];
                    subArr.erase(subArr.begin()+i);
                    subArr.erase(subArr.begin()+i);
                    BYTE needHunNum = MAX_HUN_NUM;
                    getNeedHunInSub(subArr, needHunNum, 0);
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
            
            if(hunNum > 0 && (getVal(subArr[i]) != getVal(subArr[i+1])))
            {
                BYTE m0 = subArr[i];
                hunNum = hunNum-1;
                subArr.erase(subArr.begin()+i);
                BYTE needHunNum = MAX_HUN_NUM;
                getNeedHunInSub(subArr, needHunNum, 0);
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

bool GameLogic::testHu(const vector<BYTE> &mjVec , BYTE hunMj)
{
    auto vecArr = seprateArr(mjVec, hunMj);
    BYTE curHunNum = vecArr[0].size();
    
    if (curHunNum == MAX_HUN_NUM)
    {
        return true;
    }
    
    vector<BYTE> ndHunArr;
    for(BYTE i=1 ; i< 5;i++)
    {
        BYTE needHunNum = MAX_HUN_NUM;
        getNeedHunInSub(vecArr[i], needHunNum, 0);
        ndHunArr.push_back(needHunNum);
    }
    
    bool isHu = false;
    //万
    BYTE subNeedHunAll = ndHunArr[1] + ndHunArr[2] + ndHunArr[3];
    if (subNeedHunAll <= curHunNum)
    {
        BYTE hasHunNum = curHunNum - subNeedHunAll;
        isHu = canHu(hasHunNum, vecArr[1]);
        if(isHu)
        {
            return true;
        }
    }
    
    //饼
    subNeedHunAll = ndHunArr[0] + ndHunArr[2] + ndHunArr[3];
    if (subNeedHunAll <= curHunNum)
    {
        BYTE hasHunNum = curHunNum - subNeedHunAll;
        isHu = canHu(hasHunNum, vecArr[2]);
        if(isHu)
        {
            return true;
        }
    }
    
    //条
    subNeedHunAll = ndHunArr[0] + ndHunArr[1] + ndHunArr[3];
    if (subNeedHunAll <= curHunNum)
    {
        BYTE hasHunNum = curHunNum - subNeedHunAll;
        isHu = canHu(hasHunNum, vecArr[3]);
        if(isHu)
        {
            return true;
        }
    }
    
    
    //风
    subNeedHunAll = ndHunArr[0] + ndHunArr[1] + ndHunArr[2];
    if (subNeedHunAll <= curHunNum)
    {
        BYTE hasHunNum = curHunNum - subNeedHunAll;
        isHu = canHu(hasHunNum, vecArr[4]);
        if(isHu)
        {
            return true;
        }
    }
    return false;
}


vector<BYTE> GameLogic::getHuGainArr(const vector<BYTE> &mjVec, BYTE hunMj)
{
    vector<BYTE> tingVec;
    auto vecArr = seprateArr(mjVec, hunMj);
    
    //成扑需要的癞子
    vector<BYTE> ndHunArr;
    for(BYTE i=1 ; i< 5;i++)
    {
        BYTE needHunNum = MAX_HUN_NUM;
        getNeedHunInSub(vecArr[i], needHunNum, 0);
        ndHunArr.push_back(needHunNum);
    }
    
    
    
    //含有将成扑需要的癞子
    vector<BYTE> jdHunArr;
    for(BYTE i=1 ; i< 5;i++)
    {
        BYTE needHunNum = getJiangNeedHum(vecArr[i]);
        jdHunArr.push_back(needHunNum);
    }
    
    vector<vector<BYTE>> parArr;
    vector<BYTE> wan {0x01,0x0A};
    vector<BYTE> bing{0x11,0x1A};
    vector<BYTE> tiao{0x21,0x2A};
    vector<BYTE> feng{0x31,0x38};
    parArr.push_back(wan);
    parArr.push_back(bing);
    parArr.push_back(tiao);
    parArr.push_back(feng);
    
    BYTE curHunNum = vecArr[0].size();
    //是否为单调将
    BYTE needNum = 0x00;
    for(BYTE i=0;i<4;i++)
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
    
    
    for(BYTE i=0 ; i < 4; i++)
    {
        //听牌是将
        needNum  = 0;
        for(BYTE j=0 ; j <4 ; j++)
        {
            if(i != j)
            {
                needNum =  needNum + ndHunArr[j];
            }
        }
        if(needNum <= curHunNum)
        {
            for(BYTE k=parArr[i][0];k <parArr[i][1];k++)
            {
                vector<BYTE> tmpVec{k};
                tmpVec.insert(tmpVec.begin(), vecArr[i+1].begin(),vecArr[i+1].end());
                sort(tmpVec.begin(), tmpVec.end());
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
                
                if(needNum <= curHunNum )
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
    
    if(tingVec.size() > 0 && (find(tingVec.begin(),tingVec.end(),hunMj) == tingVec.end()))
    {
        tingVec.push_back(hunMj);
    }
    
    return tingVec;
}


vector<BYTE> GameLogic::getTingDelArr(const vector<BYTE> &mjVec, BYTE hunMj)
{
    vector<BYTE> tingVec;
    auto vecArr = seprateArr(mjVec, hunMj);
    
    //成扑需要的癞子
    vector<BYTE> ndHunArr;
    for(BYTE i=1 ; i< 5;i++)
    {
        BYTE needHunNum = MAX_HUN_NUM;
        getNeedHunInSub(vecArr[i], needHunNum, 0);
        ndHunArr.push_back(needHunNum);
    }
    
    
    //含有将成扑需要的癞子
    vector<BYTE> jdHunArr;
    for(BYTE i=1 ; i< 5;i++)
    {
        BYTE needHunNum = getJiangNeedHum(vecArr[i]);
        jdHunArr.push_back(needHunNum);
    }
    
    
    //给一个混看能不能胡
    BYTE curHunNum = vecArr[0].size()+1;
    //是否为单调将
    BYTE needNum = 0x00;
    for(BYTE i=0;i<4;i++)
    {
        needNum += ndHunArr[i];
    }
    
    if(curHunNum - needNum == 1)
    {
        tingVec = mjVec;
        return tingVec;
    }
    
    for(BYTE i=0;i<4;i++)
    {
        set <BYTE> subTemp;
        subTemp.insert(vecArr[i+1].begin(),vecArr[i+1].end());
        for(auto x : subTemp)
        {
            auto subArrCopy = vecArr[i+1];
            auto iter = find(subArrCopy.begin(), subArrCopy.end(), x);
            subArrCopy.erase(iter);
            
            //将
            needNum = 0x00;
            for(BYTE j=0 ; j <4 ; j++)
            {
                if(i != j)
                {
                    needNum = needNum + ndHunArr[j];
                }
            }
            
            if(needNum <= curHunNum && (find(tingVec.begin(),tingVec.end(),x) == tingVec.end()))
            {
                if(canHu(curHunNum-needNum, subArrCopy))
                {
                    tingVec.push_back(x);
                }
            }
            
            // 扑
            for(BYTE j=0 ; j <4 ; j++)
            {
                if(vecArr[j+1].size() == 0)
                {
                    continue;
                }
                
                if(i != j)
                {
                    needNum = 0;
                    for(BYTE k = 0; k<4;k++)
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
                    
                    if(needNum <= curHunNum && (find(tingVec.begin(),tingVec.end(),x) == tingVec.end()))
                    {
                        BYTE needHunNum = MAX_HUN_NUM;
                        getNeedHunInSub(subArrCopy, needHunNum, 0);
                        if(needHunNum <= curHunNum - needHunNum)
                        {
                            tingVec.push_back(x);
                        }
                    }
                }
            }
            
        }
    }
    
    return tingVec;
}


NAMESPACE_END

