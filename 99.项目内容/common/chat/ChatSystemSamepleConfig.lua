--
-- ChatSystemSamepleConfig
-- Author: zhangyang
-- Date: 2017-04-13 
-- 聊天系统配置
--

local ChatSystemSamepleConfig = {}

-- 公共ui资源
ChatSystemSamepleConfig.chatUI = 
{
	talkLayerCsb = "comchat/comchat_talk_layer.csb",     -- csb 文件
    messageListBgPng = "comchat_message_bg2.png",    -- 快捷聊天列表背景
    messageBgPng = "comchat_message_bg3.png",        -- 快捷聊天背景
    voicePng = "#comchat_voice_ani_03.png",          -- 语音图标
    expressionBg = "comchat_ani_bg.png"  ,           -- 表情图标背景
    voiceShortPng = "comchat_img_voice_error.png" ,  -- 录音太短提示
    reCallSprPng = "comchat_img_voice_cancel.png",   -- 录音取消图标
}


-- 快速聊天
ChatSystemSamepleConfig.quickChat = 
{
    { quikWord = "别吵了！别吵了！专心玩游戏吧!",    quikEffects = "com_quick_chat_voice_01.mp3" },
	{ quikWord = "不要走~决战到天亮!",               quikEffects = "com_quick_chat_voice_02.mp3" },
	-- { quikWord = "和你合作，真是太愉快了!",          quikEffects = "com_quick_chat_voice_03.mp3" },
	{ quikWord = "快点啊，等到我花都谢了!",          quikEffects = "com_quick_chat_voice_04.mp3" },
	{ quikWord = "你这么牛叉，你家人知道吗?",        quikEffects = "com_quick_chat_voice_05.mp3" },
	{ quikWord = "噢!糟啦!",                         quikEffects = "com_quick_chat_voice_06.mp3" },
	{ quikWord = "土豪，我们做朋友吧!",              quikEffects = "com_quick_chat_voice_07.mp3" },
	{ quikWord = "无胜利，毋宁死!",                  quikEffects = "com_quick_chat_voice_08.mp3" },
	{ quikWord = "怎么又断线了，网络也太差了吧!",    quikEffects = "com_quick_chat_voice_09.mp3" },
}


-- 小黄人
ChatSystemSamepleConfig.expressions =
{
	{PlistName = "public_face_fn_01.plist", PngName = "public_face_fn_01.png", SmallPng = "public_face_icon_01.png", repeatTime = 4, delay = 0.2, sizeW = 88, sizeH = 88},
	{PlistName = "public_face_fn_02.plist", PngName = "public_face_fn_02.png", SmallPng = "public_face_icon_02.png", repeatTime = 4, delay = 0.2},
	{PlistName = "public_face_fn_03.plist", PngName = "public_face_fn_03.png", SmallPng = "public_face_icon_03.png", repeatTime = 4, delay = 0.2},
	{PlistName = "public_face_fn_04.plist", PngName = "public_face_fn_04.png", SmallPng = "public_face_icon_04.png", repeatTime = 2, delay = 0.5},
	{PlistName = "public_face_fn_05.plist", PngName = "public_face_fn_05.png", SmallPng = "public_face_icon_05.png", repeatTime = 4, delay = 0.2},
	{PlistName = "public_face_fn_06.plist", PngName = "public_face_fn_06.png", SmallPng = "public_face_icon_06.png", repeatTime = 4, delay = 0.2},
	{PlistName = "public_face_fn_07.plist", PngName = "public_face_fn_07.png", SmallPng = "public_face_icon_07.png", repeatTime = 4, delay = 0.2},
	{PlistName = "public_face_fn_08.plist", PngName = "public_face_fn_08.png", SmallPng = "public_face_icon_08.png", repeatTime = 4, delay = 0.2},
	{PlistName = "public_face_fn_09.plist", PngName = "public_face_fn_09.png", SmallPng = "public_face_icon_09.png", repeatTime = 4, delay = 0.2},
	{PlistName = "public_face_fn_10.plist", PngName = "public_face_fn_10.png", SmallPng = "public_face_icon_10.png", repeatTime = 3, delay = 0.3},
    {PlistName = "public_face_fn_11.plist", PngName = "public_face_fn_11.png", SmallPng = "public_face_icon_11.png", repeatTime = 3, delay = 0.3},
}


ChatSystemSamepleConfig.voiceAnimations = 
{
    {PlistName = "talk_ani_energy.plist", PngName = "talk_ani_energy.png", delay = 0.3},
    {PlistName = "comchat_voice_ani.plist",  PngName = "comchat_voice_ani.png", delay = 0.3},
}

ChatSystemSamepleConfig.voiceTextTips = 
{
	"手指滑动,取消发送",
	"已经停止录音",
	"说话时间超长",
	"说话时间太短",
	"录音取消",
	"录音失败,请重新说话",
	"手指松开,取消发送"
}

ChatSystemSamepleConfig.labelColors = 
{
   messageLabelColor = cc.c3b(68, 99, 154),
   voiceNumLabelColor = cc.c3b(0, 0, 0)
}

return ChatSystemSamepleConfig