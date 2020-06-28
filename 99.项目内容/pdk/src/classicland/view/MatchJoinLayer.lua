--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

 
local HNLayer= require("src.app.newHall.HNLayer") 
local MatchJoinLayer = class("MatchJoinLayer",function ()
     return HNLayer.new()
end)

function MatchJoinLayer:ctor()
    self:myInit()
    self:setupView()
end
function MatchJoinLayer:onTouchCallback(sender)
    local name = sender:getName()
    if name == "button_btnOk" then
        
        g_GameController:reqJoinMatch()
     elseif name == "button_btnOut" then
        
        self["bg2"]:setVisible(true)
    elseif name=="Button_2" then
        g_GameController:reqSignCancel()
         self["bg2"]:setVisible(false)
    elseif name == "Button_3" then
        self["bg2"]:setVisible(false)
     elseif name == "button_close" then
        ConnectManager:send2SceneServer( g_GameController.m_gameAtomTypeId,"CS_C2M_Run_Match_Exit_Game_Req", {})
    end
end
function MatchJoinLayer:setupView() 
    local node = UIAdapter:createNode("src/app/game/pdk/res/csb/land_match_cs/land_match_join.csb") 
    UIAdapter:adapter(node,handler(self, self.onTouchCallback)) 
    UIAdapter:praseNode(node,self)   
    local diffY = (display.size.height - 750) / 2
     node:setPosition(cc.p(0,diffY)) 
    local diffX = 145-(1624-display.size.width)/2 
    self["center"]:setPositionX(diffX)
    self:addChild(node)
  --  self["center"]:setPositionX(self["center"]:getPositionX()*display.scaleX)
    for k=1,9 do 
        self["image_newIcon_"..k]:setScale(0.7)
    end
end 
function MatchJoinLayer:setMatchData(info)
    --self["Text_19"]:setString( string.format("%d金币",info.m_signCost*0.01))
    --self["Text_20"]:setString( string.format("%d金币",info.m_champinAward*0.01))
    -- for k,v in pairs(info.m_signers) do
    --     local head = ToolKit:getHead( v.m_faceId) 
    --     self["image_newIcon_"..k]:loadTexture(head,1) 
    --     self["Text_"..(k+1)]:setString(v.m_nickname)
    --      self["image_newIcon_"..k]:setVisible(true)
    -- end
    if info.m_state == 0  then
        self["button_btnOk"]:setVisible(true)
        self["button_btnOut"]:setVisible(false)
        self["tips"]:setVisible(false)
    elseif info.m_state ==2 then
         self["button_btnOk"]:setVisible(false)
        self["button_btnOut"]:setVisible(true)
        self["tips"]:setVisible(true)
    end
end  
function MatchJoinLayer:SignUp()
    self["button_btnOk"]:setVisible(false)
    self["button_btnOut"]:setVisible(true)
    self["tips"]:setVisible(true)
end
function MatchJoinLayer:SignCancel()
    self["button_btnOk"]:setVisible(true)
    self["button_btnOut"]:setVisible(false)
    self["tips"]:setVisible(false)
end

function MatchJoinLayer:refreshMatchData(info)
    for k=1,9 do 
         self["image_newIcon_"..k]:setVisible(false)
    end
    for k,v in pairs(info.m_signers) do
        local head = ToolKit:getHead( v.m_faceId) 
        self["image_newIcon_"..k]:loadTexture(head,1)
        self["Text_"..(k+1)]:setString(v.m_nickname)
        self["Text_"..(k+1)]:setColor(cc.c3b(255,255,255))
         self["image_newIcon_"..k]:setVisible(true)
    end
    
end  
return MatchJoinLayer