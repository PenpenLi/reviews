//
//  WPageView.hpp
//  MyCppGame
//
//  Created by aaron on 11/01/2017.
//
//

#ifndef WPageView_hpp
#define WPageView_hpp

#include <stdio.h>
#include "cocostudio/CocoStudio.h"
#include "ui/CocosGUI.h"
#include <iostream>
#include "cocos2d.h"

using namespace std;
using namespace cocos2d;
using namespace cocos2d::ui;

class WPageView :public cocos2d::Layer
{
public:
    CREATE_FUNC(WPageView);
    void addItem(int index, std::string strname, const std::function<void(Ref*)> & callfunc);
    int    m_curIdx;
protected:
    std::map<int, Ref*> m_childItem;
    std::map<int, std::function<void(Ref*)>> m_childFunc;
    double m_lfWidth;
    double m_lfHeight;
    Size   m_szLimit;
    int    m_firstIdx;
    bool   m_bMoving;
    
    double m_ftTouch;
    bool   m_bClick;
    
    WPageView();
    ~WPageView();
    bool onTouchBegan(cocos2d::Touch* pTouch, cocos2d::Event* pEvent);
    void onTouchMoved(cocos2d::Touch *pTouch, cocos2d::Event *pEvent);
    void onTouchEnded(cocos2d::Touch *pTouch, cocos2d::Event *pEvent);
    virtual void update(float ft) override;
    virtual bool init() override;
    
};



#endif /* WPageView_hpp */
