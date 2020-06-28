-------------------------------------------------------------------------------------------
if not LUA_VERSION or LUA_VERSION ~= "5.3" then
	module(..., package.seeall)
end
require(g_protocolPath.."Peasants_vs_Landlord/protoID")


-- 公共结构定义文件注册
netLoaderCfg_Templates_common = {
	g_protocolPath.."Peasants_vs_Landlord/pubStTemp",
}

-- 协议定义文件注册
netLoaderCfg_Templates	=	{	
	g_protocolPath.."Peasants_vs_Landlord/HuanLeLand",
}

-------------------------注册协议-----------------------------
-- 公共结构协议注册
netLoaderCfg_Regs_common = 
{
	-- PstRunPlayerInfo 			= 	PSTID_RUNPLAYERINFO,
	-- PstRunUserEndInfo 			= 	PSTID_RUNUSERENDINFO,
	-- PstRunBalanceData			=	PSTID_RUNBALANCEDATA,
	-- PstRunSyncData				=	PSTID_RUNSYNCDATA,
	-- PstRunCombatGain		    =	PSTID_RUNCOMBATGAIN,
	-- PstUserCard                  =	PSTID_RUNUSERCARD,
	-- -- 
 --    PstRunResultData            =	PSTID_RUNRESULTDATA,
	-- PstRunGameRecordInfo        =	PSTID_RUNGAMERECORDINFO,
	-- PstRunUserRecordInfo        =	PSTID_RUNUSERRECORDINFO,
	-- PstMatchUser                =	PSTID_RUNMATCHUSER,
	-- PstMatchBeforeGameUser      =	PSTID_RUNMATCHBEFOREGAMEUSER,
 --    PstCalcDataEx               =	PSTID_RUNMATCHCALCDATAEX,
	-- PstCalculateAccountData     =	PSTID_RUNMATCHCALCULATEACCOUNTDATA,
	-- PstGameDataEx               =	PSTID_RUNMATCHGAMEDATAEX,
	-- --
	-- PstChairAttr		=	PSTID_CHAIRATTR,
	-- PstTableAttr		=	PSTID_TABLEATTR,
	-- PstRoomAttr			=	PSTID_ROOMATTR,
	-- PstChairUser		=	PSTID_CHAIRUSER,
	-- PstHoldSeatAttr			=	PSTID_HOLDSEATATTR,
	-- PstRoomIdAttr			=	PSTID_ROOMIDATTR,
	-- PstFreePlayerAttr		=	PSTID_FREEPLAYERATTR,
	-- PstFreePlayerInOutAttr	=	PSTID_FREEPLAYERINOUTATTR,
	-- PstFreeTodayRankAttr	=	PSTID_FREETODAYRANKATTR,
	-- PstFreeBeforeGameChair	=	PSTID_FREEBEFOREGAMECHAIR,
	-- PstFreeBeforeGameUser	=	PSTID_FREEBEFOREGAMEUSER,
	-- PstMatchBeforeGameChair	=   PSTID_MATCHBEFOREGAMECHAIR,
	-- PstMatchRewardItem 		= PSTID_MATCHREWARDITEM,
	-- PstSysBeforeGameChair	= PSTID_SYSBEFOREGAMECHAIR,
	-- PstSysBeforeGameUser	= PSTID_SYSBEFOREGAMEUSER, 

	PstRunPlayerInfo 			= 	PSTID_RUNPLAYERINFO,
	PstRunUserEndInfo 			= 	PSTID_RUNUSERENDINFO,
	PstRunBalanceData			=	PSTID_RUNBALANCEDATA,
	PstRunSyncData				=	PSTID_RUNSYNCDATA,
	PstRunCombatGain		    =	PSTID_RUNCOMBATGAIN,
	PstUserCard                 =	PSTID_RUNUSERCARD,
    PstRunResultData            =	PSTID_RUNRESULTDATA,
	PstRunGameRecordInfo        =	PSTID_RUNGAMERECORDINFO,
	PstRunUserRecordInfo        =	PSTID_RUNUSERRECORDINFO,
	PstMatchUser                =	PSTID_RUNMATCHUSER,
	PstMatchBeforeGameUser      =	PSTID_RUNMATCHBEFOREGAMEUSER,
    PstCalcDataEx               =	PSTID_RUNMATCHCALCDATAEX,
	PstCalculateAccountData     =	PSTID_RUNMATCHCALCULATEACCOUNTDATA,
	PstGameDataEx               =	PSTID_RUNMATCHGAMEDATAEX,
}

-- 协议注册
netLoaderCfg_Regs	=	
{
	CS_G2C_Run_In_Wait_Nty 		= 	CS_G2C_RUN_IN_WAIT_NTY,
    CS_G2C_Run_In_PlayGame_Nty  =   CS_G2C_RUN_IN_PLAYGAME_NTY,
    CS_G2C_Run_Begin_Nty		=	CS_G2C_RUN_BEGIN_NTY,
    CS_G2C_Run_Action_Nty			=	CS_G2C_RUN_ACTION_NTY,
    CS_G2C_Run_Pass_Nty			    =	CS_G2C_RUN_PASS_NTY,
    CS_G2C_Run_GameEnd_Nty			=	CS_G2C_RUN_GAMEEND_NTY,
    CS_C2G_Run_OutCard_Req			=	CS_C2G_RUN_OUTCARD_REQ,
	CS_G2C_Run_OutCard_Ack		    =	CS_G2C_RUN_OUTCARD_ACK,
    CS_G2C_Run_OutCard_Nty			=	CS_G2C_RUN_OUTCARD_NTY,
    CS_G2C_Run_Bomb_Nty			    =	CS_G2C_RUN_BOMB_NTY,
    SS_M2G_Run_GameCreate_Req		=	SS_M2G_RUN_GAMECREATE_REQ,
    SS_G2M_Run_GameCreate_Ack		=	SS_G2M_RUN_GAMECREATE_ACK,
    SS_M2G_Run_GameResult_Nty		=	SS_M2G_RUN_GAMERESULT_NTY,
    CS_M2C_Run_Exit_Nty			    =	CS_M2C_RUN_EXIT_NTY,
    CS_G2C_Run_CombatGains_Nty		=	CS_G2C_RUN_COMBATGAINS_NTY,
    CS_G2C_Run_Enter_Nty			=	CS_G2C_RUN_ENTER_NTY,
    CS_G2C_Run_Leave_Nty			=	CS_G2C_RUN_LEAVE_NTY,
    CS_G2C_Run_Kick_Nty			    =	CS_G2C_RUN_KICK_NTY,
	CS_G2C_Run_Warning_Nty			=	CS_G2C_RUN_WARNING_NTY,
	CS_G2C_Run_Indemnity_Nty		=	CS_G2C_RUN_INDEMNITY_NTY,
	CS_C2G_Run_AutoControl_Req		=	CS_C2G_RUN_AUTOCONTROL_REQ,
	CS_G2C_Run_AutoControl_Nty		=	CS_G2C_RUN_AUTOCONTROL_NTY,

	CS_C2G_Run_Ready_Req		    =	CS_C2G_RUN_READY_REQ,
    CS_G2C_Run_Ready_Ack		    =	CS_G2C_RUN_READY_ACK,
    CS_C2G_Run_Exit_Game_Req		=	CS_C2M_RUN_EXIT_GAME_REQ,
    CS_G2C_Run_Exit_Game_Ack		=	CS_M2C_RUN_EXIT_GAME_ACK,
    SS_G2M_Run_Game_Start_Nty		=	SS_G2M_RUN_GAMESTART_NTY,
    SS_G2M_Run_Game_End_Nty		    =	SS_G2M_RUN_GAMEEND_NTY,
	CS_C2G_Run_Continue_Req     	=	CS_C2G_RUN_CONTINUEGAME_REQ,
    CS_M2C_Run_ContinueGame_Ack     =	CS_M2C_RUN_CONTINUEGAME_ACK,

    CS_C2M_Run_Match_Sign_Up_Req    	=	CS_C2M_RUN_MATCH_SIGN_UP_REQ,
	CS_C2M_Run_Match_Sign_Up_Ack    	=	CS_M2C_RUN_MATCH_SIGN_UP_ACK,
	CS_C2M_Run_Match_Cancel_Sign_Up_Req    =	CS_C2M_RUN_MATCH_CANCEL_SIGN_UP_REQ,
	CS_M2C_Run_Match_Cancel_Sign_Up_Ack    =	CS_M2C_RUN_MATCH_CANCEL_SIGN_UP_ACK,
	CS_M2C_Run_Match_Sign_Up_Num_Nty       =	CS_M2C_RUN_MATCH_SIGN_UP_NUM_NTY,
	SS_G2M_Run_Match_Result_Nty            =	SS_G2M_RUN_MATCH_RESULT_NTY,
	CS_M2C_Run_Match_Rank_Nty              =	CS_M2C_RUN_MATCH_RANK_NTY,
	CS_M2C_Run_Match_Result_Nty            =	CS_M2C_RUN_MATCH_RESULT_NTY,
	CS_M2C_Run_Match_Before_Game_Nty       =	CS_M2C_RUN_MATCH_BEFORE_GAME_NTY,
	CS_M2C_Run_Match_Enter_Nty             =	CS_M2C_RUN_MATCH_ENTER_NTY,
	CS_M2G_Run_Match_Kick_Nty              =	SS_M2G_RUN_MATCH_KICK_NTY,
	SS_M2G_Run_Match_Create_Game_Req       =	SS_M2G_RUN_MATCH_CREATE_GAME_REQ,
	CS_C2M_Run_Match_Exit_Game_Req         =	CS_C2M_RUN_MATCH_EXIT_GAME_REQ,
	CS_M2C_Run_Match_Exit_Game_Ack		   =	CS_M2C_RUN_MATCH_EXIT_GAME_ACK,
}

if LUA_VERSION and LUA_VERSION == "5.3" then
	return netLoaderCfg_Regs
end
