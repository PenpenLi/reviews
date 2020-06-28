#include "PokerSprite.h"
using namespace cocos2d;

//新牌数据结构:A:1 2:2 3:3...K:13 小王:0x4E 大王:0x4F  -服务端
//旧牌数据结构:3:1 4:2 ...K:11 A:12 2:13 小王:14 大王:15
//花色一样:方块:0 梅花:1 红桃:2 黑桃:3

unsigned char PokerSprite::getShapeByIndex(int nIndex)
{
	return (nIndex & 0xf0) >> 4;
}

unsigned char PokerSprite::getNumberByIndex(int nIndex)
{
	return (nIndex & 0x0f);
}

std::string PokerSprite::getFilePathByIndex(int nIndex, bool isOpen)
{
	std::string filename;
	if (isOpen)
		filename = StringUtils::format(PATHFORMAT_CARDINDEX, getShapeByIndex(nIndex), getNumberByIndex(nIndex));
	else
		filename = PATH_CARDBACK;
	return filename;
}

//================修改以上内容=================================
PokerSprite::PokerSprite()
{

}

PokerSprite::~PokerSprite()
{

}

bool PokerSprite::init()
{
	if (!Sprite::init())
	{
		return false;
	}

	return true;
}

PokerSprite* PokerSprite::create(int nIndex, bool isOpen)
{
	PokerSprite *pPokerSprite = new (std::nothrow) PokerSprite();
	if (pPokerSprite && pPokerSprite->initWithFile(getFilePathByIndex(nIndex, isOpen)))
	{
		pPokerSprite->m_tagPokerData.nCardIndex = nIndex;
		pPokerSprite->m_tagPokerData.isOpen = isOpen;

		pPokerSprite->autorelease();
		return pPokerSprite;
	}
	CC_SAFE_DELETE(pPokerSprite);
	return nullptr;
}

void PokerSprite::setOpen(bool bValue)
{
	if (m_tagPokerData.isOpen == bValue) return;
	
	m_tagPokerData.isOpen = bValue;
	setTexture(Sprite::create(getFilePathByIndex(m_tagPokerData.nCardIndex, m_tagPokerData.isOpen))->getTexture());
}

void PokerSprite::setHandSelected(bool bValue)
{
	if (isHandSelected() == bValue) return;
	m_bHandSelected = bValue;
	setColor(m_bHandSelected ? ccBLUE : ccWHITE);
}

bool PokerSprite::isHandSelected()
{
	return m_bHandSelected;
}

void PokerSprite::setHandChecked(bool bValue)
{
	if (isHandChecked() == bValue) return;
	m_bHandChecked = bValue;
	setPosition(getPosition() + Vec2(bValue ? CHECK_HEIGHT : -CHECK_HEIGHT, 0));
}

bool PokerSprite::isHandChecked()
{
	return m_bHandChecked;
}

