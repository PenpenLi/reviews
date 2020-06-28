module(..., package.seeall)


-- 跑得快协议<客户端-服务器>

-- CS_G2C_LandLord_LoginData_Nty		=
-- {
--     { 1     , 1		, 'm_eRoundState'       , 'UINT'		, 1     , '游戏状态[1]等待[2]抢地主[3]游戏中[4]结束[5]翻倍[6]继续状态'},
--     { 2     , 1		, 'm_nOperateChair'     , 'UINT'		, 1     , 'm_eRoundState(2|3 当前操作的玩家座位号[1-3])'},
--     { 3     , 1		, 'm_vecValue'          , 'INT'			, 3     , 'm_eRoundState(1 等待状态[0|1准备])(2 叫分状态[-1没叫|0不叫|1-3叫分])(3 牌数[1-20])(4 计分)(5 翻倍[0还没叫 1不翻倍 其他数字表示翻的倍数])(6 是否继续[0没点继续 1点了])'},
--     { 4     , 1		, 'm_nOperateTime'      , 'UINT'		, 1     , 'm_eRoundState(1|2|3 操作倒计时(单位：秒)'},
--     { 5     , 1		, 'm_nLastOutChair'     , 'UINT'		, 1    	, 'm_eRoundState(3 上一手牌玩家[0第一手|1-3])'},
--     { 6     , 1		, 'm_vecLastOutPokers'  , 'UINT'		, 20    , 'm_eRoundState(3 上一手牌[0-53])'},
--     { 7     , 1		, 'm_nLordChairIdx'     , 'UINT'		, 1     , 'm_eRoundState(3 地主座位号[1-3])'},
--     { 8     , 1		, 'm_nLordBelordCent'   , 'UINT'		, 1     , 'm_eRoundState(3 地主叫分[1-3])'},
--     { 9     , 1		, 'm_nTotalMultiple'    , 'UINT'		, 1     , 'm_eRoundState(3|4 已产生的总倍数)'},
--     { 10    , 1		, 'm_nBombs'			, 'UINT'		, 1     , 'm_eRoundState(3|4 已产生炸弹个数)'},
-- 	{ 11	, 1		, 'm_bSpring'			, 'UINT'		, 1		, '4 [0]否[1]是'},
--     { 12    , 1		, 'm_vecTrusteeShip'    , 'UINT'		, 3     , 'm_eRoundState(2|3 托管状态[0|1])'},
--     { 13    , 1		, 'm_vecUnderPoker'     , 'UINT'		, 3     , 'm_eRoundState(1|2|3|4 底牌[0-53]黑红花片(3-KA2)小王大王)'},
--     { 14    , 1		, 'm_vec1ChairCards'    , 'UINT'		, 20    , 'm_eRoundState(2|3|4 手牌[0-53]黑红花片(3-KA2)小王大王)'},
--     { 15    , 1		, 'm_vec2ChairCards'    , 'UINT'		, 20    , 'm_eRoundState(2|3|4 手牌[0-53]黑红花片(3-KA2)小王大王)'},
--     { 16    , 1		, 'm_vec3ChairCards'    , 'UINT'		, 20    , 'm_eRoundState(2|3|4 手牌[0-53]黑红花片(3-KA2)小王大王)'},
--     { 17    , 1		, 'm_vecOutCards'       , 'UINT'		, 51    , 'm_eRoundState(3 已经打出去的牌[0-53]黑红花片(3-KA2)小王大王)'},
-- 	{ 18    , 1		, 'm_vecDouStatus'    	, 'UINT'		, 3     , '是否加倍 0 1 不加倍 2 加倍'},
-- }

-- CS_G2C_LandLord_ReconnectData_Nty		=
-- {
--    { 1     , 1		, 'm_eRoundState'       ,		'UBYTE'		, 1     , '游戏状态[1]等待[2]抢地主[3]游戏中[4]结束'},
--    { 2     , 1		, 'm_nOperateChair'     ,		'UBYTE'		, 1     , 'm_eRoundState(2|3 当前操作的玩家座位号[1-3])'},
--    { 3     , 1		, 'm_vecValue'          , 		'BYTE'		, 3     , 'm_eRoundState(1 等待状态[0|1准备])(2 叫分状态[-1没叫|0不叫|1-3叫分])(3 牌数[1-20])'},
--    { 4     , 1		, 'm_nOperateTime'      ,		'UBYTE'		, 1     , 'm_eRoundState(1|2|3 操作倒计时(单位：秒)'},
--    { 5     , 1		, 'm_nLastOutChair'     ,		'UBYTE'		, 1    	, 'm_eRoundState(3 上一手牌玩家[0第一手|1-3])'},
--    { 6     , 1		, 'm_vecLastOutPokers'  ,		'UBYTE'		, 20    , 'm_eRoundState(3 上一手牌[0-53])'},
--    { 7     , 1		, 'm_nLordChairIdx'     ,		'UBYTE'		, 1     , 'm_eRoundState(3 地主座位号[1-3])'},
--    { 8     , 1		, 'm_nLordBelordCent'   ,		'UBYTE'		, 1     , 'm_eRoundState(3 地主叫分[1-3])'},
--    { 9     , 1		, 'm_nBombMultiple'     ,		'UBYTE'		, 1     , 'm_eRoundState(3 炸弹倍数)'},
--    { 10    , 1		, 'm_vecTrusteeShip'    , 		'UBYTE'		, 3     , 'm_eRoundState(3 托管状态[0|1])'},
--    { 11    , 1		, 'm_vecUnderPoker'     , 		'UBYTE'		, 3     , 'm_eRoundState(1|2|3 底牌[0-53]黑红花片(3-KA2)小王大王)'},
--    { 12    , 1		, 'm_vec1ChairCards'    , 		'UBYTE'		, 20    , 'm_eRoundState(2|3|4 手牌[0-53]黑红花片(3-KA2)小王大王)'},
--    { 13    , 1		, 'm_vec2ChairCards'    , 		'UBYTE'		, 20    , 'm_eRoundState(2|3|4 手牌[0-53]黑红花片(3-KA2)小王大王)'},
--    { 14    , 1		, 'm_vec3ChairCards'    , 		'UBYTE'		, 20    , 'm_eRoundState(2|3|4 手牌[0-53]黑红花片(3-KA2)小王大王)'},
--    { 15    , 1		, 'm_vecOutCards'       , 		'UBYTE'		, 51    , 'm_eRoundState(3 已经打出去的牌[0-53]黑红花片(3-KA2)小王大王)'},
-- }

-- CS_C2G_LandLord_AutoControl_Nty		=
-- {
-- 	{ 1		, 1		, 'm_bOpenOrClose'		, 'UBYTE'	, 1	, '[0]关[1]开'},
-- }

-- CS_G2C_LandLord_AutoControl_Nty		=
-- {
-- 	{ 1		, 1		, 'm_nPosition'			, 'UBYTE'	, 1	, '托管座位号[1-3]'},
-- 	{ 2		, 1		, 'm_bOpenOrClose'		, 'UBYTE'	, 1	, '[0]关[1]开'},
-- }

-- CS_C2G_LandLord_Ready_Nty		=
-- {
-- }

-- CS_G2C_LandLord_Ready_Nty		=
-- {
-- 	{ 1		, 1		, 'm_nPosition'		, 'UBYTE'	, 1	, '已准备的座位号[1-3]'},
-- }

-- CS_G2C_LandLord_Begin_Nty		=
-- {
-- 	{ 1		, 1     , 'm_nBeginPosition'	,	'UBYTE' ,	1	, '开始叫分座位号[1-3]'},
-- 	{ 2		, 1		, 'm_vecGetCards'		, 	'UINT' ,	17	, '[0-53]黑红花片(3-KA2)小王大王'},
	
-- 	{ 3		, 1		, 'm_nCurRound'			,		'UINT'		, 1		, '当前轮数'},
-- 	{ 4		, 1		, 'm_nTotalRound'		,		'UINT'		, 1		, '总轮数'},
-- }

-- CS_C2G_LandLord_BeLord_Nty		=
-- {
-- 	{ 1		, 1		, 'm_nCent'				, 'UBYTE'	, 1	, '[0]不叫[1]一分[2]二分[3]三分 欢乐跑得快[0]不叫(抢) [1]叫(抢)'},
-- }

-- CS_G2C_LandLord_BeLord_Nty		=
-- {
-- 	{ 1		, 1		, 'm_nCallPosition'		, 'UBYTE'	, 1	, '叫分座位号[1-3]'},
-- 	{ 2		, 1		, 'm_nCent'				, 'UBYTE'	, 1	, '[0]不叫[1]一分[2]二分[3]三分 欢乐表示倍数'},
-- 	{ 3		, 1		, 'm_nNextPosition'		, 'UBYTE'	, 1	, '下一个叫分座位号[1-3]'},
-- 	{ 4		, 1		, 'm_nNextTime'			, 'UINT'	, 1	, '下个操作的时间(秒) 欢乐跑得快'},
-- 	{ 5		, 1		, 'm_nCallOpt'			, 'UINT'	, 1	, '欢乐 操作标记 0 不叫 1 叫 2 不抢 3 抢'},
-- }

-- CS_G2C_LandLord_BeLordResult_Nty		=
-- {
-- 	{ 1		, 1		, 'm_nLordPosition'		, 'UBYTE'	, 1	, '地主座位号[1-3]'},
-- 	{ 2		, 1		, 'm_vecCards'			, 'UINT'	, 3	, '[0-53]黑红花片(3-KA2)小王大王'},
-- 	{ 3		, 1		, 'm_nIsDouOpt'			, 'UINT'	, 1	, '是否有加倍操作'},
-- 	{ 4		, 1		, 'm_nLandCent'			, 'UINT'	, 1	, '地主分数 欢乐也是用这个表示倍数'},
-- 	{ 5		, 1		, 'm_nIsLandOpen'		, 'UINT'	, 1	, '是否有地主明牌操作 欢乐跑得快'},
-- 	{ 6		, 1		, 'm_nNextTime'			, 'UINT'	, 1	, '下个操作的时间(秒)'},
-- 	{ 7		, 1		, 'm_nLastCardsMul'		, 'UINT'	, 1 , '底牌倍数'},
-- }

-- CS_C2G_LandLord_Out_Nty		=
-- {
-- 	{ 1		, 1		, 'm_vecOutCards'		, 'UINT'		, 20	, '[0-53]黑红花片(3-KA2)小王大王'},
-- }

-- CS_G2C_LandLord_Out_Nty		=
-- {
-- 	{ 1		, 1		, 'm_nPosition'			, 'UBYTE'		, 1		, '出牌座位号[1-3]'},
-- 	{ 2		, 1		, 'm_vecOutCards'		, 'UINT'		, 20	, '[0-53]黑红花片(3-KA2)小王大王'},
-- 	{ 3		, 1		, 'm_nNextPosition'		, 'UBYTE'		, 1	    , '下一个出牌座位号[1-3]'},
-- 	{ 4		, 1		, 'm_nNextTime'			, 'UINT'		, 1		, '下个出牌的时间'},
-- 	{ 5		, 1		, 'm_nTotalDou'			, 'UINT'		, 1		, '翻倍数'},
-- 	{ 6		, 1		, 'm_nCardsNum'			, 'UINT'		, 1		, '剩余牌个数'},
-- 	{ 7		, 1		, 'm_nPunTime'			, 'UINT'		, 1		, '惩罚时间，默认 0 s, '},
--     { 8		, 1		, 'm_outAccountId'		, 'UINT'		, 1		, '出牌账户id'},
-- 	{ 9		, 1		, 'm_result'			, 'INT'			, 1		, '结果, 0：成功, -x:失败'},
-- }

-- CS_G2C_LandLord_Result_Nty		=
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
-- 	{ 11	, 1		, 'm_nLandCent'			,		'UINT'		, 1		, '地主叫分'},
-- 	{ 12	, 1		, 'm_nEndPos'			,		'UINT'		, 1		, '最后一手出牌的位置 1 2 3'},
	
-- }

-- -- 加倍操作
-- CS_C2G_LandLord_Double_Req		=
-- {
-- 	{ 1		, 1		, 'm_nDou'				, 'UINT'	, 1	, '[0]不加倍[1]加倍'},
-- }

-- CS_G2C_LandLord_Double_Nty		=
-- {
-- 	{ 1		, 1		, 'm_nPos'				, 'UINT'	, 1	, '叫分座位号[1-3]'},
-- 	{ 2		, 1		, 'm_nDou'				, 'UINT'	, 1	, '[0]不加倍[1]加倍'},
-- 	{ 3		, 1		, 'm_nOptNum'			, 'UINT'	, 1	, '已经叫了的人数'},
-- 	{ 4		, 1		, 'm_nTotalDou'			, 'UINT'	, 1	, '自己的总倍数'},
-- }

-- -- 下一轮的继续操作
-- CS_C2G_LandLord_CarryOn_Req		=
-- {
-- }

-- CS_G2C_LandLord_CarryOn_Nty		=
-- {
-- 	{ 1		, 1		, 'm_nPosition'		, 'UBYTE'	, 1	, '已继续的座位号[1-3]'},
-- }

-- -- 加倍操作通知(广播)
-- CS_G2C_LandLord_DoubleOpt_Nty	=
-- {
-- 	{ 1		, 1		, 'm_nPosArr'		, 'UINT'	, 3	, '座位号[1-3]'},
-- 	{ 2		, 1		, 'm_nTime'			, 'UINT'	, 1	, '操作时间'},
-- }
