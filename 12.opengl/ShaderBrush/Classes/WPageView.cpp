//
//  WPageView.cpp
//  MyCppGame
//
//  Created by aaron on 11/01/2017.
//
//

#include "WPageView.hpp"

WPageView::WPageView()
{
    m_lfWidth = 0.;
    m_lfHeight = 0.;
    m_firstIdx = 0;
    m_bMoving = false;
    m_curIdx = 0;
}

WPageView::~WPageView()
{
    
}

bool WPageView::init()
{
    if (!Layer::init()) return false;
    
    auto touchListener = cocos2d::EventListenerTouchOneByOne::create();
    touchListener->onTouchBegan = CC_CALLBACK_2(WPageView::onTouchBegan, this);
    touchListener->onTouchMoved = CC_CALLBACK_2(WPageView::onTouchMoved, this);
    touchListener->onTouchEnded = CC_CALLBACK_2(WPageView::onTouchEnded, this);
    _eventDispatcher->addEventListenerWithSceneGraphPriority(touchListener, this);
    
    m_szLimit = Size(200, 300);
    
    this->setContentSize(m_szLimit);
    auto temp = Layout::create();
    temp->setContentSize(m_szLimit);
    temp->setBackGroundColor(Color3B::GREEN);
    temp->setBackGroundColorType(ui::LayoutBackGroundColorType::SOLID);
    this->addChild(temp);
    
    return true;
}

void WPageView::update(float ft)
{
    Layer::update(ft);
    m_ftTouch += ft;
}

bool WPageView::onTouchBegan(cocos2d::Touch* pTouch, cocos2d::Event* pEvent)
{
    auto pt = pTouch->getLocation();
    if (!this->getBoundingBox().containsPoint(pt)) {
        return false;
    }
    if (m_bMoving) {
        return false;
    }
    
    m_ftTouch = 0;
    m_bClick = true;
    m_bMoving = true;
//    ((Button*)m_childItem[m_curIdx])->setTouchEnabled(false);
    ((Node*)m_childItem[m_curIdx])->setColor(Color3B::WHITE);
    
    return true;
}

void WPageView::onTouchMoved(cocos2d::Touch *pTouch, cocos2d::Event *pEvent)
{
    auto pt = pTouch->getLocation();
    if (!this->getBoundingBox().containsPoint(pt)) {
        m_bMoving = false;
        return ;
    }
    
    //click
    m_bClick = false;
    
    auto offset = pt - pTouch->getPreviousLocation();
    log("x, y = %f, %f", offset.x, offset.y);
    
    //left | right
    Node *firstnode = (Node*)m_childItem[m_firstIdx];
    auto firstpt = firstnode->getPosition()+Vec2(offset.x, 0);
    
    int finalidx =  (int)(m_firstIdx + m_childItem.size() - 1) % m_childItem.size();
    Node *finalnode = (Node*)m_childItem[finalidx];
    auto finalpt = finalnode->getPosition()+Vec2(offset.x, 0);
    
    double fwidth = firstnode->getContentSize().width/2 + finalnode->getContentSize().width/2;
    if (firstpt.x - firstnode->getContentSize().width/2 > 0) {
        finalnode->setPosition(firstnode->getPosition() - Vec2(fwidth, 0));
        m_firstIdx = (int)(firstnode->getTag() + m_childItem.size() - 1) % m_childItem.size();
    }else if (finalpt.x + finalnode->getContentSize().height/2 < m_szLimit.width){
        firstnode->setPosition(finalnode->getPosition() + Vec2(fwidth, 0));
        m_firstIdx = (int)(firstnode->getTag() + 1) % m_childItem.size();
    }
    
    //move
    std::map<int,Ref*>::iterator iter;
    for (iter = m_childItem.begin(); iter != m_childItem.end(); ++iter) {
        auto node = ((Node*)iter->second);
        node->setPosition(node->getPosition() + Vec2(offset.x, 0));
    }
}

void WPageView::onTouchEnded(cocos2d::Touch *pTouch, cocos2d::Event *pEvent)
{
//    auto pt = pTouch->getLocation();
//    if (!this->getBoundingBox().containsPoint(pt)) {
//        m_bMoving = false;
//        return ;
//    }
    if (m_bClick && m_ftTouch < 0.02) {
        m_childFunc[m_curIdx](m_childItem[m_curIdx]);
        m_bMoving = false;
        ((Node*)m_childItem[m_curIdx])->setColor(Color3B::RED);
        return ;
    }
    
    //back
    double backwidth = m_szLimit.width;
//    int curIndex = 0;
    std::map<int,Ref*>::iterator iter;
    for (iter = m_childItem.begin(); iter != m_childItem.end(); ++iter) {
        auto node = ((Node*)iter->second);
        if (fabs(backwidth) > fabs(node->getPosition().x - m_szLimit.width/2)) {
            backwidth = node->getPosition().x - m_szLimit.width/2;
            m_curIdx = iter->first;
        }
    }
    
    //move
    for (iter = m_childItem.begin(); iter != m_childItem.end(); ++iter) {
        auto node = ((Node*)iter->second);
        node->runAction(EaseSineOut::create(
                  MoveTo::create(0.2, Vec2(node->getPosition() + Vec2(-backwidth, 0))) ));
    }
    this->runAction(Sequence::create(DelayTime::create(0.2),
                                     CallFunc::create([=](){
                                        m_bMoving = false;
//                                        ((Button*)m_childItem[m_curIdx])->setTouchEnabled(true);
                                        ((Node*)m_childItem[m_curIdx])->setColor(Color3B::RED);
                                    }),
                                     NULL));
}

void WPageView::addItem(int index, std::string strname, const std::function<void(Ref*)> & callfunc)
{
    std::map<int,Ref*>::iterator iter = m_childItem.find(index);
    if (iter == m_childItem.end()) {
        auto spr = Sprite::create(strname);
//        spr->setTouchEnabled(false);
//        spr->addClickEventListener((std::function<void(Ref*)>)callfunc);
        this->addChild(spr);
        auto sz = spr->getContentSize();
        spr->setPosition(Vec2(m_lfWidth + sz.width/2, sz.height/2));
        m_lfWidth += sz.width;
        spr->setTag(index);
        m_childItem.insert(map<int, Ref*> :: value_type(index, spr));
        m_childFunc.insert(map<int, std::function<void(Ref*)>> :: value_type(index, callfunc));
    }else{
        log("you've add already");
    }
}







