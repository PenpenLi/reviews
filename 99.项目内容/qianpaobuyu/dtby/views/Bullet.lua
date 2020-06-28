local BulletSprite = class("BulletSprite", cc.Sprite)

function BulletSprite:ctor(type,speed,angle)
    self.isDie = false
    self.orignalAngle = angle
    self.movedir = cc.p(0,0)
    self.m_speed = speed
    self.spx = speed or 0.2 --真子弹速度x
    self.spy = speed or 0.2 --真子弹速度y
    local file = "Bullet"..type.."_Normal_1_b.png"
    self:initWithSpriteFrameName(file)
    self:setRotation(angle)
    self:initPhysicsBody()
end

function BulletSprite:initPhysicsBody()
    self:setPhysicsBody(cc.PhysicsBody:createBox(self:getContentSize()))
    --设置物理刚体类别掩码,可以通过检查或比较掩码来确定是否发生碰撞
    self:getPhysicsBody():setCategoryBitmask(2)
    --设置物理刚体碰撞掩码,可以通过检查或比较掩码来确定是否发生碰撞
    self:getPhysicsBody():setCollisionBitmask(0)
    --设置物理联系掩码,因为碰撞事件还是不会在默认状态下被接收
    self:getPhysicsBody():setContactTestBitmask(1)
    --设置子弹不受重力系数影响
    self:getPhysicsBody():setGravityEnable(false)
end

function BulletSprite:getT()
    return 2
end

function BulletSprite:fallingNet(fish)
    self.spx = 0
    self.spy = 0
    self.movedir = cc.p(0,0)
    local file = "sty_0_net0.png"
    self:initWithSpriteFrameName(file)
    local rand = math.random()
    self:setPosition(fish:getPosition())
    local call = cc.CallFunc:create(function() self.isDie = true end)
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),call))
end

return BulletSprite
