module(..., package.seeall)


-- 斗地牌友房协议 <客户端-服务器>（适用于经典跑得快，欢乐跑得快、癞子跑得快、二人跑得快）

-- 房主开始游戏
CS_C2M_LandVipRoomStart_Req = 
{
    { 1		, 1		, 'm_gameAtomTypeId'	 , 'UINT'	                              , 1	 , '游戏最小配置类型ID'},
}

-- 创建房间
CS_C2M_CreateLandVipRoom_Req = 
{
	{ 1		, 1		, 'm_gameAtomTypeId'	 , 'UINT'	                              , 1	 , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_innings'			 , 'UINT'	                              , 1    , '填 0 1 2 对应局数:6局(房卡x1),12局(房卡x2),18局(房卡x3)'},
	{ 3		, 1		, 'm_isDouble'			 , 'UBYTE'	                              , 1    , '玩法：是否加倍;1代表加倍,0代表不加倍'},
	{ 4		, 1		, 'm_limitOfBomb'		 , 'UBYTE'	                              , 1    , '填 0 1 2 3 对应炸弹上限：3炸, 4炸, 5炸, 0不封顶'},
	{ 5		, 1		, 'm_isReplace'		     , 'UBYTE'	                              , 1    , '是否替代别人创建'},
} 

CS_M2C_CreateLandVipRoom_Ack = 
{ 
    { 1		, 1		, 'm_gameAtomTypeId'	 , 'UINT'	                              , 1	 , '游戏最小配置类型ID'},
   	{ 2		, 1		, 'm_result'			 , 'SHORT'                                , 1	 , '0:成功'},
    -- { 3		, 1		, 'm_roomId'	         , 'UINT'	                              , 1	 , '房间编号'},
	-- { 5		, 1		, 'm_chairId'			 , 'UINT'	                              , 1    , '椅子编号'},
	-- { 6		, 1		, 'm_minScore'			 , 'UINT'	                              , 1    , '底分(桌主设置)'},
	-- { 7	    , 1	    , 'm_innings'			 , 'UINT'	                              , 1    , '局数:6局(房卡x1),12局(房卡x2),18局(房卡x3)'},
	-- { 8		, 1		, 'm_isDouble'			 , 'UBYTE'	                              , 1    , '玩法：是否加倍;1代表加倍,0代表不加倍'},
	-- { 9		, 1		, 'm_limitOfBomb'		 , 'UBYTE'	                              , 1    , '炸弹上限：3代表3炸,4代表4炸,5代表5炸,0代表不封顶'},
	-- { 10	, 1		, 'm_isReplace'			 , 'UBYTE'	                              , 1    , '是否替代别人创建'},
}

-- 加入房间
CS_C2M_EnterLandVipRoom_Req = 
{   
    { 1		, 1		, 'm_gameAtomTypeId'	 , 'UINT'	                               , 1	  , '游戏最小配置类型ID'},
    { 2		, 1		, 'm_roomId'	         , 'UINT'	                               , 1	  , '房间编号'},
}

CS_M2C_EnterLandVipRoom_Ack = 
{   
	{ 1		, 1		, 'm_gameAtomTypeId'	 , 'UINT'	                                , 1	   , '游戏最小配置类型ID'},
    { 2		, 1		, 'm_result'			 , 'SHORT'                               	, 1	   , '0:成功'},
    { 3		, 1		, 'm_roomId'	         , 'UINT'                                	, 1	   , '房间编号'},
	{ 4		, 1		, 'm_chairId'			 , 'UINT'	                                , 1    , '椅子编号'},
	{ 5		, 1		, 'm_minScore'			 , 'UINT'	                                , 1    , '底分(桌主设置)'},
	{ 6	    , 1	    , 'm_innings'			 , 'UINT'	                                , 1    , '局数:6局(房卡x1),12局(房卡x2),18局(房卡x3)'},
	{ 7		, 1		, 'm_isDouble'			 , 'UBYTE'	                                , 1    , '玩法：是否加倍;1代表加倍,0代表不加倍'},
	{ 8    	, 1		, 'm_limitOfBomb'		 , 'UBYTE'	                                , 1    , '炸弹上限：3代表3炸,4代表4炸,5代表5炸,0代表不封顶'},
	{ 9    	, 1		, 'm_createAccountId'	 , 'UINT'	                                , 1    , '创建者的账号id，也就是房主'},
	{ 10	, 1		, 'm_isReEnter'	         , 'UINT'                                	, 1	  , '进入类型 0正常 1未开始游戏 2游戏已经开始'},
	{ 11	, 1		, 'm_curRound'	         , 'UINT'                                	, 1	  , '当前第几轮'},
	{ 12	, 1		, 'm_isReplace'	         , 'UINT'                                	, 1	  , '是否替代别人创建'},
	{ 13	, 1		, 'm_secondAccountId'	 , 'UINT'                                	, 1	  , '次房主账号'},
}

-- 成员列表信息广播
CS_M2C_LandVipRoomBeforeGameTable_Nty =
{
	{ 1		, 1		, 'm_gameAtomTypeId'	 , 'UINT'	                                , 1	  , '游戏最小配置类型ID'},
    { 2		, 1		, 'm_roomId'	         , 'UINT'                                	, 1	  , '房间编号'},
	{ 3		, 1		, 'm_memberList'		 , 'PstLandVipRoomChairData'				, 3   , '成员列表信息'},
	{ 4		, 1		, 'm_type'		 		 , 'UINT'									, 1   , '广播类型 0 进入  1 离线  2 重连'},
	{ 5		, 1		, 'm_takeAccountId'		 , 'UINT'									, 1   , '触发的账号id'},
	{ 6		, 1		, 'm_isGame'		 	, 'UINT'									, 1   , '是否开始游戏'},
}

-- 牌友房错误通知
CS_M2C_LandVipRoomError_Nty =
{   
    { 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1		, '游戏最小配置类型ID(包含房间类型)'},
    { 2		, 1		, 'm_roomId'	            , 'UINT'	                            , 1	    , '房间编号'},
	{ 3		, 1		, 'm_error'	            	, 'UINT'	                            , 1	    , '见下面说明'},
	{ 4		, 1		, 'm_optMsg'	            , 'UINT'	                            , 1	    , '操作协议id'},
	{ 5		, 1		, 'm_param'	            	, 'STRING'	                            , 1	    , '服务器参数'},
}

-- 牌友房进入确认
CS_M2C_LandVipRoomEnterScene_Ack = 
{   
    { 1		, 1		, 'm_gameAtomTypeId'	   , 'UINT'	                                , 1	    , '游戏最小配置类型ID(包含房间类型)'},
	{ 2		, 1		, 'm_param'	               , 'UINT'	                            	, 1	    , '为 0'},
	
}

-- 解散房间
CS_C2M_DismissLandVipRoom_Req = 
{
    { 1		, 1		, 'm_gameAtomTypeId'	   , 'UINT'	                                , 1	    , '游戏最小配置类型ID(包含房间类型)'},
	{ 2		, 1		, 'm_roomId'	           , 'UINT'	                                , 1	    , '房间编号'},
}

-- 解散房间通知
CS_M2C_DismissLandVipRoom_Nty = 
{
    --{ 1		, 1		, 'm_gameAtomTypeId'	   , 'UINT'	                                , 1	    , '游戏最小配置类型ID(包含房间类型)'},
	{ 1		, 1		, 'm_roomId'	           , 'UINT'	                                , 1	    , '房间编号'},
	{ 2		, 1		, 'm_accountId'	           , 'UINT'	                                , 1	    , '发起人的账号id'},
	{ 3		, 1		, 'm_result'	           , 'UINT'	                                , 1	    , '结果:  0:解散成功 '},
	{ 4		, 1		, 'm_isInRoom'	           , 'UINT'	                                , 1	    , '发起人是否在房间 0 1'},
}

-- 发起解散游戏
CS_C2M_DismissLVRGame_Req = 
{
	{ 1		, 1		, 'm_gameAtomTypeId'	   , 'UINT'	                                , 1	    , '游戏最小配置类型ID(包含房间类型)'},
	
}

-- 发起解散游戏通知
CS_M2C_DismissLVRGame_Nty = 
{
	{ 1		, 1		, 'm_gameAtomTypeId'	   , 'UINT'	                                , 1	    , '游戏最小配置类型ID(包含房间类型)'},
	{ 2		, 1		, 'm_roomId'	           , 'UINT'	                                , 1	    , '房间编号'},
	{ 3		, 1		, 'm_accountId'	           , 'UINT'	                                , 1	    , '发起人的账号id'},
}

-- 是否同意解散游戏
CS_C2M_IsAgreeLVRGame_Req =  
{
    { 1		, 1		, 'm_gameAtomTypeId'	   , 'UINT'	                                , 1	    , '游戏最小配置类型ID(包含房间类型)'},
	{ 2		, 1		, 'm_isAgree'	           , 'UBYTE'	                            , 1	    , '是否同意解散房间:1同意,0不同意'},
}

-- 解散游戏结果通知
CS_M2C_IsAgreeLVRGame_Nty = 
{
    { 1		, 1		, 'm_gameAtomTypeId'	    , 'UINT'	                            , 1	    , '游戏最小配置类型ID(包含房间类型)'},
	{ 2		, 1		, 'm_roomId'	           	, 'UINT'	                            , 1	    , '房间编号'},
	{ 3		, 1		, 'm_result'	           	, 'UINT'	                            , 1	    , '0:解散成功 1:解散失败'},
	{ 4		, 1		, 'm_lvrDisData'	        , 'PstLandVipRoomDismissData'	        , 3	    , '结算数据，解散游戏才有'},
	{ 5		, 1		, 'm_isReEnter'	         	, 'UINT'                                , 1	  	, '进入类型 0正常 1重连进来 '},
	{ 6		, 1		, 'm_remainTime'	        , 'UINT'                                , 1	  	, '剩余时间'},
	{ 7		, 1		, 'm_disType'	        	, 'UINT'                                , 1	  	, '解散类型 0 正常解散  1 超时强制解散'},
}

-- 牌局结算界面
CS_M2C_LandVipRoomTotalAccount_Nty = 
{
    { 1		, 1		, 'm_gameAtomTypeId'	      , 'UINT'	                             , 1	 , '游戏最小配置类型ID(包含房间类型)'},
	{ 2		, 1		, 'm_roomId'	              , 'UINT'	                             , 1	 , '房间编号'},
	{ 3		, 1		, 'm_lvrGameOverData'  		  , 'PstLandVipRoomGameOverData'	     , 3  	, '结算数据项列表'},
}

-- 踢人
CS_C2M_LandVipRoomKick_Req = 
{
	{ 1		, 1		, 'm_accountId'				, 'UINT'								, 1 	, '玩家账户ID'},
}

CS_M2C_LandVipRoomKick_Nty = 
{
	{ 1		, 1		, 'm_roomId'	              , 'UINT'	                             , 1	 , '房间编号'},
	{ 2		, 1		, 'm_accountId'				  , 'UINT'								, 1 	, '玩家账户ID'},
	{ 3		, 1		, 'm_result'				  , 'UINT'								, 1 	, '0 成功  1 人不在'},
	{ 4		, 1		, 'm_secondAccountId'	 	  , 'UINT'                              , 1	  , '次房主账号'},
}

-- 我的房间列表
CS_C2M_LandVipRoomList_Req = 
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1		, '游戏最小配置类型id(包含房间类型)'},
}


CS_M2C_LandVipRoomList_Ack = 
{
    { 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1		, '游戏最小配置类型id(包含房间类型)'},
    { 2		, 1		, 'm_listData'				, 'PstLandVipRoomListData'	            , 128	, '房间列表'},
	
}

-- 退出房间
CS_C2M_LandVipRoomQuit_Req = 
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1		, '游戏最小配置类型id(包含房间类型)'},
}

CS_M2C_LandVipRoomQuit_Nty = 
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1		, '游戏最小配置类型id(包含房间类型)'},
	{ 2		, 1		, 'm_pos'					, 'UINT'								, 1 	, '推出的位置 1 2 3'},
	{ 3		, 1		, 'm_secondAccountId'	 	  , 'UINT'                              , 1	  , '次房主账号'},
}

-- 获取牌友房信息
CS_C2M_LandVipRoomInfo_Req = 
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1		, '游戏最小配置类型id(包含房间类型)'},
}

CS_M2C_LandVipRoomInfo_Ack = 
{
	{ 1		, 1		, 'm_roomId'				, 'UINT'								, 1 	, '自己所在的房间id，如果没有就为 0'},
	{ 2		, 1		, 'm_roundSvrIP'			, 'STRING'								, 1 	, '牌局服务器ip'},
	{ 3		, 1		, 'm_roundSvrPort'			, 'UINT'								, 1 	, '牌局服务器端口'},
}

-- 牌友房测试
CS_C2M_LandVipRoomTest_Req = 
{
	{ 1		, 1		, 'm_opt'					, 'UINT'								, 1		, '1 加机器人 2 测试获取房间列表'},
	{ 2		, 1		, 'm_param1'				, 'INT'									, 1 	, '参数'},
	{ 3		, 1		, 'm_param2'				, 'INT'									, 1 	, '参数'},
	{ 4		, 1		, 'm_param3'				, 'INT'									, 1 	, '参数'},
	
}

CS_M2C_LandVipRoomTest_Ack = 
{
	{ 1		, 1		, 'm_opt'					, 'UINT'								, 1		, '1 加机器人 '},
	{ 2		, 1		, 'm_roomList'				, 'PstLandVipRoomSingleData'			, 2 	, '空闲房间列表'},
}

-- 牌友房邀请 -- 服务器需要记录数据
CS_C2M_LandVipRoomInvite_Req = 
{
	{ 1		, 1		, 'm_roomId'					, 'UINT'								, 1		, '房间id '},
	
}

-- 聊天
CS_C2M_LVRClientChat_Req = 
{
	{ 1,	1, 'm_nMsgType'		, 'UINT'				, 1 	, '0表情 1快速聊天 2互动动画 3文字 4语音'},
	{ 2,	1, 'm_nOption'		, 'UINT'				, 1 	, '设置0，1，2表示索引值，3表示颜色 4无意义'},
	{ 3,	1, 'm_nAccountId'	,'UINT'					, 1		, '玩家Id'},
	{ 4,	1, 'm_nLength' 		, 'UINT' 				, 1  	, '数据长度（文字长度 或者语音长度）'},
	{ 5,	1, 'm_szData' 		, 'STRING' 				, 1  	, '二进制数据'},
	{ 6,    1, 'm_gameAtomTypeId'		, 'UINT'		, 1		, '游戏最小配置类型id(包含房间类型)'},
}

CS_M2C_LVRClientChat_Nty = 
{
	{ 1,	1, 'm_nMsgType'		, 'UINT'				, 1 	, '0表情 1快速聊天 2互动动画 3文字 4语音'},
	{ 2,	1, 'm_nOption'		, 'UINT'				, 1 	, '设置0，1，2表示索引值，3表示颜色 4无意义'},
	{ 3,	1, 'm_nAccountId'	,'UINT'					, 1		, '玩家Id'},
	{ 4,	1, 'm_nLength' 		, 'UINT' 				, 1  	, '数据长度（文字长度 或者语音长度）'},
	{ 5,	1, 'm_szData' 		, 'STRING' 				, 1  	, '二进制数据'},
	{ 6,    1, 'm_gameAtomTypeId'		, 'UINT'		, 1		, '游戏最小配置类型id(包含房间类型)'},
}

-- 牌友房主动下线
CS_C2M_LVRAccordExit_Req = 
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1		, '游戏最小配置类型id(包含房间类型)'},
}

CS_M2C_LVRAccordExit_Ack = 
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1		, '游戏最小配置类型id(包含房间类型)'},
}

-- 通知客户端清理房间
CS_M2C_LVRSysClearRoom_Nty = 
{
	{ 1		, 1		, 'm_rooms'				, 'UINT'								, 50		, '游戏最小配置类型id(包含房间类型)'},
}

-- 为他人创建返回
CS_M2C_CreateLandVipRoomOther_Ack = 
{
	{ 1		, 1		, 'm_gameAtomTypeId'	 , 'UINT'	                              , 1	 , '游戏最小配置类型ID'},
   	{ 2		, 1		, 'm_result'			 , 'SHORT'                                , 1	 , '0:成功'},
    { 3		, 1		, 'm_roomId'	         , 'UINT'	                              , 1	 , '房间编号'},
	{ 4		, 1		, 'm_chairId'			 , 'UINT'	                              , 1    , '椅子编号'},
	{ 5		, 1		, 'm_minScore'			 , 'UINT'	                              , 1    , '底分(桌主设置)'},
	{ 6	    , 1	    , 'm_innings'			 , 'UINT'	                              , 1    , '局数:6局(房卡x1),12局(房卡x2),18局(房卡x3)'},
	{ 7		, 1		, 'm_isDouble'			 , 'UBYTE'	                              , 1    , '玩法：是否加倍;1代表加倍,0代表不加倍'},
	{ 8		, 1		, 'm_limitOfBomb'		 , 'UBYTE'	                              , 1    , '炸弹上限：3代表3炸,4代表4炸,5代表5炸,0代表不封顶'},
	{ 9		, 1		, 'm_isReplace'			 , 'UBYTE'	                              , 1    , '是否替代别人创建'},
}

-- 加入房间 确认
CS_M2C_EnterLandVipRoomResult_Ack = 
{   
	{ 1		, 1		, 'm_gameAtomTypeId'	 , 'UINT'	                                , 1	   , '游戏最小配置类型ID'},
    { 2		, 1		, 'm_result'			 , 'SHORT'                               	, 1	   , '0:成功'},
}

-- 聊天vip
CS_C2M_VIPClientChat_Req = 
{
	{ 1,	1, 'm_nMsgType'		, 'UINT'				, 1 	, '0表情 1快速聊天 2互动动画 3文字 4语音'},
	{ 2,	1, 'm_nOption'		, 'UINT'				, 1 	, '设置0，1，2表示索引值，3表示颜色 4无意义'},
	{ 3,	1, 'm_nAccountId'	,'UINT'					, 1		, '玩家Id'},
	{ 4,	1, 'm_nLength' 		, 'UINT' 				, 1  	, '数据长度（文字长度 或者语音长度）'},
	{ 5,	1, 'm_szData' 		, 'STRING' 				, 1  	, '二进制数据'},
	
}



	
-- 错误通知 CS_M2C_LandVipRoomError_Nty  字段 m_error
-- 0:正常 
-- 1:开始游戏 人数不足
-- 2:游戏初始化错误 
-- 3:未知错误 
-- 4:重连-房间解散了(参数是房间id) 
-- 5:重连-游戏结束了(参数是房间id) 
-- 6:创建房间 房卡不足 参数为详细错误
-- 7:创建房间 帮别人创建达到上限 
-- 8:创建房间 创建中(扣费会有一个过程)
-- 9:创建房间 您没有登陆场景 
-- 10:创建房间 您已经在房间 
-- 11:加入房间 没有这个房间 
-- 12:加入房间 被踢cd时间内，不能加入 
-- 13:加入房间 他人创建的房间已满 
-- 14:加入房间 已满未开局 
-- 15:加入房间 已满已开局 
-- 16:加入房间 您已经在房间
-- 17:解散房间 没有这个房间 
-- 18:解散房间 您不是房主 
-- 19:解散房间 游戏中不能解散房间 
-- 20:解散房间 别人创建的不能解散
-- 21:踢人 您不是房主
-- 22:踢人 游戏中不能踢人
-- 23:退出 游戏开始了不能退
-- 24:退出 房主不能退出
-- 25:测试 返回
-- 26:踢人 不能踢出自己
-- 27:解散 他人创建房间，有人不能解散
-- 28:创建房间 他人创建房间，房卡不足
-- 29:解散发起过于频繁，请稍后再试









