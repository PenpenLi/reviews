//
//
//
//
#include "ShaderTool.h"

const char* shaderProgram = 
#include "shaderBrush.frag";

#define renderShowWithoutOpacityKEY "renderShowWithoutOpacity"

//static bool transparentHitTest(cocos2d::Layer *layer, cocos2d::Point location)
//{
//    //This is the pixel we will read and test
//    uint8 pixel[4];
//    //Prepare a render texture to draw the receiver on, so you are able to read the required pixel and test it
//    CCSize screenSize = CCDirector::sharedDirector()->getWinSize();
//    CCRenderTexture* renderTexture = CCRenderTexture::create(screenSize.width, screenSize.height, kCCTexture2DPixelFormat_RGBA8888);
//    
//    renderTexture->begin();
//    layer->visit();
//    glReadPixels((GLint)location.x, (GLint)location.y, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, pixel);
//    renderTexture->end();
//    
//    //Test if the pixel's alpha byte is transparent
//    return pixel[3] == 0;
//}

static void _addShaderToCache(const char *key, const char *shaderProgram)
{
    if (!ShaderCache::sharedShaderCache()->programForKey(key))
    {
        CCGLProgram *p = new GLProgram();
        p->initWithVertexShaderByteArray(ccPositionTextureColor_vert, shaderProgram);
        p->addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position);
        p->addAttribute(kCCAttributeNameColor, kCCVertexAttrib_Color);
        p->addAttribute(kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);
        
        p->link();
        p->updateUniforms();
        
        CHECK_GL_ERROR_DEBUG();
        
        CCShaderCache::sharedShaderCache()->addProgram(p, key);
        p->release();
    }
}

ShaderTool::ShaderTool()
{
	_addShaderToCache(renderShowWithoutOpacityKEY, shaderProgram);
    m_brush = Sprite::create("brush-medium.png");
    m_brush->retain();
}

ShaderTool::~ShaderTool()
{

}

void ShaderTool::setBrushGLState(Texture2D *pTexture)
{    // set brush texture
	if (pTexture != NULL)
    {
		SpriteFrame *lFrame = SpriteFrame::createWithTexture(pTexture, 
			CCRectMake(0, 0, pTexture->getContentSize().width, pTexture->getContentSize().height));
        m_brush->setDisplayFrame(lFrame); 
	}

	// set Brush Blend
	//m_blend = { GL_ONE, GL_ZERO };
	//m_blend = BlendFunc{ GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA };
	m_brush->setBlendFunc(m_blend); 

    // set brush program
	GLProgram *program = ShaderCache::getInstance()->programForKey(renderShowWithoutOpacityKEY);
	if (m_brush->getGLProgram() != program)
    {
		m_brush->setGLProgram(program);
    }

	// set alpha with brush
	CCGLProgram *lShaderProgram = m_brush->getGLProgram();
	GLint lAlphaValueLocation = glGetUniformLocation(lShaderProgram->getProgram(), "u_brushOpacity");
	lShaderProgram->setUniformLocationWith1f(((float)m_brush->getOpacity()) / 255, lAlphaValueLocation);

	// set brush texture
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, m_brush->getTexture()->getName());
	GLuint lCCUniformSamplerS2Location = glGetUniformLocation(lShaderProgram->getProgram(), "CC_Texture0");
	lShaderProgram->setUniformLocationWith1i(lCCUniformSamplerS2Location, 0);

	//set brush texture size
	GLuint lTexSizeLocation = glGetUniformLocation(lShaderProgram->getProgram(), "v_texSize0");
	lShaderProgram->setUniformLocationWith2f(lTexSizeLocation, m_brush->getContentSize().width, m_brush->getContentSize().height);
}

void ShaderTool::setTargetGLTex(Texture2D *pTexture, Point localPos)
{
    //set the texture of target
    GLProgram *lShaderProgram = m_brush->getShaderProgram();
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, pTexture->getName());
    GLuint lCCUniformSamplerS2Location = glGetUniformLocation(lShaderProgram->getProgram(), "CC_Texture1");
    lShaderProgram->setUniformLocationWith1i(lCCUniformSamplerS2Location, 1);

    // set target size
    GLuint lTexSize1Location = glGetUniformLocation(lShaderProgram->getProgram(), "v_texSize1");
    lShaderProgram->setUniformLocationWith2f(lTexSize1Location, pTexture->getContentSize().width, pTexture->getContentSize().height );

    // set target texture coord
    float lX = (localPos.x - m_brush->getContentSize().width / 2.0) / pTexture->getContentSize().width;
    float lY = (localPos.y - m_brush->getContentSize().height / 2.0) / pTexture->getContentSize().height;
   
    GLuint lCoordLocation = glGetUniformLocation(lShaderProgram->getProgram(), "v_texCoord1");
    lShaderProgram->setUniformLocationWith2f(lCoordLocation, lX, lY);
}

void ShaderTool::setCanvasGLState(RenderTexture *canvas)
{
    static CCTexture2D *tex = NULL;
    if (tex) {
        delete tex;
        tex = new Texture2D();
    }
    Image *img = canvas->newImage();
    tex->initWithImage(img);
    delete img;

    GLProgram *pro = m_brush->getGLProgram();
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, tex->getName());
    GLuint textureID = pro->getUniformLocation("CC_Texture2");
    pro->setUniformLocationWith1i(textureID, 2);
}


void ShaderTool::paint(Sprite *pTarget, RenderTexture *canvas, Point worldPos)
{
    CCPoint localPos = canvas->getSprite()->convertToNodeSpace(worldPos);
    localPos.y = canvas->getContentSize().height - localPos.y;
    
    // set brush glstate    
    setBrushGLState();

    // set target glstate
	setTargetGLTex(pTarget->getTexture(), worldPos);

    // set canvas glstate
    //setCanvasGLState(canvas)
    
    // draw
    canvas->begin();
    m_brush->visit();
    CCLOG("brush pos:%f %f", m_brush->getPosition().x, m_brush->getPosition().y);
    CCLOG("canvase pos%f %f", canvas->getPosition().x, canvas->getPosition().y);
    canvas->end();
}

