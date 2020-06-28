module(..., package.seeall)


-- 定点赛协议

CS_M2C_AppointmentMatch_Init_Nty =
{
	{ 1		, 1		, 'm_nNumCandidates'		, 'UINT'		, 1		, '1:当前报名人数 2:参赛人数'},
	{ 2		, 1		, 'm_nStartTime'			, 'UINT'		, 1		, '开赛时间(单位:秒)'},
	{ 3		, 1		, 'm_nSignState'			, 'UINT'		, 1		, '报名状态[0]未报名[1]已报名[2]已开赛[3]已报名重连[4]维护状态'},
	{ 4		, 1		, 'm_nSvrTime'				, 'UINT'		, 1		, '服务器时间戳'},
	{ 5		, 1		, 'm_nGroupState'			, 'UINT'		, 1		, '游戏状态[0]准备中[1]比赛开始窗口期[2]进行中[3]等待阶段结束[4]结束'},
	{ 6		, 1		, 'm_gameAtomTypeId'	 	, 'UINT'	    , 1	 	, '游戏最小配置类型ID'},
	{ 7		, 1		, 'm_reqType'	 			, 'UINT'	    , 1	 	, '请求类型'},
}

CS_C2M_AppointmentMatch_Out_Nty =
{
}

CS_C2M_AppointmentMatch_Init_Req =
{
	{ 1		, 1		, 'm_reqType'	 	, 'UINT'	    , 1	 	, '请求类型'},
}

-- 只在初始化消息或人数请求返回delta时间过后再请求
CS_M2C_AppointmentMatch_SignUpdate_Req =
{
}

CS_M2C_AppointmentMatch_SignUpdate_Ack =
{
	{ 2		, 1		, 'm_nNumCandidates'		, 'UINT'		, 1		, '1:当前报名人数 2:参赛人数'},
}

CS_C2M_AppointmentMatch_SignUp_Req =
{
	{ 1		, 1		, 'm_nOprate'			, 'UBYTE'		, 1		, '操作类型[1]报名[0]取消报名'},
	{ 2		, 1		, 'm_nOption'			, 'UBYTE'		, 1		, '报名种类[0]免费[1|2|3]收费'},
}

CS_M2C_AppointmentMatch_SignUp_Ack =
{
	{ 1		, 1		, 'm_nOprate'			, 'UBYTE'		, 1		, '操作类型[1]报名[0]取消报名'},
	{ 2		, 1		, 'm_nOpResult'			, 'UBYTE'		, 1		, '操作结果[0]失败[1]成功'},
}

--CS_C2M_AppointmentMatch_Update_SignNum_Req =
--{
--}

--CS_M2C_AppointmentMatch_Update_SignNum_Ack =
--{
--	{ 1		, 1		, 'm_nNumCandidates'		, 'UINT'		, 1		, '当前报名人数'},
--}

CS_M2C_AppointmentMatch_Begin_Nty =
{
	{ 1		, 1		, 'm_nNumCandidates'		, 'UINT'		, 1		, '参赛人数'},
	{ 2		, 1		, 'm_gameAtomTypeId'	 	, 'UINT'	    , 1	 	, '游戏最小配置类型ID'},
}

CS_M2C_AppointmentMatch_Result_Nty =
{
	{ 1		, 1		, 'm_nCoin'					, 'UINT'					, 1		, '奖励金币数量'},
	{ 2		, 1		, 'm_nDiamond'				, 'UINT'					, 1		, '奖励钻石数量'},
	{ 3		, 1		, 'm_arrItems'				, 'PstMatchRewardItem'		, 1024	, '奖励道具数组'},
	{ 4		, 1		, 'm_nRank'					, 'UINT'					, 1		, '名次'},
	{ 5		, 1		, 'm_gameAtomTypeId'	 	, 'UINT'	    , 1	 	, '游戏最小配置类型ID'},
}

CS_M2C_AppointmentMatch_RoundBegin_Nty =
{
	{ 1, 1, 'm_nStage'				, 'UINT'	, 1  , '比赛阶段(根据具体配置)'},
	{ 3, 1, 'm_nRound'				, 'UINT'	, 1  , '轮次[1,~)'},
	{ 4, 1, 'm_nGroupID'			, 'UINT'	, 1  , '所属分组ID'},
	{ 5, 1, 'm_nGroupPlayerNum'		, 'UINT'	, 1  , '所属分组人数'},
	{ 6, 1, 'm_nPromotionPlayerNum'	, 'UINT'	, 1  , '当前分组可晋级数'},
	{ 7, 1, 'm_nUpdateOnce'			, 'UINT'	, 1  , '0 播放  1 不播'},
	{ 8, 1, 'm_nStopLimit'			, 'UINT'	, 1  , '截至人数'},
	{ 9, 1, 'm_gameAtomTypeId'	 	, 'UINT'	, 1	 , '游戏最小配置类型ID'},
	{ 10, 1, 'm_score'	 			, 'INT'		, 1	 , '我的积分'},
}

CS_M2C_AppointmentMatch_RoundEndUpdate_Nty =
{
	{ 1		, 1		, 'm_nResult'			, 'UINT'		, 1		, '轮结果[0]阶段结束剩余桌数更新 or [1]晋级 [2]淘汰 [3]阶段结束广播 [4]末尾淘汰显示'},
	{ 2		, 1		, 'm_nRunningTables'	, 'UINT'		, 1		, 'm_nResult:0 正在进行的桌数'},
	{ 3		, 1		, 'm_nRank'				, 'UINT'		, 1		, '排名 大于 0 才有效，有地方会发 0 的'},
	{ 4		, 1		, 'm_gameAtomTypeId'	, 'UINT'		, 1	 	, '游戏最小配置类型ID'},
	{ 5		, 1		, 'm_score'	 			, 'INT'			, 1	 	, '我的积分'},
}

CS_M2C_AppointmentMatch_BeforePlay_Nty =
{
	{ 1, 1		, 'm_cUsers'			, 'PstLandlordAppointmentMatchCharacterData'	, 3, '游戏角色'},
	{ 2, 1		, 'm_iBaseScore'		, 'UINT'										, 1, '游戏底分'},
	{ 3, 1		, 'm_gameAtomTypeId'	, 'UINT'	    , 1	 	, '游戏最小配置类型ID'},
}

CS_M2C_AppointmentMatch_RankUpdate_Nty =
{
	{ 1		, 1		, 'm_nRank'					, 'UINT'		, 1		, '[>0]当前排名'},
	{ 2		, 1		, 'm_nLastMember'			, 'UINT'		, 1		, '剩余玩家数'},
}

CS_C2M_AppointmentMatch_GameAddr_Req =
{
	{ 1, 1, 'm_gameAtomTypeId'	 	, 'UINT'	, 1	 , '游戏最小配置类型ID'},
}

CS_M2C_AppointmentMatch_GameAddr_Ack =
{
	{ 1, 	1, 'm_gameAtomTypeId'	 	, 'UINT'		, 1	 	, '游戏最小配置类型ID'},
	{ 2, 	1, 'm_domainName'			, 'STRING'		, 1		, '游戏地主'},
	{ 3, 	1, 'm_port'					, 'UINT'		, 1		, '端口'},
	
}

