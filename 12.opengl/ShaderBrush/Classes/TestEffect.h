#pragma once

#include "cocos2d.h"

class WTestEffect : public cocos2d::Layer
{
private:
	WTestEffect();

protected:
	virtual ~WTestEffect();
	virtual bool init();
	virtual void update(float delta);

public:
	static WTestEffect* create();

public:
	cocos2d::Camera* _camera;
	void showParticle();
	void showParticle3D();
	void ShaderTest();
};
