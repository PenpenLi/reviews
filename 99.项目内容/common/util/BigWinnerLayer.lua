--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

 
local HNLayer= require("src.app.newHall.HNLayer")  
local BigWinnerLayer = class("BigWinnerLayer",function ()
     return HNLayer.new()
end)

function BigWinnerLayer:ctor()
    self:myInit()
    self:setupView()
end
function BigWinnerLayer:onTouchCallback(sender)
    local name = sender:getName()
    if name == "button_close" then
        self:setVisible(false)
    end
end
function BigWinnerLayer:setupView() 
    local node = UIAdapter:createNode("common/CommonBigWinnerView.csb")
    local image_BG = node:getChildByName("image_BG") 
    self.panel_itemModelRankItem = node:getChildByName("panel_itemModelRankItem")
	self._listViewUser = image_BG:getChildByName("listView_list");
	self._listViewUser:removeAllItems();
	self._listViewUser:setTouchEnabled(true);--可触摸   
     UIAdapter:adapter(node,handler(self, self.onTouchCallback)) 
	 self:addChild(node)
     local button_tab1 = image_BG:getChildByName("button_tab1");
      local button_tab2 = image_BG:getChildByName("button_tab2");
    button_tab1:setVisible(false)
    button_tab2:setVisible(false)
    local Image_93 = image_BG:getChildByName("Image_93");
    local image_xiazhu = Image_93:getChildByName("image_xiazhu");
    image_xiazhu:setVisible(false)
end 
 
 function BigWinnerLayer:updateUserList(userlist)

    
    self._listViewUser:removeAllItems();
   
	for k,v in pairs(userlist) do 
		local panel = self:getOneItem(v,k); 
		self._listViewUser:pushBackCustomItem(panel);
	end
end 
function BigWinnerLayer:getOneItem(userInfo,index)
    
    local csbNode = self.panel_itemModelRankItem:clone()
    local image_rank  = csbNode:getChildByName("image_rank")  
    local Image_2 = csbNode:getChildByName("Image_2")  
    if index <=3 then
        image_rank:setVisible(true)
        image_rank:loadTexture(string.format("hall/image/rank/tjylc_phb_hg%d.png",index))
        Image_2:setVisible(false)
    else
        image_rank:setVisible(false)
       
        Image_2:setVisible(true)
        local atlas_rankLabel = Image_2:getChildByName("atlas_rankLabel")  
        atlas_rankLabel:setString(index)
    end 
    local image_avatar = csbNode:getChildByName("image_avatar")  
    local head = ToolKit:getHead( userInfo.m_faceId)
    image_avatar:loadTexture(head,1)
    image_avatar:setScale(0.5) 
    local text_coin = csbNode:getChildByName("text_coin") 
    text_coin:setString(userInfo.m_score / 100);
    local text_name = csbNode:getChildByName("text_name") 
    text_name:setString(userInfo.m_nickname)
        
    return csbNode
end  
function BigWinnerLayer:myInit() 
	self._listViewUser=nil;  
end

return BigWinnerLayer