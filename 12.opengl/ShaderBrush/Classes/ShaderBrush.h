//
//  
//
//

#ifndef __MyGame__ShaderScribble__
#define __MyGame__ShaderScribble__

#include "cocos2d.h"
USING_NS_CC;

class ShaderBrush : public cocos2d::Node
{
protected:
	ShaderBrush();
	virtual ~ShaderBrush();

public:
	static ShaderBrush* createWithVertex(const std::string &vert, const std::string& frag);
	void movePaint(cocos2d::Sprite *target, cocos2d::RenderTexture *canvas, cocos2d::Point worldPos);
   
private:
	cocos2d::Vec2 _center;
	cocos2d::Vec2 _resolution;
	float      _time;
	std::string _vertFileName;
	std::string _fragFileName;
	cocos2d::CustomCommand _customCommand;
	cocos2d::Sprite *_brush;
	cocos2d::BlendFunc _blend;

	bool initWithVertex(const std::string &vert, const std::string &frag);
	void loadShaderVertex(const std::string &vert, const std::string &frag);
};

#endif /* defined(__MyGame__ShadeTool__) */
