--
-- LandMaskLayer
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 遮盖层
--

local LandMaskLayer = class("LandMaskLayer", function()
    return display.newLayer()
end)

function LandMaskLayer:ctor( toRenderFunc )
    self:initMaskLayer(toRenderFunc)
end

function LandMaskLayer:initMaskLayer(toRenderFunc)
    --print("------LandMaskLayer:ctor-------", toRenderFunc)
    local size = cc.Director:getInstance():getWinSize(); 

	local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 127), size.width, size.height)
	self:addChild(layer)

    local function closeCallback()
        if toRenderFunc then
            print("---------closeCallback----------")
            --self.mRenderNode:setVisible(false)
            toRenderFunc()
        end
    end

    local item = cc.MenuItemImage:create()
    item:setContentSize(cc.size(size.width, size.height))
    item:registerScriptTapHandler(closeCallback)
    local menu = cc.Menu:create(item)

    self:addChild(menu)
end

return LandMaskLayer