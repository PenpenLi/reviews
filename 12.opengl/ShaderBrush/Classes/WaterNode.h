#ifndef __UIManager_WaterNode__
#define __UIManager_WaterNode__

#include"cocos2d.h"

class WaterNode : public cocos2d::Node
{
private:
	cocos2d::Vec2 _center;
	cocos2d::Vec2 _resolution;
	float      _time;
	std::string _vertFileName;
	std::string _fragFileName;
	cocos2d::CustomCommand _customCommand;

	GLuint      m_texture;
	GLuint      m_attributeColor, m_attributePosition;

private:
	WaterNode();
	virtual ~WaterNode();
	CREATE_FUNC(WaterNode);
	
	bool initWithVertex(const std::string &vert, const std::string &frag);
	void loadShaderVertex(const std::string &vert, const std::string &frag);
	virtual void update(float dt) override;
	virtual void draw(cocos2d::Renderer* renderer, const cocos2d::Mat4& transform, uint32_t flags) override;
	void onDraw(const cocos2d::Mat4& transform, uint32_t flags);

public:
	static WaterNode* WaterNodeWithVertex(const std::string &vert, const std::string &frag);
	virtual void setPosition(const cocos2d::Vec2 &newPosition) override;
};

#endif
