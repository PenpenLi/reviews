----------------------------------------------------------------------------------------------------
require("app.hall.config.code.DataUtil")

BEGIN_MODULEID("跑得快场景协议",201900) --[201900 -- 202000)
PSTID_RUNPLAYERINFO       			=	GENPID(1, '历史记录')
PSTID_RUNUSERENDINFO        		=	GENPID(2, '主界面玩家信息') 
PSTID_RUNBALANCEDATA        		=	GENPID(3, '其他玩家信息')
PSTID_RUNSYNCDATA        			=	GENPID(4, '游戏同步信息')
PSTID_RUNCOMBATGAIN				    =	GENPID(5, '战绩信息')
PSTID_RUNUSERCARD                   =	GENPID(6, '玩家手牌')
PSTID_RUNRESULTDATA                 =	GENPID(7, '玩家结算信息')
PSTID_RUNMATCHUSER                  =	GENPID(8, '比赛场玩家信息')
PSTID_RUNMATCHBEFOREGAMEUSER        =	GENPID(9, '比赛场玩家场景信息')
PSTID_RUNMATCHCALCDATAEX            =	GENPID(10, '比赛场玩家单局输赢信息')
PSTID_RUNMATCHCALCULATEACCOUNTDATA  =	GENPID(11, '比赛场玩家输赢信息')
PSTID_RUNMATCHGAMEDATAEX            =	GENPID(12, '比赛场玩家初始信息')


BEGIN_MODULEID("跑得快游戏协议",202000) --[202000 -- 202100)
CS_G2C_RUN_IN_WAIT_NTY			=	GENPID(1, '玩家进入是等待状态时下发信息')
--CS_G2C_RUN_IN_SENDCARD_NTY		=	GENPID(2, '玩家进入是发牌状态时下发信息')
CS_G2C_RUN_IN_PLAYGAME_NTY		=	GENPID(2, '玩家进入是游戏状态时下发信息')
CS_G2C_RUN_BEGIN_NTY			=	GENPID(3, '通知玩家游戏进入开始状态')
CS_G2C_RUN_ACTION_NTY			=	GENPID(6, '通知玩家出牌')
CS_G2C_RUN_PASS_NTY			    =	GENPID(7, '通知玩家过牌')
CS_G2C_RUN_GAMEEND_NTY			=	GENPID(8, '通知玩家游戏结束')

CS_C2G_RUN_OUTCARD_REQ			=	GENPID(9, '玩家出牌请求')
CS_G2C_RUN_OUTCARD_ACK          =	GENPID(10, '玩家出牌响应')
CS_G2C_RUN_OUTCARD_NTY			=	GENPID(11, '玩家出牌通知')

CS_G2C_RUN_BOMB_NTY			    =	GENPID(12, '炸弹结算')

SS_M2G_RUN_GAMECREATE_REQ		=	GENPID(13, '创建游戏对象')
SS_G2M_RUN_GAMECREATE_ACK		=	GENPID(14, '创建游戏对象响应')
SS_M2G_RUN_GAMERESULT_NTY		=	GENPID(15, '游戏结算')

CS_M2C_RUN_EXIT_NTY			    =	GENPID(16, '场景退出通知')
CS_G2C_RUN_COMBATGAINS_NTY		=	GENPID(17, '场景退出通知')
CS_G2C_RUN_ENTER_NTY			=	GENPID(18, '玩家进入游戏广播')
CS_G2C_RUN_LEAVE_NTY			=	GENPID(19, '玩家退出游戏广播')
CS_G2C_RUN_KICK_NTY			    =	GENPID(20, '踢出玩家')
CS_G2C_RUN_WARNING_NTY			=	GENPID(21, '玩家报警')
CS_G2C_RUN_INDEMNITY_NTY		=	GENPID(22, '玩家包赔')
CS_C2G_RUN_AUTOCONTROL_REQ		=	GENPID(23, '托管')
CS_G2C_RUN_AUTOCONTROL_NTY		=	GENPID(24, '托管广播')

CS_C2G_RUN_READY_REQ		=	GENPID(25, '玩家准备')
CS_G2C_RUN_READY_ACK		=	GENPID(26, '玩家准备返回')
CS_C2M_RUN_EXIT_GAME_REQ		=	GENPID(27, '玩家退出游戏')
CS_M2C_RUN_EXIT_GAME_ACK		=	GENPID(28, '玩家退出游戏返回')
SS_G2M_RUN_GAMESTART_NTY		=	GENPID(29, '游戏开局')
SS_G2M_RUN_GAMEEND_NTY		    =	GENPID(30, '游戏结束')
CS_C2G_RUN_CONTINUEGAME_REQ     =	GENPID(31, '游戏继续下一局')
CS_M2C_RUN_CONTINUEGAME_ACK     =	GENPID(32, '游戏继续下一局返回')

--------------------------------------------------------------------------------------------------
-- 跑得快比赛场
CS_C2M_RUN_MATCH_SIGN_UP_REQ	    =	GENPID(51, '玩家报名')
CS_M2C_RUN_MATCH_SIGN_UP_ACK	    =	GENPID(52, '玩家报名返回')
CS_C2M_RUN_MATCH_CANCEL_SIGN_UP_REQ		=	GENPID(53, '玩家取消报名')
CS_M2C_RUN_MATCH_CANCEL_SIGN_UP_ACK		=	GENPID(54, '玩家取消报名返回')

CS_M2C_RUN_MATCH_SIGN_UP_NUM_NTY		=	GENPID(55, '通知报名人数')
SS_G2M_RUN_MATCH_RESULT_NTY             =	GENPID(56, '通知比赛结果')
CS_M2C_RUN_MATCH_RESULT_NTY             =	GENPID(57, '通知比赛结果')
CS_M2C_RUN_MATCH_RANK_NTY				= 	GENPID(58, '实时排名')
CS_M2C_RUN_MATCH_BEFORE_GAME_NTY        = 	GENPID(59, '比赛场开始信息')
CS_M2C_RUN_MATCH_ENTER_NTY              = 	GENPID(60, '比赛场通知消息')
SS_M2G_RUN_MATCH_KICK_NTY               = 	GENPID(61, '比赛场踢出用户')
SS_M2G_RUN_MATCH_CREATE_GAME_REQ	    =	GENPID(62, '比赛场创建游戏')
CS_C2M_RUN_MATCH_EXIT_GAME_REQ	        =	GENPID(63, '比赛场退出游戏')
CS_M2C_RUN_MATCH_EXIT_GAME_ACK          =	GENPID(64, '比赛场退出游戏返回')

--------------------------------------------------------------------------------------------------