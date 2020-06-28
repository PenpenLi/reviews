module(..., package.seeall)



-- 牌局玩家数据
PstRoundPlayerData = 
{
	{1,	1,	'm_accountId',  		'UINT', 	1, '玩家账号'},
	{2, 1,  'm_score',   			'INT', 		1, '输赢分数'},
	
}

--牌局数据
PstRoundData = 
{
	{1,	1,	'm_time',  				'UINT', 				1, '时间 1970 年的秒'},
	{2,	1,	'm_gameAtomTypeId',     'UINT', 				1, '游戏类型id'},
	{3, 1,  'm_roundId',   			'STRING', 				1, '牌局id'},
	{4, 1,  'm_strAccountsId',   	'STRING', 				1, '玩家账号ID'},
	{5, 1,  'm_strData',   			'STRING', 				1, '其他参数'},
	
}
-- 牌友房格式
-- m_strAccountsId : accountid;accountid;
-- m_strData ： [[账号id,分数],[0,炸弹，局数，加倍]]  例子： [[8,0],[4294967295,0],[4294967294,0],[0,3,6,0]] 


-- 进入牌局服务器
CS_C2R_Enter_Req = 
{
	{1,	1,	'm_accountId',  		'UINT', 1		, '玩家账户ID'},
	{2,	1,	'm_gameAtomTypeId',     'UINT', 1, 		'游戏类型id'},
	
}

CS_R2C_Enter_Ack = 
{
	{1,	1,	'm_result',  'UINT', 1, '0 成功  1 失败'},
	
}

-- 和牌局服务器的心跳
CS_C2R_PingReq = 
{
	{1,	1,	'm_accountId',  'UINT', 1, '玩家账户ID'},
	
}

-- 请求牌局列表
CS_C2R_RoundListReq = 
{
	{1,	1,	'm_accountId',  'UINT', 1, '玩家账户ID'},
	
}

CS_R2C_RoundListAck = 
{
	{1,	1,	'm_accountId',  'UINT', 			1, 			'玩家账户ID'},
	{2,	1,	'm_gameAtomTypeId',     'UINT', 1, 		'游戏类型id'},
	{3,	1,	'm_roundList',  'PstRoundData', 	1024, 		'牌局列表'},
	
}



