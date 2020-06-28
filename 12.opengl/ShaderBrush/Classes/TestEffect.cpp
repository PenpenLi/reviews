#include "TestEffect.h"
#include "Particle3D/CCParticleSystem3D.h"
#include "Particle3D/PU/CCPUParticleSystem3D.h"
#include "Particle3D/PU/CCPUMaterialManager.h"
#include "WaterNode.h"
#include "ShaderNode.h"

using namespace std;
using namespace cocos2d;

WTestEffect::WTestEffect()
{

}

WTestEffect::~WTestEffect()
{

}

bool WTestEffect::init()
{
	if (!Layer::init())
	{
		return false;
	}
	return true;
}

void WTestEffect::update(float delta)
{
	Layer::update(delta);
}

WTestEffect* WTestEffect::create()
{
	WTestEffect* pRet = new(std::nothrow)WTestEffect();
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

void WTestEffect::showParticle()
{

}

void WTestEffect::showParticle3D()
{
	FileUtils::getInstance()->addSearchPath("Particle3D/materials");
	FileUtils::getInstance()->addSearchPath("Particle3D/scripts");
	FileUtils::getInstance()->addSearchPath("Particle3D/textures");
	Size size = Director::getInstance()->getWinSize();
	//Camera* _camera = Camera::createPerspective(30.0f, size.width / size.height, 1.0f, 1000.0f);
	//_camera->setPosition3D(Vec3(0.0f, 0.0f, 100.0f));
	//_camera->lookAt(Vec3(0.0f, 0.0f, 0.0f), Vec3(0.0f, 1.0f, 0.0f));
	//_camera->setCameraFlag(CameraFlag::USER1);
	//this->addChild(_camera);

	float zeye = Director::getInstance()->getZEye();
	Vec3 eye(size.width / 2, size.height / 2.0f, zeye),
		center(size.width / 2, size.height / 2, 0.0f),
		up(0.0f, 1.0f, 0.0f);
	_camera = Camera::createPerspective(60, size.width / size.height, 100, 3000);// zeye + size.height / 2.0f);
	_camera->setCameraFlag(CameraFlag::USER1);
	//_camera->setPosition3D(Vec3(0, 25, 15));
	_camera->setPosition3D(eye + Vec3(0, 60, 10));
	this->addChild(_camera);
	//this->setCameraMask(2);

	//test 1
	//auto rootps = PUParticleSystem3D::create("tornadoSystem.pu");
	//auto rootps = PUParticleSystem3D::create("rainSystem_2.pu");
	auto rootps = PUParticleSystem3D::create("timeShift.pu");	
	rootps->setCameraMask((unsigned short)CameraFlag::USER1);
	rootps->setScale(10.0f);
	rootps->setPosition3D(Vec3(500, 400, 100));
	rootps->startParticleSystem();
	this->addChild(rootps, 5, 10);
	rootps->setGlobalZOrder(40);

	//test 2
	//auto rootps = PUParticleSystem3D::create("advancedLodSystem.pu");
	//this->addChild(rootps, 0, 10);
	//rootps->setCameraMask((unsigned short)CameraFlag::USER1);
	//auto scale = ScaleBy::create(1.0f, 2.0f, 2.0f, 2.0f);
	//auto rotate = RotateBy::create(1.0f, Vec3(0.0f, 0.0f, 100.0f));
	//rootps->runAction(RepeatForever::create(Sequence::create(rotate, nullptr)));
	//rootps->runAction(RepeatForever::create(Sequence::create(scale, scale->reverse(), nullptr)));
	//rootps->startParticleSystem();

}

void WTestEffect::ShaderTest()
{
	//test1
	auto sn = ShaderNode::shaderNodeWithVertex("", "Shaders/shadertoy_LensFlare.fsh");
	auto s = Director::getInstance()->getWinSize();
	sn->setPosition(Vec2(s.width / 2, s.height / 2));
	//sn->setContentSize(Size(s.width / 2, s.height / 2));
	addChild(sn);

	//test2
	auto wsn = WaterNode::WaterNodeWithVertex("", "Shaders/waternode.fsh");
	wsn->setPosition(Vec2(s.width / 2, s.height / 2));
	//sn->setContentSize(Size(s.width / 2, s.height / 2));
	addChild(wsn, 1, 10);

	// test3
	Size visibleSize = Director::getInstance()->getVisibleSize();
	auto temp2 = Sprite::create("HelloWorld.png");
	//temp2->setPosition3D(Vec3(0, 0, 0));
	temp2->setPosition(visibleSize / 2);
	this->addChild(temp2, 5);
	//{ 源因子 , 混合因子 }
	//BlendFunc cbl = { GL_SRC_ALPHA, GL_ONE };
	//BlendFunc cbl = { GL_ONE, GL_ONE_MINUS_SRC_ALPHA };
	BlendFunc cbl = { GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA };
	temp2->setBlendFunc(cbl);
	auto fileNma = "Shaders/alight.fsh";
	//auto fileNma = "Shaders/example_HorizontalColor.fsh";
	auto fragStr = FileUtils::getInstance()->getStringFromFile(fileNma);
	GLchar * fragSource = (GLchar*)fragStr.c_str();
	auto p = GLProgram::createWithByteArrays(ccPositionTextureColor_noMVP_vert, fragSource);
	temp2->setGLProgram(p);
}
