//  dpmj_logic.h
//

#ifndef WZMJ__GameLogic_h
#define WZMJ__GameLogic_h

#include <vector>
#include "wzmj_define.h"
#include "Array.h"

using namespace std;

WZMJ__NAMESPACE_BEGIN

#define MAX_RIGHT_COUNT 2
#define MAX_NUM 136
#define MAX_KIND    0x05
#define MAX_HUN_NUM 0x06

#define	INDEX_REPLACE_CARD	MAX_INDEX
#define WZMJ__MAX_HUA_CARD		0			//花牌个数

//分析子项 暂时未改动
struct tagAnalyseItem
{
    BYTE	cbCardEye;							//牌眼扑克
    bool    bMagicEye;                          //牌眼是否是王霸
    BYTE	cbWeaveKind[MAX_WEAVE];				//组合类型
    BYTE	cbCenterCard[MAX_WEAVE];			//中心扑克
    BYTE    cbCardData[MAX_WEAVE][4];           //实际扑克
};

//类型子项
struct tagKindItem
{
    short	cbWeaveKind;						//组合类型
    BYTE	cbCenterCard;						//中心扑克
    BYTE	cbValidIndex[3];					//实际扑克索引
};

//数组说明
typedef CWHArray<tagAnalyseItem,tagAnalyseItem &> CAnalyseItemArray;


class GameLogic
{
private:
	static GameLogic* m_gameInstance;
	GameLogic();
	~GameLogic();
    void resetGameData();
//    bool isValidCard(BYTE cbCardData);
    void onAnalyzeGangCard(const BYTE cardData[MAX_COUNT],BYTE moCardData,const CPGItem cpgItem[MAX_WEAVE],BYTE cbCPGCount,tagGangCardResult& gangCardResult);
	std::vector<int> getHuCardIdxs(const CARD cardDatas[MAX_COUNT], CARD notContain = 0xFF);

public:
    bool isValidCard(BYTE cbCardData);
    static GameLogic* getInstance();
    BYTE switchToCardData(BYTE cbCardIndex);
    BYTE switchToCardIndex(BYTE cbCardData);
    void destroy();
 	bool isListenCard(const CARD cardDatas[MAX_COUNT], std::unordered_map<int, std::vector<int> >& outListenCard);
    
    bool AnalyseChiHuCard(const BYTE cardIdexTemp[MAX_INDEX], const MJ_WeaveItem weaveItem[], BYTE weaveCount, BYTE cbCurrentCard);
    
    //分析扑克
    bool AnalyseCard(const BYTE cbCardIndex[MAX_INDEX], const MJ_WeaveItem WeaveItem[], BYTE cbWeaveICount, CAnalyseItemArray & AnalyseItemArray,bool bTingChannel=false);
    
    BYTE GetCardCount(const BYTE cbCardIndex[MAX_INDEX]);
    
    //组合扑克
    BYTE GetWeaveCard(BYTE cbWeaveKind, BYTE cbCenterCard, BYTE cbCardBuffer[4]);
    
    
    
public:
    enum MJ_TYPE
    {
        MJ_WAN = 0x1,
        MJ_BING,
        MJ_TIAO,
        MJ_FENG
    };
    //测试胡牌
    bool testHu(const vector<BYTE> &mjVec , BYTE hunMj);
    //获取摸到哪些牌能胡牌
    vector<BYTE> getHuGainArr(const vector<BYTE> &mjVec, BYTE hunMj);
    //获取打出去哪些牌能够听牌
    vector<BYTE> getTingDelArr(const vector<BYTE> &mjVec, BYTE hunMj);
    void resetCallTime() {m_callTime = 0;}
    int getCallTime() {return m_callTime;}
private:
    vector<vector<BYTE>> seprateArr(const vector<BYTE> &mjArr, BYTE hunMj) ;
    
    bool test3Combine(BYTE m1,BYTE m2, BYTE m3);
    
    bool test2Combine(BYTE m1,BYTE m2);
    
    //按个数至少需要的癞子
    BYTE getModNeedNum(BYTE arrLen , bool isJiang);
    
    //成为整扑需要的癞子
    void getNeedHunInSub(vector<BYTE> &subArr , BYTE &needHNum , BYTE hNum);
    
    //将在里面成扑需要的癞子
    BYTE getJiangNeedHum(vector<BYTE> &subArr);
    
    //
    bool canHu(BYTE hunNum , vector<BYTE> &subArr);
    
    BYTE getVal(BYTE mj)
    {
        return mj&MASK_VALUE;
    }
    
    BYTE getType(BYTE mj)
    {
        return ((mj&MASK_COLOR) >> 4) + 1;
    }
    
public:
    static const BYTE mjData[MAX_NUM];
    
private:
    int m_callTime;
};

NAMESPACE_END

#endif
