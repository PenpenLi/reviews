----------------------------------------------------------------------------------------------------
module(..., package.seeall)

--------------------------------------------------------------------------------------------------
PstRunPlayerInfo =
{
	{ 1, 	1, 'm_accountId'		, 'UINT'				, 1		, '玩家ID' },
	{ 2, 	1, 'm_nickname'			, 'STRING'				, 1 	, '昵称' },
	{ 3, 	1, 'm_faceId'			, 'UINT'				, 1 	, '头像ID' },
	{ 4, 	1, 'm_frameId'			, 'UINT'				, 1 	, '头像框ID' },
	{ 5, 	1, 'm_vipLevel'			, 'UINT'				, 1 	, 'vip等级' },
	{ 6, 	1, 'm_score'			, 'UINT'				, 1 	, '金币' },
	{ 7, 	1, 'm_state'			, 'UBYTE'				, 1 	, '状态 0-旁观，未参与到游戏中 1-游戏中' },
	{ 8, 	1, 'm_totalResult'		, 'UINT'				, 1 	, '玩家总输赢 ' },
	{ 9, 	1, 'm_chairId'			, 'INT'					, 1 	, '座位号 0-2' },
	{ 10, 	1, 'm_ready'			, 'UBYTE'				, 1 	, '准备 1-准备 0-未准备' },
}

PstRunUserEndInfo =
{
	{ 1, 	1, 'm_accountId'		, 'UINT'				, 1		, '玩家ID' },
	{ 2,	1, 'm_profit'			, 'INT'					, 1		, '本轮净盈利， 扣税前'},
	{ 3,	1, 'm_netProfit'		, 'INT'					, 1		, '本轮净盈利， 扣税后'},
	{ 4,	1, 'm_curScore'			, 'UINT'				, 1		, '结算后总金币'},
	{ 5,	1, 'm_bombCount'		, 'UINT'				, 1		, '炸弹个数'},
	{ 6,	1, 'm_bombScore'		, 'INT'				    , 1		, '炸弹输赢分数'},
	{ 7,	1, 'm_cards'			, 'UBYTE'				, 18	, '剩余牌面'},
	{ 8,	1, 'm_cardCount'		, 'UBYTE'				, 1		, '剩余牌张数'},
	{ 9,	1, 'm_calScore'		    , 'INT'				    , 1		, '结算分数'},
	{ 10, 	1, 'm_chairId'			, 'UINT'				, 1		, '椅子号' },
}

PstRunBalanceData =
{
	{ 1		, 1		, 'm_accountId'			, 'UINT'				, 1    , '玩家ID'},
	{ 2		, 2		, 'm_curCoin'			, 'UINT'				, 1	   , '当前金币'},
	{ 3		, 2		, 'm_type'				, 'UBYTE'				, 1	   , '操作类型 0-正常结算 1-退出'},
}

PstRunSyncData =
{
	{ 1		, 1		, 'm_syncInfo'			, 'PstSyncGameDataEx'	, 1    , '玩家信息'},
	{ 2		, 2		, 'm_chairId'			, 'UBYTE'				, 1	   , '玩家作为'},
}

PstRunCombatGain =
{
	{ 1,	1, 'm_chairId'	 		 , 'INT'						, 1		, '玩家椅子ID'},
	{ 2,	1, 'm_bWinner'	 		 , 'UBYTE'						, 1		, '是否为本桌历史赢得最多的玩家 1-是 0-否'},
	{ 3,	1, 'm_bombTimes'	 	 , 'UINT'						, 1		, '炸弹局数'},
	{ 4,	1, 'm_maxWinCoin'	 	 , 'INT'						, 1		, '最大累计赢钱数'},
	{ 5,	1, 'm_maxStreakTimes'	 , 'UINT'						, 1		, '最大连赢局数'},
	{ 6,	1, 'm_winTimes'	 		 , 'UINT'						, 1		, '胜利局数'},
	{ 7,	1, 'm_winCoin'	 		 , 'INT'						, 1		, '累计输赢金币'},
}

PstUserCard = 
{
	{ 1,	1, 'm_cards'       		 ,  'UBYTE'       				, 16     , '玩家手牌'},
}

--------------------------------------------------------------------------------------------------
--报名页面已报名玩家信息
PstMatchUser = 
{
	{ 1		, 1		, 'm_accountId'			, 'UINT'				, 1 	, '玩家账户ID'},
	{ 2		, 1		, 'm_faceId'			, 'UINT'				, 1 	, '头像ID'},
	{ 3		, 1		, 'm_nickname'			, 'STRING'				, 1 	, '昵称'},
}

--比赛场景通知显示游戏客户端(开始游戏前)
PstMatchBeforeGameUser = {
	{ 1		, 1		, 'm_accountId'			, 'UINT'				, 1 	, '玩家账户ID'},
	{ 2		, 1		, 'm_faceId'			, 'UINT'				, 1 	, '头像ID'},
	{ 3		, 1		, 'm_nickname'			, 'STRING'				, 1 	, '昵称'},
	{ 4		, 1		, 'm_level'				, 'UINT'				, 1 	, '等级'},
	{ 5		, 1		, 'm_gameScore'			, 'INT'					, 1 	, '当前积分(该积分为每轮开始前的初始积分、断线重连的积分，有可能为负数)'},
	{ 6		, 1		, 'm_chairId'			, 'UINT'				, 1 	, '椅子编号'},
}

PstCalcDataEx =
{
	{ 1		, 1		, 'm_nAccount'					, 'UINT'		, 1	, '玩家账户ID'},
	{ 2		, 1		, 'm_nCent'						, 'INT'			, 1	, '积分(正数：表示+多少，负数：表示-多少)'},
}

-- 比赛场玩家积分
PstCalculateAccountData =
{
	{ 1		, 1		, 'm_nAccount'					, 'UINT'		, 1	, '玩家账户ID'},
	{ 2		, 1		, 'm_nCent'						, 'INT'			, 1	, '积分(正数：表示+多少，负数：表示-多少)'},
	{ 3		, 1		, 'm_nPun'						, 'UINT'		, 1	, '是否托管惩罚 0 没有  1 有'},
	{ 4		, 1		, 'm_calcDataEx'				, 'PstCalcDataEx'		, 4	, '结算数据'},
}

PstGameDataEx =
{
	{ 1		, 1		, 'm_sPlayerData'				, 'PstSyncGameDataEx'		, 1		, '玩家数据'},
	{ 2		, 1		, 'm_gameAtomTypeId'			, 'UINT'			        , 1	   	, '游戏序号'},
	{ 3     , 1     , 'm_chairId'	 		        , 'INT'						, 1		, '玩家椅子ID'},
	{ 4		, 1		, 'm_score'						, 'INT'				, 1	   	, '积分，比如比赛的初始积分'},
	{ 5		, 1		, 'm_nBaseCent'					, 'UINT'			, 1		, '底分'},
	{ 6		, 1		, 'm_strBusId'					, 'STRING'			, 1		, '玩家业务关联标识(运营日志用到)'},
	{ 7		, 1		, 'm_yyParam'					, 'STRING'			, 1		, '运营参数(比赛id,其他填空)'},
}
--------------------------------------------------------------------------------------------------
