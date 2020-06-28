#ifndef _PokerSprite_h_
#define _PokerSprite_h_

#include <iostream>
#include "cocos2d.h"
#include "ui/CocosGUI.h"
//#include "cocostudio/CocosGUI.h"
//#include "Cmd_Sparrow.h"

#define PATH_CARDBACK	""
#define PATHFORMAT_CARDINDEX "%d_%d.png"
#define CHECK_HEIGHT 20

typedef std::function<void(long)> func_void_long;

struct tagPokerData
{
	bool isOpen;
	int	 nCardIndex;
};

class PokerSprite : public cocos2d::Sprite
{
private:
	tagPokerData m_tagPokerData;	
	static unsigned char getShapeByIndex(int nIndex);
	static unsigned char getNumberByIndex(int nIndex);
	static std::string getFilePathByIndex(int nIndex, bool isOpen);
	bool m_bHandSelected;
	bool m_bHandChecked;
	PokerSprite();
protected:
	virtual ~PokerSprite();
	virtual bool init();
public:
	static PokerSprite* create(int nCardIndex, bool isOpen = true);
	void setOpen(bool bValue);
	void setHandSelected(bool bValue);
	bool isHandSelected();
	void setHandChecked(bool bValue);
	bool isHandChecked();
};

#endif
