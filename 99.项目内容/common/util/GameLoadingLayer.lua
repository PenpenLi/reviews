--
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 通用加载界面

local StackLayer = require("app.hall.base.ui.StackLayer")
local CCLoadResAsync = require("app.hall.base.util.AsyncLoadRes")

local GameLoadingLayer = class("GameLoadingLayer", function ()
	return StackLayer.new()
end)

function GameLoadingLayer:ctor( __params )
	self:myInit()

	self:setExitRemove(true)
end

function GameLoadingLayer:myInit()
	self:setExitRemove(true)

    self.__nextLayer = nil -- 加载之后进入的页面

    self.loadResAsync = CCLoadResAsync.new()
    self.__resourcesTemp = nil 

    ToolKit:registDistructor(self, handler(self, self.onDestory))
end

-- 是否已经加载过(已加载过就不需要再加载)
-- return (bool) 已加载过就是true, 否则false
function GameLoadingLayer:isLoadedCompleted()
	return self.loadResAsync:isLoadedCompleted()
end

-- 设置下一个页面
-- @param __layerPath(StackLayer) 加载加载之后需要进入的界面
function GameLoadingLayer:setNextlayer( __layerPath )
	self.__nextLayer = __layerPath
end

-- 阻塞加载资源
-- @param __resourcesTemp(table) 需要加载的资源
function GameLoadingLayer:blockLoadResources( __resourcesTemp )
	self.__resourcesTemp = __resourcesTemp
	self.loadResAsync:blockLoadResources(__resourcesTemp)
end

-- 预加载资源
-- @param __resourcesTemp(table) 需要加载的资源
-- @param __callback(function) 加载完成回调
-- @param ____loadingCallback(function) 加载过程回调
function GameLoadingLayer:preloadResources( __resourcesTemp, __callback, __loadingCallback )
	self.__resourcesTemp = __resourcesTemp
	self.loadResAsync:preloadResources( __resourcesTemp, __callback, __loadingCallback )
end

-- 进入下一个页面
-- @param __info(table) 需要传递的参数
function GameLoadingLayer:gotoNextLayer( __info )
	if self:getScene() == ToolKit:getCurrentScene() then
    	self:getScene():getStackLayerManager():pushStackLayer(self.__nextLayer, {_info = __info})
    else
    	print("[WARNING]: Current Scene is not this parent when attempt to go to next layer !, scene name is: ", ToolKit:getCurrentScene().__cname)
    end
end


function GameLoadingLayer:onDestory()
	if self.loadResAsync then
		self.loadResAsync:removeResources(self.__resourcesTemp)
		self.loadResAsync:onDestory()
	end
end

return GameLoadingLayer