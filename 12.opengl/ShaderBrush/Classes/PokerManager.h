#ifndef __UIManager_WCheckList__
#define __UIManager_WCheckList__

#include <iostream>
#include "cocos2d.h"
#include "ui/CocosGUI.h"
#include "PokerSprite.h"
//#include "cocostudio/CocosGUI.h"
//#include "Cmd_Sparrow.h"

#define POKERUSER_NUM 4
#define POKER_NUM 54
typedef std::function<void(long)> func_void_long;

struct tagUserPokerData
{
	cocos2d::Vector<PokerSprite*> vecPokerSprite;
	cocos2d::Layer* pLayer;
	
	int nSeatOrder;
	bool bEnableTouch;
	cocos2d::Vec2 vecAnchorPoint;
	cocos2d::Vec2 vecCoordinate;
	float fRotate;

	float fIntervalMin; //扑克之间的间距 含正负
	float fIntervalMax; //扑克之间的间距 含正负
	cocos2d::Size sizeAdapt;	  //扑克适应矩形  横着摆放
	
	float fCurScale;	//保存当前缩放值
	float fCurInterval; //保存当前间距

};

class PokerManager :public cocos2d::Layer
{
private:
	tagUserPokerData m_tagHandPoker[POKERUSER_NUM]; //使用seatOrder作为索引
	tagUserPokerData m_tagOutPoker[POKERUSER_NUM];
	//PokerSprite* m_pPokerSprite[POKER_NUM];
	cocos2d::Point m_ptTouchBegan;
	cocos2d::Size m_szPoker;
	bool onTouchBegan(cocos2d::Touch* pTouch, cocos2d::Event* pEvent);
	void onTouchMoved(cocos2d::Touch *pTouch, cocos2d::Event *pEvent);
	void onTouchEnded(cocos2d::Touch *pTouch, cocos2d::Event *pEvent);
	PokerSprite* onTouchPoker(cocos2d::Point pt);
	void onMovedPoker(cocos2d::Point pt);
	void initUserPokerData();
	void initUserPokerData(tagUserPokerData tagUserPoker);
	void removeAllOutPoker();
	void removeAllHandPoker();
	PokerManager();
protected:
	virtual ~PokerManager();
	virtual bool init();
public:
	static PokerManager* create(); 
	void showSendPoker(unsigned char nPokerIndex[], unsigned char nPokerNum);
	void showOutPoker(unsigned char nPokerIndex[], unsigned char nPokerNum, unsigned char nSeatOrder);
};

#endif
