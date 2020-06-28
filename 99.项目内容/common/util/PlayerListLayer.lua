--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

  
local HNLayer= require("src.app.newHall.HNLayer")
local GameUserHead = require("src.app.newHall.rootLayer.UserHeadLayer") 
local PlayerListLayer = class("PlayerListLayer",function ()
     return HNLayer.new()
end)

function PlayerListLayer:ctor()
    self:myInit()
    self:setupView()
end
function PlayerListLayer:onTouchCallback(sender)
    local name = sender:getName()
    if name == "button_close" then
        self:setVisible(false)
    end
end
function PlayerListLayer:setupView() 
    -- local node = UIAdapter:createNode("common/PlayerList.csb")
    local node = CacheManager:addCSBTo(self, "common/PlayerList.csb");
    local center = node:getChildByName("Layer") 
     local diffY = (display.size.height - 750) / 2
    node:setPosition(cc.p(0,diffY))
     
    local diffX = 145-(1624-display.size.width)/2 
    center:setPositionX(diffX)
    self.panel_itemModelLine = node:getChildByName("panel_itemModelLine")
    local Panel_1 = node:getChildByName("Panel_1");  
    Panel_1:setVisible(true)
    local panel = node:getChildByName("image_bg");  
    local text_left__ = panel:getChildByName("text_left__");  
    self.text_num = text_left__:getChildByName("text_num");   
	self._listViewUser = panel:getChildByName("listView_list");
	self._listViewUser:removeAllItems();
	self._listViewUser:setTouchEnabled(true);--可触摸   
     UIAdapter:adapter(node,handler(self, self.onTouchCallback)) 
	--  self:addChild(node)
end 
 
 function PlayerListLayer:updateUserList(userlist)

    self.text_num:setString(table.nums(userlist))
    self._listViewUser:removeAllItems();
    self.orderList ={}
    local orderNum = math.floor(table.nums(userlist)/3)
    local leftNum = table.nums(userlist) % 3
    for k=1,orderNum do
        self.orderList[k]={}
        for i=1,3 do
            table.insert(self.orderList[k],userlist[3*(k-1)+i])
        end
    end
    if leftNum~=0 then
        self.orderList[orderNum+1]={}
        for k=1,leftNum do 
            table.insert(self.orderList[orderNum+1],userlist[3*orderNum+k])
        end
    end 
	for k,v in pairs(self.orderList) do 
		local panel = self:getOneItem(v,k); 
		self._listViewUser:pushBackCustomItem(panel);
	end
end 
function PlayerListLayer:getOneItem(userInfo,index)
    
    local csbNode = self.panel_itemModelLine:clone()
    for k=1,3 do 
         local panel_player = csbNode:getChildByName("panel_player_"..k) 
        if userInfo[k] then
           
            local image_avatar = panel_player:getChildByName("image_avatar") 
            local norFrame = image_avatar:getChildByName("norFrame") 
            norFrame:setVisible(false)
            local head = ToolKit:getHead( userInfo[k].m_faceId)
            image_avatar:loadTexture(head,1)
            image_avatar:setScale(0.7)
            local image_coinIcon = panel_player:getChildByName("image_coinIcon") 
            local text_coin = image_coinIcon:getChildByName("text_coin") 
            text_coin:setString((userInfo[k].m_score or userInfo[k].m_curCoin) / 100);
            local text_name = panel_player:getChildByName("text_name") 
            text_name:setString(userInfo[k].m_nickname)
        else
            panel_player:setVisible(false)
        end
	end
    return csbNode
end  
function PlayerListLayer:myInit() 
	self._listViewUser=nil;  
end

return PlayerListLayer