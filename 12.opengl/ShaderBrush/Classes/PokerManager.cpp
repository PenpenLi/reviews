#include "PokerManager.h"
using namespace cocos2d;

PokerManager::PokerManager()
{

}

PokerManager::~PokerManager()
{

}

bool PokerManager::init()
{
	if (!Layer::init()) return false;

	auto touchListener = cocos2d::EventListenerTouchOneByOne::create();
	touchListener->onTouchBegan = CC_CALLBACK_2(PokerManager::onTouchBegan, this);
	touchListener->onTouchMoved = CC_CALLBACK_2(PokerManager::onTouchMoved, this);
	touchListener->onTouchEnded = CC_CALLBACK_2(PokerManager::onTouchEnded, this);
	_eventDispatcher->addEventListenerWithSceneGraphPriority(touchListener, this);
	initUserPokerData();

	return true;
}

PokerManager* PokerManager::create()
{
	PokerManager* pPokerManager = new(std::nothrow) PokerManager();
	if (pPokerManager && pPokerManager->init())
	{
		pPokerManager->autorelease();
		return pPokerManager;
	}
	CC_SAFE_DELETE(pPokerManager);
	return nullptr;
}

bool PokerManager::onTouchBegan(cocos2d::Touch* pTouch, cocos2d::Event* pEvent)
{
	m_ptTouchBegan = pTouch->getLocation();
	PokerSprite* pPoker = onTouchPoker(pTouch->getLocation());
	if (nullptr == pPoker) pPoker->setHandSelected(true);
	return true;
}

void PokerManager::onTouchMoved(cocos2d::Touch *pTouch, cocos2d::Event *pEvent)
{
	PokerSprite* pPoker = onTouchPoker(pTouch->getLocation());
	if (nullptr == pPoker) return; 
	onMovedPoker(pTouch->getLocation());
}

void PokerManager::onTouchEnded(cocos2d::Touch *pTouch, cocos2d::Event *pEvent)
{
	auto tagUserPoker = m_tagHandPoker[0];
	auto vectorPoker = tagUserPoker.vecPokerSprite;

	//把高亮显示的牌弹出或收回
	bool boSelected = false;
	for (int i = vectorPoker.size() - 1; i >= 0; i--)
	{
		PokerSprite* pPokerSprite = vectorPoker.at(i);
		if (pPokerSprite->isHandSelected())
		{
			pPokerSprite->setHandSelected(false);
			pPokerSprite->setHandChecked(!pPokerSprite->isHandChecked());
			boSelected = true;
		}
	}
	if (!boSelected);//cancelCardCheck();

//===========etc...........
//	if (boSelected)
//	{
//		//自动提示剩余牌
//		PokerSprite* pPoker = onTouchPoker(pt);
//		if (pPoker && pPoker->isHandSelected())   //防止重复自动选牌！
//			;//autoCheckCards(pPoker);
//	}
}

PokerSprite* PokerManager::onTouchPoker(cocos2d::Point pt)
{
	auto vectorPoker = m_tagHandPoker[0].vecPokerSprite;
	for (int i = vectorPoker.size() - 1; i >= 0; i--)
	{
		PokerSprite* temp = (PokerSprite*)vectorPoker.at(i);
		if (temp && temp->getParent() && temp->getBoundingBox().containsPoint(temp->getParent()->convertToNodeSpace(pt)))
			return temp;
	}
	return nullptr;
}

void PokerManager::onMovedPoker(cocos2d::Point pt)
{
	int maxX = m_ptTouchBegan.x > pt.x ? m_ptTouchBegan.x : pt.x;
	int minX = m_ptTouchBegan.x > pt.x ? pt.x : m_ptTouchBegan.x;
	CCLog("maxX = %d, minX = %d", maxX, minX);

	auto tagUserPoker = m_tagHandPoker[0];
	auto vectorPoker = tagUserPoker.vecPokerSprite;
	ssize_t nPokerNum = vectorPoker.size();
	if (nPokerNum < 1) return;

	for (int i = nPokerNum - 1; i >= 0; i--)
	{
		auto pPokerSprite = vectorPoker.at(i);
		Rect rectPoker = pPokerSprite->getBoundingBox();
		auto ptLayerPoker = tagUserPoker.pLayer->convertToNodeSpace(pt);
		
		bool bOnMoved = true;
		if ((ptLayerPoker.y < rectPoker.getMinY()) || (ptLayerPoker.y > rectPoker.getMaxY()))
			bOnMoved = false;
		float fOffset = tagUserPoker.fCurInterval;
		if (nPokerNum - 1 == i) fOffset = m_szPoker.width * tagUserPoker.fCurScale;
		if (minX > rectPoker.getMinX() + fOffset || maxX < rectPoker.getMaxX())
			bOnMoved = false;
		pPokerSprite->setHandSelected(bOnMoved);
	}
}

void PokerManager::initUserPokerData()
{
	/*
	cocos2d::Vector<cocos2d::Sprite*> vecPokerSprite;
	cocos2d::Layer* pLayer;

	int nSeatOrder;
	bool bEnableTouch;
	cocos2d::Vec2 vecAnchorPoint;
	cocos2d::Vec2 vecCoordinate;
	float fRotate;

	cocos2d::Size sizeAdapt;	  //扑克适应矩形  横着摆放
	float fIntervalMin; //扑克之间的间距 含正负
	float fIntervalMax; //扑克之间的间距 含正负

	float fCurScale = 0.0f;	//保存当前缩放值
	float fCurInterval = 0.0f; //保存当前间距
	*/
	m_szPoker = Sprite::create(PATH_CARDBACK)->getContentSize();

	int nHandIndex = 0;
//	m_tagHandPoker[nHandIndex++] = {  cocos2d::Vector<cocos2d::Sprite*>(0), nullptr,
//		0, true, Vec2(0.5, 0.5), Vec2(640, 100), 0.0f, Size(1000, 120), -20, -10, 0.0f, 0.0f };
	
}

void PokerManager::initUserPokerData(tagUserPokerData tagUserPoker)
{
	ssize_t nPokerNum = tagUserPoker.vecPokerSprite.size();
	cocos2d::Layer* pLayer = tagUserPoker.pLayer;
	if (nPokerNum < 0)	return;

	//根据参数计算需要的缩放值
	float fScaleY = tagUserPoker.sizeAdapt.height / m_szPoker.height;
	float fScaleX = (tagUserPoker.sizeAdapt.width - (nPokerNum - 1) / nPokerNum*tagUserPoker.fIntervalMax)
		/ m_szPoker.width;
	float fScale = fScaleX;
	if (fScaleX > fScaleY) fScale = fScaleY;

	//创建扑克所在层
	Size pokerLayerSize = tagUserPoker.sizeAdapt / fScale;
	if (pLayer == nullptr)
	{
		pLayer = cocos2d::Layer::create();
		addChild(pLayer);
		pLayer->setAnchorPoint(tagUserPoker.vecAnchorPoint);
		pLayer->setRotation(tagUserPoker.fRotate);
	}
	pLayer->setContentSize(pokerLayerSize);
	pLayer->setScale(fScale);

	//摆放扑克
	float fOffset = (m_szPoker.width * nPokerNum - pokerLayerSize.width) / (nPokerNum - 1)*fScale;
	if (fOffset < tagUserPoker.fIntervalMin) fOffset = tagUserPoker.fIntervalMin;
	if (fOffset > tagUserPoker.fIntervalMax) fOffset = tagUserPoker.fIntervalMax;
	for (int nIndex = 0; nIndex < nPokerNum; ++nIndex)
	{
		PokerSprite* pPoker = (PokerSprite*)tagUserPoker.vecPokerSprite.at(nIndex);
		pPoker->setPosition(nIndex*Vec2(-fOffset, 0) + nIndex*m_szPoker + m_szPoker / 2);
		pLayer->addChild(pPoker);
	}

	//保存当前的缩放值和间距
	tagUserPoker.fCurScale = fScale;
	tagUserPoker.fCurInterval = fOffset;
}

void PokerManager::removeAllOutPoker()
{
	for (int nIndex = 0; nIndex < POKERUSER_NUM; ++nIndex)
	{
		m_tagOutPoker[nIndex].vecPokerSprite.clear();
		m_tagOutPoker[nIndex].pLayer->removeFromParentAndCleanup(true);
		m_tagOutPoker[nIndex].pLayer = nullptr;
	}
}

void PokerManager::removeAllHandPoker()
{
	for (int nIndex = 0; nIndex < POKERUSER_NUM; ++nIndex)
	{
		m_tagHandPoker[nIndex].vecPokerSprite.clear();
		m_tagHandPoker[nIndex].pLayer->removeFromParentAndCleanup(true);
		m_tagHandPoker[nIndex].pLayer = nullptr;
	}
}

void PokerManager::showSendPoker(unsigned char nPokerIndex[], unsigned char nPokerNum)
{
	
}

void PokerManager::showOutPoker(unsigned char nPokerIndex[], unsigned char nPokerNum, unsigned char nSeatOrder)
{
	removeAllOutPoker();

	for (int nIndex = 0; nIndex < nPokerNum; ++nIndex)
	{
		PokerSprite* temp = PokerSprite::create(nPokerIndex[nIndex]);
		addChild(temp);
		m_tagOutPoker[nSeatOrder].vecPokerSprite.pushBack(temp);
	}
	initUserPokerData(m_tagOutPoker[nSeatOrder]);
}





