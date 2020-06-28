-- module(..., package.seeall)

-- -- 欢乐跑得快协议<客户端-服务器>
-- CS_G2C_HLLand_LoginData_Nty		=
-- {
--     { 1     , 1		, 'm_eRoundState'       , 'UINT'		, 1     , '游戏状态[1]等待[2]抢地主[3]游戏中[4]结束[5]翻倍[7]明牌状态[8]地主明牌状态'},
--     { 2     , 1		, 'm_nOperateChair'     , 'UINT'		, 1     , 'm_eRoundState(2|3 当前操作的玩家座位号[1-3])'},
--     { 3     , 1		, 'm_vecValue'          , 'INT'			, 3     , 'm_eRoundState(1 等待状态[0|1准备])(2 叫分状态[-1 没操作 0 不叫 1 叫 2 不抢 3 抢])(3 牌数[1-20])(4 计分)(5 翻倍[0还没叫 1不翻倍 其他数字表示翻的倍数])(7 明牌状态[0没点 1点了])'},
--     { 4     , 1		, 'm_nOperateTime'      , 'UINT'		, 1     , 'm_eRoundState(1|2|3 操作倒计时(单位：秒)'},
--     { 5     , 1		, 'm_nLastOutChair'     , 'UINT'		, 1    	, 'm_eRoundState(3 上一手牌玩家[0第一手|1-3])'},
--     { 6     , 1		, 'm_vecLastOutPokers'  , 'UINT'		, 20    , 'm_eRoundState(3 上一手牌[0-53])'},
--     { 7     , 1		, 'm_nLordChairIdx'     , 'UINT'		, 1     , 'm_eRoundState(3 地主座位号[1-3])'},
--     { 8     , 1		, 'm_nLordBelordCent'   , 'UINT'		, 1     , 'm_eRoundState(3 地主叫分[1-3])'},
--     { 9     , 1		, 'm_nTotalMultiple'    , 'UINT'		, 1     , 'm_eRoundState(3|4 已产生的总倍数)'},
--     { 10    , 1		, 'm_nBombs'			, 'UINT'		, 1     , 'm_eRoundState(3|4 已产生炸弹个数)'},
-- 	{ 11	, 1		, 'm_bSpring'			, 'UINT'		, 1		, '春天 [0]否[1]是'},
--     { 12    , 1		, 'm_vecTrusteeShip'    , 'UINT'		, 3     , 'm_eRoundState(2|3 托管状态[0|1])'},
--     { 13    , 1		, 'm_vecUnderPoker'     , 'UINT'		, 3     , 'm_eRoundState(1|2|3|4 底牌[0-53]黑红花片(3-KA2)小王大王)'},
--     { 14    , 1		, 'm_vec1ChairCards'    , 'UINT'		, 20    , 'm_eRoundState(2|3|4 手牌[0-53]黑红花片(3-KA2)小王大王)'},
--     { 15    , 1		, 'm_vec2ChairCards'    , 'UINT'		, 20    , 'm_eRoundState(2|3|4 手牌[0-53]黑红花片(3-KA2)小王大王)'},
--     { 16    , 1		, 'm_vec3ChairCards'    , 'UINT'		, 20    , 'm_eRoundState(2|3|4 手牌[0-53]黑红花片(3-KA2)小王大王)'},
-- 	{ 17    , 1		, 'm_vecLandOpenCards'  , 'UINT'		, 20    , 'm_eRoundState(3|4|5 地主明牌)'},
-- 	{ 18    , 1		, 'm_vecFarmerOpenCards', 'UINT'		, 20    , 'm_eRoundState(3|4|5 农民对家明牌)'},
--     { 19    , 1		, 'm_vecOutCards'       , 'UINT'		, 51    , 'm_eRoundState(3 已经打出去的牌[0-53]黑红花片(3-KA2)小王大王)'},
-- 	{ 20    , 1		, 'm_vecDouStatus'    	, 'UINT'		, 3     , '是否加倍 0 1 不加倍 2 加倍'},
-- 	{ 21	, 1		, 'm_nOpenTime'			, 'UINT'		, 4		, '明牌时间，对应倍数的时间，毫秒'},
-- 	{ 22	, 1		, 'm_nOpenVal'			, 'UINT'		, 4		, '明牌倍数 8 6 4 2 啥的'},
-- 	{ 23	, 1		, 'm_nDouTime'			, 'UINT'		, 1		, '加倍时间 秒'},
-- 	{ 24	, 1		, 'm_nUnderMul'			, 'UINT'		, 1		, '底牌倍数'},
	
-- }

-- CS_G2C_HLLand_Begin_Nty		=
-- {
-- 	{ 1		, 1		, 'm_vecGetCards'		, 	'UINT' ,	17	, '[0-53]黑红花片(3-KA2)小王大王'},
-- 	{ 2		, 1		, 'm_nCurRound'			,	'UINT'	, 1		, '当前轮数'},
-- 	{ 3		, 1		, 'm_nTotalRound'		,	'UINT'	, 1		, '总轮数'},
-- 	{ 4		, 1		, 'm_nOpenTime'			,	'UINT'	, 4		, '明牌时间，对应倍数的时间，毫秒'},
-- 	{ 5		, 1		, 'm_nOpenVal'			,	'UINT'	, 4		, '明牌倍数 8 6 4 2 啥的'},
-- }

-- CS_C2G_HLLand_OpenPoker_Req		=
-- {
-- 	{ 1		, 1		, 'm_nOpenMul'		,'UBYTE'	, 1	, '明牌倍数'},
-- }

-- CS_G2C_HLLand_OpenPoker_Nty		=
-- {
-- 	{ 1		, 1		, 'm_nOpenPosition' 	,	'UINT'	, 1	, '操作明牌座位号[1-3]'},
-- 	{ 2		, 1		, 'm_vecChairCards'		, 	'UINT'	, 20, '明牌玩家手牌'},
-- 	{ 3		, 1		, 'm_vecLastCards'		, 	'UINT'	, 3 , '底牌'},
-- 	{ 4		, 1		, 'm_nOpenVal'			, 	'UINT'	, 1	, '明牌 0 不明牌，1 明牌'},
-- 	{ 5		, 1		, 'm_nNextPosition'		, 	'UINT'	, 1	, '下一个操作座位号[1-3]'},
-- 	{ 6		, 1		, 'm_vecFarmerCards'	, 	'UINT'	, 17, '农民对家明牌'},
-- 	{ 7		, 1		, 'm_nNextTime'			, 	'UINT'	, 1, '下个阶段操作时间(秒) 下个阶段是 加倍 或者 叫分'},
-- 	{ 8		, 1		, 'm_nOpenMul'			, 	'UINT'	, 1, '明牌倍数'},
-- 	{ 9		, 1		, 'm_nLastCardsMul'		, 	'UINT'	, 1, '底牌倍数'},
-- }

-- -- CS_C2G_HLLand_BeLord_Req		=
-- -- {
-- 	-- { 1		, 1		, 'm_nCall'				, 'UBYTE'	, 1	, '[0]不叫[1]叫地主  [0]不抢[1]抢地主'},
-- -- }

-- -- CS_G2C_HLLand_BeLord_Nty		=
-- -- {
-- 	-- { 1		, 1		, 'm_nCallPosition'		, 'UBYTE'	, 1	, '叫分座位号[1-3]'},
-- 	-- { 2		, 1		, 'm_nIsCall'			, 'UBYTE'	, 1	, '0不叫(显示叫地主ui) 1叫地主(显示抢地主ui)'},
-- 	-- { 3		, 1		, 'm_nNextPosition'		, 'UBYTE'	, 1	, '下一个叫分座位号[1-3]'},
-- -- }

-- -- CS_G2C_HLLand_BeLordResult_Nty		=
-- -- {
-- 	-- { 1		, 1		, 'm_nLordPosition'		, 'UBYTE'	, 1	, '地主座位号[1-3]'},
-- 	-- { 2		, 1		, 'm_vecCards'			, 'UBYTE'	, 3	, '[0-53]黑红花片(3-KA2)小王大王'},
-- 	-- { 3		, 1		, 'm_nIsLandOpen'		, 'UINT'	, 1	, '是否有地主明牌操作'},
-- -- }

-- CS_C2G_HLLand_LandOpenPoker_Req		=
-- {
-- 	{ 1		, 1		, 'm_nIsOpenCards'		,'UBYTE'	, 1	, '地主是否明牌  0 不明牌  1 明牌'},
-- }

-- CS_G2C_HLLand_LandOpenPoker_Nty		=
-- {
-- 	{ 1		, 1		, 'm_vecChairCards'		, 	'UINT'	, 20, '地主明牌 内容为空表示地主不明牌'},
-- 	{ 2		, 1		, 'm_vecFarmerCards'	, 	'UINT'	, 17, '农民对家明牌'},
-- 	{ 3		, 1		, 'm_nNextTime'			, 	'UINT'	, 1, '下个阶段操作时间(秒) 下个阶段是 加倍'},
-- 	{ 4		, 1		, 'm_nOpenMul'			, 	'UINT'	, 1, '明牌倍数'},
-- }

-- CS_G2C_HLLand_Result_Nty		=
-- {
-- 	{ 1		, 1		, 'm_bSpring'			,		'UBYTE'		, 1		, '[0]否[1]是'},
-- 	{ 2		, 1		, 'm_nTotalMultiple'	,		'UINT'		, 1		, '总倍数'},
-- 	{ 3		, 1		, 'm_nTotalBombs'		,		'UINT'		, 1		, '炸弹个数'},
-- 	{ 4		, 1		, 'm_vecScore'			,		'INT'		, 3		, '记分(单位:金币)'},
-- 	{ 5		, 1		, 'm_vec1ChairCards'	, 		'UINT'		, 20	, '剩余手牌[0-53]黑红花片(3-KA2)小王大王'},
-- 	{ 6		, 1		, 'm_vec2ChairCards'	, 		'UINT'		, 20	, '剩余手牌[0-53]黑红花片(3-KA2)小王大王'},
-- 	{ 7		, 1		, 'm_vec3ChairCards'	, 		'UINT'		, 20	, '剩余手牌[0-53]黑红花片(3-KA2)小王大王'},	
-- 	{ 8		, 1		, 'm_nCurRound'			,		'UINT'		, 1		, '当前轮数'},
-- 	{ 9		, 1		, 'm_nTotalRound'		,		'UINT'		, 1		, '总轮数'},
-- 	{ 10	, 1		, 'm_nLandPos'			,		'UINT'		, 1		, '地主位置 1 2 3'},
	
-- 	{ 11	, 1		, 'm_nOpenMul'			,		'UINT'		, 1		, '明牌倍数 0 表示无'},
-- 	{ 12	, 1		, 'm_nCallMul'			,		'UINT'		, 1		, '抢地主倍数 0 或者 1 表示无'},
-- 	{ 13	, 1		, 'm_nLastCardsMul'		,		'UINT'		, 1		, '底牌倍数 0 表示无'},
-- 	{ 14	, 1		, 'm_nDoubleMul'		,		'UINT'		, 1		, '加倍操作的倍数 1 表示无'},
-- 	{ 15	, 1		, 'm_nPunResult'		,		'UINT'		, 1		, '惩罚结果 0 没有惩罚  1 有惩罚'},
-- 	{ 16	, 1		, 'm_nEndPos'			,		'UINT'		, 1		, '最后一手出牌的位置 1 2 3'},
-- 	-- { 17	, 1		, 'm_nPunResultVal'		,		'UINT'		, 1		, '惩罚结果是否影响结算 0 没有  1 有  这个客户端自己算，更据 m_nPunResult 和 m_vecScore'},
-- }


----------------------------------------------------------------------------------------------------
module(..., package.seeall)


-- 跑得快协议<客户端-服务器>

--------------------------------------------------------------------------------------------------
-- 玩家进入
CS_G2C_Run_Enter_Nty = 
{
	{ 1,	1, 'm_playerInfo'  		 ,  'PstRunPlayerInfo'	, 1		, '玩家信息'},
}
-- 玩家进入返回
CS_G2C_Run_Leave_Nty = 
{
	{ 1,	1, 'm_accountId'  		 ,  'UINT'						, 1		, '玩家ID'},
	{ 2,	1, 'm_chairId'       	 ,  'INT'       				, 1     , '椅子号' },
}
CS_M2C_Run_Exit_Nty =
{
	{ 1		, 1		, 'm_type'		,		'UBYTE'	, 1		, '退出， 0-正常结束 1-分配游戏服失败 2-同步游戏服失败'},
}
-- 玩家申请准备
CS_C2G_Run_Ready_Req = 
{
 	{ 1,	1, 'm_chairId'			 ,  'UBYTE'						, 1		, '玩家椅子号'},
 	{ 2,	1, 'm_accountId'  		 ,  'UINT'						, 1		, '玩家ID'},
}
-- 玩家准备返回
CS_G2C_Run_Ready_Ack = 
{
   { 1,	1, 'm_chairId'			 ,  'UBYTE'						, 1		, '玩家椅子号'},
   { 2,	1, 'm_result'		     ,  'INT'						, 1		, '玩家准备结果'},
}
-- 退出游戏
CS_C2G_Run_Exit_Game_Req  =
{
	{ 1		, 1		, 'm_accountId'		    , 'UINT'	, 1     , '玩家ID'},
	{ 2		, 1		, 'm_type'				, 'UINT'	, 1     , '强退类型，0:普通, 1:定点赛开赛提醒强退'},
}
CS_G2C_Run_Exit_Game_Ack  =
{
	{ 1		, 1		, 'm_result'				, 'SHORT'	, 1		, '0:成功, ,-X:错误码'},
	{ 2		, 1		, 'm_type'					, 'UINT'	, 1     , '强退类型，0:普通, 1:定点赛开赛提醒强退'},
}
-- 游戏开始 结束
SS_G2M_Run_Game_Start_Nty =
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'	, 1     , '游戏最小配置类型ID'},
}

SS_G2M_Run_Game_End_Nty =
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'	, 1     , '游戏最小配置类型ID'},
}
-- 游戏继续
CS_C2G_Run_Continue_Req =
{
	{ 1		, 1		, 'm_accountId'  		 ,  'UINT'		, 1     , '游戏最小配置类型ID'},
}
CS_M2C_Run_ContinueGame_Ack =
{
	{ 1		, 1		, 'm_gameAtomTypeId'		, 'UINT'	, 1     , '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_result'				, 'INT'		, 1     , '继续游戏结果 0成功 -1表示玩家已退出，请重试 -2：玩家还在游戏中'},
}
---------------------------------------------------------------------------------------------------
-- 进入游戏，未开局
CS_G2C_Run_In_Wait_Nty = 
{
	{ 1,	1, 'm_state'  		 	 ,  'UBYTE'						, 1		, '1-表示开始等待状态 2-发牌状态 3-游戏中'},
	{ 2,	1, 'm_beginTime'  		 ,  'UINT'						, 1		, '开始准备时间'},
	{ 3,	1, 'm_thinkTime'  		 ,  'UINT'						, 1		, '每次出牌考虑时间'},
	{ 4,	1, 'm_cell'              ,  'UINT'						, 1		, '底分'},	
	{ 5,	1, 'm_allPlayers'  		 ,  'PstRunPlayerInfo'	        , 3		, '玩家信息'},
}
-- 进入游戏，游戏状态
CS_G2C_Run_In_PlayGame_Nty = 
{
	{ 1,	1, 'm_state'  		 	 ,  'UBYTE'						, 1		, '1-表示开始等待状态 2-发牌状态 3-游戏中'},
	{ 2,	1, 'm_beginTime'  		 ,  'UINT'						, 1		, '开始准备时间'},
	{ 3,	1, 'm_thinkTime'  		 ,  'UINT'						, 1		, '每次出牌考虑时间'},
	{ 4,	1, 'm_cell'              ,  'UINT'						, 1		, '底分'},	
	{ 5,	1, 'm_allPlayers'  		 ,  'PstRunPlayerInfo'	        , 3		, '玩家信息'},
	-- 各玩家的状态， 以及手牌情况
	{ 6,	1, 'm_discardCards'  	 ,  'UBYTE'					    , 48	, '已出牌'},
	{ 7,	1, 'm_handCounts'		 ,  'UBYTE'						, 3		, '玩家手牌张数'},
	{ 8,	1, 'm_chairId'			 ,  'UBYTE'					    , 1		, '当前玩家座位号'},
	{ 9,	1, 'm_myCards'			 ,  'UBYTE'						, 16	, '当前玩家牌'},
	{ 10,	1, 'm_autoChairId'		 ,  'UBYTE'						, 3	,   '托管玩家[0]否[1]是'},
	{ 11,	1, 'm_warningChairId'	 ,  'UBYTE'						, 3	,   '报警玩家[0]否[1]是'},
	{ 12,	1, 'm_operChairId'	     ,  'UBYTE'						, 1	,   '当前操作玩家'},
	{ 13,	1, 'm_chairOneOutCards'	 ,  'UBYTE'						, 16,   '椅子号1当前出牌'},
	{ 14,	1, 'm_chairTwoOutCards'	 ,  'UBYTE'						, 16,   '椅子号2当前出牌'},
	{ 15,	1, 'm_chairThreeOutCards'	 ,  'UBYTE'					, 16,   '椅子号3当前出牌'},
	{ 16,	1, 'm_recordId'	 ,          'STRING'					, 1,    '牌局编号'},
}
-- 托管申请
CS_C2G_Run_AutoControl_Req		=
{
	{ 1		, 1		, 'm_accountId'		    , 'UINT'	, 1  , '玩家ID'},
	{ 2		, 1		, 'm_bOpenOrClose'		, 'UBYTE'	, 1	, '[0]关[1]开'},
}
-- 托管通知
CS_G2C_Run_AutoControl_Nty		=
{
	{ 1		, 1		, 'm_nPosition'			, 'UBYTE'	, 1	, '托管座位号[1-3]'},
	{ 2		, 1		, 'm_bOpenOrClose'		, 'UBYTE'	, 1	, '[0]关[1]开'},
}
---------------------------------------------------------------------------------------------------
--通知开局
CS_G2C_Run_Begin_Nty = 
{
    { 1,	1, 'm_status'			 ,  'UBYTE'						, 1		, '开始状态'},
	{ 2,	1, 'm_cards'       		 ,  'UBYTE'       				, 16     , '玩家手牌'},
	{ 3,	1, 'm_recordId'	 ,          'STRING'					, 1,    '牌局编号'},
	{ 4		, 1		, 'm_nCurRound'			,	'UINT'	, 1		, 'µ±Ç°ÂÖÊý'},
	{ 5		, 1		, 'm_nTotalRound'		,	'UINT'	, 1		, '×ÜÂÖÊý'},
}
--提示玩家出牌
CS_G2C_Run_Action_Nty =
{
    { 1,	1, 'm_chairId'			 ,  'UBYTE'						, 1		, '出牌玩家椅子号'},
}
--提示玩家过牌
CS_G2C_Run_Pass_Nty =
{
    { 1,	1, 'm_chairId'			 ,  'UBYTE'						, 1		, '过牌玩家椅子号'},
}
--通知玩家结算
CS_G2C_Run_GameEnd_Nty = 
{
	{ 1,	1, 'm_allResult'      	 ,  'PstRunUserEndInfo'    , 3   , '所有玩家结算结果，包括自己的' },
	{ 2,	1, 'm_indemnityChairId'			 ,  'UBYTE'						, 1	, '包赔玩家'},
	{ 3		, 1		, 'm_nCurRound'			,		'UINT'		, 1		, 'µ±Ç°ÂÖÊý'},
	{ 4		, 1		, 'm_nTotalRound'		,		'UINT'		, 1		, '×ÜÂÖÊý'},
}

-- PstRunUserEndInfo =
-- {
-- 	{ 1, 	1, 'm_accountId'		, 'UINT'				, 1		, '玩家ID' },
-- 	{ 2,	1, 'm_profit'			, 'INT'					, 1		, '本轮净盈利， 扣税前'},
-- 	{ 3,	1, 'm_netProfit'		, 'INT'					, 1		, '本轮净盈利， 扣税后'},
-- 	{ 4,	1, 'm_curScore'			, 'UINT'				, 1		, '结算后总金币'},
-- 	{ 5,	1, 'm_bombCount'		, 'UINT'				, 1		, '炸弹个数'},
-- 	{ 6,	1, 'm_bombScore'		, 'INT'				    , 1		, '炸弹输赢分数'},
-- 	{ 7,	1, 'm_cards'			, 'UBYTE'				, 18	, '剩余牌面'},
-- 	{ 8,	1, 'm_cardCount'		, 'UBYTE'				, 1		, '剩余牌张数'},
-- 	{ 9,	1, 'm_calScore'		    , 'INT'				    , 1		, '结算分数'},
-- 	{ 10, 	1, 'm_chairId'			, 'UINT'				, 1		, '椅子号' },
-- }

--提示其他玩家出牌
CS_G2C_Run_OutCard_Nty = 
{
    { 1,	1, 'm_chairId'			 ,  'UBYTE'						, 1		, '玩家椅子号'},
	{ 2,	1, 'm_cards'			 ,  'UBYTE'						, 16	, '玩家出牌'},
}
--玩家出牌请求
CS_C2G_Run_OutCard_Req = 
{
	{ 1,	1, 'm_accountId'  		 ,  'UINT'					, 1		, '玩家ID'},
	{ 2,	1, 'm_cards'       	 ,  'UBYTE'       			    , 16    , '玩家出牌' },
}
--玩家出牌返回
CS_G2C_Run_OutCard_Ack = 
{
    { 1,	1, 'm_chairId'		     ,  'UBYTE'						, 1		, '玩家椅子号'},
    { 2,	1, 'm_cards'			 ,  'UBYTE'						, 16	, '玩家出牌'},
    { 3,	1, 'm_result'		     ,  'INT'						, 1		, '玩家出牌结果'},
}
--炸弹结算信息
CS_G2C_Run_Bomb_Nty = 
{
    { 1,	1, 'm_chairId'		     ,  'UBYTE'						, 1		, '炸弹玩家椅子号'},
    { 2,	1, 'm_result'		     ,  'INT'						, 3		, '炸弹结算结果'},
}
--玩家报警
CS_G2C_Run_Warning_Nty = 
{
    { 1,	1, 'm_chairId'		     ,  'UBYTE'						, 1		, '报警玩家椅子号'},
}
--------------------------------------------------------------------------------------------------
-- 比赛场
CS_C2M_Run_Match_Sign_Up_Req = 
{
    { 1,	1, 'm_accountId'  		 ,  'UINT'						, 1		, '玩家ID'},
}

CS_C2M_Run_Match_Sign_Up_Ack = 
{
    { 1,	1, 'm_accountId'  		 ,  'UINT'						, 1		, '玩家ID'},
	{ 2,	1, 'm_result'  		     ,  'UINT'						, 1		, '报名结果'},
}

CS_C2M_Run_Match_Cancel_Sign_Up_Req  = 
{
    { 1,	1, 'm_accountId'  		 ,  'UINT'						, 1		, '玩家ID'},
}

CS_M2C_Run_Match_Cancel_Sign_Up_Ack  = 
{
    { 1,	1, 'm_accountId'  		 ,  'UINT'						, 1		, '玩家ID'},
	{ 2,	1, 'm_result'  		     ,  'UINT'						, 1		, '取消报名结果'},
}
	
CS_M2C_Run_Match_Sign_Up_Num_Nty = 
{
    { 1,	1, 'm_count'  		 ,  'UINT'						, 1		, '报名人数'},
}

SS_G2M_Run_Match_Result_Nty =
{
	{ 1		, 1		, 'm_strGameObjId'		,		'STRING'								, 1		, 'gameObjId'},
	{ 2		, 1		, 'm_vecScore'			,		'PstCalculateAccountData'		        , 3	    , '玩家记分'},
	{ 3		, 1		, 'm_startGameTime'			,	'UINT'									, 1		, '开始游戏的时间'},
	{ 4		, 1		, 'm_isOver'			,		'UINT'									, 1		, '是否结束'},
}

CS_M2C_Run_Match_Rank_Nty =
{
	{ 1		, 1		, 'm_rank'					, 'UINT'								, 1     , '玩家当前名次'},
	{ 2		, 1		, 'm_totalPlayerNum'		, 'UINT'								, 1     , '当前轮次比赛总人数'},
}

CS_M2C_Run_Match_Result_Nty =
{
	{ 1		, 1		, 'm_type'						, 'UBYTE'					 , 1		, '类型，0:淘汰,1:晋级,2:整场比赛结束'},
	{ 2		, 1		, 'm_upgradeCnt'				, 'UINT'					 , 1		, '前N名晋级, 非决赛使用'},
	{ 3		, 1		, 'm_curRank'					, 'UINT'					 , 1		, '玩家当前排名, 非决赛使用'},
	{ 4		, 1		, 'm_goldCoin'					, 'UINT'					 , 1		, '玩家奖励金币数量, 非决赛使用'},
}
--分配该轮信息
CS_M2C_Run_Match_Before_Game_Nty =
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
}

CS_M2C_Run_Match_Enter_Nty =
{
	{ 1		, 1		, 'm_state'						, 'UBYTE'		        , 1	    , '类型 0：未报名(按钮状态：未报名)，1:报名扣费中(显示为报名, 暂时不可点击), 2：已报名(报名成功，按钮显示为退赛) 3: 报名人员已满, 分配房间中(不可退赛) 4: 已开赛, 正在游戏中(不显示报名页面) 5: 当前轮比赛结束, 显示等待中 6:晋级界面,显示名次'} ,	
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

CS_M2G_Run_Match_Kick_Nty =
{
	{ 1		, 1		, 'm_gameAtomTypeId'			, 'UINT'					 , 1		, '游戏最小配置类型ID'},
	{ 2		, 1		, 'm_accountId'					, 'UINT'					 , 1		, '玩家ID'},
}

SS_M2G_Run_Match_Create_Game_Req =
{
	{ 1		, 1		, 'm_strGameObjId'		,		'STRING'						, 1		, '游戏ID'},
	{ 2		, 1		, 'm_nTimes'			,		'UINT'							, 1		, '局数'},
	{ 3		, 1		, 'm_nBaseCent'			, 		'UINT'							, 1		, '底分'},
	{ 4		, 1		, 'm_vecAccounts'		,		'PstGameDataEx'					, 3		, '玩家数据'},
	{ 5		, 1		, 'm_isLimitTs'			,		'UINT'							, 1		, '是否限制托管'},
	{ 6		, 1		, 'm_eGameMode'			,		'UINT'							, 1		, '游戏模式(与gameAtomType相同)'},
	{ 7	, 1		, 'm_yyParam'			,		'STRING'						, 1		, '运营参数(比赛id,其他填空)'},
	{ 8	, 1		, 'm_isLastRound'		,		'UBYTE'							, 1		, '是否最后一轮比赛'},
}

CS_C2M_Run_Match_Exit_Game_Req =
{
    { 1		, 1		, 'm_accountId'					, 'UINT'					 , 1		, '玩家ID'},
}

CS_M2C_Run_Match_Exit_Game_Ack =
{
    { 1		, 1		, 'm_result'					, 'UINT'					 , 1		, '玩家退出比赛结果'},
}
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
-- 目前没用消息
SS_M2G_Run_GameResult_Nty =
{
	{ 1		, 1		, 'm_vecAccounts'		,		'PstRunUserEndInfo'	, 3		, '玩家数据'},
}
-- 创建游戏牌桌
SS_M2G_Run_GameCreate_Req =
{
	{ 1		, 1		, 'm_strGameObjId'		,		'STRING'					, 1		, '游戏对象ID'},
	{ 2		, 1		, 'm_vecAccounts'		,		'PstRunSyncData'			, 3		, '玩家数据'},
}
-- 创建游戏牌桌返回
SS_G2M_Run_GameCreate_Ack =
{
	{ 1		, 1		, 'm_strGameObjId'		,		'STRING'					, 1		, '游戏对象ID'},
	{ 2		, 1		, 'm_nResult'			,		'UINT'						, 1		, '结果 1-成功 0-失败'},
	{ 3		, 1		, 'm_vecAccounts'		,		'PstOperateRes'				, 3		, '玩家初始化结果数据'},
}
-- 战绩
CS_G2C_Run_CombatGains_Nty = 
{
	{ 1,	1, 'm_combatGains'	 	, 'PstRunCombatGain'	, 3		, '战绩信息'},
}
-- 踢人
CS_G2C_Run_Kick_Nty =
{
	{ 1,    1		, 'm_type'		,		'UBYTE'	, 1		, '踢人 1:金币低于每局入场限制被踢出 2:超时未准备踢出'},
}
SS_G2M_Run_Exit_Nty = 
{
    { 1,	1, 'm_accountId'  		 ,  'UINT'						, 1		, '玩家ID'},
}
SS_G2M_Run_Robot_Exit_Nty = 
{
    { 1,	1, 'm_accountId'  		 ,  'UINT'						, 1		, '玩家ID'},
}
--------------------------------------------------------------------------------------------------
