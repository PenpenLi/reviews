/*
1.创建rendertexture,在上面画调色板
    m_spriteColor = CCSprite::create("extensions/vitta.png");
    m_spriteColor->setPosition( ccp(m_spriteColor->getContentSize().width /2, m_spriteColor->getContentSize().height/2 * m_spriteColor->getScaleY()) );
    this->addChild(m_spriteColor, 0);
    //
    m_pRender = CCRenderTexture::create(s.width, s.height, kCCTexture2DPixelFormat_RGBA8888);
    m_pRender->setPosition(ccp(s.width / 2, s.height / 2 * m_spriteColor->getScaleY() ));
    this->addChild(m_pRender, 1);
    m_pRender->beginWithClear(0, 0, 0, 0);
    m_spriteColor->visit();
    m_pRender->end();
    m_spriteColor->setVisible(false);
2.根据点击位置，获取颜色
	void SelectColor::toSelectColor(CCPoint point)
{
    CCSize s = m_pRender->getSprite()->getTexture()->getContentSizeInPixels();
    int tx = s.width;
    int ty = s.height;
    
    int bytesPerPixel = 4;
    int bitsPerPixel = bytesPerPixel * 8;
    int bytesPerRow = bytesPerPixel * tx;
    int myDataLength = bytesPerRow * ty;
    
    GLubyte *buffer = (GLubyte *)malloc(sizeof(GLubyte)*myDataLength);
    if (!buffer) {
        free(buffer);
        m_color = ccc3(128, 128, 128);
    }
    m_pRender->begin();
    glReadPixels(0, 0, tx, ty, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    m_pRender->end();
    
    int x, y;
    x = point.x ;
    y = point.y ;
    const GLubyte r = buffer[(y * bytesPerRow + ((x * bytesPerPixel)+0))];
    const GLubyte g = buffer[(y * bytesPerRow + ((x * bytesPerPixel)+1))];
    const GLubyte b = buffer[(y * bytesPerRow + ((x * bytesPerPixel)+2))];
    const GLubyte o = buffer[(y * bytesPerRow + ((x * bytesPerPixel)+3))];
    ccColor3B color = {r, g, b};
    
    free(buffer);
    m_color = color;
}
*/

