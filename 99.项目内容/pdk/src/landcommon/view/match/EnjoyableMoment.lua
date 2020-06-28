
local EnjoyableMomentConfig = require("app.landgame.view.EnjoyableMomentConfig")
--local GlobalData = require("app.qkasdk.data.GlobalData")
local scheduler = require("framework.scheduler")

local EnjoyableMoment = class("EnjoyableMoment", function()
    return display.newLayer()
end)



-- 开心一刻刷新时间为3小时
local ENJOYABLE_MOMENT_REFRESH_TIME = 3*60*60 

function EnjoyableMoment:ctor( landMainScene )
	
	self.m_JokeTag = {
		10001,
		10002,
	    10003,
	    10004,
	    10005,
	}
	
	self.m_enum = {
		BLANK = 20,
		NUM_EVERY_PAGE = 5, --一页显示多少个段子
	}
	
    self.m_pMainNode = nil
	self.m_pScrollView = nil

	self.m_labelWidth = nil
	self.m_labelX = nil
	
	self.m_JokeTable = {}
    self.m_landMainScene = landMainScene
	-- by dzf, 三小时内仍然显示同一页笑话
	self.m_nJokeIndex = self:getJokeIndexAndPosition()

    self:init()
end

function EnjoyableMoment:init()
	print("----------------EnjoyableMoment:init()-----------------")
	
    local size = cc.Director:getInstance():getWinSize(); 
    local function closeCallback()
		self.m_landMainScene:removeEnjoyableMoment()
    end

    local item = cc.MenuItemImage:create()
    item:setContentSize(cc.size(size.width, size.height))
    item:registerScriptTapHandler(closeCallback)
    local menu = cc.Menu:create(item)
    self:addChild(menu)

    self.m_pMainNode = cc.CSLoader:createNode("src/app/game/pdk/res/csb/land_match_enjoyable_moment.csb")
    self:addChild(self.m_pMainNode)
    self.root_node = self.m_pMainNode:getChildByName("root_node")

    local temp = self.m_pMainNode:getChildren()
    for i=1,#temp do
        temp[i]:setPositionY(temp[i]:getPositionY()*display.standardScale)
    end
	
	self.m_pScrollView = self.root_node:getChildByName("scrollView")
	
	local content = self.m_pScrollView:getChildByName("content")
	content:setVisible(false)
	self.m_labelWidth = content:getContentSize().width
	self.m_labelX = content:getPositionX()
	
	
	local function onButtonCallBack(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.m_pBackBtn then
				-- 返回按钮
				self.m_landMainScene:removeEnjoyableMoment()
			elseif sender == self.m_pRefreshBtn then
				-- 刷新按钮
				GlobalData:setLandEnjoyMomentRefreshTime(os.time())
				GlobalData:setLandEnjoyMomentLastIndex(self.m_nJokeIndex)
				self:showJoke()
			end
		end
	end
	
	self.m_pBackBtn = self.root_node:getChildByName("btn_close")
	self.m_pRefreshBtn = self.root_node:getChildByName("btn_refresh")
	self.m_pBackBtn:addTouchEventListener(onButtonCallBack)
	self.m_pRefreshBtn:addTouchEventListener(onButtonCallBack)
	
	self:showJoke()

end

function EnjoyableMoment:getOnePageJoke()
	local ret = {}
	for i = 1, self.m_enum.NUM_EVERY_PAGE do
		table.insert(ret, EnjoyableMomentConfig[self.m_nJokeIndex])
		self.m_nJokeIndex = self.m_nJokeIndex + 1
		if self.m_nJokeIndex > #EnjoyableMomentConfig then
			self.m_nJokeIndex = self.m_nJokeIndex - #EnjoyableMomentConfig
		end
	end
	return ret
end

function EnjoyableMoment:removeAllJoke()
	for i, v in pairs(self.m_JokeTag)do
		local label = self.m_pScrollView:getChildByTag(v)
		if label then
			self.m_pScrollView:removeChild(label)
		end
	end
end

function EnjoyableMoment:showJoke()
	self:removeAllJoke()

	local jokeTable = self:getOnePageJoke()
	local jokeLabelTable = {}
	
	local totalHeight = self.m_enum.BLANK
	local scrollViewS = self.m_pScrollView:getContentSize()
	
	for i = 1, #jokeTable do
		jokeLabelTable[i] = display.newTTFLabel( {
			text = jokeTable[i].title .. "\r\n" .. jokeTable[i].content, 
			font = "黑体", 
			size = 20, 
			color = cc.c3b(117, 71, 25),
			dimensions = cc.size(self.m_labelWidth, 0),
		} )
		jokeLabelTable[i]:setTag(self.m_JokeTag[i])
		jokeLabelTable[i]:setAnchorPoint(cc.p(0, 1))
		self.m_pScrollView:addChild(jokeLabelTable[i])
		local label_jokeS = jokeLabelTable[i]:getContentSize()
		totalHeight = totalHeight + label_jokeS.height + self.m_enum.BLANK
	end
	--
	local now_y
	if scrollViewS.height > totalHeight then
		self.m_pScrollView:setInnerContainerSize(cc.size(scrollViewS.width, scrollViewS.height))
		now_y = scrollViewS.height - 10
	else
		self.m_pScrollView:setInnerContainerSize(cc.size(scrollViewS.width, totalHeight))
		now_y = totalHeight - 10
	end
	for i = 1, #jokeLabelTable do
		jokeLabelTable[i]:setPosition(cc.p(self.m_labelX, now_y))
		now_y = now_y - jokeLabelTable[i]:getContentSize().height - self.m_enum.BLANK
	end
	
	self.m_pScrollView:jumpToTop()
end

function EnjoyableMoment:getJokeIndexAndPosition()
	local curTime = os.time()
	print("Current Time is"..curTime)
	local oldTime = GlobalData:getLandEnjoyMomentRefreshTime()
	if (oldTime == nil) then
		oldTime = 0
	end

	print("Old Time is"..oldTime)

	local retIndex = math.random( 1, #EnjoyableMomentConfig )
	if (curTime - oldTime > ENJOYABLE_MOMENT_REFRESH_TIME) then
		GlobalData:setLandEnjoyMomentRefreshTime(curTime)
		print("Current Time is"..curTime)
		GlobalData:setLandEnjoyMomentLastIndex(retIndex)
		return retIndex
	else
		local lastIndex = GlobalData:getLandEnjoyMomentLastIndex()
		if (lastIndex ~= nil and lastIndex >= 1 and lastIndex <= #EnjoyableMomentConfig) then
			return lastIndex
		else
			GlobalData:setLandEnjoyMomentRefreshTime(curTime)
			GlobalData:setLandEnjoyMomentLastIndex(retIndex)
			return retIndex
		end
	end

	return retIndex
end

return EnjoyableMoment