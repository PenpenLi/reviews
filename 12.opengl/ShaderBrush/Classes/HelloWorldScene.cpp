#include "HelloWorldScene.h"
#include "AndroidDisposer.h"
#include"AudioEngine.h"
#include "WCheckList.h"
#include "TestEffect.h"
#include "Test3D.h"
#include "ShaderBrush.h"
#include "WPageView.hpp"
//#include "ui/CocosGUI.h"
//#include "cocostudio/CocoStudio.h"
USING_NS_CC;
using namespace cocos2d::experimental;

Scene* HelloWorld::createScene()
{
	auto pScene = Scene::create();
	auto pLayer = HelloWorld::create();
	pScene->addChild(pLayer);
	return pScene;
}

bool HelloWorld::init()
{
	if (!Layer::init())
	{
		return false;
	}
	Size visibleSize = Director::getInstance()->getVisibleSize();
	Vec2 origin = Director::getInstance()->getVisibleOrigin();

	// add a "close" icon to exit the progress. it's an autorelease object
	auto closeItem = MenuItemImage::create(
		"CloseNormal.png",
		"CloseSelected.png",
		CC_CALLBACK_1(HelloWorld::menuCloseCallback, this));
	closeItem->setPosition(Vec2(origin.x + visibleSize.width - closeItem->getContentSize().width / 2,
		origin.y + closeItem->getContentSize().height / 2));

	// create menu, it's an autorelease object
	auto menu = Menu::create(closeItem, NULL);
	menu->setPosition(Vec2::ZERO);
	this->addChild(menu, 1);

	// add your codes below...
	auto label = Label::createWithTTF("Hello World", "fonts/Marker Felt.ttf", 24);
	label->setPosition(Vec2(origin.x + visibleSize.width / 2,
		origin.y + visibleSize.height - label->getContentSize().height));
	this->addChild(label, 1);

	CCLOG("bool HelloWorld::init()");
	onTest();
	
	return true;
}

void HelloWorld::menuCloseCallback(Ref* pSender)
{
	Director::getInstance()->end();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	exit(0);
#endif
}

void HelloWorld::onLoadDataFileTest()
{
	//upload
	std::string pFileName = "7.DAT";
	auto pFileUtils = FileUtils::getInstance();
	if (!pFileUtils->isFileExist(pFileName))
	{
		CCLOG("pFileUtils->isFileExist(%s)", pFileName.c_str());
		//return;
	}
	cocos2d::Data dataFile = pFileUtils->getDataFromFile(pFileName);

	//judge
	std::string strCopyPath = pFileUtils->getWritablePath() + "wtf.wtf";
	if (!pFileUtils->isFileExist(strCopyPath))
	{
		CCLOG("pFileUtils->isFileExist(%s)", strCopyPath.c_str());
		//return;
	}

	//download
	FILE *pFileCopy = fopen(strCopyPath.c_str(), "wb");
	if (nullptr == pFileCopy)
	{
		CCLOG("nullptr == pf");
		//return;
	}
	fseek(pFileCopy, 0, 0);
	fwrite(dataFile.getBytes(), sizeof(char), dataFile.getSize(), pFileCopy);
	fclose(pFileCopy);

	//loadframe
	addChild(Sprite::create(strCopyPath), 200);
}

void HelloWorld::onAndroidDisposerTest()
{
	AndroidDisposer::getInstance()->callAndroidDisposer([=](std::string path)
	{
		CCLOG("callback path= %s", path.c_str());
		std::string strFullPath = path;
		Size visibleSize = Director::getInstance()->getVisibleSize();
		Vec2 origin = Director::getInstance()->getVisibleOrigin();
		auto file = FileUtils::getInstance()->getWritablePath();
		CCLOG("test file= %s", file.c_str());

		auto fileExt = FileUtils::getInstance()->getFileExtension(strFullPath);
		//Text* pText = Text::create();
		//pText->setString(m_strImage);
		//this->addChild(pText, 21);

		if (fileExt == ".png" || fileExt == ".jpg")
		{
			auto temp = Sprite::create(strFullPath.c_str());
			temp->setPosition(Vec2(visibleSize.width / 2 + origin.x, visibleSize.height / 2 + origin.y));
			this->addChild(temp, 20);
		}
		if (fileExt == ".mp3")
		{
			//AudioEngine::preload(m_strImage.c_str());
			AudioEngine::stopAll();
			AudioEngine::play2d(strFullPath.c_str(), true);
		}
	});
}

void HelloWorld::onWCheckListTest()
{
	WCheckList* wcl = WCheckList::create();	
	addChild(wcl);
    wcl->addCheckListItem("danda", cocos2d::ui::Layout::create());
    wcl->addCheckListItem("danda", cocos2d::ui::Layout::create());
}

void HelloWorld::onWPageViewTest()
{
    auto winSize = Director::getInstance()->getVisibleSize();
//    auto itemSize = winSize/4;
    auto btn = Button::create("scrollviewbg.png");
    this->addChild(btn);
    btn->setPosition(Vec2(winSize/2));
    
    auto temp = WPageView::create();
    for (short i = 0; i < 4; ++i) {
        auto str = StringUtils::format("pageview/scrollviewbg_%d.png", i);
        temp->addItem(i, str, [=](Ref*pRef){log("wtf...%d", ((Node*)pRef)->getTag());});
    }
    temp->setPosition(winSize/2);
    this->addChild(temp);
}

void HelloWorld::onShaderEffectTest()
{
	WTestEffect* wte = WTestEffect::create();
	addChild(wte);
	wte->ShaderTest();
}

void HelloWorld::onParticleEffectTest()
{
	WTestEffect* wte = WTestEffect::create();
	addChild(wte);
	wte->showParticle();
	wte->showParticle3D();
}

void HelloWorld::on3DWorldTest()
{
	WTest3D* wt3d = WTest3D::create();
	addChild(wt3d);
	wt3d->createWorld3D();
	wt3d->showSprite3D();
	//wt3d->addEventListenerTest();
}

void HelloWorld::onShaderBrushTest()
{
	auto s = Director::getInstance()->getVisibleSize();
	auto pRender = new RenderTexture();
	pRender->initWithWidthAndHeight(s.width, s.height, Texture2D::PixelFormat::RGBA8888, 0);
	pRender->setContentSize(Size(s.width, s.height));
	pRender->setPosition(Vec2(s/2));
	addChild(pRender, 20, 20);
	pRender->beginWithClear(1, 1, 0, 1);
	pRender->end();
	ShaderBrush* psb = ShaderBrush::createWithVertex("", "Shaders/brush.fsh");
	psb->retain();

	//
	auto pSprite = Sprite::create("HelloWorld.png");
	pSprite->retain();
	//´¥ÃþÏìÓ¦×¢²á
	auto touchListener = cocos2d::EventListenerTouchOneByOne::create();//´´½¨µ¥µã´¥ÃþÊÂ¼þ¼àÌýÆ÷
	touchListener->onTouchBegan = [=](cocos2d::Touch* touch, cocos2d::Event* event)->bool{return true; };//´¥Ãþ¿ªÊ¼
	touchListener->onTouchMoved = [=](cocos2d::Touch* touch, cocos2d::Event* event){
		psb->movePaint(pSprite, pRender, touch->getLocation());
	};//´¥ÃþÒÆ¶¯
	touchListener->onTouchEnded = [=](cocos2d::Touch* touch, cocos2d::Event* event){ };//´¥Ãþ½áÊø
	_eventDispatcher->addEventListenerWithSceneGraphPriority(touchListener, this);//×¢²á·Ö·¢Æ÷

}

void HelloWorld::onTest()
{
//	onShaderBrushTest();
    onWPageViewTest();
}


