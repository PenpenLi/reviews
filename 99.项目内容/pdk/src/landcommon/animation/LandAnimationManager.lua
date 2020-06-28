--
-- LandAnimationManager
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 跑得快动画管理
--

local LandGlobalDefine = require("app.game.pdk.src.landcommon.data.LandGlobalDefine")
local LandArmature = require("app.game.pdk.src.landcommon.animation.LandArmature")
local LandArmatureResource = require("src.app.game.pdk.src.landcommon.animation.LandArmatureResource")
local LandAnimationManager = class("LandAnimationManager")

LandAnimationManager.instance = nil

-- 获取经典跑得快管理的单例
function LandAnimationManager:getInstance(animationLayer)
    if LandAnimationManager.instance == nil then
       LandAnimationManager.instance = LandAnimationManager.new(animationLayer)
    end

    return LandAnimationManager.instance
end
function LandAnimationManager:ctor(animationLayer)
    self.m_animationLayer = animationLayer 
    self.loopLandArmatures = {}
    self.spriteAnis = {}
    self.mLandArmatures = {}

end 

-- 跑得快动画类型
function LandAnimationManager:playAnimationWithType( m_bTurnOutType, pos )
    local winsize = cc.Director:getInstance():getWinSize()
    if not pos then pos = cc.p(winsize.width * 0.5, winsize.height * 0.5) end

    self:playActionAnim(m_bTurnOutType, pos)
    self:playSpriteFrameAnim(m_bTurnOutType, pos)
    self:PlayEffectAnimation(m_bTurnOutType, pos)
end
-- 动作动画
function LandAnimationManager:playActionAnim( m_bTurnOutType, pos )
    local ttInfo = 
    {
        [LandGlobalDefine.CT_SINGLE_LINE]       = { name = "fj_anim_txt_4.png" },
        [LandGlobalDefine.CT_DOUBLE_LINE]       = { name = "fj_anim_txt_3.png" },
        [LandGlobalDefine.CT_THREE_TAKE_TT]     = { name = "fj_anim_txt_5_0.png" },
        [LandGlobalDefine.CT_FOUR_TAKE_THREE]   = { name = "fj_anim_txt_7_0.png" },
    }
    local tInfo = ttInfo[m_bTurnOutType]
    if not tInfo then return end 

    -- 动画添加
    local run_animate = cc.DelayTime:create(1.0)
    -- local animate_forever = cc.RepeatForever:create(run_animate)
    local run_sequence = cc.Sequence:create(run_animate, cc.RemoveSelf:create())
    -- 精灵
    local spr_temp = cc.Sprite:createWithSpriteFrameName(tInfo.name)
    spr_temp:runAction(run_sequence)
    spr_temp:setPosition(pos)
    self.m_animationLayer:addChild(spr_temp)
    return true
end
-- 播放帧动画
function LandAnimationManager:playSpriteFrameAnim( m_bTurnOutType, pos )
    local ttInfo = 
    {
        [LandGlobalDefine.CT_FEIJI_TAKE_TWO]    = { beginid = 1, endid = 22, formatname = "fj_anim_plane_%03d.png" },
        -- [LandGlobalDefine.CT_BOMB_CARD]         = { beginid = 1, endid = 10, formatname = "fj_anim_bomb_zd%02d.png" },
    }
    local tInfo = ttInfo[m_bTurnOutType]
    if not tInfo then return end 

    -- 动画添加
    local run_animation = cc.Animation:create()
    for i = tInfo.beginid, tInfo.endid do
        if (m_bTurnOutType == LandGlobalDefine.CT_BOMB_CARD) and (i == 2 or i == 9) then
        else
            local spriteFrame =  display.newSpriteFrame( string.format(tInfo.formatname, i) )
            if spriteFrame then
                run_animation:addSpriteFrame(spriteFrame)
            end
        end
    end
    run_animation:setDelayPerUnit(0.1)
    run_animation:setRestoreOriginalFrame(true)
    local run_animate = cc.Animate:create(run_animation)
    -- local animate_forever = cc.RepeatForever:create(run_animate)
    local run_sequence = cc.Sequence:create(run_animate, cc.RemoveSelf:create())
    -- 精灵
    local spr_temp = cc.Sprite:createWithSpriteFrameName( string.format(tInfo.formatname, tInfo.beginid) )
    spr_temp:runAction(run_sequence)
    spr_temp:setPosition(pos)
    self.m_animationLayer:addChild(spr_temp)
    return true
end

--播放动画
function LandAnimationManager:PlayEffectAnimation( m_bTurnOutType, pos)
    --LogINFO("-----------------PlayEffectAnimation------------------")
    if false then
    ---[[ 
    elseif m_bTurnOutType == LandGlobalDefine.CT_BOMB_CARD or m_bTurnOutType == LandGlobalDefine.CT_RUAN_BOMB or m_bTurnOutType == LandGlobalDefine.CT_LAIZI_BOMB then -- 炸弹判断
        LogINFO("播放炸弹动画")
        local info = LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_ZADAN]
        dump(info, "info::::", 10)
        local function removeLandArmature()
            if info.isCache == false then
                self:stopAndClearArmatureAnimation(info.resourceById)
            end
        end
        local landArmature = self:playArmatureAnimation( info.resourceById, pos, removeLandArmature )
        self.mLandArmatures[info.resourceById] = landArmature
        landArmature:runAction(cc.Sequence:create(cc.FadeOut:create(info.time),cc.CallFunc:create(removeLandArmature)))
    --]]

    --[[ 目前没用的
    elseif m_bTurnOutType == LandGlobalDefine.CT_FEIJI_TAKE_ONE or 
        m_bTurnOutType == LandGlobalDefine.CT_FEIJI_TAKE_TWO or m_bTurnOutType == LandGlobalDefine.CT_THREE_LINE then 
        LogINFO("播放飞机动画")
        local info = LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_AIR_PLANE]
        local function removeLandArmature()
            if info.isCache == false then
                self:stopAndClearArmatureAnimation(info.resourceById)
            end
        end
        local landArmature = self:playArmatureAnimation( info.resourceById , pos)
        --landArmature:runAction(cc.Sequence:create(cc.MoveTo:create(info.time, info.po2), cc.CallFunc:create(removeLandArmature)))

    elseif m_bTurnOutType == LandGlobalDefine.CT_DOUBLE_LINE then
        LogINFO("播放连对动画, LandGlobalDefine.CT_DOUBLE_LINE")
        local info = LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_LIANDUI]
        local function removeLandArmature()
            if info.isCache == false then
                self:stopAndClearArmatureAnimation(info.resourceById)
            end
        end
        local landArmature = self:playArmatureAnimation( info.resourceById, pos, removeLandArmature )
        self.mLandArmatures[info.resourceById] = landArmature
        --landArmature:runAction(cc.Sequence:create(cc.FadeOut:create(info.time),cc.CallFunc:create(removeLandArmature)))

    elseif m_bTurnOutType == LandGlobalDefine.CT_SINGLE_LINE then
        LogINFO("播放顺子动画")
        local info = LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_SHUNZHI]
        local function removeLandArmature()
            if info.isCache == false then
                self:stopAndClearArmatureAnimation(info.resourceById)
            end
        end
        local landArmature = self:playArmatureAnimation( info.resourceById, pos, removeLandArmature )
        self.mLandArmatures[info.resourceById] = landArmature
        --landArmature:runAction(cc.Sequence:create(cc.FadeOut:create(info.time),cc.CallFunc:create(removeLandArmature)))

    elseif m_bTurnOutType == LandGlobalDefine.CT_MISSILE_CARD then
        LogINFO("播放火箭动画")
        local info = LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_HUOJIANBAOZA]
        local function removeLandArmature()
            if info.isCache == false then
                self:stopAndClearArmatureAnimation(info.resourceById)
            end
        end
        local landArmature = self:playArmatureAnimation( info.resourceById, pos, removeLandArmature , true)
        self.mLandArmatures[info.resourceById] = landArmature
        --landArmature:runAction(cc.Sequence:create(cc.FadeOut:create(info.time),cc.CallFunc:create(removeLandArmature)))

    elseif m_bTurnOutType == LandGlobalDefine.CT_CHUNTIAN then
        LogINFO("播放春天动画")
        local info = LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_SPRING]
        local function removeLandArmature()
            LogINFO("removeLandArmature id:"..info.resourceById)
            if info.isCache == false then
                self:stopAndClearArmatureAnimation(info.resourceById)
            end
        end
        local landArmature = self:playArmatureAnimation( info.resourceById, pos, removeLandArmature , true)
        self.mLandArmatures[info.resourceById] = landArmature
        --landArmature:runAction(cc.Sequence:create(cc.FadeOut:create(info.time),cc.CallFunc:create(removeLandArmature)))
    --]]

    end
    
end

--播放动画 红灯 胜利 失败 等待房开局
function LandAnimationManager:PlayAnimation( animationType, layer, pos)
    LogINFO("-----------------PlayAnimation------------------animationType"..animationType)
    local info = LandArmatureResource.armatureResourceInfo[animationType]
    local function removeLandArmature()
        LogINFO("removeLandArmature id:"..info.resourceById)
        if info.isCache == false then
            self:stopAndClearArmatureAnimation(info.resourceById)
        end
    end
    local landArmature = nil
   layer = layer and layer or self.m_animationLayer
    landArmature  = LandArmature.new( info.resourceById, layer, handerBack )
    if info.isDelete == false then
        landArmature:setMovementEventCallFunc(removeLandArmature)
    end
    layer:addChild( landArmature) 
    layer:setLocalZOrder(100)
    self.mLandArmatures[info.resourceById] = landArmature
    landArmature:setPosition(pos and pos or info.po1 )
    landArmature:playAnimation(info.isLoop)
    return landArmature
end
-- 地主 农民形象, 比赛场动画(开始,第几名,晋级)
function LandAnimationManager:getAnimation(animationType, layer, pos)
    LogINFO("-----------------getAnimation------------------")
    local info = LandArmatureResource.armatureResourceInfo[animationType]
    local landArmature  = LandArmature.new(info.resourceById, self.m_animationLayer)
    landArmature:setPosition(pos and pos or info.po1 )
    layer:addChild(landArmature)
    return landArmature
end

--播放骨骼动画
function LandAnimationManager:playArmatureAnimation( resourceById, pos, handerBack, isfull)
    local landArmature = nil
    local info = LandArmatureResource.armatureResourceInfo[resourceById]
    if true then --self.mLandArmatures[resourceById] == nil then
        --LogINFO("没有缓存,重新创建")
        landArmature  = LandArmature.new( resourceById, self.m_animationLayer, handerBack )
        self.m_animationLayer:addChild( landArmature )
        if true then --info.isCache == true then
            --LogINFO("缓存动画")
        --    self.mLandArmatures[resourceById] = landArmature
        end
    else
        --LogINFO("有缓存,直接拿来就好")
        --landArmature = self.mLandArmatures[resourceById]
    end
    landArmature:setPosition(pos and pos or info.po1 )
    if isfull then landArmature:setScale(display.width/1280, display.height/720) end
    landArmature:playAnimation(info.isLoop)
    return landArmature
end 

function LandAnimationManager:playBoomWithAnimation()
    -- local pos = cc.p(display.cx,display.cy)
    -- self.m_animationLayer
end 
function LandAnimationManager:playWaitStartAnimation()
    
end 
--停止播放骨骼动画,并清除骨骼动画
function LandAnimationManager:stopAndClearArmatureAnimation(resourceById )
     if resourceById and self.mLandArmatures[resourceById]  then
         LogINFO("删除动画 resourceById : ",resourceById)
        self.mLandArmatures[resourceById]:stopAllActionsEx()
        self.mLandArmatures[resourceById]:clearArmatureFileInfo()
        self.m_animationLayer:removeChild( self.mLandArmatures[resourceById] )
        self.mLandArmatures[resourceById] = nil
     end
end

--停止播放骨骼动画,并清除骨骼动画
function LandAnimationManager:clearAnimation()
    for k,v in pairs(self.mLandArmatures) do
        if v then
           v:stopAllActionsEx()
           v:clearArmatureFileInfo()
           self.m_animationLayer:removeChild(v)
           v = nil
        end
    end
end

-- 用于清除动画，在切到后台情况
function LandAnimationManager:clearAllAnimations()
  for i=1,#self.spriteAnis do
       transition.stopTarget( self.spriteAnis[ i ] )   
       if not tolua.isnull( self.spriteAnis[ i ]) then
           self.m_animationLayer:removeChild( self.spriteAnis[ i ])
       end
    end
    self.spriteAnis = {}
end


return LandAnimationManager



