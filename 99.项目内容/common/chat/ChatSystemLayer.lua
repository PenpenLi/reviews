--
-- ChatSystemLayer
-- Author: chenzhanming
-- Date: 2016-10-16 
-- 聊天系统组件
--

local ChatSystemSamepleConfig = require("src.app.game.common.chat.ChatSystemSamepleConfig")
local scheduler = require("framework.scheduler")
require("app.hall.base.third.ImgUpload")

local Expression_Effect_Times = 3   --表情播放次数

local ChatSystemLayer = class("ChatSystemLayer", function()
    return display.newLayer()
end)

ChatSystemLayer.SELECTED_BTN_TAG_ZHANGFEI = 1
ChatSystemLayer.SELECTED_BTN_TAG_QUICK_CHAT = 2
ChatSystemLayer.SELECTED_BTN_TAG_CHAT_RECORD = 3
ChatSystemLayer.SELECTED_BTN_TAG_TALK_BUTTON = 4

ChatSystemLayer.EXPRESSION_TYPE_ZHANGFEI = 0
ChatSystemLayer.EXPRESSION_TYPE_QUICK_CHAT = 1
ChatSystemLayer.EXPRESSION_TYPE_INTERACT = 2

ChatSystemLayer.EXPRESSION_TYPE_BTN_CLICK = 999

ChatSystemLayer.TALK_PATH = device.writablePath .. "phrase/"
ChatSystemLayer.SERVER_TALK_PATH = AliYunUtil.voicePath
ChatSystemLayer.RECOGNIZER_MIN_TIME = 500  --毫秒
ChatSystemLayer.RECOGNIZER_MAX_TIME = 30000.0
ChatSystemLayer.RECOGNIZER_STOP_OK = 2000.0

ChatSystemLayer.RES_PATH = "src/app/game/common/chat/phrase"


-- 0表情 1快速聊天 2互动动画 3文字 4语音
ChatSystemLayer.CLICK_HANDLER_ANI_TYPE = 0
-- 快捷聊天接口类型
ChatSystemLayer.CLICK_HANDLER_TEXT_TYPE = 1
-- 语音类型
ChatSystemLayer.CLICK_HANDLER_VOICE = 4

ChatSystemLayer.CLICK_HANDLER_AMUSING_TYPE = 5

function ChatSystemLayer:ctor( params )
	
	self.isOpenChat = true
	--self.isOpenVoice = true
	
    self.gameKind = params.gameKind                 -- 游戏id
    self.resourcePath = params.resourcePath         -- 外部资源路径
    self.messageButtonPos = params.messageButtonPos -- 聊天按钮位置
    self.voiceBtnPos = params.voiceBtnPos           -- 语音按钮位置
	self.gameUIConfig = params.gameUIConfig
	
	self.gameAtomTypeId = params.gameAtomTypeId		-- 游戏id
	self.serverReq = params.serverReq
	self.serverAck = params.serverAck
	
	self.chatUI = {}
	self.labelColors = {}
	self.quickChat = {}
	self.expressions = {}
	self.voiceAnimations = {}
	self.voiceTextTips = {}

	for k,v in pairs(ChatSystemSamepleConfig) do
		if self[k]  then
			for t,d in pairs(v) do
				self[k][t] = d
			end
		end
	end
	
	if self.gameUIConfig then
		for k,v in pairs(self.gameUIConfig) do
			if self[k]  then
				for t,d in pairs(v) do
					self[k][t] = d
				end
			end
		end
	end
		
    self:setTouchSwallowEnabled(false)
    self:setNodeEventEnabled( true )

    
    UpdateFunctions.mkDir(ChatSystemLayer.TALK_PATH)       -- 创建目录
    self:addSearchPath4TalkVoice()                 
    self:loadPlistPng()
    self:initData()
	self:initUI()
    self.musicvolume = g_GameMusicUtil:getMusicVolume()
    -- 注册服务器回调
    --
	-- 接收场景转发消息
   	TotalController:registerNetMsgCallback(self, Protocol.SceneServer, "CS_H2C_HandleMsg_Ack", handler(self, self.sceneNetMsgHandler))
	
	addMsgCallBack(self, PublicGameMsg.MSG_PUBLIC_CHAT_AMUSING, handler(self, self.onReciveAmusing))
end

function ChatSystemLayer:onEnter()
   
end

function ChatSystemLayer:onExit()
	print("ChatSystemLayer:onExit()")
	-- 注销服务器回调
    --
	TotalController:removeNetMsgCallback(self, Protocol.SceneServer, "CS_H2C_HandleMsg_Ack")
	
	removeMsgCallBack(self,PublicGameMsg.MSG_PUBLIC_CHAT_AMUSING)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:removeEventListener( self.listenner )
    self:hideTalkErrorTimerEnd()
    self:monitorTalkIsLongTimerEnd()
    self:removePlistPng()
end


function ChatSystemLayer:isOpenVoice()
	print("ChatSystemLayer:isOpenVoice()")
	return g_GameSwitchUtil:getVoiceStatus()==ccui.CheckBoxEventType.selected
end

function ChatSystemLayer:sceneNetMsgHandler(__idStr, __info, __tag)
	print(__idStr, __tag)
	if __idStr == "CS_H2C_HandleMsg_Ack" then
		if __info.m_result == 0 then
			local gameAtomTypeId = __info.m_gameAtomTypeId
			local cmdId = __info.m_message[1].id
			local info = __info.m_message[1].msgs
			if self.onHandleDataByServer then
				self:onHandleDataByServer(cmdId, info)
			end
		else
			print("找不到场景信息")
		end
	end
end

function ChatSystemLayer:sendToServer(msg_type,tag,uid,str_len,str_data)
	ConnectManager:send2SceneServer( self.gameAtomTypeId, self.serverReq, { msg_type,tag,uid,str_len,str_data, self.gameAtomTypeId} )
end
function ChatSystemLayer:onHandleDataByServer(__idStr, __info)
--  struct CMD_GP_TableChat
--  {
--    BYTE  dwType;                   // 0表情 1快速聊天 2互动动画 3文字 4语音
--    DWORD dwOption;                 // 设置0，1，2表示索引值，3表示颜色 4无意义
--    DWORD dwUserID;                 // 发送用户
--    WORD wChatLen;                  // 数据长度（文字长度 或者语音长度）
--    TCHAR szData[128];
--  }
	if __idStr == self.serverAck then
		__info = __info or {}
		local server_data = __info
		local filter = {}
		filter[ChatSystemLayer.CLICK_HANDLER_ANI_TYPE] = true
		filter[ChatSystemLayer.CLICK_HANDLER_TEXT_TYPE] = true
		if filter[server_data.m_nMsgType] then
			if server_data.m_nAccountId == Player:getAccountID() then
				return 
			end
		end
			
		if server_data.m_nMsgType ==  ChatSystemLayer.CLICK_HANDLER_ANI_TYPE then
			local data = {server_data.m_nOption, server_data.m_nAccountId}
			self:onHandleImageByServer(data)

		elseif server_data.m_nMsgType == ChatSystemLayer.CLICK_HANDLER_TEXT_TYPE then
			local data = {server_data.m_nOption, server_data.m_nAccountId}
			self:onHandleTextByServer(data)

		elseif server_data.m_nMsgType == ChatSystemLayer.CLICK_HANDLER_VOICE then
			local strdata = server_data.m_szData
			print("strlist=",strdata)
			local strlist = string.split(strdata, ',')
			local data = {strlist[1], strlist[2], strlist[3], server_data.m_nAccountId}
			self:onHandleVoiceByServer(data)
		elseif server_data.m_nMsgType == ChatSystemLayer.CLICK_HANDLER_AMUSING_TYPE then
			local strdata = server_data.m_szData
			print("strlist=",strdata)
			local strlist = string.split(strdata, ',')
			local data = {}
			data.tag = strlist[1]
			data.send_userId = tonumber(strlist[2])
			data.recive_userId = tonumber(strlist[3])
			self:onHandleAmusingByServer(data)
		end
	end

end

function ChatSystemLayer:addSearchPath4TalkVoice()
	ToolKit:addSearchPath(self.RES_PATH)
    if self.resourcePath then
       ToolKit:addSearchPath(self.resourcePath)
    end
end

function ChatSystemLayer:loadPlistAsyncHandler(plistFilename,image)
	print(plistFilename)
	print(image)
    local asyncHandler = function(texture)
		if texture then
			cc.SpriteFrameCache:getInstance():addSpriteFrames(plistFilename)
		end
    end
    display.addImageAsync(image, asyncHandler)

end

function ChatSystemLayer:loadPlistPng()
     -- 加載动画plist
	for k,v in pairs(self.expressions)  do
		--display.addSpriteFrames(v.PlistName,v.PngName)
		self:loadPlistAsyncHandler(v.PlistName,v.PngName)
	end
		for k,v in pairs(self.voiceAnimations)  do
		--display.addSpriteFrames(v.PlistName,v.PngName)
		self:loadPlistAsyncHandler(v.PlistName,v.PngName)
	end
end

function ChatSystemLayer:removePlistPng()
	 -- 卸載动画plist
	for k,v in pairs(self.expressions)  do
		display.removeSpriteFramesWithFile(v.PlistName)
	end
		for k,v in pairs(self.voiceAnimations)  do
		display.removeSpriteFramesWithFile(v.PlistName)
	end
end


function ChatSystemLayer:initData()
    self.isShowChatNode = false
	self.voiceDataQueue = {}
	self.txtDataQueue = {}
    self.usersTable = {}
    self.voiceIsPlays = {}
    self.speexFileName = nil 
    self.isUploadFileCallback = true
    self.isStopRecordOK = true
    self.isSendVoiceMessage = true
    self.recordingTimeIsShort = false
    self.userHeadFiles = {}  --玩家头像信息 userId{headFile}(key-value)
    self.chatDatas = {}      --聊天信息 {uuid{uuid,voiceTime,spx,userId, }} 语音id,录音时间
    -- 玩家全球唯一ID
    self.userId = Player:getAccountID()
    -- 组合成本地录音名字
    self.recordName = ""
    -- 开始时间
    self.beginTime = 0
    -- 录音时间
    self.recordTime = 0
    -- 是否正在播放中
    self.isPlayingRecordVoice = false
    -- 滑动终止录音 0:录音完成, 1:开始录音, 2:中断录音
    self.recordVoiceState = 0
    -- 是否正在录音
    self.isRecordVoice = false   
    self.messageNodeNum = 0

    -- self.headSize = cc.size(55,55)
    -- self.headFilePath = ""
    -- local data = {
    --     filename=UserInfo._faceID,
    --     height=self.headSize.height,
    --     ret = 2,
    --     callback = function(filePath)
    --         self.headFilePath = filePath
    --     end
    -- }
    -- require("app.lobby.data.DownLoadHead").new(data)
end

function ChatSystemLayer:isFileExist( filename )
    local isExist = true
    if not cc.FileUtils:getInstance():isFileExist(filename) then
       local stringText = string.format("找不到文件:%s,请认真检查传入的资源路径!",filename) 
       print(stringText)
       isExist =  false
    end
    return isExist
end
function ChatSystemLayer:onCreateLayerCallBack(sender)
	local name = sender:getName()
	print(name)
	if name == "comlang_btn" then
	   self.comLangBtn:setTouchEnabled(false)
	   self.comLangBtn:setBright(false)
	   self.expressionBtn:setTouchEnabled(true)
	   self.expressionBtn:setBright(true)
	   self.comLangScrollview:setVisible(true)
	   self.expressionScrollview:setVisible(false)
       self.comLangScrollview:jumpToTop()
	elseif name == "expression_btn"  then
	   self.comLangBtn:setTouchEnabled(true)
	   self.comLangBtn:setBright(true)
	   self.expressionBtn:setTouchEnabled(false)
	   self.expressionBtn:setBright(false)
	   self.comLangScrollview:setVisible(false)
	   self.expressionScrollview:setVisible(true)
       self.expressionScrollview:jumpToTop()
	end
end
-- 初始化UI
function ChatSystemLayer:initUI()
    print("-------------------------------ChatSystemLayer:initUI-------------------------------")
    
    if not  self:isFileExist( self.chatUI.talkLayerCsb ) then
       return
    end
    self.talkVoiceNode = UIAdapter:createNode( self.chatUI.talkLayerCsb )
    self:addChild(self.talkVoiceNode, -1)
	UIAdapter:adapter(self.talkVoiceNode, handler(self, self.onCreateLayerCallBack))

    self.talkVoiceNode:setVisible(true)
    self.chatNode = self.talkVoiceNode:getChildByName("chat_bg")
    self.chatNode:setVisible(false)
    -- 常用语按钮
    self.comLangBtn = self.chatNode:getChildByName("comlang_btn")
    --UIAdapter:transNode(self.comLangBtn)
	--self.comLangBtn:addTouchEventListener(handler(self,self.onTabPressButtons)) 
	--self.comLangBtn:setVisible(false)
    -- 表情
    self.expressionBtn = self.chatNode:getChildByName("expression_btn")
	--UIAdapter:transNode(self.expressionBtn)
    --self.expressionBtn:addTouchEventListener(handler(self,self.onTabPressButtons)) 

    -- 常用语滑动列表
    self.comLangScrollview = self.chatNode:getChildByName("comlang_scrollview")
    self.comLangScrollview:setTouchSwallowEnabled(false)

    --表情滑动列表
    self.expressionScrollview = self.chatNode:getChildByName("expression_scrollview")
    self.expressionScrollview:setTouchSwallowEnabled(false)

    -- 预览节点查看表情和快捷聊天预览
     --self.previewNode = self.talkViceNode:getChildByName("previewNode")

    self.talkNode = self.talkVoiceNode:getChildByName("talk_node")
    self.talkNode:setVisible(false)
    -- 录音动画节点
    self.talkAniNode = self.talkNode:getChildByName("ani_node")
    -- 录音器图片
    self.talkImage = self.talkNode:getChildByName("image")
    -- 录音提示文字
    self.voiceTipsLabel = self.talkNode:getChildByName("voice_tips_label")
    -- 录音太短提示图标
    self.shortNode = self.talkNode:getChildByName("short_node")
    
    -- 聊天按钮
    self.messageButton = self.talkVoiceNode:getChildByName("message_button")
    tolua.cast(self.messageButton,"ccui.Button")
    local messageButtonLocationPos = cc.p(self.messageButton:getPosition())
    if self.messageButtonPos == "" or self.messageButtonPos == nil then
       self.messageButtonPos = messageButtonLocationPos
    end
    self.messageButton:setPosition(self.messageButtonPos)
    self.messageButton:addTouchEventListener(handler(self, self.onPressMessageButtons))

    -- 语音按钮
    self.talkButton = self.talkVoiceNode:getChildByName("talk_button")
    tolua.cast(self.talkButton,"ccui.Button")
    local voiceBtnLocationPos = cc.p(self.talkButton:getPosition())
    if self.voiceBtnPos == "" or self.voiceBtnPos == nil then
       self.voiceBtnPos =  voiceBtnLocationPos
    end
    self.talkButton:setPosition(self.voiceBtnPos)
    self.talkButton:addTouchEventListener(handler(self,self.ontVoiceBtnPressButtons))
	if VoiceRecordUtil.setCallback then
		local upload_callback = handler(self,self.speexRecordCallback)
		VoiceRecordUtil:setCallback(upload_callback)
		--VoiceRecordUtil:addVoiceRecordTouchCallback(self.talkButton,handler(self,self.ontVoiceBtnPressButtons))
	end
	
    -- 初始化常用语滚动框
    self:initComLangScrollview()
    
    -- 初始化表情滚动框
    self:initExpressionScrollview()

    self:voiceBtnOnOrOff()

    self.comLangBtn:setTouchEnabled(true)
    self.comLangBtn:setBright(true)
    self.expressionBtn:setTouchEnabled(false)
    self.expressionBtn:setBright(false)
    self.comLangScrollview:setVisible(false)
    self.expressionScrollview:setVisible(true)
    
    --添加拖动框响应事件,各种坑必须用这种方法去实现拖动框里的节点响应事件
    self.listenner = cc.EventListenerTouchOneByOne:create()
    self.listenner:setSwallowTouches(false)
    self.listenner:registerScriptHandler(function(touch, event)
            return self:onTouchBegan(touch:getLocation().x, touch:getLocation().y)
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    self.listenner:registerScriptHandler(function(touch, event)
            self:onTouchMoved(touch:getLocation().x, touch:getLocation().y)
        end,cc.Handler.EVENT_TOUCH_MOVED )
    self.listenner:registerScriptHandler(function(touch, event)
            self:onTouchEnded(touch:getLocation().x, touch:getLocation().y)
        end,cc.Handler.EVENT_TOUCH_ENDED )
    self.listenner:registerScriptHandler(function(touch, event)
            self:onTouchCancelled(touch:getLocation().x, touch:getLocation().y)
        end,cc.Handler.EVENT_TOUCH_CANCELLED )
    local eventDispatcher = self:getEventDispatcher()
    --eventDispatcher:addEventListenerWithFixedPriority(self.listenner,-128)
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.listenner, self)
end

function ChatSystemLayer:onPressMessageButtons(sender,eventType)
    if sender then
        if eventType == ccui.TouchEventType.began then
           --self.isShowChatNode = not self.isShowChatNode
           local visible =  self.chatNode:isVisible()
           self.chatNode:setVisible( not visible )
        end
    end
end

function ChatSystemLayer:initComLangScrollview()
    local size = self.comLangScrollview:getContentSize()
    self.expressionQuickChat = self.quickChat
    local quickChatNum =table.nums(self.expressionQuickChat)
    local oneLineHeiht = 46
    local totalHeight = oneLineHeiht * quickChatNum 
    local startY = 0

    if size.height <  totalHeight then
        self.comLangScrollview:setInnerContainerSize(cc.size(size.width, totalHeight))
        startY = totalHeight
    else
        startY = size.height
    end

    for i = 1, #self.expressionQuickChat do
        print("self.expressionQuickChat")
        local color = cc.c4b(255,255,255,0)
        local messageBg = cc.LayerColor:create(color)
        self.comLangScrollview:addChild(messageBg)
        messageBg:setTag(i)
        messageBg:setAnchorPoint(cc.p(0,0.5))
        messageBg:setPosition(10 , startY - oneLineHeiht*math.floor(i))
		messageBg:setContentSize(cc.size(size.width-10, oneLineHeiht))
		
		local label = display.newTTFLabel({text = self.expressionQuickChat[i].quikWord,size = 24,font = "ttf/jcy.TTF"})
        label:setColor(cc.c3b(255, 255, 255))
        label:setDimensions(size.width-10, 0) 
        label:setAnchorPoint(cc.p(0, 0.5))
        label:setOpacity(200)
        --label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        --label:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_TOP)
        label:setPosition(10, oneLineHeiht*0.5)
        messageBg:addChild(label) 
        messageBg.label = label
		
		local line = display.newSprite("comchat/diz_di_laiotian3.png")
		line:setAnchorPoint(cc.p(0, 0.5))
		line:setPositionY(2)
		messageBg:addChild(line)
    end

    self.comLangNode = nil
    self.comLangNodeTag = nil

end

function ChatSystemLayer:initExpressionScrollview()
    local size =  self.expressionScrollview:getContentSize()
    
    self.mZhangFeiExpressionCnt = table.getn(self.expressions)
    local totalHeight = 70*math.ceil(self.mZhangFeiExpressionCnt/5)
    local startY = nil
    
    if size.height <  totalHeight then
        self.expressionScrollview:setInnerContainerSize(cc.size(size.width, totalHeight))
        startY = totalHeight - 35
    else
        startY = size.height - 35
    end

    for k, v in pairs(self.expressions) do
        local smallPng = v["SmallPng"]
        local expressBg = display.newSprite(smallPng)
        self.expressionScrollview:addChild(expressBg)
		
		expressBg:setScale(0.75)
        expressBg:setTag(k)
        local pos = cc.p((size.width/10)*(2*((k - 1)%5) + 1), startY - 100*math.floor((k - 1)/5))
        expressBg:setPosition(pos)
        --local firstFrame = display.newSprite(smallPng)
        --firstFrame:setPosition(cc.p(27, 35))
        --expressBg:addChild(firstFrame)
    end
    self.expressionScrollview:jumpToTop()

    self.expressionNode = nil
    self.expressionNodeTag = nil
end

-- 清空聊天坐标
function ChatSystemLayer:cleanUserIDPosTable(void)
    self.usersTable = {}
    self.voiceIsPlays = {}
end

-- 设置一个玩家显示表情和快捷聊天坐标
function ChatSystemLayer:setUserIDPos( params )
     self.usersTable[params.userID] = {
           messagepos    = params.messagepos or cc.p(0,0)    ,
           expressionPos = params.expressionPos or  cc.p(0,0),
           isFlippedX    = params.isFlippedX or false        , 
           isFlippedY    = params.isFlippedY or false        ,
           gender        = params.gender or 1                ,
     }
     self.voiceIsPlays[params.userID] = 0
end

function ChatSystemLayer:removePosByUserID( userID )
    if self.usersTable[userID] ~= nil then
       table.remove(self.usersTable,userID)
    end
end


function ChatSystemLayer:addChatData( uuid, uuidTable )
    self.chatDatas[uuid] = uuidTable
	dump(uuidTable)
end


function ChatSystemLayer:removeChatDataByUUID( uuid )
    table.remove(self.chatDatas, uuid )
end

function ChatSystemLayer:getChatDataByUUID( uuid )
    return self.chatDatas[ uuid ]
end

function ChatSystemLayer:setChatNodeVisible(bVisible)
    self.chatNode:setVisible( bVisible )
end

function ChatSystemLayer:isChatNodeVisible()
    return self.chatNode:isVisible()
end

function ChatSystemLayer:voiceBtnOnOrOff()
    self.messageButton:setVisible(true)
    self.talkButton:setVisible(true)
end

-- 设置聊天按钮和语音按钮的位置
function ChatSystemLayer:setMessageAndTalkButtonPos(messagePos, talkPos )
    self.messageButton:setPosition(messagePos)
    self.talkButton:setPosition(talkPos)
end

-- 设置聊天按钮和语音按钮的触摸状态
function ChatSystemLayer:setMessageAndTalkButtonEnabled( isEnable )
    self.messageButton:setTouchEnabled( isEnable )
    self.talkButton:setTouchEnabled( isEnable )
end

-- 设置聊天按钮显示状态
function ChatSystemLayer:setMessageButtonVisible( isShow )
    self.messageButton:setVisible( isShow )
end

-- 设置语言的按钮的显示状态
function ChatSystemLayer:settalkButtonVisible( isShow )
    self.talkButton:setVisible( isShow )
end

function ChatSystemLayer:speexRecordCallback( _ret ,_uuid, _speexFile,_voiceTime)
    self.isStopRecordOK = true
	self:addChatData(_uuid,{_uuid,_voiceTime,_speexFile,self.userId}) 
	self:uploadFileCallback(_ret..";".._uuid..";".._speexFile)
end

function ChatSystemLayer:uploadFileCallback( agrs )
    local strlist = string.split(agrs, ';')
    if  tonumber(strlist[1]) == 1 then
        self:delayShowUploadFileCallback(strlist[2],strlist[3])
    else 
        print("uploadFile Failed:", strlist[3])
        self:showTalkError( self.voiceTextTips[6] )
        self:hideTalkErrorTimerBegin( 2 )
    end
end

function ChatSystemLayer:read_files( fileName )
    local f = io.open(fileName,'r')
    local content = f:read("*all")
    f:close()
    return content
end 

function ChatSystemLayer:write_content( fileName,content )
    local  f = io.open(fileName,'a')
    f:write(content)
    f:close()
end



function ChatSystemLayer:delayShowUploadFileCallback( _uuid, _spxFile)
    print("uploadFile OK:", _spxFile)
    local chatData = self:getChatDataByUUID( _uuid )
    local strdata = _uuid .. "," .. tostring(chatData[2]) .. "," .. tostring(chatData[3])
    local strdata_len = string.len(strdata)
    self:showVoiceNodeToUser( _uuid )
	
	--voice send to service 
	self:sendToServer(ChatSystemLayer.CLICK_HANDLER_VOICE,4,self.userId,strdata_len,strdata)

end

function ChatSystemLayer:talkIsShort()
    local time = cc.net.SocketTCP.getTime()*1000 - self.beginTime
    if time < ChatSystemLayer.RECOGNIZER_MIN_TIME then 
        self.recordingTimeIsShort = true
        return true
    else
        return false
    end
end

function ChatSystemLayer:talkIsLong()
    local time = cc.net.SocketTCP.getTime()*1000  - self.beginTime
    if time >= ChatSystemLayer.RECOGNIZER_MAX_TIME then
       return true
    else
       return false
    end
end

function ChatSystemLayer:sureStopRecordOK()
    local time = cc.net.SocketTCP.getTime()*1000  - self.beginTime
    if time > ChatSystemLayer.RECOGNIZER_STOP_OK then
       print("------------------sureStopRecordOK-------------------------")
       self.isStopRecordOK = true
    end
end

--监测录音时间是否超过60s
function ChatSystemLayer:monitorTalkIsLong(dt)
    if self:talkIsLong() then
       self:monitorTalkIsLongTimerEnd()
       self:showTalkError( self.voiceTextTips[3] )
       self:hideTalkErrorTimerBegin( 1 )
       -- 恢复暂停的音乐
       g_GameMusicUtil:resumeAll()
      

    end
end

function ChatSystemLayer:monitorTalkIsLongTimerBegin()
    print("----------------- statusTimerBegin ----------------------------")
    if self.monitorTalkIsLongTimer then
        scheduler.unscheduleGlobal(self.monitorTalkIsLongTimer)
        self.monitorTalkIsLongTimer= nil
    end
    self.monitorTalkIsLongTimer = scheduler.scheduleGlobal(handler(self, self.monitorTalkIsLong),0)
end

function ChatSystemLayer:monitorTalkIsLongTimerEnd()
    if not self.monitorTalkIsLongTimer then
        return
    end
    scheduler.unscheduleGlobal(self.monitorTalkIsLongTimer)
    self.monitorTalkIsLongTimer = nil
end


function ChatSystemLayer:runVoiceAnimation( tips )
    if self.shortSpr then
        self.shortSpr:removeFromParent()
        self.shortSpr = nil
    end
    if self.reCallSpr then
       self.reCallSpr:removeFromParent()
       self.reCallSpr = nil
    end
    if self.voiceAnimationSpr then
        self.voiceAnimationSpr:stopAllActions()
        self.voiceAnimationSpr:removeFromParent()
        self.voiceAnimationSpr = nil
    end
    self.voiceTipsLabel:setString( tips )
    self.voiceTipsLabel:setColor(cc.c3b(255, 255, 255))
    self.talkImage:setVisible(true)
    self.voiceAnimationSpr = cc.Sprite:create()
    self.voiceAnimationSpr:setAnchorPoint(0.5, 0.0)
    self.talkAniNode:addChild( self.voiceAnimationSpr )
    -- 播放动画

    local tabData = self.voiceAnimations[1]
    local delayPerUnit = tabData["delay"]
    
    local preViewAni = self:getAnimationFromPlist(tabData["PlistName"])
    preViewAni:setDelayPerUnit(delayPerUnit)
    preViewAni:setLoops(1)
    preViewAni:setRestoreOriginalFrame(false)
    self.chatNode:setVisible(false)
    self.talkNode:setVisible(true)
    self.voiceAnimationSpr:runAction(cc.RepeatForever:create(cc.Animate:create(preViewAni)))
end

function ChatSystemLayer:stopVoiceAnimation()
    if self.voiceAnimationSpr then
        self.voiceAnimationSpr:stopAllActions()
        self.voiceAnimationSpr:removeFromParent()
        self.voiceAnimationSpr = nil
    end
    self.talkNode:setVisible(false)
end

function ChatSystemLayer:showTalkError( tips )
   if self.shortSpr then
        self.shortSpr:removeFromParent()
        self.shortSpr = nil
    end
    if self.reCallSpr then
       self.reCallSpr:removeFromParent()
       self.reCallSpr = nil
    end
    self:setVoiceAnimationSprVisible( false )
    self.shortSpr = cc.Sprite:create(self.chatUI.voiceShortPng)
    self.shortSpr:setAnchorPoint(0.5, 0.0)
    self.voiceTipsLabel:setColor(cc.c3b(255,0,0))
    self.shortNode:setVisible(true)
    self.shortNode:addChild( self.shortSpr )
    self.voiceTipsLabel:setString( tips )
    self.talkImage:setVisible(false)
    self.talkNode:setVisible(true)
    self.talkButton:setTouchEnabled(false)
end

function ChatSystemLayer:hideTalkError()
   if self.shortSpr then
        self.shortSpr:removeFromParent()
        self.shortSpr = nil
    end
    self.talkNode:setVisible(false)
    self.talkButton:setTouchEnabled(true)
end

-- 显示撤销提示
function ChatSystemLayer:showReCall( tips )
    if self.shortSpr then
        self.shortSpr:removeFromParent()
        self.shortSpr = nil
    end
    if self.reCallSpr then
       self.reCallSpr:removeFromParent()
       self.reCallSpr = nil
    end
    self:setVoiceAnimationSprVisible( false )
    self.reCallSpr = cc.Sprite:create(self.chatUI.reCallSprPng)
    self.reCallSpr:setAnchorPoint(0.5, 0.0)
    self.shortNode:setVisible(true)
    self.shortNode:addChild( self.reCallSpr )
    self.voiceTipsLabel:setString( tips )
    self.voiceTipsLabel:setColor(cc.c3b(255,0,0))
    self.talkImage:setVisible(false)
    self.talkNode:setVisible(true)
end

function ChatSystemLayer:setVoiceAnimationSprVisible( isVisible )
    if self.voiceAnimationSpr then
        self.voiceAnimationSpr:setVisible( isVisible )
    end
end



function ChatSystemLayer:hideTalkErrorTimerBegin( _time )
    if self.hideTalkErrorTimer then
        scheduler.unscheduleGlobal( self.hideTalkErrorTimer )
        self.hideTalkErrorTimer = nil
    end
    self.hideTalkErrorTimer = scheduler.performWithDelayGlobal(handler(self, self.hideTalkError),_time)
end

function ChatSystemLayer:hideTalkErrorTimerEnd()
    if not self.hideTalkErrorTimer then
        return
    end
    scheduler.unscheduleGlobal( self.hideTalkErrorTimer )
    self.hideTalkErrorTimer = nil
end

function ChatSystemLayer:ontVoiceBtnPressButtons(sender,eventType)
    if  sender then 
        if eventType == ccui.TouchEventType.began then 
            print("-----------------------ccui.TouchEventType.began-----------------------")

            print("self.recordVoiceState=",tostring(self.recordVoiceState)) 
            print("self.isStopRecordOK=",tostring(self.isStopRecordOK))
            if self.recordVoiceState ~= 0 or  not self.isStopRecordOK  then
                return
            end 
			if not self:isOpenVoice() then
				TOAST("语音已关闭")
				return 
			end
            self.isRecordVoice = true
			self.isRecordVoiceOutMove = false

            self.recordVoiceState = 1
			
			VoiceRecordUtil:stopSpeexVoice()
            -- 录音开始
			VoiceRecordUtil:startRecord()
            self.isStopRecordOK = false
            self.recordingTimeIsShort = false
            self:monitorTalkIsLongTimerBegin()

            self.uuid = QkaPhoneInfoUtil:getIMEI()
            self.speexFile = self.uuid ..".spx"
	         self.beginTime = cc.net.SocketTCP.getTime()*1000 
            self:runVoiceAnimation( self.voiceTextTips[1] )
        elseif eventType == ccui.TouchEventType.moved then
            --print("-----------------------ccui.TouchEventType.moved------------------------")
            if sender:isHighlighted() then
                self.shortNode:setVisible(false)
                self:setVoiceAnimationSprVisible( true )
                self.talkImage:setVisible(true)
                self.voiceTipsLabel:setColor(cc.c3b(255,255,255))
                self.voiceTipsLabel:setString(self.voiceTextTips[1])
				self.isRecordVoiceOutMove = false
            else 
                self:showReCall( self.voiceTextTips[7] )
				self.isRecordVoiceOutMove = true
            end 
        elseif eventType == ccui.TouchEventType.ended then
            print("-----------------------ccui.TouchEventType.ended-------------------------------")
            self.recordVoiceState = 0
            self:monitorTalkIsLongTimerEnd()

			self:stopVoiceAnimation()
			self.isRecordVoice = false  
			self.isStopRecordOK = true
			
            --停止录音
            if self:talkIsShort() then
				VoiceRecordUtil:cancelRecord() 
                -- 恢复暂停的音乐
               g_GameMusicUtil:resumeAll() 
               self.isRecordVoice = false
               self:showTalkError( self.voiceTextTips[4] )
               self:hideTalkErrorTimerBegin( 2 )
               return
            end
			
            self:sureStopRecordOK()
            if self:talkIsLong() then
				VoiceRecordUtil:cancelRecord()
				self.voiceTipsLabel:setString(self.voiceTextTips[3])
				return 
            end
			VoiceRecordUtil:stopRecord()
            -- 恢复暂停的音乐
            g_GameMusicUtil:resumeAll() 
            
			self:playVoiceDataInQueue()  
            
			-- for test 
			--self:delayShowUploadFileCallback(self.uuid,self.speexFile)
        elseif eventType == ccui.TouchEventType.canceled then
            print("--------------------ccui.TouchEventType.canceled---------------------------")
            if not self.isRecordVoiceOutMove then
                print("ok~~~~~~")
                VoiceRecordUtil:stopRecord()
                 self:stopVoiceAnimation()
            else
                VoiceRecordUtil:cancelRecord()
                self:stopVoiceAnimation()
                self:showTalkError( self.voiceTextTips[5] )
                self:hideTalkErrorTimerBegin( 0.5 )
            end
			
            -- 恢复暂停的音乐
            g_GameMusicUtil:resumeAll() 
            self.isRecordVoice = false
			self.isStopRecordOK = true

            self.recordVoiceState = 0
            self:monitorTalkIsLongTimerEnd()
			
            self:playVoiceDataInQueue() 

        end
    end
end

-- 此Plist文件必须包且只包含一个动画的所有图片,
-- 并且此文件必须已经加载到帧缓存
function ChatSystemLayer:getAnimationFromPlist(plistName)
    local animation = cc.Animation:create()
    local plistMap = cc.FileUtils:getInstance():getValueMapFromFile(plistName)
    if (plistMap == nil) then
        return nil
    end

    local pngMap = plistMap["frames"]

    for k, v in pairs(pngMap) do
        animation:addSpriteFrame(display.newSpriteFrame(k))
    end

    return animation
end

function ChatSystemLayer:playVoiceAnimation(sprite, time)
    local voiceSprite = sprite:getChildByTag(99)
    local userid = voiceSprite:getTag()
    local tabData = self.voiceAnimations[2]
    local delayPerUnit = tabData["delay"]
    local expSprite = cc.Sprite:create()
    expSprite:setFlippedX(voiceSprite:isFlippedX())
    expSprite:setAnchorPoint(0,0.5)
    expSprite:setPosition(voiceSprite:getPosition())
    local ani = self:getAnimationFromPlist(tabData["PlistName"])
    ani:setDelayPerUnit(delayPerUnit)
    ani:setLoops(1)
    ani:setRestoreOriginalFrame(false)
    local animate = cc.Animate:create(ani)  
    print("playVoiceAnimation_time:"..time)
    expSprite:runAction(
        cc.Sequence:create(
        cc.Repeat:create(animate, time),
        cc.CallFunc:create(function ()
            -- 播放声音
            if not self.isRecordVoice then
               g_GameMusicUtil:resumeAll() 
            end
            sprite:removeFromParent()
            self.isPlayingRecordVoice = false
            self.voiceIsPlays[ userid ] = 0
        end)
        ))
	self.isPlayingRecordVoice = true
	sprite:addChild(expSprite)
	voiceSprite:setVisible(false)
end

function ChatSystemLayer:onTouchCancelled()
	--print("ChatSystemLayer::onTouchCancelled()")
end

function ChatSystemLayer:onTouchBegan(x, y)
    self.mIsMoved = false
    self.mBeginX = x
    self.mBeginY = y
    if not self.chatNode:isVisible() then
        local node_tab = self:getChildren()
        for i=1,#node_tab do
            local sprite = node_tab[i]
            local uuid = sprite:getName()
            if self.chatDatas[uuid] ~= nil then
                local pt = sprite:convertToNodeSpace(cc.p(x, y))
                local spriteSize = sprite:getContentSize()

                if cc.rectContainsPoint(cc.rect(0, 0, spriteSize.width, spriteSize.height), pt) then 
                   if not self:isOpenVoice() then 
                        local userId = sprite:getTag()
                        if self.voiceIsPlays[ userId ] and self.voiceIsPlays[ userId ] == 0 then
                            self.voiceIsPlays[ userId ] = 1
                            local _spxfileName = self.chatDatas[uuid][3]
                            local time = self.chatDatas[uuid][2]
                            print("self:", _spxfileName, time)   
                            -- 停止播放声音
                            g_GameMusicUtil:museAll()
                            -- 播放录音
                            VoiceRecordUtil:playRecord(_spxfileName, function() end)
                            -- 播放动画
                            self:playVoiceAnimation(sprite, time)
                        end
                        return true
                    end
                end
            end
        end
        return false
    end

    local chatNodeSize = self.chatNode:getContentSize()
    local comLangBtnSize = self.comLangBtn:getContentSize()
    local expressionBtnSize = self.expressionBtn:getContentSize()
    local messageButtonSize = self.messageButton:getContentSize()
    local talkButtonSize = self.talkButton:getContentSize()
    local pt = self.chatNode:convertToNodeSpace(cc.p(x, y))
    local comLangPt = self.comLangBtn:convertToNodeSpace(cc.p(x, y))
    local expressionBtnPt = self.expressionBtn:convertToNodeSpace(cc.p(x, y))
    local messageButtonPt = self.messageButton:convertToNodeSpace(cc.p(x, y))
    local talkButtonPt = self.talkButton:convertToNodeSpace(cc.p(x, y))
    if not cc.rectContainsPoint(cc.rect(0, 0, chatNodeSize.width, chatNodeSize.height), pt) then
        if   cc.rectContainsPoint(cc.rect(0, 0, comLangBtnSize.width, comLangBtnSize.height), comLangPt) 
            or cc.rectContainsPoint(cc.rect(0, 0, expressionBtnSize.width, expressionBtnSize.height),expressionBtnPt )
            or cc.rectContainsPoint(cc.rect(0, 0, messageButtonSize.width, messageButtonSize.height), messageButtonPt)
              then
         else
           self.chatNode:setVisible( false )    
         end
        return false
    end

    -- 表情拖动框事件响应
    if self.expressionScrollview:isVisible()then
        local pt = self.expressionScrollview:convertToNodeSpace(cc.p(x, y))
        local viewSize = self.expressionScrollview:getContentSize()
        if  not cc.rectContainsPoint(cc.rect(0, 0, viewSize.width, viewSize.height), pt) then
            return true
        end
        local node_tab = self.expressionScrollview:getChildren()
        for i=1,#node_tab do
            local sprite = node_tab[i]
            local pt = sprite:convertToNodeSpace(cc.p(x, y))
            local spriteSize = sprite:getContentSize()
            if cc.rectContainsPoint(cc.rect(0, 0, spriteSize.width, spriteSize.height), pt) then
                sprite:setColor(cc.c3b(150, 150, 150))
                self.expressionNode = sprite
                self.expressionNodeTag = sprite:getTag()
                break
            end
        end
    -- 快捷聊天拖动框逻辑
    elseif self.comLangScrollview:isVisible() then
        local pt = self.comLangScrollview:convertToNodeSpace(cc.p(x, y))
        local viewSize = self.comLangScrollview:getContentSize()
        if not  cc.rectContainsPoint(cc.rect(0, 0, viewSize.width - 56, viewSize.height), pt) then
            return true
        end

        local node_tab = self.comLangScrollview:getChildren()
        for i=1,#node_tab do
            local sprite = node_tab[i]
            local pt = sprite:convertToNodeSpace(cc.p(x, y))
            local spriteSize = sprite:getContentSize()
            if cc.rectContainsPoint(cc.rect(0, 0, spriteSize.width, spriteSize.height), pt) then
                if sprite.label then
                    sprite.label:setColor(cc.c3b(150,135, 135))
                end
                self.comLangNode = sprite
                self.comLangNodeTag = sprite:getTag()
                break
            end
        end
    end
	return true
end


function ChatSystemLayer:onTouchMoved(x, y)
  if (math.abs(self.mBeginX - x) > 5 or math.abs(self.mBeginY - y) > 5) then
        self.mIsMoved = true
    end 
end

function ChatSystemLayer:onTouchEnded(x, y)
	
    if (math.abs(self.mBeginX - x) < 5 and math.abs(self.mBeginY - y) < 5 and (not self.mIsMoved)) then
		 
        if self.expressionScrollview:isVisible() then 
            if  self.expressionNode == nil  or self.expressionNodeTag == nil then
                return
            end

            self:showAniToUser(self.expressionNodeTag , Player:getAccountID())

			self:sendToServer(ChatSystemLayer.CLICK_HANDLER_ANI_TYPE,self.expressionNodeTag,Player:getAccountID(),0,"")
            self.chatNode:setVisible(false)
            --self.previewNode:setVisible(false)
       
        elseif self.comLangScrollview:isVisible() then
		
            if self.comLangNode == nil or  self.comLangNodeTag == nil  then
                return
            end
			 
            self:showTextToUser(self.comLangNodeTag, Player:getAccountID())
			self:sendToServer(ChatSystemLayer.CLICK_HANDLER_TEXT_TYPE,self.comLangNodeTag,Player:getAccountID(),0,"")
            self.chatNode:setVisible(false)
        else
            --self.chatNode:setVisible(false)
        end
    end
    self:clearSelectedSprites()
end

function ChatSystemLayer:clearSelectedSprites()
    if self.expressionNode then
       self.expressionNode:setColor(cc.c3b(255, 255, 255))
       self.expressionNode = nil
       self.expressionNodeTag = nil
    end
    if self.comLangNode  then
       if self.comLangNode.label then
            self.comLangNode.label:setColor(cc.c3b(255,255, 255))
       end
       self.comLangNode = nil
       self.comLangNodeTag = nil
    end
end


function ChatSystemLayer:onHandleAmusingByServer(data)
	local tag = data.tag
	local send_userId = data.send_userId
	local recive_userId = data.recive_userId
	self:showAmusingAniToUser(tag,send_userId,recive_userId)
end

function ChatSystemLayer:onReciveAmusing(msgStr, data)
	local tag = data.tag
	local send_userId = data.send_userId
	local recive_userId = data.recive_userId
	self:showAmusingAniToUser(tag,send_userId,recive_userId)
    local strdata = tag .. "," .. tostring(send_userId) .. "," .. tostring(recive_userId)
    local strdata_len = string.len(strdata)
	self:sendToServer(ChatSystemLayer.CLICK_HANDLER_AMUSING_TYPE,4,self.userId,strdata_len,strdata)
end

local armature_path = "src/app/game/common/chat/expression/"
local suffix = ".ExportJson"
local __nameList = {}
--加载骨骼动画数据
function ChatSystemLayer:loadArmature(name)
	if __nameList[name] then return end
	local a_path = armature_path..name.."/"..name..suffix
	print("load armature:",name..suffix)
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(a_path)
	__nameList[name]= true
end

--清除骨骼数据
function  ChatSystemLayer:clearArmature(name)
	local a_path = armature_path..name.."/"..name..suffix
	print("clear armature:",name..suffix)
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(a_path)
	__nameList[name]= nil
end

function ChatSystemLayer:unLoadAll()
	local temp = clone(__nameList)
	for name,v in pairs(temp) do
		self:clearArmature(name)
	end
	__nameList = {}
end

--动画播放回调
function ChatSystemLayer:animationEvent( armature, movementType, movementID )
    --非循环播放一次
    if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then

        if not armature.isLoop then
            armature:removeFromParent()
        end 

        if armature.callback then
            armature.callback(armature, "complete")
        end
    end
end

--播放动画
function ChatSystemLayer:playArmature(name,animationName,callback,isLoop)
    print("play armature:",name)
	self:loadArmature(name)
	local armature = ccs.Armature:create(name)
	if armature then 
        local animationData = armature:getAnimation():getAnimationData()
        local data = animationData:getMovement(animationName)
        if data then
		    armature:getAnimation():play(animationName,-1,1)
        else
            armature:getAnimation():playWithIndex(0,-1,1)
        end
		armature:getAnimation():setMovementEventCallFunc(handler(self,self.animationEvent))
		armature.callback = callback
        armature.isLoop = isLoop
		return armature
	end
end


function ChatSystemLayer:showAmusingAniToUser(tag,send_userId,recive_userId)
	local send_user = self.usersTable[send_userId]
	local recive_user = self.usersTable[recive_userId]
	
	 if send_user == nil or recive_user == nil then
        print("self.usersTable[send_userId] == nil:", send_userId)
		print("self.usersTable[recive_userId] == nil:", recive_userId)
        return
    end
	
	if send_user == recive_user then
		print("can't send to myself")
		return 
	end
	
	local ani_list = 
	{
		["boom"] = {name = "common_exp_boom",dy1=0,dy2=0},
		["chicken"] = {name = "common_exp_chicken",dy1=-20,dy2=0},
		["diutuoxie"] = {name = "common_exp_slipper",dy1=0,dy2=0},
		["jidan"] = {name = "common_exp_egg",dy1=20,dy2=20},
		["poshui"] = {name = "common_exp_splash",dy1=-50,dy2=0},
		["songchaopiao"] = {name = "common_exp_money",dy1=-120,dy2=0},
		["xianhua"] = {name = "common_exp_flower",dy1=0,dy2=0},
	}
	
	local data = ani_list[tag]
	if not data then 
		print("don't have ani :", tag)
		return 
	end
	local send_pos = clone(send_user.expressionPos)
	local recive_pos =clone(recive_user.expressionPos)
	
	send_pos.y = send_pos.y + data.dy1
	recive_pos.y = recive_pos.y + data.dy1
	local name = data.name
	local ani = self:playArmature(name,"move",nil,true)
	self:addChild(ani)
	ani:setPosition(send_pos.x,send_pos.y)
	
	if tag=="diutuoxie" then
		if send_pos.y>recive_pos.y then
			ani:setScaleY(-1)
		end
		if send_pos.x>recive_pos.x then
			ani:setScaleX(-1)
		end
	end

	
	local function ani_end()
		ani.isLoop = false
		local animationName = "end"
		local animationData = ani:getAnimation():getAnimationData()
		local ani_data = animationData:getMovement(animationName)
        if ani_data then
		    ani:getAnimation():play(animationName,-1,1)
        else
            ani:getAnimation():playWithIndex(0,-1,1)
        end
		local recive_pos =clone(recive_user.expressionPos)
		recive_pos.y = recive_pos.y + data.dy2
		ani:setPositionY(recive_pos.y)
		ani:setScaleY(1)
		ani:setScaleX(1)
	end
	local dis = cc.pGetDistance(send_pos,recive_pos)
	local t = 0.5*dis/1000
	local act = {}
	act[1] = cc.MoveTo:create(t,recive_pos)
	act[2] = cc.CallFunc:create(ani_end)
	local action = cc.Sequence:create(act)
	ani:runAction(action)
end

-- 表情动画显示到角色附近
function ChatSystemLayer:showAniToUser(tag, userID)

	local user = self.usersTable[userID]
    if user == nil then
        print("self.usersTable[userID] == nil:", userID)
        return
    end
    
    local pos = user.expressionPos
    local isFlippedX = user.isFlippedX

    local ani_Name = ""

    if tag>=10 then
        ani_Name = string.format("public_face_icon_%d", tag)
    else
        ani_Name = string.format("public_face_icon_0%d", tag)
    end

    print("ani_Name:", ani_Name)

    if self.expressions[tag] == nil then
        return
    end

    self.m_PlayExpre_Effect_Times = 1

    local ani = self:playArmature(ani_Name, ani_Name, handler(self, self.playExpreEffectTimes), true)
    ani:setScale(0.7)
    self:addChild(ani)
    ani:setPosition(cc.p(pos.x, pos.y - 70))
end

function ChatSystemLayer:playExpreEffectTimes(animate, complete)
    self.m_PlayExpre_Effect_Times = self.m_PlayExpre_Effect_Times  + 1
    if self.m_PlayExpre_Effect_Times >= Expression_Effect_Times then
        animate.isLoop = false
        return
    end
    
end


-- 快速聊天显示到角色附近
function ChatSystemLayer:showTextToUser(tag, userID)
    if self.usersTable[userID] == nil then
        return
    end
	
	local txtInfo = self.txtDataQueue[userID]
	if txtInfo then
		audio.stopSound(txtInfo.handler)
		pcall(function() txtInfo.messageNode:setVisible(false) end)
	end

    local pos = self.usersTable[userID].messagepos
    local isFlippedX = self.usersTable[userID].isFlippedX
    local isFlippedY = self.usersTable[userID].isFlippedY
    local tabData =  self.expressionQuickChat[tag]
    local messageNode = display.newNode()
    messageNode:setPosition(pos)
    self:addChild(messageNode,-2)
	local label = display.newTTFLabel({text = tabData.quikWord,size = 24,font="ttf/jcy.TTF"})
	UIAdapter:adapter(label)
    local contentSize = label:getContentSize()
    local messagewidth = 184
    if contentSize.width < messagewidth then
       messagewidth = contentSize.width
    end
    label:setColor( self.labelColors.messageLabelColor )
    label:setDimensions( messagewidth, 0) 
    label:setAnchorPoint(cc.p(0, 0.5))
    label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    local labelContentSize = label:getContentSize()
    local messageBg = display.newScale9Sprite(self.chatUI.messageBgPng,0,0,cc.size(messagewidth+12, labelContentSize.height+36),cc.rect(30,10,10,10))
    messageBg:setAnchorPoint(cc.p(0,0))
    messageBg:setFlippedX(isFlippedX)
    messageBg:setFlippedY(isFlippedY)
    messageNode:addChild(messageBg, -2)

    local labelBgSize = messageBg:getContentSize()
    
    if isFlippedX then
       label:setPositionX(-labelBgSize.width+7)
    else
       label:setPositionX(0+7)
    end
    if isFlippedY then
       label:setPositionY(-labelBgSize.height*0.6)
    else
       label:setPositionY(labelBgSize.height*0.6)
    end
    --label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    --label:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    messageNode:addChild(label) 
    
	local handler =nil
    -- GENDER_NULL = 0                 --未知性别
    -- GENDER_BOY = 1                  --男性性别
    -- GENDER_GIRL = 2                 --女性性别
    if tabData.quikEffects ~= "" then
        local soundPath = "chatsound/boy/"..tabData.quikEffects
        if self.usersTable[userID].gender then 
           if self.usersTable[userID].gender == 1 then
              soundPath = "chatsound/boy/"..tabData.quikEffects
           elseif self.usersTable[userID].gender== 2 then
              soundPath = "chatsound/girl/"..tabData.quikEffects
           end
        end
        if self:isFileExist(soundPath) then
			handler = g_GameMusicUtil:playSound(soundPath, false)
			self.messageNodeNum = self.messageNodeNum + 1

        end
    end
	
	local info = {}
	info.messageNode = messageNode
	info.handler = handler
	self.txtDataQueue[userID] = info
    -- 延迟3秒
    messageNode:runAction(cc.Sequence:create(
                cc.DelayTime:create(3.0),
                cc.CallFunc:create(function ()
                 --恢复暂停的音乐
                self.messageNodeNum = self.messageNodeNum - 1
                local param = self.txtDataQueue[userID]
				if param then
					if param.messageNode==messageNode then
						self.txtDataQueue[userID] = nil
					end
				end
                messageNode:removeFromParent()
                end)))
end

function ChatSystemLayer:playVoiceDataInQueue()
	if not self.isPlayingRecordVoice and not self.isRecordVoice then
		local info = self.voiceDataQueue[1]
		if info then
			table.remove(self.voiceDataQueue,1)
			self:addChatData(info.uuid,info.chatData)
			local t_time = info.chatData[2] 
			if t_time then
				if t_time == 1 then
				   t_time  = t_time + 2
				else
				   t_time = t_time + 1
				end
			end
			if t_time then
				self:showVoiceNodeToUser( info.uuid,true)
				local function play ()
					self.isPlayingRecordVoice = false
					self:playVoiceDataInQueue()
				end
				performWithDelay(self,handler(self,self.playVoiceDataInQueue),t_time)
			end
		end	
	end
end

function ChatSystemLayer:addVoiceDataToQueue(uuid,chatData)
	self.voiceDataQueue = self.voiceDataQueue or {}
	local tempData = clone(chatData)
	local info = {}
	info.uuid = uuid
	info.chatData = tempData
	table.insert(self.voiceDataQueue,info)
	self:playVoiceDataInQueue()
end

function ChatSystemLayer:showVoiceNodeToUser( uuid,isTruePlay )
    local chatData = self:getChatDataByUUID(uuid)
    if chatData == nil then
        --TOAST({text = "chatData == nil"})
        return
    end
	if not isTruePlay then
		self:addVoiceDataToQueue(uuid,chatData)
		return 
	end
    local userid = chatData[4]
    if self.usersTable[userid] == nil then
        --TOAST({text = "self.usersTable[userid] == nil"})
        print("<ChatSystemLayer:addOrtherVoiceNodeByUser>: userid is nil",tostring(userid))
        return
    end
    local pos = self.usersTable[userid].messagepos
    local isFlippedX = self.usersTable[userid].isFlippedX
    local isFlippedY = self.usersTable[userid].isFlippedY

    local oldTalkBgSprite = self:getChildByTag( userid )
    print("--------------------oldTalkBgSprite--------------------------")
    if oldTalkBgSprite then
       oldTalkBgSprite:removeFromParent()
       if self.voiceIsPlays[ userid ] == 1 then 
            if not self.isRecordVoice then
                -- 恢复暂停的音乐
                g_GameMusicUtil:resumeAll()
            end
       end
    end
    self.voiceIsPlays[ userid ] = 0
    
    local talkBgSprite = display.newSprite(self.chatUI.messageBgPng)
    local talkBtnSize = talkBgSprite:getContentSize()
    talkBgSprite:setAnchorPoint(cc.p(0.0, 0.0))
    talkBgSprite:setPosition(pos)
    talkBgSprite:setVisible(true)
    talkBgSprite:setTag( userid )

    local voiceSprite = display.newSprite( self.chatUI.voicePng )
    voiceSprite:setTag(99)
    local  voiceSpriteSize = voiceSprite:getContentSize()
    voiceSprite:setAnchorPoint(cc.p(0.0, 0.5))
    voiceSprite:setFlippedX(isFlippedX)
    talkBgSprite:setFlippedX(isFlippedX)
    talkBgSprite:setFlippedY(isFlippedY)
   -- print("isFlippedY="..isFlippedY)

    -- 添加声音数字
    local voiceTime = math.ceil(chatData[2]) 
	local numTable = display.newTTFLabel({text = tostring(voiceTime).."'",size = 16,font = "ttf/jcy.TTF"})
    -- local numTable = cc.Label:create()
    -- numTable:setString(tostring(voiceTime) .. "'")
    -- numTable:setSystemFontSize(16)
    
	UIAdapter:adapter(numTable)
    numTable:setColor(self.labelColors.voiceNumLabelColor)
    numTable:setAnchorPoint(cc.p(0, 0.5))
    print("voiceTime=",tostring(voiceTime))
    local numTableSize = numTable:getContentSize()
    local anchorPointX = 0
    local anchorPointY = 0
    -- 坐标
    if isFlippedX then
         voiceSprite:setPositionX( 15 )
         numTable:setPositionX( 18+voiceSpriteSize.width )
         anchorPointX  = 1
    else
        numTable:setPositionX( 15 )
        voiceSprite:setPositionX( 18+numTableSize.width )
        anchorPointX = 0 
    end
    if isFlippedY then
       anchorPointY = 1
       numTable:setPositionY( talkBtnSize.height*0.4 )
       voiceSprite:setPositionY( talkBtnSize.height*0.4 )
    else
       anchorPointY = 0
       numTable:setPositionY( talkBtnSize.height*0.6 )
       voiceSprite:setPositionY( talkBtnSize.height*0.6 )
    end
    talkBgSprite:setAnchorPoint(cc.p(anchorPointX,anchorPointY))
    print("isFlippedX=",tostring(isFlippedX))
    print("isFlippedY=",tostring(isFlippedY))

    talkBgSprite:setName( uuid )
    
    print("add bg sprite as child !!!")
    talkBgSprite:addChild(voiceSprite)
    talkBgSprite:addChild(numTable)
    self:addChild(talkBgSprite, -2)

    print("run play voice action !!!, this may cause crash !!, modifyed, crash not found any more ")
    if self:isOpenVoice() then
        local seq = cc.Sequence:create(cc.DelayTime:create(5), cc.CallFunc:create(function ()
            talkBgSprite:setVisible(self.voiceIsPlays[userid] ~= 0)
            self.isPlayingRecordVoice = false
        end))
        talkBgSprite:runAction(seq)
    end


    if self:isOpenVoice() then
        print("real player voice !!!")
        self:autoPlayVoice(talkBgSprite, uuid)
    end
end

function ChatSystemLayer:autoPlayVoice(sprite, uuid )
    if  self.chatDatas[uuid] then
        local _spxfileName = self.chatDatas[uuid][3] 
        local t_time = self.chatDatas[uuid][2] 
        if t_time then
            if t_time == 1 then
               t_time  = t_time + 2
            else
               t_time = t_time + 1
            end
        end
        print("_spxfileName and t_time : ", _spxfileName, " ", t_time)

        print("3 play voice and animation, this may cause crash!!")
        if _spxfileName and t_time then
            local userid = self.chatDatas[uuid][4] 
            self.voiceIsPlays[ userid ] = 1
            -- 停止播放声音
            print("museAll()")
            g_GameMusicUtil:museAll()
            -- -- 播放录音
            print("VoiceRecordUtil:playRecord(_spxfileName, function() end)")
            VoiceRecordUtil:playRecord(_spxfileName, function() end)
            -- -- 播放动画
            print("self:playVoiceAnimation(sprite, t_time)")
            self:playVoiceAnimation(sprite, t_time)
        end
    end
end



-- 接收服务器发来的数据
-- 接收到表情包
-- 张飞表情
function ChatSystemLayer:onHandleImageByServer(data)
    local tag = data[1] 
    local userid = data[2]
    -- 聊天功能开关
	if self.isOpenChat then
		self:showAniToUser(tag, userid)
	end

end

-- 接收服务器发来的数据
-- 接收到快捷聊天
function ChatSystemLayer:onHandleTextByServer(data)
    local tag = data[1] 
    local userid = data[2]
   -- 聊天功能开关
	if self.isOpenChat then
		self:showTextToUser(tag, userid)
	end
end

-- 从第三方下载语音回调
function ChatSystemLayer:isDownloadRecordOk( agrs )
    --下载失败开始全部废除全部加载
    local strlist = {agrs}
    if strlist[1] == 0 then
        print("isDownloadRecord Failed")
        return
    end
    print("isDownloadRecordOK")
    self:onCompleteVoiceByServerData(self.download_uuid)
end

-- 接收服务器发来的数据
-- 接收到语音聊天
function ChatSystemLayer:onHandleVoiceByServer(data)
    -- uuid ,播放时间,播放声音路径(需要从第三方阿里云下载)
    self:addChatData(data[1],data)
    local sound_path = ChatSystemLayer.TALK_PATH .. data[3]
    -- 语音功能开关
    if self:isOpenVoice() then
       self.download_uuid = data[1]
       AliYunUtil:downloadFileEx(ChatSystemLayer.SERVER_TALK_PATH .. data[3], sound_path,  handler(self,self.isDownloadRecordOk))
    end
	--self:showVoiceNodeToUser( data[1] )
end

-- 完成所有下载声音后回调这函数
function ChatSystemLayer:onCompleteVoiceByServerData(uuid)
    self:showVoiceNodeToUser( uuid )
end

--清除骨骼资源
function ChatSystemLayer:onExit()
    self:unLoadAll()
end

return ChatSystemLayer