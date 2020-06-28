module(..., package.seeall)



-----------------------------自由房<客户端-服务器>-------------------
CS_M2C_EnterFreedomRoom_Nty	= 
{
	{ 1		, 1     , 'm_gameAtomTypeId'  	, 'UINT'        		, 1    , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_result'			, 'SHORT'				, 1	   , '0:成功, -1:已在游戏中，不允许同时玩多款游戏, -2:不在规定时间段内,-3:不在规定时刻,-4:参数非法'},
	{ 3		, 1		, 'm_roomInfo'			, 'PstRoomAttr'			, 1	   , '当前房间信息'},
    { 4		, 1     , 'm_roomIdArr'			, 'PstRoomIdAttr' 		, 4096 , '房间编号数组'},
 	{ 5		, 1		, 'm_faceId'			, 'UINT'				, 1 	, '头像ID'},
	{ 6		, 1		, 'm_nickname'			, 'STRING'				, 1 	, '昵称'},
	{ 7		, 1		, 'm_goldCoin'			, 'UINT'				, 1 	, '金币数量'},
	{ 8		, 1		, 'm_level'				, 'UINT'				, 1 	, '等级'},
}

CS_M2C_EnterFreedomRoomPhone_Nty =
{
	{ 1		, 1     , 'm_gameAtomTypeId'  	, 'UINT'        		, 1     , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_result'			, 'SHORT'				, 1	    , '0:成功, -1:已在游戏中，不允许同时玩多款游戏, -2:不在规定时间段内,-3:不在规定时刻,-4:参数非法'},
	{ 3		, 1		, 'm_roomId'			, 'UINT'				, 1 	, '房间编号(自由房填服务器生成的编号，其他填0)'},
	{ 4		, 1		, 'm_type'				, 'UBYTE'				, 1 	, '0:正常进入，1：断线重连'},
}

CS_C2M_ApplyTableChair_Req =
{
	{ 1		, 1		, 'm_gameAtomTypeId'	, 'UINT'	, 1	, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_roomId'			, 'UINT'	, 1 , '房间编号(自由房填服务器生成的编号，其他填0)'},
	{ 3		, 1		, 'm_tableId'			, 'UINT'	, 1 , '桌子编号'},
	{ 4		, 1		, 'm_chairId'			, 'UINT'	, 1 , '椅子编号'},
	{ 5		, 1		, 'm_minScore'			, 'UINT'	, 1 , '底分(桌主设置)'},
	{ 6		, 1		, 'm_validateType'		, 'USHORT'	, 1 , '验证类型，0:不需要验证，1:询问桌主验证,2:密码验证(桌主设置)'},
	{ 7		, 1		, 'm_key'				, 'STRING'	, 1 , '进桌密钥(仅当验证类型是密码验证时，桌主设置)'},
}

CS_M2C_ApplyTableChair_Ack =
{
	{ 1		, 1		, 'm_gameAtomTypeId'	, 'UINT'					, 1		, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_result'			, 'SHORT'					, 1		, '0:成功，-1:桌子已满人,-2:桌子不满，但椅子上已有人, -3:金币不足,-4:道具不足'},
	{ 3		, 1		, 'm_roomId'			, 'UINT'					, 1 	, '房间编号(自由房填服务器生成的编号，其他填0)'},
	{ 4		, 1		, 'm_tableInfo'			, 'PstTableAttr'			, 1		, '桌子信息'},	
}

CS_M2C_AskPermitEnter_Req =
{
	{ 1		, 1		, 'm_gameAtomTypeId'			, 'UINT'		, 1	, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_slaveAccountId'			, 'UINT'		, 1	, '验证玩家账户ID'},
	{ 3		, 1		, 'm_slaveNickname'				, 'STRING'		, 1	, '验证玩家昵称'},
	{ 4		, 1		, 'm_roomId'					, 'UINT'		, 1	, '房间编号(自由房填服务器生成的编号，其他填0)'},
	{ 5		, 1		, 'm_tableId'					, 'UINT'		, 1	, '桌子编号'},	
}

CS_C2M_AskPermitEnter_Ack = 
{
	{ 1		, 1		, 'm_gameAtomTypeId'			, 'UINT'		, 1	, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_result'					, 'SHORT'		, 1	, '0:允许, -1:不允许'},
	{ 3		, 1		, 'm_slaveAccountId'			, 'UINT'		, 1	, '验证玩家账户ID'},
	{ 4		, 1		, 'm_roomId'					, 'UINT'		, 1	, '房间编号(自由房填服务器生成的编号，其他填0)'},
	{ 5		, 1		, 'm_tableId'					, 'UINT'		, 1	, '桌子编号'},	
}

CS_M2C_UpdateRoomTable_Nty =
{
	{ 1		, 1     ,'m_gameAtomTypeId'  	, 'UINT'        		, 1     , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_roomInfo'			, 'PstRoomAttr'			, 1		, '自由房房间大厅信息'},
	{ 3		, 1     , 'm_roomIdArr'			, 'PstRoomIdAttr' 		, 4096 , '房间编号数组(自由房填服务器生成的编号，其他填0)'}, 	
}

CS_C2M_EnterTableVerify_Req =
{
	{ 1		, 1		, 'm_gameAtomTypeId'	, 'UINT'	, 1	, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_roomId'			, 'UINT'	, 1 , '房间编号(自由房填服务器生成的编号，其他填0)'},
	{ 3		, 1		, 'm_tableId'			, 'UINT'	, 1 , '桌子编号'},
	{ 4		, 1		, 'm_key'				, 'STRING'	, 1 , '进桌密钥(仅当验证类型是密码验证时,需要填写)'},
	{ 5		, 1		, 'm_minScore'			, 'UINT'	, 1 , '底分(桌主设置)'},
}

CS_M2C_EnterTableVerify_Ack =
{
	{ 1		, 1		, 'm_gameAtomTypeId'	, 'UINT'	, 1	, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_result'			, 'SHORT'	, 1	, '0:验证通过，-1：密码不对, -2:桌主不同意,-3:桌子已满人'},	
	{ 3		, 1		, 'm_roomId'			, 'UINT'	, 1 , '房间编号(自由房填服务器生成的编号，其他填0)'},
	{ 4		, 1		, 'm_tableId'			, 'UINT'	, 1 , '桌子编号'},
	{ 5		, 1		, 'm_masterNickName'	, 'STRING'	, 1 , '桌主昵称'},
}

CS_C2M_EnterSpecificFreeRoomHall_Req =
{
	{ 1		, 1		, 'm_gameAtomTypeId'	, 'UINT'	, 1	, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_roomId'			, 'UINT'	, 1 , '房间编号(自由房填服务器生成的编号，其他填0)'},
}

CS_M2C_EnterSpecificFreeRoomHall_Ack =
{
	{ 1		, 1		, 'm_gameAtomTypeId'	, 'UINT'	, 1	, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_result'			, 'SHORT'	, 1	, '0:成功, -1:游戏中，不能进入其他房间'},
	{ 3		, 1		, 'm_roomInfo'			, 'PstRoomAttr'	, 1	   , '当前房间信息'},
	{ 4		, 1     , 'm_roomIdArr'			, 'PstRoomIdAttr' 		, 4096 , '房间编号数组'},
}

CS_C2M_FastEnterFreeTable_Req =
{
	{ 1		, 1		, 'm_gameAtomTypeId'	, 'UINT'	, 1	, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_roomId'			, 'UINT'	, 1 , '房间编号(自由房填服务器生成的编号，其他填0)'},
}

CS_M2C_FastEnterFreeTable_Ack =
{
	{ 1		, 1		, 'm_gameAtomTypeId'	, 'UINT'				, 1		, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_result'			, 'SHORT'				, 1		, '0:成功，-1:房间已满，请进入其他房间大厅,-2:金币不足'},
	{ 3		, 1		, 'm_roomId'			, 'UINT'				, 1 	, '房间编号(自由房填服务器生成的编号，其他填0)'},
	{ 4		, 1		, 'm_tableInfo'			, 'PstTableAttr'		, 1		, '桌子信息'},	
}

CS_M2C_FastEnterFreeTableOther_Ack =
{
	{ 1		, 1		, 'm_gameAtomTypeId'	, 'UINT'				, 1		, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_result'			, 'SHORT'				, 1		, '0:成功，-1:房间已满，请进入其他房间大厅,-2:金币不足'},
	{ 3		, 1		, 'm_roomInfo'			, 'PstRoomAttr'			, 1	   , '当前房间信息'},
    { 4		, 1     , 'm_roomIdArr'			, 'PstRoomIdAttr' 		, 4096 , '房间编号数组'},	
}

CS_C2M_FastEnterFreeTablePhone_Req =
{
	{ 1		, 1		, 'm_gameAtomTypeId'	, 'UINT'	, 1	, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_roomId'			, 'UINT'	, 1 , '房间编号(自由房填服务器生成的编号，其他填0)'},
}

CS_M2C_FastEnterFreeTablePhone_Ack =
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'						, 1		, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_result'				, 'SHORT'						, 1		, '0:成功，-1:房间已满，请进入其他房间大厅,-2:金币不足'},
	{ 3		, 1		, 'm_roomId'				, 'UINT'						, 1 	, '房间编号(自由房填服务器生成的编号，其他填0)'},
	{ 4		, 1		, 'm_tableId'				, 'UINT'						, 1 	, '桌子编号'},
	{ 5		, 1		, 'm_minScore'				, 'UINT'						, 1     , '底分'},
	{ 6		, 1		, 'm_beforeGameChair'		, 'PstFreeBeforeGameChair'		, 1024  , '椅子数组'},
	{ 7		, 1		, 'm_beforeGameUser'		, 'PstFreeBeforeGameUser'		, 1024  , '玩家数组'},
}

CS_M2C_UpdateRoomIdList_Nty =
{
	{ 1		, 1		, 'm_gameAtomTypeId'	, 'UINT'			, 1	   , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_roomIdArr'			, 'PstRoomIdAttr'	, 4096 , '房间编号数组'},
}

CS_C2M_ExitFreeRoomHall_Req =
{
	{ 1		, 1		, 'm_gameAtomTypeId'	, 'UINT'	, 1	   , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_roomId'			, 'UINT'	, 1    , '房间编号(自由房填服务器生成的编号，其他填0)'},
}

CS_M2C_ExitFreeRoomHall_Ack =
{
	{ 1		, 1		, 'm_gameAtomTypeId'	, 'UINT'	, 1	   , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_roomId'			, 'UINT'	, 1    , '房间编号(自由房填服务器生成的编号，其他填0)'},
	{ 3		, 1		, 'm_result'			, 'SHORT'	, 1		, '0:成功, -1:不在房间中'},
}

CS_M2C_TableValidateTimeOut_Nty =
{
	{ 1		, 1		, 'm_gameAtomTypeId'	, 'UINT'	, 1	   , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_roomId'			, 'UINT'	, 1    , '被踢出房间编号(自由房填服务器生成的编号，其他填0)'},
	{ 3		, 1		, 'm_tableId'			, 'UINT'	, 1    , '被踢出桌子编号'},
}

CS_M2C_FreeScenePlayerList_Nty =
{
	{ 1		, 1		, 'm_gameAtomTypeId'	, 'UINT'				, 1     , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_playerArr'			, 'PstFreePlayerAttr'	, 4096  , '自由房场景内玩家列表'},
}

CS_M2C_FreeSceneTodayRank_Nty =
{
	{ 1		, 1		, 'm_gameAtomTypeId'	, 'UINT'					, 1     , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_rankList'			, 'PstFreeTodayRankAttr'	, 4096  , '当天赢取金币排行榜'},
}

CS_M2C_FreeScenePersonalInfo_Nty =
{
	{ 1		, 1		, 'm_gameAtomTypeId'	, 'UINT'				, 1     , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_faceId'			, 'UINT'				, 1 	, '头像ID'},
	{ 3		, 1		, 'm_nickname'			, 'STRING'				, 1 	, '昵称'},
	{ 4		, 1		, 'm_goldCoin'			, 'UINT'				, 1 	, '金币数量'},
	{ 5		, 1		, 'm_level'				, 'UINT'				, 1 	, '等级'},
}

CS_M2C_FreeScenePlayerInOut_Nty =
{
	{ 1		, 1		, 'm_gameAtomTypeId'	, 'UINT'					, 1        , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_playerInOut'		, 'PstFreePlayerInOutAttr'	, 4096     , '进入/退出玩家'},
	{ 3		, 1		, 'm_playerArr'			, 'PstFreePlayerAttr'	    , 4096     , '进入玩家的属性(备注：只有进入玩家才需要读取该属性)'},
}

CS_M2C_FreeBeforeGameTable_Nty =
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1     , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_roomId'				, 'UINT'								, 1     , '房间编号'},
	{ 3		, 1		, 'm_tableId'				, 'UINT'								, 1     , '桌子编号'},
	{ 4		, 1		, 'm_minScore'				, 'UINT'								, 1     , '底分'},
	{ 5		, 1		, 'm_moveType'				, 'SHORT'								, 1 	, '进入/退出类型,0:进入，1：退出,2:断线重连'},
	{ 6		, 1		, 'm_moveChairId'			, 'UINT'								, 1     , '进入/退出的椅子编号'},	
	{ 7		, 1		, 'm_beforeGameChair'		, 'PstFreeBeforeGameChair'				, 1024  , '椅子数组'},
	{ 8		, 1		, 'm_beforeGameUser'		, 'PstFreeBeforeGameUser'				, 1024  , '玩家数组'},
}

CS_C2M_FreeGameEndExitOrContinue_Req =
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1     , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_type'					, 'UBYTE'								, 1     , '类型，0：退出，1：继续'},	
}

CS_M2C_FreeGameEndExitOrContinue_Ack =
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1     , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_type'					, 'UBYTE'								, 1     , '类型，0：退出，1：继续'},
	{ 3		, 1		, 'm_result'				, 'SHORT'								, 1		, '0:成功, 1(正1):超时未操作已清理，重新进入,-X:错误码'},
}

CS_C2M_FreeExitGame_Req =
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1     , '游戏最小配置类型ID'},
}

CS_M2C_FreeExitGame_Ack =
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1     , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_result'				, 'SHORT'								, 1		, '0:成功, -x:失败'},
}

CS_M2C_FreeGameEndTimeout_Nty =
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1     , '游戏最小配置类型ID'},
}


-----------------------------自由房<服务器-服务器>-------------------


-----------------------------系统分配房<客户端-服务器>---------------
CS_M2C_SysEnter_Nty =
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'				, 1 	, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_type'					, 'UBYTE'				, 1		, '类型，0：正常进入，1:断线重连'},
	{ 3		, 1		, 'm_faceId'				, 'UINT'				, 1 	, '头像ID'},
	{ 4		, 1		, 'm_nickname'				, 'STRING'				, 1 	, '昵称'},
	{ 5		, 1		, 'm_level'					, 'UINT'				, 1 	, '等级'},
	{ 6		, 1		, 'm_goldCoin'				, 'UINT'				, 1 	, '金币'},
}
															
CS_M2C_SysBeforeGameTable_Nty =
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1		, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_tableId'				, 'UINT'								, 1     , '桌子编号'},
	{ 3		, 1		, 'm_minScore'				, 'UINT'								, 1     , '底分'},
	{ 4		, 1		, 'm_roomCost'				, 'UINT'								, 1 	, '房费'},	
	{ 5		, 1		, 'm_beforeGameChair'		, 'PstSysBeforeGameChair'				, 1024  , '椅子数组'},
	{ 6		, 1		, 'm_beforeGameUser'		, 'PstSysBeforeGameUser'				, 1024  , '玩家数组'},
}		
	
CS_C2M_SysExitGame_Req = {
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1     , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_type'					, 'UINT'								, 1     , '强退类型，0:普通, 1:定点赛开赛提醒强退'},
}						      			

CS_M2C_SysExitGame_Ack = {
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1     , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_result'				, 'SHORT'								, 1		, '0:成功, ,-X:错误码'},
	{ 3		, 1		, 'm_type'					, 'UINT'								, 1     , '强退类型，0:普通, 1:定点赛开赛提醒强退'},
}

CS_M2C_SysEnd_Nty = {
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1     , '游戏最小配置类型ID'},
}

CS_M2C_SysKick_Nty = {
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1     , '游戏最小配置类型ID'},
}

--通知玩家分配游戏服失败
CS_M2C_AllocGameFail_Nty =
{
	{ 1		, 1		, 'm_gameAtomTypeId'	, 'UINT'		, 1	, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_roomId'			, 'UINT'		, 1 , '房间编号(自由房填服务器生成的编号，其他填0)'},
	{ 3		, 1		, 'm_tableId'			, 'UINT'		, 1 , '桌子编号'},
	{ 4		, 1		, 'm_result'			, 'SHORT'		, 1 , '失败原因(错误码表)'},
}

CS_M2C_SysExitSpecialAskPlayer_Nty =
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1     , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_leftCoin'				, 'UINT'								, 1     , '暂扣金币数目'},
	{ 3		, 1		, 'm_type'					, 'UINT'								, 1     , '强退类型，0:普通, 1:定点赛开赛提醒强退'},
}

CS_C2M_SysExitSpecialConfirm_Req =
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1     , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_type'					, 'UINT'								, 1     , '强退类型，0:普通, 1:定点赛开赛提醒强退'},
}

CS_M2C_SysExitSpecialConfirm_Ack =
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1     , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_result'				, 'SHORT'								, 1		, '0:成功, -X:错误码'},
	{ 3		, 1		, 'm_leftCoin'				, 'UINT'								, 1     , '暂扣金币数目'},
	{ 4		, 1		, 'm_returnCoin'			, 'UINT'								, 1     , '返回大厅金币数目'},
	{ 5		, 1		, 'm_type'					, 'UINT'								, 1     , '强退类型，0:普通, 1:定点赛开赛提醒强退'},
}

CS_C2M_SysContinueGame_Req =
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1     , '游戏最小配置类型ID'},
}

CS_M2C_SysContinueGame_Ack =
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1     , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_result'				, 'INT'									, 1     , '继续游戏结果 0成功 -1表示玩家已退出，请重试 -2：玩家还在游戏中'},
}
-----------------------------系统分配房<服务器-服务器>---------------

-----------------------------满人赛比赛房<客户端-服务器>-------------------
CS_M2C_MatchEnter_Nty =
{
	--{ 1		, 1		, 'm_signCnt'					, 'UINT'		, 1	, '已报名人数, 0-9人'},
	--{ 2		, 1		, 'm_beginNum'					, 'UINT'	    , 1 , '开赛需要人数'},
	{ 1		, 1		, 'm_state'						, 'UBYTE'		, 1	, '类型 0：未报名(按钮状态：未报名)，1:报名扣费中(显示为报名, 暂时不可点击), 2：已报名(报名成功，按钮显示为退赛) 3: 报名人员已满, 分配房间中(不可退赛) 4: 已开赛, 正在游戏中(不显示报名页面) 5: 当前轮比赛结束, 显示等待中 6:晋级界面,显示名次'} ,
	--{ 4		, 1		, 'm_signCost'					, 'UINT'		, 1	, '报名费'},
	--{ 5		, 1		, 'm_champinAward'				, 'UINT'	    , 1 , '冠军奖励'},
	--{ 6		, 1		, 'm_signers'					, 'PstMatchUser'		, 1024  , '比赛未开始, 这里显示为报名玩家信息'},	
	{ 2		, 1		, 'm_tableId'					, 'UINT'				, 1     , '桌子编号'},
	{ 3		, 1		, 'm_minScore'					, 'UINT'				, 1     , '底分'},	
	{ 4		, 1		, 'm_roundIndex'				, 'UBYTE'				, 1     , '第N轮'},
	{ 5		, 1		, 'm_roundNum'					, 'UBYTE'				, 1     , '总N轮'},
	{ 6		, 1		, 'm_upgradeCnt'				, 'UINT'				, 1     , '该轮前N名晋级'},
	{ 7		, 1		, 'm_roundPlayerNum'			, 'UINT'				, 1     , '当前轮总人数'},
	{ 8		, 1		, 'm_curStage'					, 'UBYTE'				, 1     , '当前阶段，1:晋级赛，2:半决赛，3:决赛，其他值为数值错误'},
	{ 9		, 1		, 'm_players'					, 'PstMatchBeforeGameUser'	, 3  , '如果游戏已经开始, 这里下发组桌玩家信息'},
	{ 10	, 1		, 'm_showRank'					, 'UINT'				, 1  	, '中间晋级界面, 该状态持续10s, 才开始下一轮, 只针对状态6可用, 决赛或者淘汰不会下发'},
	{ 11	, 1		, 'm_inning'					, 'UINT'				, 1     , '当前第几局'},
	{ 12	, 1		, 'm_totalInning'				, 'UINT'				, 1     , '总局数'},
}


--报名信息展示
CS_M2C_SignInfo_Nty = 
{
	--{ 1		, 1		, 'm_signCnt'					, 'UINT'		, 1	, '已报名人数, 0-9人'},
	--{ 2		, 1		, 'm_beginNum'					, 'UINT'	    , 1 , '开赛需要人数'},
	--{ 3		, 1		, 'm_state'						, 'UBYTE'		, 1	, '类型 0：未报名(按钮状态：未报名)，1:报名扣费中(显示为报名, 暂时不可点击), 2：已报名(报名成功，按钮显示为退赛) 3: 报名人员已满, 分配房间中(不可退赛) 4: 已开赛(不显示报名页面)'},
	--{ 4		, 1		, 'm_signCost'					, 'UINT'		, 1	, '报名费'},
	--{ 5		, 1		, 'm_champinAward'				, 'UINT'	    , 1 , '冠军奖励'},
	{ 1		, 1		, 'm_signers'					, 'PstMatchUser'		, 1024  , '比赛未开始, 这里显示为报名玩家信息'},
}

--[[
CS_C2M_MatchSignUp_Req =
{
	{ 1		, 1		, 'm_gameAtomTypeId'			, 'UINT'		, 1	, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_contidion'					, 'UBYTE'		, 1	, '比赛报名条件，0：免费报名，1：开赛选项1,2：开赛选项2，3：开赛选项3'},
}

CS_M2C_MatchSignUp_Ack =
{
	{ 1		, 1		, 'm_gameAtomTypeId'			, 'UINT'		, 1	, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_result'					, 'INT'			, 1	, '结果，0：报名成功，1:报名进入扣费状态，-X:失败(凡是失败情况，状态重置为 报名页未报名状态(按钮状态：未报名))'},
}

CS_C2M_MatchCancelSignUp_Req =
{
	{ 1		, 1		, 'm_gameAtomTypeId'			, 'UINT'		, 1	, '游戏最小配置类型ID'},
}

CS_M2C_MatchCancelSignUp_Ack =
{
	{ 1		, 1		, 'm_gameAtomTypeId'			, 'UINT'		, 1	, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_result'					, 'INT'			, 1	, '结果，0：退赛成功，-X:失败'},
}

CS_C2M_MatchCloseSignupPage_Req =
{
	{ 1		, 1		, 'm_gameAtomTypeId'			, 'UINT'		, 1	, '游戏最小配置类型ID'},
}

CS_M2C_MatchCloseSignupPage_Ack =
{
	{ 1		, 1		, 'm_gameAtomTypeId'			, 'UINT'		, 1	, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_result'					, 'INT'			, 1	, '结果，0：未报名成功，1：扣费阶段成功，2：已报名成功，3:收集状态成功, -X:失败'},
}

CS_M2C_MatchUpdateSignUpCnt_Nty =
{
	{ 1		, 1		, 'm_gameAtomTypeId'			, 'UINT'		, 1	, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_signUpCnt'					, 'UINT'		, 1	, '已报名人数'},
}
--]]

--分配时发的
CS_M2C_MatchBeforeGameTable_Nty =
{
	{ 1		, 1		, 'm_tableId'				, 'UINT'								, 1     , '桌子编号'},
	{ 2		, 1		, 'm_minScore'				, 'UINT'								, 1     , '底分'},	
	{ 3		, 1		, 'm_roundIndex'			, 'UBYTE'								, 1     , '第N轮'},
	{ 4		, 1		, 'm_roundNum'				, 'UBYTE'								, 1     , '总N轮'},
	{ 5		, 1		, 'm_upgradeCnt'			, 'UINT'								, 1     , '该轮前N名晋级'},
	{ 6		, 1		, 'm_roundPlayerNum'		, 'UINT'								, 1     , '当前轮总人数'},
	{ 7		, 1		, 'm_curStage'				, 'UBYTE'								, 1     , '当前阶段，1:晋级赛，2:半决赛，3:决赛，其他值为数值错误'},
	{ 8		, 1		, 'm_beforeGameUser'		, 'PstMatchBeforeGameUser'				, 3  	, '玩家数组'},
	{ 9		, 1		, 'm_showRank'				, 'UINT'								, 1  	, '中间晋级界面, 该状态持续10s, 才开始下一轮, 只针对状态6可用, 决赛或者淘汰不会下发'},
	{ 10	, 1		, 'm_inning'				, 'UINT'								, 1     , '当前第几局'},
	{ 11	, 1		, 'm_totalInning'			, 'UINT'								, 1     , '总局数'},
	
	--{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1		, '游戏最小配置类型ID'},
	--{ 1		, 1		, 'm_tableId'				, 'UINT'								, 1     , '桌子编号'},
	--{ 2		, 1		, 'm_minScore'				, 'UINT'								, 1     , '底分'},	
	--{ 4		, 1		, 'm_isShowMatchBegin'		, 'UBYTE'								, 1     , '是否显示【比赛开始】,0:不显示，1:显示'},
	--{ 3		, 1		, 'm_roundIndex'			, 'UBYTE'								, 1     , '第N轮'},
	--{ 4		, 1		, 'm_roundNum'				, 'UBYTE'								, 1     , '总N轮'},
	--{ 6		, 1		, 'm_upgradeType'			, 'UBYTE'								, 1     , '晋级类型：0:一局定胜，本桌第1名晋级,1:前N名晋级'},
	--{ 4		, 1		, 'm_isShowUpgrade'			, 'UBYTE'								, 1     , '是否显示本轮积极多少名'},
	--{ 5		, 1		, 'm_upgradeCnt'			, 'UINT'								, 1     , '该轮前N名晋级'},
	--{ 8		, 1		, 'm_curRoundtimes'			, 'UBYTE'								, 1     , '该轮共计N局'},
	--{ 9		, 1		, 'm_curTimesIndex'			, 'UBYTE'								, 1     , '该轮第N局'},	
	--{ 10	, 1		, 'm_isShowRoundUpgrade'	, 'UBYTE'								, 1     , '是否显示【第N轮、晋级类型、前N名晋级、该轮共计N局】,0:不显示，1:显示'},
	--{ 11	, 1		, 'm_totalRoundCnt'			, 'UBYTE'								, 1     , '整场比赛总共多少轮'},
	--{ 12	, 1		, 'm_isShowFinal'			, 'UBYTE'								, 1     , '是否显示【决赛】，0：不显示，1：显示'},
	--{ 6	, 1			, 'm_curStage'				, 'UBYTE'								, 1     , '当前阶段，1:晋级赛，2:半决赛，3:决赛，其他值为数值错误'},
	--{ 14	, 1		, 'm_isFirstTime'			, 'UBYTE'								, 1     , '是否第一次,0:否，1:是'},
	--{ 15	, 1		, 'm_lastEliminateCnt'		, 'UINT'								, 1     , '上一轮淘汰人数'},
	--{ 16	, 1		, 'm_lastUpgradeCnt'		, 'UINT'								, 1     , '上一轮前N名晋级'},
	--{ 17	, 1		, 'm_lastRank'				, 'UINT'								, 1     , '上一轮结束排名名次'},
	--{ 18	, 1		, 'm_beforeGameChair'		, 'PstMatchBeforeGameChair'				, 1024  , '椅子数组'},
	--{ 7	, 1			, 'm_beforeGameUser'		, 'PstMatchBeforeGameUser'				, 3  , '玩家数组'},
}

CS_M2C_RefreshMatchRank_Nty =
{
	{ 1		, 1		, 'm_rank'					, 'UINT'								, 1     , '玩家当前名次'},
	{ 2		, 1		, 'm_totalPlayerNum'		, 'UINT'								, 1     , '当前轮次比赛总人数'},
}

CS_C2M_MatchExitGame_Req =
{
	--{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1     , '游戏最小配置类型ID'},
}

CS_M2C_MatchExitGame_Ack =
{
	--{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1     , '游戏最小配置类型ID'},
	{ 1		, 1		, 'm_result'				, 'SHORT'								, 1		, '0:成功, -x:失败'},
}

--[[CS_C2M_MatchOpenSignUpOrExitMatchPage_Req =
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1     , '游戏最小配置类型ID'},
}

CS_M2C_MatchOpenSignUpOrExitMatchPage_Ack =
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'								, 1     , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_result'				, 'SHORT'								, 1		, '0:成功, -x:失败'},
}--]]

CS_M2C_MatchGameResult_Nty =
{
	--{ 1		, 1		, 'm_gameAtomTypeId'			, 'UINT'					 , 1		, '游戏最小配置类型ID'},
	{ 1		, 1		, 'm_type'						, 'UBYTE'					 , 1		, '类型，0:淘汰,1:晋级,2:整场比赛结束'},
	--{ 2		, 1		, 'm_contidion'					, 'UBYTE'					 , 1	    , '比赛报名条件，0：免费报名，1：开赛选项1,2：开赛选项2，3：开赛选项3'},
	--{ 4		, 1		, 'm_upgradeNextRound'			, 'UBYTE'					 , 1		, '晋级到下一轮的轮次(只针对m_type=1的情况)'},
	{ 2		, 1		, 'm_upgradeCnt'				, 'UINT'					 , 1		, '前N名晋级, 非决赛使用'},
	{ 3		, 1		, 'm_curRank'					, 'UINT'					 , 1		, '玩家当前排名, 非决赛使用'},
	{ 4		, 1		, 'm_goldCoin'					, 'UINT'					 , 1		, '玩家奖励金币数量, 非决赛使用'},
	--{ 5		, 1		, 'm_lastRankAward'				, 'PstMatchRankReward'		 , 3		, '最终决赛比赛奖励'},
	--{ 8		, 1		, 'm_diamond'					, 'UINT'					 , 1		, '奖励钻石数量'},
	--{ 9		, 1		, 'm_itemArr'					, 'PstMatchRewardItem'		 , 1024		, '奖励道具数组'},
}

--[[
CS_M2C_MatchStatusAfterExit_Nty =
{
	{ 1		, 1		, 'm_gameAtomTypeId'			, 'UINT'					 , 1		, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_status'					, 'UINT'					 , 1		, '状态， 0:未开始 1:进行中  2：完成'},
}
--]]

CS_M2C_MatchKick_Nty =
{
	{ 1		, 1		, 'm_ret'				, 'INT'					 , 1		, '踢人通知类型 1-报名超时'},
}

CS_M2C_MatchSignTimeOut_Nty =
{
	
}

--[[
CS_C2M_FastGetGameAddr_Req =
{
	{ 1		, 1		, 'm_gameAtomTypeId'			, 'UINT'					 , 1		, '游戏最小配置类型ID'},
}

CS_M2C_FastGetGameAddr_Ack =
{
	{ 1		, 1		, 'm_gameAtomTypeId'			, 'UINT'					 , 1		, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_domainName'				, 'STRING'					 , 1		, '游戏地址'},
	{ 3		, 1		, 'm_port'						, 'UINT'					 , 1		, '端口'},
}


CS_C2M_FastRoomStatus_Req =
{
	{ 1		, 1		, 'm_gameAtomTypeId'			, 'UINT'					 , 1		, '游戏最小配置类型ID'},
}

CS_M2C_FastRoomStatus_Ack =
{
	{ 1		, 1		, 'm_gameAtomTypeId'			, 'UINT'					 , 1		, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_status'					, 'UINT'					 , 1		, '0: 无 1:已报名  2:进行中 3：维护中'},
}

CS_C2M_FastGetExploit_Req =
{
	{ 1		, 1		, 'm_gameAtomTypeId'			, 'UINT'					 , 1		, '游戏最小配置类型ID'},
}

CS_M2C_FastGetExploit_Ack =
{
	{ 1		, 1		, 'm_gameAtomTypeId'			, 'UINT'					 , 1		, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_bestRank'					, 'UINT'					 , 1		, '最佳排名 0:无  >0: 排名'},
	{ 3		, 1		, 'm_bestRankTime'				, 'UINT'					 , 1		, '最佳排名时间'},
	{ 4		, 1		, 'm_upRank'					, 'UINT'					 , 1		, '上升名次 0:无, >0: 上升名次'},
}

--]]
-----------------------------比赛房<服务器-服务器>-------------------
