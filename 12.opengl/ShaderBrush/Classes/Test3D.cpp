#include "Test3D.h"

using namespace std;
using namespace cocos2d;

WTest3D::WTest3D()
{

}

WTest3D::~WTest3D()
{

}

bool WTest3D::init()
{
	if (!Layer::init())
	{
		return false;
	}
	return true;
}

void WTest3D::update(float delta)
{
	Layer::update(delta);
}

WTest3D* WTest3D::create()
{
	WTest3D* pRet = new(std::nothrow)WTest3D();
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

void WTest3D::createWorld3D()
{
	// create skybox

	// create the second texture for cylinder
	_textureCube = TextureCube::create("Sprite3DTest/skybox/left.jpg",
		"Sprite3DTest/skybox/right.jpg",
		"Sprite3DTest/skybox/top.jpg",
		"Sprite3DTest/skybox/bottom.jpg",
		"Sprite3DTest/skybox/front.jpg",
		"Sprite3DTest/skybox/back.jpg");

	//set texture parameters
	Texture2D::TexParams tRepeatParams;
	tRepeatParams.magFilter = GL_LINEAR;
	tRepeatParams.minFilter = GL_LINEAR;
	tRepeatParams.wrapS = GL_MIRRORED_REPEAT;
	tRepeatParams.wrapT = GL_MIRRORED_REPEAT;
	_textureCube->setTexParameters(tRepeatParams);

	// add skybox
	_skyBox = Skybox::create();
	_skyBox->setCameraMask((unsigned short)CameraFlag::USER1);
	_skyBox->setTexture(_textureCube);
	_skyBox->setScale(700.f);

	////create and set our custom shader
	//auto shader = GLProgram::createWithFilenames("Sprite3DTest/cube_map.vert",
	//	"Sprite3DTest/cube_map.frag");
	//auto state = GLProgramState::create(shader);
	//// pass the texture sampler to our custom shader
	//state->setUniformTexture("u_cubeTex", _textureCube);

	// create terrain
	Terrain::DetailMap r("TerrainTest/dirt.jpg");
	Terrain::DetailMap g("TerrainTest/Grass2.jpg", 10);
	Terrain::DetailMap b("TerrainTest/road.jpg");
	Terrain::DetailMap a("TerrainTest/GreenSkin.jpg", 20);
	Terrain::TerrainData data("TerrainTest/heightmap16.jpg",
		"TerrainTest/alphamap.png",
		r, g, b, a, Size(32, 32), 40.0f, 2);
	_terrain = Terrain::create(data, Terrain::CrackFixedType::SKIRT);
	_terrain->setMaxDetailMapAmount(4);
	_terrain->setDrawWire(false);
	_terrain->setSkirtHeightRatio(3);
	_terrain->setLODDistance(64, 128, 192);

	//addChild(_skyBox);
	_terrain->setPosition3D(Vec3(500, 0, -500));
	_terrain->setScale(15.0);
	addChild(_terrain, 10);

	//// create player
	//_player = Player::create("Sprite3DTest/girl.c3b",
	//	_gameCameras[CAMERA_WORLD_3D_SCENE],
	//	_terrain);
	//_player->setScale(0.08);
	//_player->setPositionY(_terrain->getHeight(_player->getPositionX(),
	//	_player->getPositionZ()));
	//auto animation = Animation3D::create("Sprite3DTest/girl.c3b", "Take 001");
	//if (animation)
	//{
	//	auto animate = Animate3D::create(animation);
	//	_player->runAction(RepeatForever::create(animate));
	//}
}

void WTest3D::showSprite3D()
{
	//the assets are from the OpenVR demo
	//get the visible size.
	Size size = Director::getInstance()->getVisibleSize();
	float zeye = Director::getInstance()->getZEye();
	Vec3 eye(size.width / 2, size.height / 2.0f, zeye),
		center(size.width / 2, size.height / 2, 0.0f),
		up(0.0f, 1.0f, 0.0f);
	_camera = Camera::createPerspective(60, size.width / size.height, 100, 3000);// zeye + size.height / 2.0f);
	_camera->setCameraFlag(CameraFlag::USER1);
	//_camera->setPosition3D(Vec3(0, 25, 15));
	_camera->setPosition3D(eye + Vec3(0, 60, 10));
	//_camera->lookAt(center, up);
	//_camera->setRotation3D(Vec3(-35, 0, 0));
	//auto LightMapScene = Sprite3D::create("Sprite3DTest/boss1.obj");
	//LightMapScene->setTexture("Sprite3DTest/boss.png");
	//auto LightMapScene = Sprite3D::create("Sprite3DTest/aaaa.c3b");
	addChild(_camera);
	setCameraMask(2);

	std::string fileName = "Sprite3DTest/orc.c3b";
	//std::string fileName = "Sprite3DTest/cccc.c3b";
	for (int i = 0; i < 14; ++i)
	{
		auto LightMapScene = Sprite3D::create(fileName);
		LightMapScene->setScale(8);
		addChild(LightMapScene, 100 + i, 100 + i);

		LightMapScene->setRotation3D(Vec3(0, 180, 0));
		auto sc = LightMapScene->getScale();
		auto sz = LightMapScene->getContentSize();
		auto curY = _terrain->getHeight(Vec2(250 + i*(sc*sz.width - 150), 10));
		LightMapScene->setPosition3D(Vec3(250 + i*(sc*sz.width - 150), curY, 10));
	}

	for (int i = 0; i < 14; ++i)
	{
		auto LightMapScene = Sprite3D::create(fileName);
		LightMapScene->setScale(8);
		addChild(LightMapScene, 200 + i, 200 + i);

		LightMapScene->setRotation3D(Vec3(0, 0, 0));
		auto sc = LightMapScene->getScale();
		auto sz = LightMapScene->getContentSize();
		auto curY = _terrain->getHeight(Vec2(250 + i*(sc*sz.width - 150), -1500));
		LightMapScene->setPosition3D(Vec3(250 + i*(sc*sz.width - 150), curY, -1500));
	}

	for (int i = 0; i < 14; ++i)
	{
		auto LightMapScene = Sprite3D::create(fileName);
		LightMapScene->setScale(8);
		addChild(LightMapScene, 300 + i, 300 + i);

		LightMapScene->setRotation3D(Vec3(0, 90, 0));
		auto sc = LightMapScene->getScale();
		auto sz = LightMapScene->getContentSize();
		auto curY = _terrain->getHeight(Vec2(20, -400 - i * 80));
		LightMapScene->setPosition3D(Vec3(20, curY, -400 - i * 80));
	}

	for (int i = 0; i < 14; ++i)
	{
		auto LightMapScene = Sprite3D::create(fileName);
		LightMapScene->setScale(8);
		addChild(LightMapScene, 400 + i, 400 + i);

		LightMapScene->setRotation3D(Vec3(0, 270, 0));
		auto sc = LightMapScene->getScale();
		auto sz = LightMapScene->getContentSize();
		auto curY = _terrain->getHeight(Vec2(1200, -400 - i * 80));
		LightMapScene->setPosition3D(Vec3(1200, curY, -400 - i * 80));
	}

	//for (int i = 0; i < 10; ++i)
	//{
	//	auto LightMapScene = Sprite3D::create(fileName);
	//	LightMapScene->setScale(8);
	//	addChild(LightMapScene, i, i);

	//	LightMapScene->setRotation3D(Vec3(90, 180, 0));
	//	auto sc = LightMapScene->getScale();
	//	auto sz = LightMapScene->getContentSize();
	//	CCLOG("getContentSize().width = %f, getContentSize().height = %f",
	//		getContentSize().width, getContentSize().height);
	//	LightMapScene->setPosition3D(Vec3(200 + i*(sc*sz.width - 150), 100, -300));
	//}

	Sprite3D* temp = (Sprite3D*)getChildByTag(100 + 13);
	CCLOG("getPositionX() = %f, getPositionY() = %f, getPositionZ = %f",
		temp->getPositionX(), temp->getPositionY(), temp->getPositionZ());
	CCLOG("getScaleX() = %f, getScaleX() = %f, getScaleZ = %f",
		temp->getScaleX(), temp->getScaleY(), temp->getScaleZ());
	CCLOG("getContentSize().width = %f, getContentSize().height = %f",
		temp->getContentSize().width, temp->getContentSize().height);
	CCLOG("getAnchorPoint().x = %f, getAnchorPoint().y = %f",
		temp->getAnchorPoint().x, temp->getAnchorPoint().y);

	//actions
	temp->runAction(Sequence::create(
		DelayTime::create(2),
		CCMoveBy::create(0.5, Vec3(0, 100, 0)),
		CCMoveTo::create(1, Vec3(500, _terrain->getHeight(500, -500), -500)),
		nullptr));
	temp->runAction(Sequence::create(
		DelayTime::create(2.5),
		CCRotateBy::create(1, Vec3(90, 0, 0)),
		nullptr));

	// actions
	_camera->runAction(Sequence::create(
		DelayTime::create(5),
		MoveBy::create(3, Vec3(0, 0, -1300)),
		CallFunc::create([=](){
		for (int i = 0; i < 14; ++i)
		{
			Sprite3D* temp = (Sprite3D*)getChildByTag(200 + i);
			temp->runAction(Sequence::create(
				RotateTo::create(0.5, Vec3(90, 0, 0)),
				nullptr));
		}
	}),
		nullptr));
}

void WTest3D::addEventListenerTest()
{
	//create a listener
	auto listener = EventListenerTouchAllAtOnce::create();
	listener->onTouchesMoved = CC_CALLBACK_2(WTest3D::onTouchesMovedsss, this);
	_eventDispatcher->addEventListenerWithSceneGraphPriority(listener, this);
}

void WTest3D::onTouchesMovedsss(const std::vector<cocos2d::Touch*>& touches, cocos2d::Event* event)
{
	if (touches.size() == 1)
	{
		float delta = Director::getInstance()->getDeltaTime();
		auto touch = touches[0];
		auto location = touch->getLocation();
		auto PreviousLocation = touch->getPreviousLocation();
		Point newPos = PreviousLocation - location;

		Vec3 cameraDir;
		Vec3 cameraRightDir;
		_camera->getNodeToWorldTransform().getForwardVector(&cameraDir);
		cameraDir.normalize();
		cameraDir.y = 0;
		_camera->getNodeToWorldTransform().getRightVector(&cameraRightDir);
		cameraRightDir.normalize();
		cameraRightDir.y = 0;
		Vec3 cameraPos = _camera->getPosition3D();
		cameraPos += cameraDir*newPos.y*delta;
		cameraPos += cameraRightDir*newPos.x*delta;
		_camera->setPosition3D(cameraPos);
	}
}
