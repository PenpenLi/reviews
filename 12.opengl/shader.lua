--[[
0.sprite 混合代码
    local render = cc.RenderTexture:create(1024,768)
	render:beginWithClear(0,0,0,0)
	local spr = cc.Sprite:create("xxx.png")
	spr:setBlendFunc(gl.ZERO,gl.ONE_MINUS_SRC_ALPHA)
	spr:visit()
	render:endToLua()

	self:addChild(render)
	render:setPosition(512,384)

1.sprite 使用shader: sprite, GLProgram, GLProgramState绑定
    local sprite=display.newSprite("shader.png")
        :move(display.center)
        :addTo(self)
 
    local prog = cc.GLProgram:create("shader.vsh", "shader.fsh")
    prog:link()
    prog:updateUniforms()

    local progStat = cc.GLProgramState:create(prog)
    sprite:setGLProgramState(progStat)

    

2.GPU 渲染原理
https://juejin.im/post/5ddbe82051882573033a4114
顶点着色器-图元装配-几何着色器-光栅化-片段着色器-测试与混合

3.相机机制
只要 cameraFlag&cameraMask 不为0就可在这个相机显示。
camera->lookAt必须在camera->setPostion3D之后，

4.涂抹功能 混合
	--擦除后要显示的图片
	local tupian = CCSprite:create(ROOT_RES .. "set/tip.png")
	tupian:setPosition(ccp(WinSizeWidth / 2, WinSizeHeight / 2))
	layer:addChild(tupian)
	
	-- rendertexture
	local tu = CCSprite:create(ROOT_RES..'set/user/BG.png')
	tu:setPosition(ccp(WinSizeWidth/2,WinSizeHeight/2))
	--layer:addChild(tu)
	--将图层遍历到texture,再将texture加入当前层
	local ptex = CCRenderTexture:create(1280,720)
	ptex:setPosition(ccp(WinSizeWidth/2,WinSizeHeight/2))
	layer:addChild(ptex)
	ptex:begin()
	tu:visit()
	ptex:endToLua()

	--橡皮擦CCDrawNode
	--point = CCDrawNode:create()
	--point:drawDot(ccp(0,0),10,ccc4f(0,0,0,0))
	local point = CCSprite:create(ROOT_RES..'set/labBtn.png')
	layer:addChild(point)
	-- 处理涂抹
	layer:registerScriptTouchHandler(function (eventType,x,y)
		if eventType == "began" then
			cclog("began")
			return true
		elseif eventType == "moved" then
			cclog("move")
			point:setPosition(x,y)
			local blend = ccBlendFunc()
			blend.src = 1
			blend.dst = 0
			point:setBlendFunc(blend)
			ptex:begin()
			point:visit()
			ptex:endToLua()
		elseif eventType == "ended" then
			cclog("end")
		elseif eventType == "cancelled" then
			
		end
	end,false,-1000,true)
	layer:setTouchEnabled(true)

5.涂抹功能 shader


--]]    


