#pragma once

#include "cocos2d.h"

class WTest3D : public cocos2d::Layer
{
private:
	WTest3D();

protected:
	virtual ~WTest3D();
	virtual bool init();
	virtual void update(float delta);

public:
	static WTest3D* create();
	//void gofDesignPattern()
	//{
	//	Factory* fac = new FactoryA<ProductA>();
	//	Product* prod = fac->createProduct();
	//}
public:
	// texture cube
	cocos2d::TextureCube*        _textureCube;
	cocos2d::Skybox*             _skyBox;
	cocos2d::Terrain*   _terrain;
	void createWorld3D();

	// sprites
	cocos2d::Camera* _camera;
	void showSprite3D();
	void addEventListenerTest();
	void onTouchesMovedsss(const std::vector<cocos2d::Touch*>& touches, cocos2d::Event* event);

};