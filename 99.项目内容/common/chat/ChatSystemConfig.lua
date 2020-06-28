--
-- ChatSystemConfig
-- Author: chenzhanming
-- Date: 2016-10-16 
-- 聊天系统配置
--
local GameSceneDef = require("app.lobby.def.GameSceneDef")

local ChatSystemConfig = {}

-- 公共ui资源
ChatSystemConfig.commonChatUI = 
{
	talkLayerCsb = "chatui/comchat_talk_layer.csb",     -- csb 文件
    messageListBgPng = "comchat_message_bg2.png",    -- 快捷聊天列表背景
    messageBgPng = "comchat_message_bg3.png",        -- 快捷聊天背景
    voicePng = "#comchat_voice_ani_03.png",          -- 语音图标
    expressionBg = "comchat_ani_bg.png"  ,           -- 表情图标背景
    voiceShortPng = "comchat_img_voice_error.png" ,  -- 录音太短提示
    reCallSprPng = "comchat_img_voice_cancel.png",   -- 录音取消图标
}


-- ui资源
ChatSystemConfig.chatUI = 
{
    [ GameSceneDef.ID_KIND_DOUDIZHU ] = 
    {   
        talkLayerCsb = "ddz/ddz_talk_layer.csb",     -- csb 文件
        messageListBgPng = "ddz_message_bg2.png",    -- 快捷聊天列表背景
        messageBgPng = "ddz_message_bg3.png",        -- 快捷聊天背景
        voicePng = "#ddz_voice_ani_03.png",          -- 语音图标
        expressionBg = "ddz_ani_bg.png"  ,           -- 表情图标背景
        voiceShortPng = "ddz_img_voice_error.png" ,  -- 录音太短提示
        reCallSprPng = "ddz_img_voice_cancel.png",   -- 录音取消图标
    },

    [ GameSceneDef.ID_KIND_CCMJ ] = 
    {
        talkLayerCsb = "ccmj/ccmj_talk_layer.csb",    -- csb 文件
        messageListBgPng = "ccmj_message_bg2.png",    -- 快捷聊天列表背景图片
        messageBgPng = "ccmj_message_bg3.png",        -- 快捷聊天背景
        voicePng = "#ccmj_voice_ani_03.png",          -- 语音图标
        expressionBg = "ccmj_ani_bg.png"   ,          -- 表情图标背景
        voiceShortPng = "ccmj_img_voice_error.png" ,  -- 录音太短提示
        reCallSprPng = "ccmj_img_voice_cancel.png",   -- 录音取消图标
    },

    [ GameSceneDef.ID_KIND_TIANDAKENG ] = ChatSystemConfig.commonChatUI ,
    -- 捕鱼
    [GameSceneDef.ID_KIND_FISH] = ChatSystemConfig.commonChatUI ,


}

ChatSystemConfig.comQuickChat = 
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

-- 快速聊天
ChatSystemConfig.quickChat = 
{   
	-- 斗地主
	[ GameSceneDef.ID_KIND_DOUDIZHU ] = 
	{
	    { quikWord = "快点啊，等到我花都谢了!",          quikEffects = "ddz_quick_chat_voice_01.mp3" },
		{ quikWord = "小伙伴，你和地主是一家吧?",        quikEffects = "ddz_quick_chat_voice_02.mp3" },
		-- { quikWord = "和你合作，真是太愉快了!",          quikEffects = "ddz_quick_chat_voice_03.mp3" },
		{ quikWord = "你这么牛叉，你家人知道吗?",        quikEffects = "ddz_quick_chat_voice_04.mp3" },
		{ quikWord = "噢!糟啦!",                         quikEffects = "ddz_quick_chat_voice_05.mp3" },
		{ quikWord = "怎么又断线了,网络也太差了吧!",     quikEffects = "ddz_quick_chat_voice_06.mp3" },
		{ quikWord = "别吵了！别吵了！专心玩游戏吧!",    quikEffects = "ddz_quick_chat_voice_07.mp3" },
		{ quikWord = "不要走~决战到天亮!",               quikEffects = "ddz_quick_chat_voice_08.mp3" },
		{ quikWord = "土豪，我们做朋友吧!",              quikEffects = "ddz_quick_chat_voice_09.mp3" },
		{ quikWord = "来，大家互相伤害吧!",              quikEffects = "ddz_quick_chat_voice_10.mp3" },
		{ quikWord = "唉，无敌是多么的寂寞",             quikEffects = "ddz_quick_chat_voice_11.mp3" },
		{ quikWord = "抱歉，刚接了个电话",               quikEffects = "ddz_quick_chat_voice_12.mp3" },
		{ quikWord = "别高兴的太早出来混迟早是要还得",   quikEffects = "ddz_quick_chat_voice_13.mp3" },
    },
    
    -- 麻将
    [ GameSceneDef.ID_KIND_CCMJ ] = 
	{
	    { quikWord = "抱歉，刚接了个电话",					quikEffects = "ccmj_quick_chat_voice_01.mp3" },
		{ quikWord = "不好意思，急事离开一会",				quikEffects = "ccmj_quick_chat_voice_02.mp3" },
		{ quikWord = "风水轮流转你可别高兴的太早了",		quikEffects = "ccmj_quick_chat_voice_03.mp3" },
		{ quikWord = "今天我的运气真是太好了！",			quikEffects = "ccmj_quick_chat_voice_04.mp3" },
		{ quikWord = "快点儿吧，别憋了",					quikEffects = "ccmj_quick_chat_voice_05.mp3" },
		{ quikWord = "上听了，你们都小心点",				quikEffects = "ccmj_quick_chat_voice_06.mp3" },
		{ quikWord = "我的哥！你真的是太厉害了",			quikEffects = "ccmj_quick_chat_voice_07.mp3" },
		{ quikWord = "无敌是多么的寂寞",					quikEffects = "ccmj_quick_chat_voice_08.mp3" },
		{ quikWord = "小样儿。打得不错！真是谢谢你了",		quikEffects = "ccmj_quick_chat_voice_09.mp3" },
		{ quikWord = "怎么又断线了啊，还能不能好好玩耍",	quikEffects = "ccmj_quick_chat_voice_10.mp3" },
    },
    -- 填大坑
	[ GameSceneDef.ID_KIND_TIANDAKENG ] = 
	{
	    { quikWord = "快点啊，等到我花都谢了!",          quikEffects = "tdk_quick_chat_voice_01.mp3" },
		-- { quikWord = "和你合作，真是太愉快了!",          quikEffects = "tdk_quick_chat_voice_02.mp3" },
		{ quikWord = "你这么牛叉，你家人知道吗?",        quikEffects = "tdk_quick_chat_voice_03.mp3" },
		{ quikWord = "噢!糟啦!",                         quikEffects = "tdk_quick_chat_voice_04.mp3" },
		{ quikWord = "怎么又断线了,网络也太差了吧!",     quikEffects = "tdk_quick_chat_voice_05.mp3" },
		{ quikWord = "别吵了！别吵了！专心玩游戏吧!",    quikEffects = "tdk_quick_chat_voice_06.mp3" },
		{ quikWord = "不要走~决战到天亮!",               quikEffects = "tdk_quick_chat_voice_07.mp3" },
		{ quikWord = "土豪，我们做朋友吧!",              quikEffects = "tdk_quick_chat_voice_08.mp3" },
	    { quikWord = "起脚反踢呀！",                     quikEffects = "tdk_quick_chat_voice_09.mp3" },
		{ quikWord = "来，大家互相伤害吧!",              quikEffects = "tdk_quick_chat_voice_10.mp3" },
		{ quikWord = "唉，无敌是多么的寂寞",             quikEffects = "tdk_quick_chat_voice_11.mp3" },
		{ quikWord = "抱歉，刚接了个电话",               quikEffects = "tdk_quick_chat_voice_12.mp3" },
		{ quikWord = "别高兴的太早出来混迟早是要还得",   quikEffects = "tdk_quick_chat_voice_13.mp3" },
    },
  
    -- 捕鱼
    [GameSceneDef.ID_KIND_FISH] = 	
    {
	    { quikWord = "哎，人长得帅，捕鱼就怎么打怎么下啊!",   quikEffects = "buyu_quick_chat_voice_01.mp3" },
		{ quikWord = "别高兴的太早出来混迟早是要还的",        quikEffects = "buyu_quick_chat_voice_02.mp3" },
		{ quikWord = "哈哈，抢你鱼的感觉怎么样",              quikEffects = "buyu_quick_chat_voice_03.mp3" },
		{ quikWord = "今天没看黄历，裤衩都快输没了",          quikEffects = "buyu_quick_chat_voice_04.mp3" },
		{ quikWord = "来呀互相伤害啊",                        quikEffects = "buyu_quick_chat_voice_05.mp3" },
		{ quikWord = "你敢动我的鱼，我就让你血本无归",        quikEffects = "buyu_quick_chat_voice_06.mp3" },
		{ quikWord = "你这样抢鱼以后会没有朋友的",            quikEffects = "buyu_quick_chat_voice_07.mp3" },
		{ quikWord = "有急事要离开下，今天就打到这里吧",      quikEffects = "buyu_quick_chat_voice_08.mp3" },
		{ quikWord = "怎么又抢我鱼",                          quikEffects = "buyu_quick_chat_voice_09.mp3" },
		{ quikWord = "这鱼太好打了，闭着眼都能打下来",        quikEffects = "buyu_quick_chat_voice_10.mp3" },
    },
}

-- 张飞表情
ChatSystemConfig.ExpressionZhangFei =
{
	{PlistName = "talk_emoji01_ani.plist", PngName = "talk_emoji01_ani.png", SmallPng = "talk_Small-0.png", repeatTime = 4, delay = 0.2, sizeW = 88, sizeH = 88},
	{PlistName = "talk_emoji02_ani.plist", PngName = "talk_emoji02_ani.png", SmallPng = "talk_Small-1.png", repeatTime = 3, delay = 0.3},
	{PlistName = "talk_emoji03_ani.plist", PngName = "talk_emoji03_ani.png", SmallPng = "talk_Small-2.png", repeatTime = 4, delay = 0.2},
	{PlistName = "talk_emoji04_ani.plist", PngName = "talk_emoji04_ani.png", SmallPng = "talk_Small-3.png", repeatTime = 4, delay = 0.2},
	{PlistName = "talk_emoji05_ani.plist", PngName = "talk_emoji05_ani.png", SmallPng = "talk_Small-4.png", repeatTime = 2, delay = 0.5},
	{PlistName = "talk_emoji06_ani.plist", PngName = "talk_emoji06_ani.png", SmallPng = "talk_Small-5.png", repeatTime = 4, delay = 0.2},
	{PlistName = "talk_emoji07_ani.plist", PngName = "talk_emoji07_ani.png", SmallPng = "talk_Small-6.png", repeatTime = 4, delay = 0.2},
	{PlistName = "talk_emoji08_ani.plist", PngName = "talk_emoji08_ani.png", SmallPng = "talk_Small-7.png", repeatTime = 4, delay = 0.2},
	{PlistName = "talk_emoji09_ani.plist", PngName = "talk_emoji09_ani.png", SmallPng = "talk_Small-8.png", repeatTime = 4, delay = 0.2},
	{PlistName = "talk_emoji10_ani.plist", PngName = "talk_emoji10_ani.png", SmallPng = "talk_Small-9.png", repeatTime = 4, delay = 0.2},
	{PlistName = "talk_emoji11_ani.plist", PngName = "talk_emoji11_ani.png", SmallPng = "talk_Small-10.png", repeatTime = 3, delay = 0.3},
	{PlistName = "talk_emoji12_ani.plist", PngName = "talk_emoji12_ani.png", SmallPng = "talk_Small-11.png", repeatTime = 4, delay = 0.2},
	{PlistName = "talk_emoji13_ani.plist", PngName = "talk_emoji13_ani.png", SmallPng = "talk_Small-12.png", repeatTime = 3, delay = 0.3},
	{PlistName = "talk_emoji14_ani.plist", PngName = "talk_emoji14_ani.png", SmallPng = "talk_Small-13.png", repeatTime = 4, delay = 0.2},
	{PlistName = "talk_emoji15_ani.plist", PngName = "talk_emoji15_ani.png", SmallPng = "talk_Small-14.png", repeatTime = 2, delay = 0.3},
	{PlistName = "talk_emoji16_ani.plist", PngName = "talk_emoji16_ani.png", SmallPng = "talk_Small-15.png", repeatTime = 4, delay = 0.2},
	{PlistName = "talk_emoji17_ani.plist", PngName = "talk_emoji17_ani.png", SmallPng = "talk_Small-16.png", repeatTime = 4, delay = 0.2},
	{PlistName = "talk_emoji18_ani.plist", PngName = "talk_emoji18_ani.png", SmallPng = "talk_Small-17.png", repeatTime = 4, delay = 0.2},
	{PlistName = "talk_emoji19_ani.plist", PngName = "talk_emoji19_ani.png", SmallPng = "talk_Small-18.png", repeatTime = 5, delay = 0.1},
	{PlistName = "talk_emoji20_ani.plist", PngName = "talk_emoji20_ani.png", SmallPng = "talk_Small-19.png", repeatTime = 5, delay = 0.3},

}

-- 小黄人
ChatSystemConfig.ExpressionMinions =
{
	{PlistName = "chat_face_ani_01.plist", PngName = "chat_face_ani_01.png", SmallPng = "chat_face_icon_01.png", repeatTime = 4, delay = 0.2, sizeW = 88, sizeH = 88},
	{PlistName = "chat_face_ani_02.plist", PngName = "chat_face_ani_02.png", SmallPng = "chat_face_icon_02.png", repeatTime = 4, delay = 0.2},
	{PlistName = "chat_face_ani_03.plist", PngName = "chat_face_ani_03.png", SmallPng = "chat_face_icon_03.png", repeatTime = 4, delay = 0.2},
	{PlistName = "chat_face_ani_04.plist", PngName = "chat_face_ani_04.png", SmallPng = "chat_face_icon_04.png", repeatTime = 2, delay = 0.5},
	{PlistName = "chat_face_ani_05.plist", PngName = "chat_face_ani_05.png", SmallPng = "chat_face_icon_05.png", repeatTime = 4, delay = 0.2},
	{PlistName = "chat_face_ani_06.plist", PngName = "chat_face_ani_06.png", SmallPng = "chat_face_icon_06.png", repeatTime = 4, delay = 0.2},
	{PlistName = "chat_face_ani_07.plist", PngName = "chat_face_ani_07.png", SmallPng = "chat_face_icon_07.png", repeatTime = 4, delay = 0.2},
	{PlistName = "chat_face_ani_08.plist", PngName = "chat_face_ani_08.png", SmallPng = "chat_face_icon_08.png", repeatTime = 4, delay = 0.2},
	{PlistName = "chat_face_ani_09.plist", PngName = "chat_face_ani_09.png", SmallPng = "chat_face_icon_09.png", repeatTime = 4, delay = 0.2},
	{PlistName = "chat_face_ani_10.plist", PngName = "chat_face_ani_10.png", SmallPng = "chat_face_icon_10.png", repeatTime = 3, delay = 0.3},
    {PlistName = "chat_face_ani_11.plist", PngName = "chat_face_ani_11.png", SmallPng = "chat_face_icon_11.png", repeatTime = 3, delay = 0.3},
}

ChatSystemConfig.expressions = 
{
    [ GameSceneDef.ID_KIND_DOUDIZHU ] = ChatSystemConfig.ExpressionMinions,
    [ GameSceneDef.ID_KIND_CCMJ ] =  ChatSystemConfig.ExpressionMinions,
    [ GameSceneDef.ID_KIND_TIANDAKENG ] =  ChatSystemConfig.ExpressionMinions,
    [GameSceneDef.ID_KIND_FISH] =  ChatSystemConfig.ExpressionMinions,
}

ChatSystemConfig.comVoiceAnimation = 
{
    {PlistName = "talk_ani_energy.plist", PngName = "talk_ani_energy.png", delay = 0.3},
    {PlistName = "comchat_voice_ani.plist",  PngName = "comchat_voice_ani.png", delay = 0.3},
}

ChatSystemConfig.voiceAnimations = 
{
     [ GameSceneDef.ID_KIND_DOUDIZHU ] = 
     {  
        {PlistName = "talk_ani_energy.plist", PngName = "talk_ani_energy.png", delay = 0.3},
        {PlistName = "ddz_voice_ani.plist",  PngName = "ddz_voice_ani.png", delay = 0.3},
     },

     [ GameSceneDef.ID_KIND_CCMJ ] = 
     {   
         {PlistName = "talk_ani_energy.plist", PngName = "talk_ani_energy.png", delay = 0.3},
         {PlistName = "ccmj_voice_ani.plist", PngName = "ccmj_voice_ani.png", delay = 0.3},
     },
     [ GameSceneDef.ID_KIND_TIANDAKENG ] = ChatSystemConfig.comVoiceAnimation,

     [GameSceneDef.ID_KIND_FISH] = ChatSystemConfig.comVoiceAnimation ,
}



ChatSystemConfig.voiceTextTips = 
{
	"手指滑动,取消发送",
	"已经停止录音",
	"说话时间超长",
	"说话时间太短",
	"录音取消",
	"录音失败,请重新说话",
	"手指松开,取消发送"
}

ChatSystemConfig.comlabelColor = 
{
   messageLabelColor = cc.c3b(12, 101, 147),
   voiceNumLabelColor = cc.c3b(0, 0, 0)
}

ChatSystemConfig.labelColors = 
{  
    [ GameSceneDef.ID_KIND_DOUDIZHU ] = 
	    {
	       messageLabelColor = cc.c3b(12, 101, 147),
	       voiceNumLabelColor = cc.c3b(0, 0, 0)
	    } ,
    [ GameSceneDef.ID_KIND_CCMJ ] = 
	    {  
	       messageLabelColor = cc.c3b(255, 255, 255),
	       voiceNumLabelColor = cc.c3b(255, 255, 255)
	    },

	[ GameSceneDef.ID_KIND_TIANDAKENG ]  = ChatSystemConfig.comlabelColor,

	[GameSceneDef.ID_KIND_FISH] = ChatSystemConfig.comlabelColor,

}

--语音自动播放开关
ChatSystemConfig.autoPlayVocieOnOff = 
{
    [ GameSceneDef.ID_KIND_DOUDIZHU ] = 
    {
      vocieOnOff = true,
    } ,

    [ GameSceneDef.ID_KIND_CCMJ ] = 
    {  
      vocieOnOff = true,
    },

	[ GameSceneDef.ID_KIND_TIANDAKENG ]  = 
    {  
      vocieOnOff = true,
    },

	[GameSceneDef.ID_KIND_FISH] = 
    {  
      vocieOnOff = true,
    },
}

return ChatSystemConfig