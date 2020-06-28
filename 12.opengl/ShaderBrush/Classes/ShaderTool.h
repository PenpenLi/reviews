//
//  
//
//

#ifndef __MyGame__ShaderScribble__
#define __MyGame__ShaderScribble__

#include "cocos2d.h"
USING_NS_CC;

class ShaderTool : public Ref
{
public:
	ShaderTool();
	virtual ~ShaderTool();

    void setBrushGLState(Texture2D *pTexture = nullptr);
    void setCanvasGLState(RenderTexture *p);
    void setTargetGLTex(Texture2D *pTexture, Point localPos);
    //
    void paint(Sprite *target, RenderTexture *canvas, Point worldPos);
   
private:
    Sprite *m_brush;
    BlendFunc m_blend;
    
};

#endif /* defined(__MyGame__ShadeTool__) */
