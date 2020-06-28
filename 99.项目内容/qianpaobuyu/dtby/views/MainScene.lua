require("cocos.init")
local fishTrace1_1 = require("app.models.fishTrace1_1")
local fishTrace1_2 = require("app.models.fishTrace1_2")
local fishTrace1_3 = require("app.models.fishTrace1_3")
local fishTrace1_4 = require("app.models.fishTrace1_4")
local fishTrace1_5 = require("app.models.fishTrace1_5")

local fishTrace2_1 = require("app.models.fishTrace2_1")
local fishTrace2_2 = require("app.models.fishTrace2_2")

local fishTrace3_1 = require("app.models.fishTrace3_1")
local fishTrace3_2 = require("app.models.fishTrace3_2")
local fishTrace3_3 = require("app.models.fishTrace3_3")
local fishTrace3_4 = require("app.models.fishTrace3_4")
local fishTrace3_5 = require("app.models.fishTrace3_5")
local fishTrace3_6 = require("app.models.fishTrace3_6")

local fishTrace4_1 = require("app.models.fishTrace4_1")
local fishTrace4_2 = require("app.models.fishTrace4_2")

local fishTrace5_1 = require("app.models.fishTrace5_1")
local fishTrace5_2 = require("app.models.fishTrace5_2")
local fishTrace5_3 = require("app.models.fishTrace5_3")
local fishTrace5_4 = require("app.models.fishTrace5_4")
local fishTrace5_5 = require("app.models.fishTrace5_5")

local MainScene = class("MainScene", cc.load("mvc").ViewBase)
local BulletSprite = require("app.views.Bullet")
local FishSprite = require("app.views.Fish")
local Game_CMD = require("app.views.Common")
local scheduler = cc.Director:getInstance():getScheduler()
local winsize = cc.Director:getInstance():getVisibleSize()
local bulletLimite = 100
local m_WScale = winsize.width/1280/100 --宽度比例
local m_HScale = winsize.height/720/100 --高度比例
local m_AScale = 0.01 --角度比例

MainScene.RESOURCE_FILENAME = "MainScene.csb"

function MainScene:onCreate()
    --子弹集合
    self.bullets = {}
    --鱼集合
    self.fishs = {}
    --自动发射定时器
    self.m_autoShootSchedule = nil
    --所有子弹定时器
    self.m_scheduleUpdateBullet = nil
    --所有鱼定时器
    self.m_scheduleUpdateFish = nil
    --物体刚体数据
    self.m_bodyList = {}
    --鱼层
    self.m_fishLayer = cc.Layer:create()
    :addTo(self,5)
    --根节点
    local root = self:getResourceNode()
    --座位布局
    self.panel_seat = root:getChildByName("panel_seat")
    --左1等待节点
    local leftone_wait = self.panel_seat:getChildByName("leftone_wait")
    leftone_wait:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1.5),cc.FadeIn:create(1.5))))
    --左2等待节点
    local lefttwo_wait = self.panel_seat:getChildByName("lefttwo_wait")
    lefttwo_wait:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1.5),cc.FadeIn:create(1.5))))
    --右2等待节点
    local righttwo_wait = self.panel_seat:getChildByName("righttwo_wait")
    righttwo_wait:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1.5),cc.FadeIn:create(1.5))))
    --右1炮台节点
    local rightone_cannon = self.panel_seat:getChildByName("rightone_cannon")
    --本家可以控制的炮台
    self.cannon = rightone_cannon:getChildByName("cannon")
    self.cannonPosX = rightone_cannon:getPositionX()
    self.cannonPosY = rightone_cannon:getPositionY()

    --给布局添加点击事件
    self.panel_seat:addTouchEventListener(function(sender,type)
        --if #self.fishs == 0 then return end
        if type == ccui.TouchEventType.began then
            self:onTouchBegan(sender,type)
        elseif type == ccui.TouchEventType.moved then
            self:onTouchMoved(sender,type)
        elseif type == ccui.TouchEventType.ended then
            self:onTouchEnded(sender,type)
        end
    end)

    self:registerEvent(self)
    self:readyBodyPlist("Resource/fish_bodies.plist")
    self:readyBodyPlist("Resource/bullet_bodies.plist")
end

--解析刚体数据 plist
function MainScene:readyBodyPlist( param )
    local Path = cc.FileUtils:getInstance():fullPathForFilename(param)
    local datalist = cc.FileUtils:getInstance():getValueMapFromFile(Path)
    local bodies = datalist["bodies"]

    --解析数据
    for k,v in pairs(bodies) do
        if  k ~= nil then
            local bodyName = k
            local sub = bodies[bodyName]
            local fixtures = sub["fixtures"]
            local polygonsarr = fixtures[1]
            local polygons = polygonsarr["polygons"]
            local points = {}
            for i=1,#polygons do
                table.insert(points, polygons[i])
            end
            table.insert(self.m_bodyList,{k = bodyName,p = points})
        end
    end
end

function MainScene:registerEvent(node)
    if nil == node then
        return false
    end
    local function onNodeEvent( event )
    --进入场景事件
    if event == "enter" and nil ~= node.onEnter then
        node:onEnter()
    --进入场景且过渡动画结束事件
    elseif event == "enterTransitionFinish" then
        if nil ~= node.onEnterTransitionFinish then
            node:onEnterTransitionFinish()
        end
    --退出场景且开始过渡动画开始事件
    elseif event == "exitTransitionStart" and nil ~= node.onExitTransitionStart then
        node:onExitTransitionStart()
    --退出场景事件
    elseif event == "exit" and nil ~= node.onExit then
        if nil ~= node._listener then
            local eventDispatcher = node:getEventDispatcher()
            eventDispatcher:removeEventListener(node._listener)
        end
        if nil ~= node.onExit then
            node:onExit()
        end
    --场景对象被清除事件
    elseif event == "cleanup" and nil ~= node.onCleanup then
        node:onCleanup()
        end
    end
    node:registerScriptHandler(onNodeEvent)
end

function MainScene:onEnter()
    print("onEnter")
    -- 创建物理世界
    cc.Director:getInstance():getRunningScene():initWithPhysics()
    cc.Director:getInstance():getRunningScene():getPhysicsWorld():setGravity(cc.p(0, -100))

    self.m_scheduleUpdateBullet = scheduler:scheduleScriptFunc(handler(self,self.updateBullet),0.031,false)

    local function imageLoaded(texture)
        cc.SpriteFrameCache:getInstance():addSpriteFrames("Resource/bullet_guns_coins.plist")
        cc.SpriteFrameCache:getInstance():addSpriteFrames("Resource/fish_move1.plist")
        cc.SpriteFrameCache:getInstance():addSpriteFrames("Resource/fish_move2.plist")
        cc.SpriteFrameCache:getInstance():addSpriteFrames("Resource/effect_bg_water0.plist")
        cc.SpriteFrameCache:getInstance():addSpriteFrames("Resource/effect_bg_water1.plist")
        cc.SpriteFrameCache:getInstance():addSpriteFrames("Resource/effect_bg_water2.plist")
        cc.SpriteFrameCache:getInstance():addSpriteFrames("Resource/fish_jinbi_10.plist")
        cc.SpriteFrameCache:getInstance():addSpriteFrames("Resource/batch_frame_net.plist")
        self:readAni()
    end
    cc.Director:getInstance():getTextureCache():addImageAsync("Resource/bullet_guns_coins.png",function()end)
    cc.Director:getInstance():getTextureCache():addImageAsync("Resource/fish_move1.png", function()end)
    cc.Director:getInstance():getTextureCache():addImageAsync("Resource/fish_move2.png", function()end)
    cc.Director:getInstance():getTextureCache():addImageAsync("Resource/effect_bg_water0.png", function()end)
    cc.Director:getInstance():getTextureCache():addImageAsync("Resource/effect_bg_water1.png", function()end)
    cc.Director:getInstance():getTextureCache():addImageAsync("Resource/effect_bg_water2.png", function()end)
    cc.Director:getInstance():getTextureCache():addImageAsync("Resource/fish_jinbi_10.png", function()end)
    cc.Director:getInstance():getTextureCache():addImageAsync("Resource/batch_frame_net.png", imageLoaded)

    -- 水波效果
    local manager = ccs.ArmatureDataManager:getInstance()
    manager:addArmatureFileInfo("Resource/effect_bg_water.ExportJson")
    manager:addArmatureFileInfo("Resource/fish_jinbi_1.ExportJson")

    local armature = ccs.Armature:create("effect_bg_water")
    armature:setPosition(1280/2,720/2)
    self:addChild(armature,1000)
    armature:getAnimation():play("effect_bg_water_animation",-1,1)

    --自动创建鱼
    self:runAction(cc.Sequence:create(cc.DelayTime:create(5.5), cc.CallFunc:create(handler(self,self.createFish))))
    self.m_scheduleUpdateFish = scheduler:scheduleScriptFunc(handler(self,self.updateFish),0.031,false)
    --self.m_scheduleUpdateFish = scheduler:scheduleScriptFunc(handler(self,self.goRubish),10,false)
    -- 碰撞监听
    self:addContact()
end

function MainScene:onExit()
    -- 移除碰撞监听
    cc.Director:getInstance():getEventDispatcher():removeEventListener(self.contactListener)

    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("Resource/bullet_guns_coins.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("Resource/bullet_guns_coins.png")

    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("Resource/fish_move1.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("Resource/fish_move1.png")

    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("Resource/fish_move2.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("Resource/fish_move2.png")

    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("Resource/effect_bg_water0.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("Resource/effect_bg_water0.png")

    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("Resource/effect_bg_water1.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("Resource/effect_bg_water1.png")

    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("Resource/effect_bg_water2.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("Resource/effect_bg_water2.png")

    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("Resource/fish_jinbi_10.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("Resource/fish_jinbi_10.png")

    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("Resource/batch_frame_net.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("Resource/batch_frame_net.png")
end

function MainScene:updateFish(dt)
    if #self.fishs == 0 then return end --没有鱼直接返回
    if #self.fishs <= 50 then self:createFish() end
    for i=#self.fishs,1,-1 do
        local fish = self.fishs[i]
        if fish.isDie then --判断鱼已经死亡
            fish:removeAllChildren(true)
            fish:removeFromParent(true)
            table.remove(self.fishs,i)
        elseif fish.alreadyDie == false then --鱼游动
            if (fish.Xpos < -200 or fish.Xpos > 1500 or fish.Ypos < -200 or fish.Ypos > 900) then
                fish.isDie = true
            else
                if fish.CurrPathindex < 5 then
                    local NextRolation = Game_CMD.PathIndex[fish.m_pathIndex][fish.CurrPathindex + 1][3]
                    if NextRolation > 360 then
                        NextRolation = NextRolation - 360
                    end
                    if fish.Rolation == NextRolation then
                        fish.CurrPathindex = fish.CurrPathindex + 1
                        --fish:runAction(cc.RotateTo:create(Game_CMD.PathIndex[fish.m_pathIndex][fish.CurrPathindex][7], fish.Rolation + fish.disAngle))
                    else
                        if Game_CMD.PathIndex[fish.m_pathIndex][fish.CurrPathindex + 1][7] == 0 then
                            fish.Rolation = fish.Rolation + 1
                            if fish.Rolation > 360 then
                                fish.Rolation = fish.Rolation - 360
                            end
                        elseif Game_CMD.PathIndex[fish.m_pathIndex][fish.CurrPathindex + 1][7] == 1 then
                            fish.Rolation = fish.Rolation - 1
                            if fish.Rolation < 0 then
                                fish.Rolation = fish.Rolation + 360
                            end
                        end
                        if fish.m_pathIndex ~= 20 then
                            fish:setRotation(fish.Rolation - 180)
                        else
                            fish:setRotation(fish.Rolation)
                        end
                    end
                end
                fish.m_speed = fish.m_speed + Game_CMD.PathIndex[fish.m_pathIndex][fish.CurrPathindex][6] * 1
                fish.Xpos = fish.Xpos + Game_CMD.FISHMOVEBILI * fish.mX * fish.m_speed * math.sin(fish.Rolation * 0.0174533)
                fish.Ypos = fish.Ypos + Game_CMD.FISHMOVEBILI * fish.mY * fish.m_speed * math.cos(fish.Rolation * 0.0174533)
                fish:setConvertPoint(cc.p(fish.Xpos, fish.Ypos))
            end
        end
    end
end

function MainScene:createFish()
    local num = math.random(10,20)
    for i=1,num do
        local pathType = math.random(100)
        local pathIndex = nil
        if pathType <= 97 then
            pathIndex = math.random(35) --36及以上均在打转
        elseif pathType > 97 then
            pathIndex = math.random(36,47)
        end
        if pathIndex ~= 1 and pathIndex ~= 4 and pathIndex ~= 9 and pathIndex ~= 10 and pathIndex ~= 28 and pathIndex ~= 33 and pathIndex ~= 44 and pathIndex ~= 45 then
            local fishTrace = {}
            local path = math.random(41)
            local fishType = math.random(100)
            local type = nil
            if fishType < 98 then
                type = math.random(15) -- 16-20为大鱼 21为鳄鱼 22为章鱼 23为白龙 24为炸弹 25为熊猫 26为渣渣 27为轮子
            elseif fishType == 99 then
                type = math.random(16,20)
            elseif fishType == 100 then
                type = math.random(16,24)
            end
            if type ~= 21 and type ~= nil then --鳄鱼体积过大,当boss处理
                fishTrace = fishTrace1_1[path]
                --路线1,4,9,10,28,33会倒着游44,45,最多47
                local fish = FishSprite:create(type,1,pathIndex,self.m_bodyList,self)
                fish:setscene(fishTrace)
                local pos = math.random(100)
                if pos >= 1 and pos <= 23 then
                    fish:setConvertPoint(cc.p(fishTrace[1][1] * m_WScale * 0.5, fishTrace[1][2] * m_HScale + 500), fishTrace[1][3] * m_AScale) --上中角
                elseif pos >= 24 and pos <= 46 then
                    fish:setConvertPoint(cc.p(fishTrace[1][1] * m_WScale * 0.5, fishTrace[1][2] * m_HScale * 0.001 - 200), fishTrace[1][3] * m_AScale) --下中角
                elseif pos >= 47 and pos <= 69 then
                    fish:setConvertPoint(cc.p(fishTrace[1][1] * m_WScale + 300, fishTrace[1][2] * m_HScale + 200), fishTrace[1][3] * m_AScale) --右上角
                elseif pos >= 70 and pos <= 92 then
                    fish:setConvertPoint(cc.p(fishTrace[1][1] * m_WScale + 300, fishTrace[1][2] * m_HScale * 0.5), fishTrace[1][3] * m_AScale) --右中角
                elseif pos >= 93 and pos <= 96 then
                    fish:setConvertPoint(cc.p(fishTrace[1][1] * m_WScale * 0.0001 - 100, fishTrace[1][2] * m_HScale + 400), fishTrace[1][3] * m_AScale) --左上角
                elseif pos >= 97 and pos <= 100 then
                    fish:setConvertPoint(cc.p(fishTrace[1][1] * m_WScale * 0.00001 - 100, fishTrace[1][2] * m_HScale * 0.7), fishTrace[1][3] * m_AScale) --左中角
                end
                self.m_fishLayer:addChild(fish,type+1)
                table.insert(self.fishs,fish)
            end
        end
    end
end

function MainScene:goRubish(dt)
    collectgarbage("collect")
end

function MainScene:updateBullet(dt)
    --print(collectgarbage("count"))
    if #self.bullets == 0 then return end --没有子弹直接返回
    for i=#self.bullets,1,-1 do
        if self.bullets[i].isDie then --判断子弹已经死亡
            self.bullets[i]:removeAllChildren(true)
            self.bullets[i]:removeFromParent(true)
            table.remove(self.bullets,i)
            --collectgarbage("collect")
        else --子弹移动
            local posx = self.bullets[i]:getPositionX()+self.bullets[i].movedir.x*self.bullets[i].spx
            local posy = self.bullets[i]:getPositionY()+self.bullets[i].movedir.y*self.bullets[i].spy
            if posx <= 0 or posx >= winsize.width then
                self.bullets[i].spx = -self.bullets[i].spx
                self.bullets[i].orignalAngle = -self.bullets[i].orignalAngle
            end
            if posy <= 0 or posy >= winsize.height then
                self.bullets[i].spy = -self.bullets[i].spy
                self.bullets[i].orignalAngle = 180-self.bullets[i].orignalAngle
            end
            self.bullets[i]:setRotation(self.bullets[i].orignalAngle)
            self.bullets[i]:setPosition(cc.p(posx, posy))
        end
    end
end

function MainScene:productBullet(type,speed)
    if #self.bullets >= bulletLimite then return end
    local bullet = nil
    local angle = self.cannon:getRotation()
    bullet = BulletSprite:create(type,speed,angle)
    self:addChild(bullet,100)

    --math.rad返回一个角度数对应的弧度值
    angle = math.rad(90-angle)
    --使用内部函数根据弧度值计算cos余弦值和sin正弦值
    local movedir = cc.pForAngle(angle)
    movedir = cc.p(movedir.x*55,movedir.y*55)
    local offset = cc.p(25*math.sin(angle),5*math.cos(angle))
    local moveby = cc.MoveBy:create(0.065,cc.p(-movedir.x*0.3,-movedir.y*0.3))
    self.cannon:runAction(cc.Sequence:create(moveby,moveby:reverse()))

    local pos = cc.p(self.cannonPosX,self.cannonPosY)
    pos = cc.p(pos.x,pos.y-offset.y/2)
    bullet:setPosition(pos)
    bullet.movedir = movedir
    table.insert(self.bullets,bullet)
    bullet = nil
end

function MainScene:getAngleByTwoPoint(vec)
    local point = cc.p(vec.x-self.cannonPosX,vec.y-self.cannonPosY)
    --math.atan2返回指定点到原点(0,0)之间直线倾斜角的反正切值,返回值的单位是弧度
    --math.deg返回一个弧度数对应的角度值
    local angle = 90 - math.deg(math.atan2(point.y,point.x))
    self.cannon:setRotation(angle)
end

function MainScene:onTouchBegan(touch,event)
    local location = touch:getTouchBeganPosition()
    self:getAngleByTwoPoint(location)
    self:productBullet(1,0.75)
    local function updateAuto(dt)
        self:productBullet(1,0.75)
    end
    self.m_autoShootSchedule = scheduler:scheduleScriptFunc(updateAuto,0.3,false)
    return true
end

function MainScene:onTouchMoved(touch,event)
    local location = touch:getTouchMovePosition()
    self:getAngleByTwoPoint(location)
end

function MainScene:onTouchEnded(touch,event)
    if self.m_autoShootSchedule ~= nil then
        scheduler:unscheduleScriptEntry(self.m_autoShootSchedule)
    end
end

function MainScene:readAni()
    --25种
    local fishFrameMoveNum =
    {
        6,8,12,
        12,12,13,
        12,10,12,
        8,12,6,
        12,10,12,
        12,12,9,
        16,20,15,
        12,8,1,
        12
    }
    --22 + 3种
    local fishFrameDeadNum =
    {
        2,2,2,
        3,3,3,
        6,3,2,
        6,4,3,
        3,3,3,
        3,3,3,
        8,20,9,
        0,0,0,
        12
    }

    --鱼游动
    for i=1,25 do
        local frames = {}
        local actionTime = 0.2
        if i == 20 then --金龙
            actionTime = 0.3
        end
        local num = fishFrameMoveNum[i]
        for j=1,num do
            local frameName = string.format("fishMove_%03d_%02d.png",i,j)
            local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
            table.insert(frames,frame)
        end
        local animation = cc.Animation:createWithSpriteFrames(frames,actionTime)
        --设置两帧之间的间隔时间
        animation:setDelayPerUnit(3/num)
        local key = string.format("animation_fish_move%d",i)
        cc.AnimationCache:getInstance():addAnimation(animation,key)
    end
end

function MainScene:addContact()
    local function onContactBegin(contact)
        local a = contact:getShapeA():getBody():getNode()
        local b = contact:getShapeB():getBody():getNode()
        local bullet
        if a and b then
            if a:getT() == 2 then
                bullet = a
            end
            if b:getT() == 2 then
                bullet = b
            end
        end

        local fish
        if a and b then
            if a:getT() == 1 then
                fish = a
            end
            if b:getT() == 1 then
                fish = b
            end
        end

        --碰撞出网清除子弹以及附带数据
        if nil ~= bullet then
            if nil ~= fish then
                fish:runAction(cc.Sequence:create(cc.TintTo:create(0.2, 255, 0, 0), cc.TintTo:create(0.2, 255, 255, 255)))
                fish.live = fish.live - 1
                fish:fallingCoin()
                bullet:fallingNet(fish)
            end
        end
        return true
    end

    local dispatcher = self:getEventDispatcher()
    self.contactListener = cc.EventListenerPhysicsContact:create()
    self.contactListener:registerScriptHandler(onContactBegin, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
    dispatcher:addEventListenerWithSceneGraphPriority(self.contactListener, self)
end

return MainScene
