--
-- LandOverTopInfo
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 要不起界面,托管界面
--

local LandOverTopInfo = class("LandOverTopInfo", function()
    return display.newLayer()
end)

function LandOverTopInfo:ctor( landMainScene )
    self.m_pInfoNode = nil
    self.m_landMainScene = landMainScene
    self:setNodeEventEnabled( true )
    self:init()
end

function LandOverTopInfo:init()
	local size = cc.Director:getInstance():getWinSize()
    local item = cc.MenuItemImage:create()
    item:setContentSize(cc.size(size.width, size.height))
    item:registerScriptTapHandler(function()
		self.m_landMainScene:OnPassCard()
        self:setNotAffordVisible(false)
	end)
    self.backMenu = cc.Menu:create(item)
    self:addChild(self.backMenu)
    self.backMenu:setEnabled(false)

	self.m_pInfoNode = UIAdapter:createNode("src/app/game/pdk/res/csb/land_common_cs/land_overtopinfo.csb")
    self:addChild(self.m_pInfoNode)
    UIAdapter:adapter(self.m_pInfoNode, handler(self, self.onTouchCallback))

    -- 要不起界面显示
    self.notaffordPanel = self.m_pInfoNode:getChildByName("notafford_panel")
    self.notaffordPanel:setVisible(false)
    
	self.notaffordLabel = self.m_pInfoNode:getChildByName("bt_no_afford_label")
	self.notaffordLabel:enableOutline({r = 203, g = 56, b = 47, a = 255}, 3)
    local function onTouchNotAffordButton(sender,eventType)
        if sender then
            if eventType == ccui.TouchEventType.ended then
            	--请求弃牌
        		self.m_landMainScene:OnPassCard()
        		self:setNotAffordVisible(false)
            end
        end
    end  
  
    local noBtn = self.notaffordPanel:getChildByName("bt_no_afford")
    tolua.cast(noBtn,"ccui.Button")
    noBtn:addTouchEventListener(onTouchNotAffordButton)

    -- 游戏托管
    local function onTouchTuoGuanButton(sender,eventType)
        if sender then
            if eventType == ccui.TouchEventType.ended then
                self.m_landMainScene:OnTuoGuan(false)
                --self:setHostingBtnVisible(false)
            end
        end
    end  
    self.hostPanel = self.m_pInfoNode:getChildByName("hosting_panel")
    self.btCancle = self.hostPanel:getChildByName("cancel_hosting_btn")
	self.btCancleLabel = self.hostPanel:getChildByName("cancel_hosting_label")
	self.btCancleLabel:enableOutline({r = 28, g = 142, b = 122, a = 255}, 3)
    
    self.btCancle:setPositionX(display.width/2)
    self.btCancle:addTouchEventListener(onTouchTuoGuanButton)
    self.hostPanel:setVisible(false)
    self.btCancle:setVisible(false)
    
end


function LandOverTopInfo:setNotAffordVisible(_isShow)
	if _isShow then
		self:setHostingBtnVisible( false )
	end
    self.backMenu:setEnabled(_isShow)
    self.notaffordPanel:setVisible(_isShow)
end

function LandOverTopInfo:isNotAffordVisible()
    return self.notaffordPanel:isVisible()
end

-- 取消托管按钮
function LandOverTopInfo:setHostingBtnVisible( state )
	if state then
		self:setNotAffordVisible(false)
	end
    self.hostPanel:setVisible( state )
    self.btCancle:setVisible( state )
end

function LandOverTopInfo:HostingBtnIsVisible()
    return self.hostPanel:isVisible()
end


function LandOverTopInfo:onExit()
   self.m_landMainScene = nil
end

function LandOverTopInfo:onTouchCallback( sender )
    local name = sender:getName()
    LogINFO("name: ", name)
end

return LandOverTopInfo