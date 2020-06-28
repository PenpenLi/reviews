#ifndef __UIManager_WCheckList__
#define __UIManager_WCheckList__

#include "cocos2d.h"
//#include "cocostudio/CocosGUI.h"
#include "ui/CocosGUI.h"
//#include "Cmd_Sparrow.h"
#include <iostream>

typedef std::function<void(long)> func_void_long;

class WCheckList : public cocos2d::ui::Layout
{
private:
	cocos2d::FileUtils*		m_pFileUtils;
	cocos2d::Size				m_vecContentSize;
	float					m_fCheckMargin;
	std::string				m_strCheckNormal;
	std::string				m_strCheckSelected;
	cocos2d::ui::ListView*		m_pListViewCheckBoxs;
	cocos2d::Size				m_vecLayoutSize;
	std::string				m_strLayoutBackGround;
	cocos2d::ui::Layout*		m_pLayout;
	cocos2d::ui::ImageView*	m_pLayoutBack;
	WCheckList();
	float getCheckHeight();
	void onCheckBoxsClicked(cocos2d::Ref* pSender);
	void onPictureChange();

protected:
	virtual bool init();
	virtual ~WCheckList();

public:
	static WCheckList* create(const cocos2d::Vec2& contentSize = cocos2d::Vec2(600, 450), float checkMargin = 0.0, const std::string& checkNormal = "", const std::string& checkSelected = "");
	void addCheckListItem(const std::string& strCheckName, cocos2d::ui::Layout* pLayout);
	void onCheckBoxPicChange();
};

#endif
