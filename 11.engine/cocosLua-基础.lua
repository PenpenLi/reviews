--[[
0.目录 官网文档
1.ccui 九宫格缩放,九宫格尺寸
2.ccui 设置尺寸：忽略ContentSize,使用TextureSize
3.ccui.Layout 函数
4.CCClippingNode和Layout 裁剪有冲突
5.ccui.ListView 函数
6.ccui.Text 函数
7.ccui.TextField 与 ccui.EditBox
8.ccui loadTexture
9.加载资源
10.帧动画
11.骨骼动画
12.clippingnode 
13.URL编码
14.cc.XMLHttpRequest GET&POST 
15.头像信息本地，下载，比较替换，
16.ccui.Slider ccui.LoadingBar cc.ProgressTimer
17.启动游戏，切换场景
18.热更新
19.ccexp.VideoPlayer
20.ccui.ListView 移动位置事件
21.string table 函数
22.string 特殊字符处理
23.unicode utf8 转换
24.想必做过爬虫的同学肯定被编码问题困扰过，有 UTF-8、GBK、Unicode 等等编码方式
25.事件处理
26.鹅鹅鹅
--]]
--[[
0.官方文档 
https://www.cocos.com/docs
cocos2d.lua
display.lua
1.ccui 九宫格缩放,九宫格尺寸
local t_recsize = cc.rect(t_imgsize.width/4, t_imgsize.height/4, t_imgsize.width/2, t_imgsize.height/2)
img_bg:setScale9Enabled(true)
img_bg:setCapInsets(t_recsize)
:setContentSize()
:setScale()
2.ccui 设置尺寸：忽略ContentSize,使用TextureSize
isIgnoreContentAdaptWithSize()
ignoreContentAdaptWithSize(true)
3.ccui.Layout 函数
-- 容器背景颜色类型
-- 0 LAYOUT_COLOR_NONE                      = ccui.LayoutBackGroundColorType.none
-- LAYOUT_COLOR_SOLID                     = ccui.LayoutBackGroundColorType.solid
-- LAYOUT_COLOR_GRADIENT                  = ccui.LayoutBackGroundColorType.gradient
-- 容器类型
-- 0 LAYOUT_ABSOLUTE                        = ccui.LayoutType.ABSOLUTE
-- LAYOUT_LINEAR_VERTICAL                 = ccui.LayoutType.VERTICAL
-- LAYOUT_LINEAR_HORIZONTAL               = ccui.LayoutType.HORIZONTAL
-- LAYOUT_RELATIVE                        = ccui.LayoutType.RELATIVE
local  layout_bg = ccui.Layout:create():addTo(parent)
:setContentSize(size_visible)
:setBackGroundColorType(LAYOUT_COLOR_SOLID)
:setBackGroundColor(cc.c3b(255,0,0))
:setBackGroundColorOpacity(120)
setBackGroundImage
setBackGroundImageScale9Enabled
setBackGroundImageCapInsets
setBackGroundImageColor
setBackGroundImageOpacity
isClippingEnabled
setClippingEnabled
setLayoutType-LayoutType
4.CCClippingNode和Layout 裁剪有冲突
5.ccui.ListView 函数
-- 0 LISTVIEW_DIR_NONE                      = ccui.ListViewDirection.none
-- LISTVIEW_DIR_VERTICAL                  = ccui.ListViewDirection.vertical
-- LISTVIEW_DIR_HORIZONTAL                = ccui.ListViewDirection.horizontal
:setItemsMargin
:setScrollBarEnabled
:setScrollBarColor
:setScrollBarAutoHideTime
:setScrollBarAutoHideEnabled
:setScrollBarWidth
:setBounceEnabled
:setDirection
:setMagneticType
:setHorizontalAlignment
:setVerticalAlignment
6.ccui.Text 函数
:setTextHorizontalAlignment
:getTextVerticalAlignment
:setFontSize
:setFontName
:setTextColor
7.ccui.TextField 与 ccui.EditBox
getMaxLength
getPlaceHolder
local func_onEditboxEvent = function (event, editbox)
	-- print("-------------", event)
	if event == "began" then  
	elseif event == "changed" then   
	elseif event == "ended" then  
	elseif event == "return" then  
	end
end
local editBox = ccui.EditBox:create(size, "");  
editBox:setAnchorPoint(pAnchorPoint);               --锚点  
editBox:setPosition(pos);                           --位置  
editBox:setLocalZOrder(iZOrder);                    --层级  
editBox:setName(pName);                             --名称  
editBox:setTag(iTag);                               --Tag  
editBox:setFontSize(fontSize);                      --文本尺寸  
editBox:setFontColor(textColor);                    --文本尺寸
editBox:setFontName(fontName)                       -- .ttf 
editBox:setPlaceHolder(sPlaceHolder);               --占位文本  
editBox:setPlaceholderFontSize(fontSize);           --占位文本尺寸  
if iMaxLength ~= nil then  
    editBox:setMaxLength(iMaxLength);               --字数限制  
end 
editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)  --键盘返回类型  
editBox:registerScriptEditBoxHandler(func_onEditboxEvent)
editBox:setInputMode(par_n_inputmode)
8.ccui loadTexture
loadTextures
loadTextureNormal
loadTexture
9.加载资源
display.loadSpriteFrames("others/plist/expression.plist", "others/plist/expression.png")
local t_sprback = cc.Sprite:createWithSpriteFrameName(par_t_info.s_sprback)
-- if (t_sprback) then
--   t_mjspr:setDisplayFrame(par_t_info.s_sprback)
-- end
local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(par_t_info.s_sprback)  
t_mjspr:setSpriteFrame(frame)
10.帧动画
local ani_mation = cc.Animation:create()
local frame_temp = nil
local s_temp = nil
for i=1,20 do
	s_temp = string.format("bq%d_%d.png", par_n_key, i)
	frame_temp = SpriteFrameCache:getSpriteFrame(s_temp) --getSpriteFrameByName
	if (frame_temp) then
	  ani_mation:addSpriteFrame(frame_temp)
	else
	  break
	end
end
ani_mation:setDelayPerUnit(0.2)
ani_mation:setLoops(10)
spr_express:runAction(cc.Animate:create(ani_mation))
11.骨骼动画
local newAnimationSpine = function(s_path)
  local animation = sp.SkeletonAnimation:create(s_path ..".json", s_path .. ".atlas")
  function animation:stopAnimation()
    self:clearTracks()
    return self
  end  
  function animation:playAnimation(trackIndex, name, isLoop)
    self:setToSetupPose()
    self:setAnimation(trackIndex, name, isLoop)
    return self
  end
  return animation
end
local s_path = "others/lxtpmj/roundover/NewProject"
local an_ = newAnimationSpine(s_path):addTo(self)
an_:setAnimation(0, "newAnimation", false)
12.clippingnode 
local img_avatar
local s_clipavatar = "o"
local spr_clipavatar = cc.Sprite:create(s_clipavatar)
:set....
local size_avatar = img_avatar:getContentSize()
--
local clip = cc.ClippingNode:create()
clip:setInverted(false) -- 倒置
clip:setStencil(spr_clipavatar) -- 模板
clip:setAlphaThreshold(0) -- 透明度起始点
clip:setPosition(img_avatar:getPosition())
clip:addTo(img_avatar:getParent())
--
img_avatar:setTouchEnabled(true)
img_avatar:addClickEventListener(hallbtn_click)
img_avatar = ccui.ImageView:create()
img_avatar:loadTexture(s_clipavatar)
img_avatar:ignoreContentAdaptWithSize(false)
img_avatar:setContentSize(size_avatar)
img_avatar:addTo(clip)
self.img_avatar = img_avatar
13.URL编码
local function decodeURI(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end
local function encodeURI(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end
14.cc.XMLHttpRequest GET&POST 
local url = "http://103.101.207.36/WS/account.ashx"
local param = "action=bindexchangeaccount&userid=2175&signature=6C4CB4473E29189C455878AB0884825F&time=1562917536&realname=%e5%91%b5%e5%91%b5%e5%93%92&exchangeaccount=%e5%91%b5%e5%91%b5%e5%93%92&type=0"
local tab_fileutils = cc.FileUtils:getInstance()
local par_s_postdata -- post参数
local par_s_url = url .. "?" .. param
local par_func_ = function (par_response)
    -- dump(json.decode(par_response), par_response)
    -- local par_s_filename = "heheda.png"
    -- local fullFileName = tab_fileutils:getWritablePath() .. par_s_filename
    -- local file = io.open(fullFileName,"wb")
    -- file:write(par_response)
    -- file:close()
end
local xhr = cc.XMLHttpRequest:new()
xhr._callfunc = par_func_
xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
xhr:open("GET", par_s_url)
local function onResponse()
    if xhr._callfunc and xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
      xhr._callfunc(xhr.response)
    end
    xhr:unregisterScriptHandler()
end
xhr:registerScriptHandler(onResponse)
xhr:send(par_s_postdata)
15.头像信息本地，下载，比较替换，
local wx_headimgurl = cc.UserDefault:getInstance():getStringForKey("wx_headimgurl")
local n_userid = tab_mydata.n_userid  
local s_avatarname = tab_myutils.getShowUserAvatar(n_userid)
local s_userid = string.format("%d", n_userid)
local s_identifier_value = tab_userdefault:getStringForKey(s_userid, "")
if (tab_fileutils:isFileExist(s_avatarname) and (s_identifier_value == wx_headimgurl)) then
  img_avatar:loadTexture(s_avatarname)
else
  if tab_fileutils:isFileExist(s_avatarname) then
    tab_fileutils:removeFile(s_avatarname)
  end
  tab_myutils.getDownloadFile(wx_headimgurl, s_avatarname, function (par_s_para, par_s_filename)
    -- body
    local fullFileName = cc.FileUtils:getInstance():getWritablePath() .. par_s_filename
    local file = io.open(fullFileName,"wb")
    file:write(par_s_para)
    file:close()
    if (t_self and t_self.img_avatar) then
      tab_userdefault:setStringForKey(s_userid, wx_headimgurl);
      t_self.img_avatar:loadTexture(fullFileName)
    end
  end)
end
16.ccui.Slider ccui.LoadingBar cc.ProgressTimer
-- ProgressTimer
local right = cc.ProgressTimer:create(cc.Sprite:create(getRes("progress.png")))
right:setType(cc.PROGRESS_TIMER_TYPE_BAR)
right:setMidpoint(cc.p(0, 1)) -- Setup for a bar starting from the left since the midpoint is 1 for the x
right:setBarChangeRate(cc.p(1, 0)) -- Setup for a horizontal bar since the bar change rate is 0 for y meaning no vertical change
right:setPosition(cc.p(640, 100))
right:setPercentage(0)
right:addTo(self)
--
local right = ccui.Slider:create()
right:loadBarTexture(getRes("progressbg.png"))
right:loadProgressBarTexture(getRes("progress.png"))
right:loadSlidBallTextures(getRes("progresspt.png"),"","");
right:setTouchEnabled(false)
right:setPosition(cc.p(640, 100))
right:setPercent(100)
right:addTo(self)
17.启动游戏，切换场景
function AppBase:run(initSceneName)
    self:enterScene(initSceneName)
end
require("app.MyApp"):create():run()
self:getApp():enterSceneEx("plaza.views.LogonScene","FADE",1)
local runScene = cc.Director:getInstance():getRunningScene()
18.热更新
装包后，判断是否解压文件
require("app.models.command")
package.loaded["app.models.command"] = nil
ClientUpdate
底包更新文件，单独处理. 不能包含外部文件 不能直接更新内容 只能获取本地版本.
版本信息记录在，底包+本地，和网站，比较更新类型. md5
--更新类型：更新（是否为强制） 热更新 (是否为强制)
--分开各部分更新
--justcheckVersion 如果网站慢，可以从服务端获取版本先
tab_myassetmanager = cc.AssetsManagerEx:create("project.manifest", storagePath)
tab_myassetmanager:retain()
-- 设置下载消息listener
local function onCheckProgress(event)
    local eventCode = event:getEventCode()
    if (eventCode ~= 5 and eventCode ~= 6) then print("onCheckProgress", eventCode) end
    if (tab_myassetcode.ALREADY_UP_TO_DATE == eventCode) then 
        onCompeleted()
    elseif (tab_myassetcode.UPDATE_FINISHED == eventCode) then
        if (cc.exports.myapp.s_localversion) then
            -- restart app
            restartApp();
        else
            -- enter
            onCompeleted()
        end
    elseif (tab_myassetcode.UPDATE_PROGRESSION == eventCode) then
        local percent = 0
        if (event.getPercent) then
            percent = event:getPercent()
        -- elseif (event.getPercentByFile) then
        --     percent = event:getPercentByFile()
        end
        if downloadProgress then
            if (downloadProgress.setPercentage) then
                downloadProgress:setPercentage(percent)
            elseif (downloadProgress.setPercent) then
                downloadProgress:setPercent(percent)
            end
        end
    elseif (tab_myassetcode.ERROR_NO_LOCAL_MANIFEST == eventCode 
        or tab_myassetcode.ERROR_DOWNLOAD_MANIFEST == eventCode
        or tab_myassetcode.ERROR_PARSE_MANIFEST == eventCode
        or tab_myassetcode.ERROR_UPDATING == eventCode) then
        -- showRetryPop()
        -- tab_myassetmanager:downloadFailedAssets()
    elseif (tab_myassetcode.UPDATE_FAILED == eventCode) then
        showRetryPop()
    elseif (tab_myassetcode.NEW_VERSION_FOUND == eventCode) then
        WNotice:showWait(t_self)
        WNotice:showWait(t_self, tab_mylanguage.res_updating)
    end
end
-- dispatch
eventListenerAssetsManagerEx = cc.EventListenerAssetsManagerEx:create(tab_myassetmanager, onCheckProgress)
-- eventListenerAssetsManagerEx:retain()
dispatcher:addEventListenerWithFixedPriority(eventListenerAssetsManagerEx, 1)
tab_myassetmanager:update()      -- 检查版本并升级
19.ccexp.VideoPlayer
local visibleSize = cc.Director:getInstance():getVisibleSize() 
local videoPlayer = ccexp.VideoPlayer:create() --
videoPlayer:setPosition(tab_designcenterpos)
videoPlayer:setAnchorPoint(cc.p(0.5, 0.5))
videoPlayer:setContentSize(cc.size(visibleSize.width, visibleSize.height))
videoPlayer:setFileName(par_s_path) -- 设置文件
videoPlayer:setKeepAspectRatioEnabled(false) -- 保持长宽比
videoPlayer:setTouchEnabled(false)
videoPlayer:setFullScreenEnabled(false) -- 设置全屏可获取
videoPlayer:setVisible(true)
local onVideoEventCallback = function (sener, eventType)
    if eventType ~= ccexp.VideoPlayerEvent.COMPLETED then 
        return 
    end
    -- self:goUpdateLayer()
    videoPlayer:stop()
    if (par_func_callback) then
        videoPlayer:runAction(cc.Sequence:create(
        cc.CallFunc:create(par_func_callback),
        cc.RemoveSelf:create(),
        nil))
    else
        videoPlayer:runAction(cc.Sequence:create(
        cc.RemoveSelf:create(),
        nil))
    end
end
videoPlayer:addEventListener(onVideoEventCallback)
self:addChild(videoPlayer)
videoPlayer:play()
20.ccui.ListView 移动位置事件
t_self.list_member:pushBackCustomItem(view_temp)
t_self.list_room:insertCustomItem(layout_temp, 0);
local n_currentselected = t_self.list_member:getCurSelectedIndex()
print("n_currentselected", n_currentselected);
local n_maxcount = t_self.list_member:getChildrenCount()
if n_currentselected < 2 then
    t_self.list_member:jumpToTop()
elseif n_currentselected >= n_maxcount - 2 then
    t_self.list_member:jumpToBottom()
else
    t_self.list_member:jumpToItem(n_currentselected, cc.p(0.5, 0.5), cc.p(0.5, 0.5))
end
-- 
local n_count = list_member:getChildrenCount()
local par_ref = par_t_item
local layout_container = self.list_member:getInnerContainer()
local n_xx = layout_container:getPositionX() + par_ref:getPositionX()
local n_yy = layout_container:getPositionY() + par_ref:getPositionY()
local pos = self:convertToNodeSpace(cc.p(n_xx, n_yy)) 
img_setting:setPositionY(pos.y)
--
list_record:onScroll(self.onSelectedItemEventScrollView)
function _M.onSelectedItemEventScrollView(par_ref_)
	print(par_ref_)
	print("par_ref_.name", par_ref_.name)
end
21.string table 函数
string.sub(s,2,2) -- 从第二个到第二个的子串（包含）
string.sub(s,2,-2) -- 从第二个到倒数第二个的子串（包含）
函数原型 string.gsub(s, pat, repl [, n])
就是 global 全局替换子字符串的意思
s: 源字符串
pat: 即 pattern， 匹配模式
repl: replacement， 将 pat 匹配到的字串替换为 repl
[, n]: 可选， 表示只看源字符串的前 n 个字符
--
函数原型 string.find(s, pattern [, init [, plain] ]
s: 源字符串
pattern: 待搜索模式串
init: 可选， 起始位置
plain: 我没用过
print(string.find("haha", 'ah') )  ----- 输出 2 3
--
string.format()
string.len() string.char() string.byte()
table.insert(t_, value) table.remove(t_, index) table.sort(t_, func(a,b) end)
22.string 特殊字符处理
local removeString = function(str, remove)  
    local lcSubStrTab = {}  
    while true do  
        local lcPos = string.find(str,remove)  
        if not lcPos then  
            lcSubStrTab[#lcSubStrTab+1] =  str      
            break  
        end  
        local lcSubStr  = string.sub(str,1,lcPos-1)  
        lcSubStrTab[#lcSubStrTab+1] = lcSubStr  
        str = string.sub(str,lcPos+1,#str)  
    end  
    local lcMergeStr =""  
    local lci = 1  
    while true do  
        if lcSubStrTab[lci] then  
            lcMergeStr = lcMergeStr .. lcSubStrTab[lci]   
            lci = lci + 1  
        else   
            break  
        end  
    end  
    return lcMergeStr  
end,
local par_func_ = function(par_s_unicode)
    par_s_unicode = string.gsub(par_s_unicode,"\\u","\\\\u")
    par_s_unicode = string.gsub(par_s_unicode,"\\r\\n","")
    local par_s_ = tab_myutils.unicode_to_utf8(par_s_unicode)
    par_s_ = tab_myutils.removeString(par_s_,"\\")
    print(par_s_)
    local t_info = json.decode(par_s_)
 end
23.unicode utf8 转换
 unicode_to_utf8 = function(convertStr)
    if type(convertStr)~="string" then
        return convertStr
    end
    local resultStr=""
    local i=1
    while true do
        local num1=string.byte(convertStr,i)
        local unicode
        if num1~=nil and string.sub(convertStr,i,i+1)=="\\u" then
            unicode=tonumber("0x"..string.sub(convertStr,i+2,i+5))
            i=i+6
        elseif num1~=nil then
            unicode=num1
            i=i+1
        else
            break
        end
        -- print(unicode)
        if unicode <= 0x007f then
            resultStr=resultStr..string.char(bit.band(unicode,0x7f))
        elseif unicode >= 0x0080 and unicode <= 0x07ff then
            resultStr=resultStr..string.char(bit.bor(0xc0,bit.band(bit.rshift(unicode,6),0x1f)))
            resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
        elseif unicode >= 0x0800 and unicode <= 0xffff then
            resultStr=resultStr..string.char(bit.bor(0xe0,bit.band(bit.rshift(unicode,12),0x0f)))
            resultStr=resultStr..string.char(bit.bor(0x80,bit.band(bit.rshift(unicode,6),0x3f)))
            resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
        end
    end
    resultStr=resultStr..'\0'
    -- print(resultStr)
    return resultStr
end,
utf8_to_unicode = function(convertStr)
    if type(convertStr)~="string" then
        return convertStr
    end
    local resultStr=""
    local i=1
    local num1=string.byte(convertStr,i)
    while num1~=nil do
        -- print(num1)
        local tempVar1,tempVar2
        if num1 >= 0x00 and num1 <= 0x7f then
            tempVar1=num1
            tempVar2=0
        elseif bit.band(num1,0xe0)== 0xc0 then
            local t1 = 0
            local t2 = 0
            t1 = bit.band(num1,bit.rshift(0xff,3))
            i=i+1
            num1=string.byte(convertStr,i)
            t2 = bit.band(num1,bit.rshift(0xff,2))
            tempVar1=bit.bor(t2,bit.lshift(bit.band(t1,bit.rshift(0xff,6)),6))
            tempVar2=bit.rshift(t1,2)
        elseif bit.band(num1,0xf0)== 0xe0 then
            local t1 = 0
            local t2 = 0
            local t3 = 0
            t1 = bit.band(num1,bit.rshift(0xff,3))
            i=i+1
            num1=string.byte(convertStr,i)
            t2 = bit.band(num1,bit.rshift(0xff,2))
            i=i+1
            num1=string.byte(convertStr,i)
            t3 = bit.band(num1,bit.rshift(0xff,2))
            tempVar1=bit.bor(bit.lshift(bit.band(t2,bit.rshift(0xff,6)),6),t3)
            tempVar2=bit.bor(bit.lshift(t1,4),bit.rshift(t2,2))
        end
        resultStr=resultStr..string.format("\\u%02x%02x",tempVar2,tempVar1)
        -- print(resultStr)
        i=i+1
        num1=string.byte(convertStr,i)
    end
    -- print(resultStr)
    return resultStr
end,
24.想必做过爬虫的同学肯定被编码问题困扰过，有ASCII UTF-8、GBK、Unicode 等等编码方式
将其转化为二进制存储到计算机中，这个过程我们称之为编码。
GB2312:
ASCII: 在美国，这 128 是够了，但是其他国家不答应啊
Unicode:Unicode 为世界上所有字符都分配了一个唯一的数字编号，这个编号范围从 0x000000 到 0x10FFFF (十六进制)，
有 110 多万，每个字符都有一个唯一的 Unicode 编号，这个编号一般写成 16 进制，在前面加上 U+。
例如：“马”的 Unicode 是U+9A6C。 Unicode 就相当于一张表，建立了字符与编号之间的联系。
--
Unicode 本身只规定了每个字符的数字编号是多少，并没有规定这个编号如何存储。
有的人会说了，那我可以直接把 Unicode 编号直接转换成二进制进行存储，是的，你可以，但是这个就需要人为的规定了，而 
Unicode 并没有说这样弄，因为除了你这种直接转换成二进制的方案外，还有其他方案，接下来我们会逐一看到。 
编号怎么对应到二进制表示呢？有多种方案：主要有 UTF-8，UTF-16，UTF-32。
25.事件处理
--
addTouchEventListener
addClickEventListener
addEventListener
-- 定义事件分发器
local eventDispatcher = self:getEventDispatcher()
if 0 == self._fixedPriority then
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.t_touchlistener, self)
	eventDispatcher:addEventListenerWithSceneGraphPriority(self.t_touchlistener:clone(), self)
else
    eventDispatcher:addEventListenerWithFixedPriority(self.t_touchlistener,self._fixedPriority)
end
self:getEventDispatcher():removeEventListener(self.t_touchlistener)
_eventDispatcher->removeAllEventListeners();
-- 事件监听 触摸
self.t_touchlistener = cc.EventListenerTouchOneByOne:create()
self.t_touchlistener:registerScriptHandler(handler(self,self.onTouchBegan),cc.Handler.EVENT_TOUCH_BEGAN )
self.t_touchlistener:registerScriptHandler(handler(self,self.onTouchMoved),cc.Handler.EVENT_TOUCH_MOVED )
self.t_touchlistener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED )
self.t_touchlistener:registerScriptHandler(handler(self,self.onTouchCancel),cc.Handler.EVENT_TOUCH_CANCELLED )
function WMahjongCtrl:onTouchBegan(par_touch, par_event)
	par_touch:getLocation()
end
-- 事件监听 通用
local listener1 = cc.EventListenerCustom:create(cc.exports.myevent.CONNECT_FAILURE, handler(self, self.onConnectFailContinue))
c.Director:getInstance():getEventDispatcher():dispatchEvent()
26.鹅鹅鹅
cc.PLATFORM_OS_MAC     = 2
cc.PLATFORM_OS_ANDROID = 3
cc.PLATFORM_OS_IPHONE  = 4
cc.PLATFORM_OS_IPAD    = 5
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
cc.CSLoader:createNode()
--]]














