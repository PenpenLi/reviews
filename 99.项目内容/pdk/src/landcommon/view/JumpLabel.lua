-- JumpLabel
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 跳动的文字

------------------------------
--遍历UTF8字符串， 将每一个字符单独取出放一个table里
local function traversalUTF8(str)
	local ret = {}
	local arr = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
	local i = 1
	while i <= #str do
		local tmp = string.byte(str, i)
		
		local thisLen = #arr
		while arr[thisLen] do
			if tmp >= arr[thisLen] then
				break
			end
			thisLen = thisLen - 1
		end
		
		local thisChar = string.sub(str, i, i + thisLen - 1)
		
		table.insert(ret, thisChar)
		
		i = i + thisLen
	end
	return ret
end

---------------------------
local JumpLabel = class("JumpLabel", function()
    return display.newNode()
end)

function JumpLabel:ctor(str, size, color, blank)
	self.m_str = str
	self.m_blank = blank or 0
	self.m_size = size or 20
	self.m_color = color or cc.c3b(255, 255, 255)
	
	self.m_height = self.m_size
	self.m_width = 0

	self.m_labelTable = {}
	
	self.m_upIndex = 1 --当前跳起来的index
	
	self:init()
end

--按照锚点是 0.5，0.5 的设置位置
function JumpLabel:setPositionWithMidAnchor(pos)
	local x = pos.x - self.m_width / 2
	local y = pos.y - self.m_height / 2
	
	self:setPosition(cc.p( x, y ))
end

function JumpLabel:init()
	local charTable = traversalUTF8(self.m_str)
	--
	local now_x = 0
	for _, v in pairs(charTable)do
		local label = display.newTTFLabel({
			text = v, 
			font = "font/jcy.TTF", 
			color = self.m_color,
			x = now_x, y = 0,
			size = self.m_size,
		})
		label:setAnchorPoint(cc.p( 0, 0 ))
		table.insert(self.m_labelTable, label)
		self:addChild(label)
		
		now_x = now_x + self.m_size + self.m_blank
	end
	self.m_width = now_x
	--
	if #self.m_labelTable > 0 then
		self:runJumpAction()
	end
end

function JumpLabel:runJumpAction()
	local jumpUp = cc.MoveBy:create(0.1, cc.p(0, self.m_size * 2 / 3))
	local jumpDown = cc.MoveBy:create(0.1, cc.p(0, -self.m_size * 2 / 3))
	local callBack = cc.CallFunc:create(function() self:onJumpActionEnd() end)
	local seq = cc.Sequence:create(jumpUp, jumpDown, callBack)
	if self.m_labelTable[self.m_upIndex] then
		self.m_labelTable[self.m_upIndex]:runAction(seq)
	else
		self.m_labelTable[1]:runAction(seq)
	end
end

function JumpLabel:onJumpActionEnd()
	self.m_upIndex = self.m_upIndex + 1
	if self.m_upIndex > #self.m_labelTable then
		self.m_upIndex = 1
	end
	--
	self:runJumpAction()
end

return JumpLabel










