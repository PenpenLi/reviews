--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
 
 
local HNLayer= require("src.app.newHall.HNLayer") 
local MatchJinjiLayer = class("MatchJinjiLayer",function ()
     return HNLayer.new()
end)

function MatchJinjiLayer:ctor()
    self:myInit()
    self:setupView()
end
function MatchJinjiLayer:onTouchCallback(sender)
    local name = sender:getName() 
end
function MatchJinjiLayer:setupView() 
    local node = UIAdapter:createNode("src/app/game/pdk/res/csb/land_match_cs/land_match_upgrade.csb")  
    UIAdapter:praseNode(node,self) 
     self:addChild(node) 
     local diffY = (display.size.height - 750) / 2
     node:setPosition(cc.p(0,diffY)) 
    local diffX = 145-(1624-display.size.width)/2 
    self["center"]:setPositionX(diffX)
end 
function MatchJinjiLayer:setData(info) 
    
    self["score"]:setString(info.m_upgradeCnt)
end  
return MatchJinjiLayer