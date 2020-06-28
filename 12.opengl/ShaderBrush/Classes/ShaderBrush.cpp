#include "ShaderBrush.h"

enum
{
	SIZE_X = 1136,
	SIZE_Y = 640,
};
#define	NAME_BRUSH "Shaders/brush.png"

ShaderBrush::ShaderBrush()
:_center(Vec2(0.0f, 0.0f))
, _resolution(Vec2(0.0f, 0.0f))
, _time(0.0f)
{

}

ShaderBrush::~ShaderBrush()
{

}

ShaderBrush* ShaderBrush::createWithVertex(const std::string &vert, const std::string& frag)
{
	auto node = new (std::nothrow) ShaderBrush();
	node->initWithVertex(vert, frag);
	node->autorelease();
	return node;
}

bool ShaderBrush::initWithVertex(const std::string &vert, const std::string &frag)
{
	_vertFileName = vert;
	_fragFileName = frag;
#if CC_ENABLE_CACHE_TEXTURE_DATA
	auto listener = EventListenerCustom::create(EVENT_RENDERER_RECREATED, [this](EventCustom* event){
		this->setGLProgramState(nullptr);
		loadShaderVertex(_vertFileName, _fragFileName);
	});

	_eventDispatcher->addEventListenerWithSceneGraphPriority(listener, this);
#endif

	loadShaderVertex(vert, frag);

	_time = 0;
	_resolution = Vec2(SIZE_X, SIZE_Y);

	scheduleUpdate();

	setContentSize(Size(SIZE_X, SIZE_Y));
	setAnchorPoint(Vec2(0.5f, 0.5f));

	return true;
}

void ShaderBrush::loadShaderVertex(const std::string &vert, const std::string &frag)
{
	auto fileUtiles = FileUtils::getInstance();

	// frag
	auto fragmentFilePath = fileUtiles->fullPathForFilename(frag);
	auto fragSource = fileUtiles->getStringFromFile(fragmentFilePath);

	// vert
	std::string vertSource;
	if (vert.empty()) {
		//vertSource = ccPositionTextureColor_vert;
		vertSource = ccPositionTextureColor_noMVP_vert;
	}
	else {
		std::string vertexFilePath = fileUtiles->fullPathForFilename(vert);
		vertSource = fileUtiles->getStringFromFile(vertexFilePath);
	}

	auto glprogram = GLProgram::createWithByteArrays(vertSource.c_str(), fragSource.c_str());
	auto glprogramstate = GLProgramState::getOrCreateWithGLProgram(glprogram);
	
	// brush
	_brush = Sprite::create(NAME_BRUSH);
	_brush->retain();
	_blend = { GL_ONE, GL_ZERO };
	//_blend = BlendFunc{ GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA };
	_brush->setBlendFunc(_blend); 
	_brush->setGLProgramState(glprogramstate);

	auto s = Director::getInstance()->getVisibleSize();
	GLProgramState* pGLPS = _brush->getGLProgramState();
	pGLPS->setUniformVec2("resolution", Vec2(s)); 
}

void ShaderBrush::movePaint(Sprite *pTarget, RenderTexture *pCanvas, Point worldPos)
{
	Point localPos = pCanvas->getSprite()->convertToNodeSpace(worldPos);
	localPos.y = pCanvas->getContentSize().height - localPos.y;

	GLProgramState* pGLPS = _brush->getGLProgramState();
	_brush->setPosition(worldPos);
//	CCLOG("movePaint worldPos%f %f", worldPos.x, worldPos.y);

	// set brush texture
	GL::bindTexture2DN(0, _brush->getTexture()->getName());
	pGLPS->setUniformTexture("u_brushTexture", _brush->getTexture()->getName());
	pGLPS->setUniformFloat("u_brushOpacity", ((float)_brush->getOpacity()) / 255);
	pGLPS->setUniformVec2("u_brushSize", Vec2(_brush->getContentSize()));

	// set target glstate && texture coord
	GL::bindTexture2DN(1, pTarget->getTexture()->getName());
	pGLPS->setUniformTexture("u_targetTexture", pTarget->getTexture()->getName());
	float lX = (localPos.x - _brush->getContentSize().width / 2.0) / pTarget->getContentSize().width;
	float lY = (localPos.y - _brush->getContentSize().height / 2.0) / pTarget->getContentSize().height;
	pGLPS->setUniformVec2("v_targetCoord", Vec2(lX, lY));
	pGLPS->setUniformVec2("u_targetSize", Vec2(pTarget->getContentSize()));

	// set canvas glstate
	//static CCTexture2D *pCanvasTex = NULL;
	//if (pCanvasTex) {
	//	delete pCanvasTex;
	//	pCanvasTex = new Texture2D();
	//}
	//Image *img = pCanvas->newImage();
	//pCanvasTex->initWithImage(img);
	//delete img;
	//GL::bindTexture2DN(2, pCanvasTex->getName());
	//_brush->getGLProgramState()->setUniformTexture("u_canvasTexture", pCanvasTex->getName());

	// draw
	pCanvas->begin();
	_brush->visit();
	//CCLOG("brush pos:%f %f", _brush->getPosition().x, _brush->getPosition().y);
	//CCLOG("canvase pos%f %f", pCanvas->getPosition().x, pCanvas->getPosition().y);
	pCanvas->end();
}
