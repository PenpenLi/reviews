--------------------------------------------------------
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 超快赛,定点赛共用比赛开始界面动画
local LandGlobalDefine     = require("src.app.game.pdk.src.landcommon.data.LandGlobalDefine")
local LandAnimationManager = require("src.app.game.pdk.src.landcommon.animation.LandAnimationManager")
local LandArmatureResource = require("src.app.game.pdk.src.landcommon.animation.LandArmatureResource")
local LandSoundManager     = require("src.app.game.pdk.src.landcommon.data.LandSoundManager")

local LandMatchTipsGameBegin = class("LandMatchTipsGameBegin", function()
    return display.newLayer()
end)

function LandMatchTipsGameBegin:ctor( landMainScene )
    self.m_landMainScene = landMainScene
    self.landAnimationManager = LandAnimationManager.new(self)  
end 

function LandMatchTipsGameBegin:showGameBeginAnimation(nextAciton, stage)
 	LogINFO("显示超快赛比赛开始动画")

--[[    local function onComplete()
        self:setVisible(false)
        if nextAciton then
            nextAciton(stage)
        end
    end--]]

--[[    local animation = LandAnimationManager:getInstance():getAnimation(LandArmatureResource.ANI_MATCH, self, cc.p(display.cx, display.cy))
    animation:setMovementEventCallFunc(onComplete)
    animation:setScaleX(display.width/1280)
    animation:playAnimationByName("lord_match_ani_start")--]]

    local root  = cc.CSLoader:createNode("src/app/game/pdk/res/csb/land_match_cs/land_match_begin.csb")
    root:addTo(self)

    local begin_node = root:getChildByName("begin_node")

    local img = root:getChildByName("img")

    local x = begin_node:getPositionX()
    local y = begin_node:getPositionY()

    begin_node:setPosition(cc.p(x - 1280, y))
 
    local actionM ={}
    actionM[1] = cc.Spawn:create(cc.ScaleTo:create(0.5, 2), cc.FadeTo:create(0.5, 125))  
    actionM[2] = cc.DelayTime:create(0.2)  
    actionM[3] = cc.CallFunc:create(function()
        self:setVisible(false)
        if nextAciton then
            nextAciton(stage)
        end
    end)

    local actionT = {}
    actionT[1] =  cc.MoveTo:create(0.3, cc.p(x, y))
    actionT[2] = cc.TargetedAction:create( img , cc.Sequence:create(actionM))

    begin_node:runAction(cc.Sequence:create(actionT))

end

function LandMatchTipsGameBegin:onTouchCallback(sender)
    local name = sender:getName()
    local tag = sender:getTag()
    print("LandMatchTipsNewLayer name: ", name)
    --self:removeFromParent()
end

return LandMatchTipsGameBegin


