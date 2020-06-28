#include "WCheckList.h"
#include "cocostudio/CocoStudio.h"

using namespace std;
using namespace cocos2d;
using namespace cocos2d::ui;

#define TAGOFFSET 10
#define TAG_CHECKNORMAL 11
#define TAG_CHECKSELECTED 12
#define TAG_CHECKTEXT 12

//#define PLAY_BUTTON_EFFECT
#define VEC_SCALE9 Vec2(15, 15)
#define STR_BACKGROUND "checklist/wRoomDesc.png"
#define STR_CHECKNORMAL "checklist/btnItems.png"
#define STR_CHECKSELECTED "checklist/btnReady.png"

WCheckList::WCheckList()
{

}

WCheckList::~WCheckList()
{

}
WCheckList* WCheckList::create(const cocos2d::Vec2& contentSize, float checkMargin, const std::string& checkNormal, const std::string& checkSelected)
{
	auto pRet = new(std::nothrow)WCheckList();
	pRet->m_vecContentSize = contentSize;
	pRet->m_fCheckMargin = checkMargin;
	pRet->m_strCheckNormal = checkNormal;
	pRet->m_strCheckSelected = checkSelected;
	if (pRet && pRet->init())
	{
		pRet->autorelease();
	}
	else
	{
		delete pRet;
		pRet = nullptr;
	}
	return pRet;
}

bool WCheckList::init()
{
	if (!Layout::init())
	{
		return false;
	}
	m_pFileUtils = FileUtils::getInstance();

	m_pListViewCheckBoxs = ListView::create();
	m_pListViewCheckBoxs->setClippingEnabled(false);
	m_pListViewCheckBoxs->setScrollBarEnabled(false);
	m_pListViewCheckBoxs->setItemsMargin(m_fCheckMargin);
	m_pListViewCheckBoxs->setDirection(ScrollView::Direction::HORIZONTAL);
	m_pListViewCheckBoxs->setLayoutComponentEnabled(true);
	this->addChild(m_pListViewCheckBoxs);

	m_pLayout = Layout::create();
	m_pLayout->setClippingEnabled(true);
	m_pLayout->setAnchorPoint(Vec2(0, 0));
	m_pLayout->setPosition(Vec2(0, 0));
	this->addChild(m_pLayout);

	m_pLayoutBack = ImageView::create(STR_BACKGROUND);
	m_pLayoutBack->setScale9Enabled(true);
	m_pLayoutBack->setAnchorPoint(Vec2(0.5, 0.5));
	m_pLayout->addChild(m_pLayoutBack, 1);

	if (!m_pFileUtils->isFileExist(m_strCheckNormal)) m_strCheckNormal = STR_CHECKNORMAL;
	if (!m_pFileUtils->isFileExist(m_strCheckSelected)) m_strCheckSelected = STR_CHECKSELECTED;
	if (!m_pFileUtils->isFileExist(m_strLayoutBackGround)) m_strLayoutBackGround = STR_BACKGROUND;

	onPictureChange();

	return true;
}

float WCheckList::getCheckHeight()
{
	auto temp = 0.0f;
	if (m_pFileUtils->isFileExist(m_strCheckNormal) && m_pFileUtils->isFileExist(m_strCheckSelected))
	{
		auto height1 = Sprite::create(m_strCheckNormal)->getContentSize().height;
		auto height2 = Sprite::create(m_strCheckSelected)->getContentSize().height;
		temp = height1 > height2 ? height1 : height2;
	}
	CCLOG("WCheckList:: listview height = %f", temp);
	return temp;
}

void WCheckList::addCheckListItem(const std::string& strCheckName, cocos2d::ui::Layout* pLayout)
{
	if (!pLayout || pLayout->getParent())
	{
		CCLOG("addCheckListItem -> pLayout");
		return;
	}

	auto sizeCheck = ImageView::create(m_strCheckNormal)->getContentSize();
	auto pCheckBox = CheckBox::create(m_strCheckNormal, "");
	auto linear = LinearLayoutParameter::create();
	pCheckBox->setTag((long long)pCheckBox);
	pCheckBox->addClickEventListener(CC_CALLBACK_1(WCheckList::onCheckBoxsClicked, this));
	m_pListViewCheckBoxs->pushBackCustomItem(pCheckBox);
	m_pListViewCheckBoxs->setContentSize(
		Size(m_pListViewCheckBoxs->getContentSize().width + sizeCheck.width,
		m_pListViewCheckBoxs->getContentSize().height));
	m_pListViewCheckBoxs->setPositionX(m_vecLayoutSize.width / 2 - m_pListViewCheckBoxs->getContentSize().width / 2);
	
	auto imgSelected = ImageView::create(m_strCheckSelected);
	imgSelected->setAnchorPoint(Vec2(0.5, 0));
	imgSelected->setPosition(Vec2(sizeCheck.width / 2, 0));
	pCheckBox->addChild(imgSelected, 0, TAG_CHECKSELECTED);
	auto strCheckText = Text::create(strCheckName, "Arial", 20);
	strCheckText->setAnchorPoint(Vec2(0.5, 0));
	strCheckText->setPosition(Vec2(sizeCheck.width / 2, 0));
	pCheckBox->addChild(strCheckText, 1, TAG_CHECKTEXT);

	pLayout->addChild(Text::create(StringUtils::format("what = %ld", pCheckBox), "Arial", 40));
	pLayout->setAnchorPoint(Vec2(0.5, 0.5));
	pLayout->setPosition(m_vecContentSize / 2);
	m_pLayout->addChild(pLayout, 0, (long)pCheckBox);

	onCheckBoxsClicked(pCheckBox);
}

void WCheckList::onCheckBoxsClicked(Ref* pSender)
{
	//PLAY_BUTTON_EFFECT;
	CCLOG("onCheckBoxsClicked pSender = %d", pSender);
	for (auto child : m_pListViewCheckBoxs->getChildren())
	{
		auto value = (pSender == child);
		static_cast<CheckBox*>(child)->setEnabled(!value);
		child->getChildByTag(TAG_CHECKSELECTED)->setVisible(value);
		m_pLayout->getChildByTag((long)child)->setVisible(value);

		Vec2 vecLayoutSize = m_pLayout->getChildByTag((long)child)->getContentSize();
		if (vecLayoutSize.x < 2 * VEC_SCALE9.x || vecLayoutSize.y < 2 * VEC_SCALE9.y) vecLayoutSize = m_vecLayoutSize;
	
		m_pLayoutBack->setScaleX((vecLayoutSize.x - 2 * VEC_SCALE9.x) / (m_pLayoutBack->getContentSize().width - 2 * VEC_SCALE9.x));
		m_pLayoutBack->setScaleY((vecLayoutSize.y - 2 * VEC_SCALE9.y) / (m_pLayoutBack->getContentSize().height - 2 * VEC_SCALE9.y));
		//m_pLayoutBack->setScaleX((vecLayoutSize.x) / (m_pLayoutBack->getContentSize().width));
		//m_pLayoutBack->setScaleY((vecLayoutSize.y) / (m_pLayoutBack->getContentSize().height));
	}
}

void WCheckList::onPictureChange()
{
	m_vecLayoutSize = Vec2(m_vecContentSize) - Vec2(0, getCheckHeight());
	auto normalCheckSize = Sprite::create(m_strCheckNormal)->getContentSize();

	m_pLayout->setContentSize(Size(m_vecLayoutSize));
	m_pLayoutBack->setCapInsets(CCRect(VEC_SCALE9.x, VEC_SCALE9.y, m_vecLayoutSize.width - VEC_SCALE9.x, m_vecLayoutSize.height - VEC_SCALE9.y));
	m_pLayoutBack->setPosition(m_vecLayoutSize / 2);
	m_pLayoutBack->setScaleX((m_vecLayoutSize.width - 2 * VEC_SCALE9.x) / (m_pLayoutBack->getContentSize().width - 2 * VEC_SCALE9.x));
	m_pLayoutBack->setScaleY((m_vecLayoutSize.height - 2 * VEC_SCALE9.y) / m_pLayoutBack->getContentSize().height - 2 * VEC_SCALE9.y);

	for (auto child : m_pListViewCheckBoxs->getChildren())
	{
		auto checkbox = (static_cast<CheckBox*>(m_pListViewCheckBoxs->getChildByTag((long)child)));
		checkbox->setContentSize(normalCheckSize);
		checkbox->loadTextureBackGround(m_strCheckNormal);
		auto imgSelected = static_cast<ImageView*>(checkbox->getChildByTag(TAG_CHECKSELECTED));
		imgSelected->loadTexture(m_strCheckSelected);
		imgSelected->setAnchorPoint(Vec2(0.5, 0));
		imgSelected->setPosition(Vec2(normalCheckSize.width / 2, 0));
	}
	m_pListViewCheckBoxs->setContentSize(Size(m_pListViewCheckBoxs->getItems().size()*normalCheckSize.width, normalCheckSize.height));
	m_pListViewCheckBoxs->setPosition(Vec2(m_vecLayoutSize.width / 2 - m_pListViewCheckBoxs->getContentSize().width / 2, m_vecLayoutSize.height));

}

void WCheckList::onCheckBoxPicChange()
{
	//m_strCheckNormal = "HelloWorld.png";
	onPictureChange();
}
