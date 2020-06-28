--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

 
local USER_HEAD_MASK			= "platform/common/touxiangdi.png";
local GameUserHead = require("app.newHall.rootLayer.UserHeadLayer")
local PlayerHeadLayer = class("PlayerHeadLayer", function()
		return display.newLayer()
	end)

function PlayerHeadLayer:ctor(node,nType, root) 
    self:myInit()
    self:setupViews(node,nType, root)
end
 
function PlayerHeadLayer:setupViews(node,nType, root)
    self.node = node
    if nType== 2 then
        if root then
            self.root = root;
        else
            self.root = UIAdapter:createNode("common/PlayerHead.csb")
            node:addChild(self.root)
        end
        
        local node_nodeAvatar = self.root:getChildByName("node_nodeAvatar")
        local image_infoBg = self.root:getChildByName("image_infoBg")
        self._txt_name  = image_infoBg:getChildByName("text_nickname")
         self._txt_gold= image_infoBg:getChildByName("text_coin")
         self._userHead = node_nodeAvatar:getChildByName("image_avatar")
         self.root:setScale(0.6)
         self.posx,self.posy =self.root:getPosition()
    else
         self._txt_name  = node:getChildByName("text_selfName")
         self._txt_gold= node:getChildByName("text_selfMoneyNum")
         self._userHead = node:getChildByName("image_selfAvatar")
    end
    
end

function PlayerHeadLayer:setPlayerInfo(info)
    self._txt_name:setString(info.m_nickname);
	if (self._txt_gold) then 
		local money = info.m_score/100;
		self._txt_gold:setString(money);
	end 
--	self._txt_vip:setString(info.m_vipLevel);
	local head = ToolKit:getHead(info.m_faceId); 
	self._userHead:loadTexture(head,1); 
 
end
function PlayerHeadLayer:showPlayer(show)
    self.node:setVisible(show);
end
function PlayerHeadLayer:setUserMoney(money)
    
	if (self._txt_gold) then  
		self._txt_gold:setString(money);
	end
end
function PlayerHeadLayer:showZhuangImg(show) 
--    if (self._img_zhuang) then
--        self._img_zhuang:setVisible(show);
--	end
end
function PlayerHeadLayer:showOtherRun(nType)
    self.root:setPosition(self.posx,self.posy)
    self.root:stopAllActions();  
	local moveby1 = cc.MoveBy:create(0.1, cc.p(-10,0));
	local moveby2 = cc.MoveBy:create(0.1, cc.p(10,0));
    if nType == 1 then
	    self.root:runAction(cc.Sequence:create(moveby2, moveby1,nil));
    else
        self.root:runAction(cc.Sequence:create(moveby1, moveby2,nil));
    end
end 

function PlayerHeadLayer:myInit() 
    self._txt_name= nil
    self._txt_gold= nil 
    self._userHead= nil 
end

return PlayerHeadLayer