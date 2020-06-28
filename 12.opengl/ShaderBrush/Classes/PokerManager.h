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

	float fIntervalMin; //�˿�֮��ļ�� ������
	float fIntervalMax; //�˿�֮��ļ�� ������
	cocos2d::Size sizeAdapt;	  //�˿���Ӧ����  ���Űڷ�
	
	float fCurScale;	//���浱ǰ����ֵ
	float fCurInterval; //���浱ǰ���

};

class PokerManager :public cocos2d::Layer
{
private:
	tagUserPokerData m_tagHandPoker[POKERUSER_NUM]; //ʹ��seatOrder��Ϊ����
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
