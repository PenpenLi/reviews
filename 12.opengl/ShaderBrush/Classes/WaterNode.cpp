
#include "WaterNode.h"
using namespace cocos2d;

enum
{
	SIZE_X = 1136,
	SIZE_Y = 640,
};

WaterNode::WaterNode()
{
}

WaterNode::~WaterNode()
{
}

WaterNode* WaterNode::WaterNodeWithVertex(const std::string &vert, const std::string& frag)
{
	auto node = new (std::nothrow) WaterNode();
	node->initWithVertex(vert, frag);
	node->autorelease();
	return node;
}

bool WaterNode::initWithVertex(const std::string &vert, const std::string &frag)
{
	_vertFileName = vert;
	_fragFileName = frag;
#if CC_ENABLE_CACHE_TEXTURE_DATA
	auto listener = EventListenerCustom::create(
		EVENT_RENDERER_RECREATED, [this](EventCustom* event){
			this->setGLProgramState(nullptr);
			loadShaderVertex(_vertFileName, _fragFileName);
	});

	_eventDispatcher->addEventListenerWithSceneGraphPriority(listener, this);
#endif

	loadShaderVertex(vert, frag);

	_time = 0;
	_resolution = Vec2(SIZE_X, SIZE_Y);
	m_texture = CCTextureCache::sharedTextureCache()->addImage("HelloWorld.png")->getName();

	scheduleUpdate();

	setContentSize(Size(SIZE_X, SIZE_Y));
	setAnchorPoint(Vec2(0.5f, 0.5f));

	return true;
}

void WaterNode::loadShaderVertex(const std::string &vert, const std::string &frag)
{
	auto fileUtiles = FileUtils::getInstance();

	// frag
	auto fragmentFilePath = fileUtiles->fullPathForFilename(frag);
	auto fragSource = fileUtiles->getStringFromFile(fragmentFilePath);

	// vert
	std::string vertSource;
	if (vert.empty()) {
		vertSource = ccPositionTextureColor_vert;
	}
	else {
		std::string vertexFilePath = fileUtiles->fullPathForFilename(vert);
		vertSource = fileUtiles->getStringFromFile(vertexFilePath);
	}

	auto glprogram = GLProgram::createWithByteArrays(vertSource.c_str(), fragSource.c_str());
	auto glprogramstate = GLProgramState::getOrCreateWithGLProgram(glprogram);
	setGLProgramState(glprogramstate);
}

void WaterNode::update(float dt)
{
	_time += dt;
}

void WaterNode::setPosition(const Vec2 &newPosition)
{
	Node::setPosition(newPosition);
	auto position = getPosition();
	auto frameSize = Director::getInstance()->getOpenGLView()->getFrameSize();
	auto visibleSize = Director::getInstance()->getVisibleSize();
	auto retinaFactor = Director::getInstance()->getOpenGLView()->getRetinaFactor();
	_center = Vec2(position.x * frameSize.width / visibleSize.width * retinaFactor, position.y * frameSize.height / visibleSize.height * retinaFactor);
}

void WaterNode::draw(Renderer *renderer, const Mat4 &transform, uint32_t flags)
{
	_customCommand.init(_globalZOrder, transform, flags);
	_customCommand.func = CC_CALLBACK_0(WaterNode::onDraw, this, transform, flags);
	renderer->addCommand(&_customCommand);
}

void WaterNode::onDraw(const Mat4 &transform, uint32_t flags)
{
	float w = SIZE_X, h = SIZE_Y;
	GLfloat vertices[12] = { 0, 0, w, 0, w, h, 0, 0, 0, h, w, h };

	auto glProgramState = getGLProgramState();
	glProgramState->setUniformVec2("resolution", _resolution);
	glProgramState->setUniformVec2("center", _center);
	glProgramState->setUniformFloat("time", _time);
	glProgramState->setVertexAttribPointer("a_position", 2, GL_FLOAT, GL_FALSE, 0, vertices);
	glProgramState->setUniformTexture("tex0", m_texture);
	glProgramState->setUniformVec4("color", Vec4(1,1,1,1));


	//ccGLBindTexture2D(m_texture);              
	//glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 0, 0, w, h, 0);  

	glProgramState->apply(transform);

	glDrawArrays(GL_TRIANGLES, 0, 6);

	CC_INCREMENT_GL_DRAWN_BATCHES_AND_VERTICES(1, 6);
}