#include "AndroidDisposer.h"
#include "ui/CocosGUI.h"
//#include "cocostudio/CocoStudio.h"
//#include "UtilAPI.h"
#import "PhotoManager.h"

USING_NS_CC;
using namespace cocos2d::ui;

#define CONTROL_TRANSPARENTX	"AndroidDisposer/transparent_x.png"
#define CONTROL_TRANSPARENTY	"AndroidDisposer/transparent_y.png"
#define CONTROL_BUTTONUP		"AndroidDisposer/android_disup.png"
#define CONTROL_BUTTONMID		"AndroidDisposer/android_dismid.png"
#define CONTROL_BUTTONDOWN		"AndroidDisposer/android_disdown.png"
#define CONTROL_BUTTON			CONTROL_BUTTONUP

//--------------------------------------------------
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#import  "ImagePickerViewController.h"
#import  "RootViewController.h"
#endif
//--------------------------------------------------
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#define JAVA_CLASS              "org/cocos2dx/cpp/AndroidDisposer"
//#define JAVA_CLASS              "com/kaka4/platform/upload/AndroidDisposer"
#define JAVA_FUNC_OPEN_PHOTO    "openPhoto"
#define JAVA_FUNC_OPEN_CAMERA   "openCamera"
#define JAVA_FUNC_OPEN_AUDIO	"openAudio"
#include "platform/android/jni/JniHelper.h"
#endif
//--------------------------------------------------

//--------------------------------------------------
AndroidDisposer* AndroidDisposer::s_instance = NULL;
//--------------------------------------------------
AndroidDisposer* AndroidDisposer::getInstance()
{
    if (s_instance == NULL)
    {
        s_instance = new AndroidDisposer();
    }
    return s_instance;
}
//--------------------------------------------------
void AndroidDisposer::destoryInstance()
{
    CC_SAFE_DELETE(s_instance);
}
//--------------------------------------------------
AndroidDisposer::AndroidDisposer()
:m_callback(nullptr)
{
    Director::getInstance()->getEventDispatcher()->addCustomEventListener("AndroidDisposerEvent", [=](EventCustom* eve)
    {
        std::string* path = (std::string*)eve->getUserData();
		CCLOG("(std::string*)eve->getUserData(); = %s", (*path).c_str());
        if (path && m_callback != nullptr)
        {
			CCLOG("path && m_callback != nullptr");
			m_callback((*path));
        }
    });
}
//--------------------------------------------------
void AndroidDisposer::callAndroidDisposer(const std::function<void(std::string)>& callback)
{
    s_instance->init();
    setListener(callback);
}
//--------------------------------------------------
void AndroidDisposer::setListener(const std::function<void(std::string)>& callback)
{
    m_callback = callback;
}
//--------------------------------------------------
void AndroidDisposer::removeListener()
{
    m_callback = nullptr;
}
//--------------------------------------------------
void AndroidDisposer::openPhoto()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    [[PhotoManager getInstance] setShuping];
    
    ImagePickerViewController* pImagePickerViewController = [[ImagePickerViewController alloc] initWithNibName:nil bundle:nil];
    
    RootViewController* _viewController = (RootViewController*)m_viewController;
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
	    [_viewController.view addSubview:pImagePickerViewController.view];
	}
	else
	{
	    [_viewController addChildViewController : pImagePickerViewController];
	}
    
    [pImagePickerViewController localPhoto];
#endif
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JniMethodInfo info;
    bool ret = JniHelper::getStaticMethodInfo(info, JAVA_CLASS, JAVA_FUNC_OPEN_PHOTO,"()V");
    if (ret)
    {
        info.env->CallStaticVoidMethod(info.classID, info.methodID);
    }
#endif
}
//--------------------------------------------------
void AndroidDisposer::openCamera()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    [[PhotoManager getInstance] setShuping];
    
    ImagePickerViewController* pImagePickerViewController = [[ImagePickerViewController alloc] initWithNibName:nil bundle:nil];
    
    RootViewController* _viewController = (RootViewController*)m_viewController;
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
	    [_viewController.view addSubview:pImagePickerViewController.view];
	}
	else
	{
	    [_viewController addChildViewController : pImagePickerViewController];
	}
    [pImagePickerViewController takePhoto];
#endif
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JniMethodInfo info;
    bool ret = JniHelper::getStaticMethodInfo(info, JAVA_CLASS, JAVA_FUNC_OPEN_CAMERA,"()V");
    if (ret)
    {
        info.env->CallStaticVoidMethod(info.classID, info.methodID);
    }
#endif
}
//--------------------------------------------------
void AndroidDisposer::openAudio()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	JniMethodInfo info;
	bool ret = JniHelper::getStaticMethodInfo(info, JAVA_CLASS, JAVA_FUNC_OPEN_AUDIO, "()V");
	if (ret)
	{
		info.env->CallStaticVoidMethod(info.classID, info.methodID);
	}
#endif
}

//--------------------------------------------------
bool AndroidDisposer::init()
{
    cocos2d::Size visibleSize = Director::getInstance()->getVisibleSize();
    
    //-------------------------------------
    // 根层
    //-------------------------------------
    LayerColor* m_layer = LayerColor::create(Color4B(0, 0, 0, 125));
    m_layer->retain();
    //-------------------------------------
    // 按钮背景
    //-------------------------------------
	//Sprite* sprite = Sprite::create(CONTROL_SPRITE);
 //   sprite->setAnchorPoint(Vec2(0.5, 0));
 //   sprite->setPosition(Vec2(visibleSize.width/2, 20));
 //   m_layer->addChild(sprite);
    //-------------------------------------
    // 按钮
    //-------------------------------------
	auto sizeCheck = ImageView::create(CONTROL_BUTTON)->getContentSize();
	auto m_pListViewCheckBoxs = ListView::create();
	m_pListViewCheckBoxs->setClippingEnabled(false);
    m_pListViewCheckBoxs->setContentSize(cocos2d::Size(sizeCheck.width, 0));
	m_pListViewCheckBoxs->setScrollBarEnabled(false);
	//m_pListViewCheckBoxs->setItemsMargin(-1);
	m_pListViewCheckBoxs->setAnchorPoint(Vec2(0.5, 0));
	m_pListViewCheckBoxs->setPosition(Vec2(visibleSize.width / 2, 40));
	m_pListViewCheckBoxs->setDirection(ScrollView::Direction::VERTICAL);
	m_pListViewCheckBoxs->setLayoutComponentEnabled(true);
	m_layer->addChild(m_pListViewCheckBoxs);

	auto cancelCallback = [=](Ref*){
		float height = Director::getInstance()->getVisibleSize().height;
		MoveBy* move = MoveBy::create(0.2, Vec2(0, -height));
		m_pListViewCheckBoxs->runAction(move->clone());
		Sequence* seq = Sequence::createWithTwoActions(FadeOut::create(0.2), RemoveSelf::create());
		m_layer->runAction(seq);
	};

	addListItem(m_pListViewCheckBoxs, CONTROL_BUTTONUP, "", [=](Ref*){});
	//addListItem(m_pListViewCheckBoxs, CONTROL_BUTTONMID, "Audio", [=](Ref*){ openAudio(); cancelCallback(nullptr); });
	addListItem(m_pListViewCheckBoxs, CONTROL_BUTTONMID, ("photo"), [=](Ref*){ openPhoto(); cancelCallback(nullptr); });
	addListItem(m_pListViewCheckBoxs, CONTROL_BUTTONMID, ("camera"), [=](Ref*){ openCamera(); cancelCallback(nullptr); });
	addListItem(m_pListViewCheckBoxs, CONTROL_TRANSPARENTX, "", [=](Ref*){});
	addListItem(m_pListViewCheckBoxs, CONTROL_BUTTONDOWN, ("cancel"), [=](Ref*){ cancelCallback(nullptr); });
	addListItem(m_pListViewCheckBoxs, CONTROL_TRANSPARENTX, "", [=](Ref*){});
	

	//-------------------------------------
    // 准备显示
    //-------------------------------------
    Director::getInstance()->getRunningScene()->scheduleOnce([=](float time)
    {
        Director::getInstance()->getRunningScene()->addChild(m_layer, INT_MAX);
        m_layer->release();

        float height = Director::getInstance()->getVisibleSize().height;
		m_pListViewCheckBoxs->setPositionY(m_pListViewCheckBoxs->getPositionY() - height);
        MoveBy* move = MoveBy::create(0.3, Vec2(0, height));
		m_pListViewCheckBoxs->runAction(move->clone());

        m_layer->setOpacity(0);
        m_layer->runAction(FadeTo::create(0.2, 125));

    }, 0.1, "AndroidDisposerScheduleOnce");
    //-------------------------------------
    // 截断事件
    //-------------------------------------
	/*    EventListenerTouchOneByOne* touchEvent = EventListenerTouchOneByOne::create();
		touchEvent->setSwallowTouches(true);
		touchEvent->onTouchBegan = [=](Touch* touch, Event* eve)
		{
		if(sprite->getBoundingBox().containsPoint(touch->getLocation()))
		return true;

		float height = sprite->getContentSize().height;

		MoveBy* move = MoveBy::create(0.2, Vec2(0, -height));
		sprite->runAction(move);
		m_pListViewCheckBoxs->runAction(move->clone());

		Sequence* seq = Sequence::createWithTwoActions(FadeOut::create(0.2), RemoveSelf::create());
		m_layer->runAction(seq);

		return true;
		};
		Director::getInstance()->getEventDispatcher()->addEventListenerWithSceneGraphPriority(touchEvent, sprite);
		*/ //-------------------------------------
    return true;
}

void AndroidDisposer::addListItem(cocos2d::ui::ListView *pListView, const std::string& strBack,
	const std::string& strText, const std::function<void(Ref*)>& callback)
{
	auto visibleSize = Director::getInstance()->getVisibleSize();
	auto pButton = ImageView::create(strBack.c_str());
	pButton->setTouchEnabled(true);
	pListView->pushBackCustomItem(pButton);
	pButton->setTag((long long)pButton);
	pButton->addClickEventListener(callback);
	auto pText = Label::createWithSystemFont(strText, "", 40);
	pText->setPosition(pButton->getContentSize() / 2);
	pText->setTextColor(Color4B::BLUE);
	pButton->addChild(pText);

	auto sizeCheck = pButton->getContentSize();
    pListView->setContentSize(cocos2d::Size(pListView->getContentSize().width, pListView->getContentSize().height + sizeCheck.height));
	//pListView->setPositionY(visibleSize.height / 2 - pListView->getContentSize().height / 2);
}
//--------------------------------------------------
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
void  AndroidDisposer::setViewController(void* viewController)
{
    m_viewController = viewController;
}
#endif
//--------------------------------------------------
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
extern "C"
{
	void Java_org_cocos2dx_cpp_AndroidDisposer_ccpCallback(JNIEnv* env, jobject thiz, jstring path)
	//void Java_com_kaka4_platform_upload_AndroidDisposer_ccpCallback(JNIEnv* env, jobject thiz, jstring path)
	{
		log("Java_com_kaka4_platform_upload_AndroidDisposer_ccpCallback");
        std::string strPath = JniHelper::jstring2string(path);
        Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("AndroidDisposerEvent", &strPath);
    }
}
#endif
//--------------------------------------------------
