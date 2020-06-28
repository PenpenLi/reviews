#ifndef __HELLOWORLD_SCENE_H__
#define __HELLOWORLD_SCENE_H__

#include "cocos2d.h"

class HelloWorld : public cocos2d::Layer
{
public:
    static cocos2d::Scene* createScene();
    virtual bool init();
	void menuCloseCallback(Ref* pSender);
    // implement the "static create()" method manually
    CREATE_FUNC(HelloWorld);

public:
	void onTest();
	void onLoadDataFileTest();
	void onAndroidDisposerTest();
	void onWCheckListTest();
    void onWPageViewTest();
	void onShaderEffectTest();
	void onParticleEffectTest();
	void on3DWorldTest();
	void onShaderBrushTest();

};

#endif // __HELLOWORLD_SCENE_H__

