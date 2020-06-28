local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local cmd = {}
cmd.RES_PATH = "game/yule/qpby/res/"
cmd.VERSION = appdf.VersionValue(6, 7, 0, 1)
cmd.KIND_ID = 413
cmd.GAME_PLAYER = 4
cmd.SERVER_LEN = 32
cmd.INT_MAX = 2147483647
cmd.Event_LoadingFish = "Event_LoadingFinish"
cmd.Event_FishCreate = "Event_FishCreate"
cmd.SCREENWIDTH = 1152.0
cmd.SCREENHEIGTH = 720.0
cmd.FISHMOVEBILI = 0.8
cmd.Small_0 = "sound_res/small_0.wav"
cmd.Small_1 = "sound_res/small_1.wav"
cmd.Small_2 = "sound_res/small_2.wav"
cmd.Small_3 = "sound_res/small_3.wav"
cmd.Small_4 = "sound_res/small_4.wav"
cmd.Small_5 = "sound_res/small_5.wav"
cmd.Big_7 = "sound_res/big_7.wav"
cmd.Big_8 = "sound_res/big_8.wav"
cmd.Big_9 = "sound_res/big_9.wav"
cmd.Big_10 = "sound_res/big_10.wav"
cmd.Big_11 = "sound_res/big_11.wav"
cmd.Big_12 = "sound_res/big_12.wav"
cmd.Big_13 = "sound_res/big_13.wav"
cmd.Big_14 = "sound_res/big_14.wav"
cmd.Big_15 = "sound_res/big_15.wav"
cmd.Big_16 = "sound_res/big_16.wav"
cmd.Beauty_0 = "sound_res/beauty_0.wav"
cmd.Beauty_1 = "sound_res/beauty_1.wav"
cmd.Beauty_2 = "sound_res/beauty_2.wav"
cmd.Beauty_3 = "sound_res/beauty_3.wav"
cmd.Load_Back = "sound_res/LOAD_BACK.mp3"
cmd.Music_Back_1 = "sound_res/MUSIC_BACK_01.mp3"
cmd.Music_Back_2 = "sound_res/MUSIC_BACK_02.mp3"
cmd.Music_Back_3 = "sound_res/MUSIC_BACK_03.mp3"
cmd.Change_Scene = "sound_res/CHANGE_SCENE.wav"
cmd.CoinAnimation = "sound_res/CoinAnimation.wav"
cmd.Coinfly = "sound_res/coinfly.wav"
cmd.Fish_Special = "sound_res/fish_special.wav"
cmd.Special_Shoot = "sound_res/special_shoot.wav"
cmd.Combo = "sound_res/combo.wav"
cmd.Shell_8 = "sound_res/SHELL_8.wav"
cmd.Small_Begin = "sound_res/SMALL_BEGIN.wav"
cmd.SmashFail = "sound_res/SmashFail.wav"
cmd.CoinLightMove = "sound_res/CoinLightMove.wav"
cmd.Prop_armour_piercing = "sound_res/PROP_ARMOUR_PIERCING.wav"
cmd.SWITCHING_RUN = "sound_res/SWITCHING_RUN.wav"
cmd.bingo = "sound_res/bingo.wav"
cmd.FishType_XiaoHuangCiYu = 0
cmd.FishType_XiaoCaoYu = 1
cmd.FishType_ReDaiHuangYu = 2
cmd.FishType_DaYanJinYu = 3
cmd.FishType_ReDaiZiYu = 4
cmd.FishType_XiaoChouYu = 5
cmd.FishType_HeTun = 6
cmd.FishType_ShiTouYu = 7
cmd.FishType_DengLongYu = 8
cmd.FishType_WuGui = 9
cmd.FishType_ShengXianYu = 10
cmd.FishType_HuDieYu = 11
cmd.FishType_LingDangYu = 12
cmd.FishType_JianYu = 13
cmd.FishType_MoGuiYu = 14
cmd.FishType_DaBaiSha = 15
cmd.FishType_DaJinSha = 16
cmd.FishType_JuXingHuangJinSha = 17
cmd.FishType_JinJing = 18
cmd.FishType_JinLong = 19
cmd.FishType_QiE = 20
cmd.FishType_LiKui = 21
cmd.FishType_ZhongYiTang = 22
cmd.FishType_ShuiHuZhuan = 23
cmd.FishType_QuanPingZhadan = 24
cmd.FishType_BaoXiang = 25
cmd.FishType_ShanHu = 26
cmd.FishType_YuanBao = 27
cmd.FishType_HuoShan = 28
cmd.FishType_General_Max = 22
cmd.FishType_Normal_Max = 25
cmd.FishType_Max = 27
cmd.FishType_Small_Max = 9
cmd.FishType_Moderate_Max = 15
cmd.FishType_Moderate_Big_Max = 18
cmd.FishType_Big_Max = 25
cmd.FishType_Invalid = -1
cmd.FISH_KING_MAX = 7
cmd.FISH_NORMAL_MAX = 18
cmd.FISH_ALL_COUNT = 20
cmd.SPECIAL_FISH_BOMB = 0
cmd.SPECIAL_FISH_CRAB = 1
cmd.SPECIAL_FISH_MAX = 2
cmd.MULTIPLE_MAX_INDEX = 6
cmd.S_TOP_LEFT = 0
cmd.S_TOP_CENTER = 1
cmd.S_TOP_RIGHT = 2
cmd.S_BOTTOM_LEFT = 3
cmd.S_BOTTOM_CENTER = 4
cmd.S_BOTTOM_RIGHT = 5
cmd.C_TOP_LEFT = 0
cmd.C_TOP_CENTER = 1
cmd.C_TOP_RIGHT = 2
cmd.C_BOTTOM_LEFT = 3
cmd.C_BOTTOM_CENTER = 4
cmd.C_BOTTOM_RIGHT = 5
cmd.DEFAULE_WIDTH = 1280
cmd.DEFAULE_HEIGHT = 800
cmd.OBLIGATE_LENGTH = 300
cmd.CAPTION_TOP_SIZE = 25
cmd.CAPTION_BOTTOM_SIZE = 40
cmd.BULLET_ONE = 0
cmd.BULLET_TWO = 1
cmd.BULLET_THREE = 2
cmd.BULLET_FOUR = 3
cmd.BULLET_FIVE = 4
cmd.BULLET_SIX = 5
cmd.BULLET_SEVEN = 6
cmd.BULLET_EIGHT = 7
cmd.BULLET_MAX = 8
cmd.BEZIER_POINT_MAX = 8
cmd.QIAN_PAO_BULLET = 1
cmd.PlayChair_Max = 6
cmd.PlayChair_Invalid = 0xffff
cmd.PlayName_Len = 32
cmd.QianPao_Bullet = 1
cmd.Multiple_Max = 6
cmd.Tag_Fish = 10
cmd.Tag_Bullet = 11
cmd.Tag_Laser = 12
cmd.Fish_MOVE_TYPE_NUM = 25
cmd.Fish_DEAD_TYPE_NUM = 25
cmd.BomNormal = 0
cmd.BomSameTye = 1
cmd.BomThreeTye = 2
cmd.BomForuTye = 3
cmd.BomSnakHead = 4
cmd.BomSnakBody = 5
cmd.BomSnakTail = 6
cmd.TAG_START = 1
local enumScoreType = {"EST_Cold", "EST_YuanBao", "EST_Laser", "EST_Speed", "EST_Gift", "EST_NULL"}
cmd.SupplyType = ExternalFun.declarEnumWithTable(0, enumScoreType)
local enumRoomType = {"ERT_Unknown", "ERT_QianPao", "ERT_Moni"}
cmd.RoomType = ExternalFun.declarEnumWithTable(0, enumRoomType)
local enumCannonType = {"Normal_Cannon", "Bignet_Cannon", "Special_Cannon", "Laser_Cannon", "Laser_Shooting"}
cmd.CannonType = ExternalFun.declarEnumWithTable(0, enumCannonType)
local enumPropObjectType = {"POT_NULL", "POT_ATTACK", "POT_DEFENSE", "POT_BULLET"}
cmd.PropObjectType = ExternalFun.declarEnumWithTable(0, enumPropObjectType)
cmd.FishType = {
    FishType_XiaoHuangCiYu = 0,
    FishType_XiaoCaoYu = 1,
    FishType_ReDaiHuangYu = 2,
    FishType_DaYanJinYu = 3,
    FishType_ReDaiZiYu = 4,
    FishType_XiaoChouYu = 5,
    FishType_HeTun = 6,
    FishType_ShiTouYu = 7,
    FishType_DengLongYu = 8,
    FishType_WuGui = 9,
    FishType_ShengXianYu = 10,
    FishType_HuDieYu = 11,
    FishType_LingDangYu = 12,
    FishType_JianYu = 13,
    FishType_MoGuiYu = 14,
    FishType_DaBaiSha = 15,
    FishType_DaJinSha = 16,
    FishType_ShuangTouQiEn = 17,
    FishType_JuXingHuangJinSha = 18,
    FishType_JinLong = 19,
    FishType_LiKui = 20,
    FishType_ShuiHuZhuan = 21,
    FishType_ZhongYiTang = 22,
    FishType_BaoZhaFeiBiao = 23,
    FishType_BaoXiang = 26,
    FishType_YuanBao = 27,
    FishType_General_Max = 21,
    FishType_Normal_Max = 24,
    FishType_Max = 26,
    FishType_Small_Max = 9,
    FishType_Moderate_Max = 15,
    FishType_Moderate_Big_Max = 18,
    FishType_Big_Max = 24,
    FishType_Invalid = -1
}
local enumFishState = {"FishState_Normal", "FishState_King", "FishState_Killer", "FishState_Aquatic"}
cmd.FishState = ExternalFun.declarEnumWithTable(0, enumFishState)
cmd.SUB_S_OVER = 106
cmd.SUB_S_DELAY_BEGIN = 107
cmd.SUB_S_DELAY = 108
cmd.SUB_S_BEGIN_LASER = 109
cmd.SUB_S_LASER = 75
cmd.SUB_S_BANK_TAKE = 11
cmd.SUB_S_SPEECH = 112
cmd.SUB_S_SYSTEM = 113
cmd.SUB_S_SUPPLY_TIP = 115
cmd.SUB_S_SUPPLY = 116
cmd.SUB_S_AWARD_TIP = 117
cmd.SUB_S_CONTROL = 118
cmd.SUB_S_UPDATE_GAME = 119
cmd.SUB_S_STAY_FISH = 61
cmd.SUB_S_UPDATE_FISH_SCORE = 121
cmd.SUB_S_FISH_CREATE = 100
cmd.SUB_S_TRACE_POINT = 101
cmd.SUB_S_MULTIPLE = 102
cmd.SUB_S_FIRE = 103
cmd.SUB_S_NOFISH = 104
cmd.SUB_S_FISH_CATCH = 105
cmd.SUB_S_BULLET_ION_TIMEOUT = 106
cmd.SUB_S_LOCK_TIMEOUT = 107
cmd.SUB_S_CATCH_SWEEP_FISH = 108
cmd.SUB_S_CATCH_SWEEP_FISH_RESULT = 109
cmd.SUB_S_EXCHANGE_SCENE = 111
cmd.SUB_S_NoFire = 128
cmd.SUB_S_TimeUp = 129
cmd.SUB_S_Zongfen = 131
cmd.SUB_S_FISH_GROUP_TRACE = 123
cmd.FishMoveData = {
    {k = "ActiveTime", t = "int"},
    {k = "FishType", t = "int"},
    {k = "bomtype", t = "int"},
    {k = "PathIndex", t = "int"},
    {k = "Xpos", t = "float"},
    {k = "Ypos", t = "float"},
    {k = "Rolation", t = "float"},
    {k = "Speed", t = "float"},
    {k = "MoveTime", t = "int"},
    {k = "CurrPathindex", t = "int"},
    {k = "FishId", t = "int"},
    {k = "RandScore", t = "int"}
}
cmd.CDoulbePoint = {{k = "x", t = "double"}, {k = "y", t = "double"}}
cmd.ShortPoint = {{k = "x", t = "short"}, {k = "y", t = "short"}}
cmd.tagBezierPoint = {
    {k = "BeginPoint", t = "table", d = cmd.CDoulbePoint},
    {k = "EndPoint", t = "table", d = cmd.CDoulbePoint},
    {k = "KeyOne", t = "table", d = cmd.CDoulbePoint},
    {k = "KeyTwo", t = "table", d = cmd.CDoulbePoint},
    {k = "Time", t = "dword"}
}
cmd.CMD_S_FishCreate = {
    {k = "nFishKey", t = "int"},
    {k = "nFishType", t = "int"},
    {k = "nBezierCount", t = "int"},
    {k = "m_fudaifishtype", t = "int"},
    {k = "m_BuildTime", t = "int"},
    {k = "unCreateTime", t = "int"},
    {k = "nFishState", t = "int"}
}
cmd.CMD_S_FishMissed = {{k = "chair_id", t = "word"}, {k = "bullet_mul", t = "int"}}
cmd.FPoint = {{k = "x", t = "float"}, {k = "y", t = "float"}}
cmd.CMD_S_FishTrace = {
    {k = "init_pos", t = "table", d = cmd.FPoint, l = {5}},
    {k = "init_count", t = "int"},
    {k = "cmd_version", t = "byte"},
    {k = "fish_kind", t = "int"},
    {k = "fish_id", t = "int"},
    {k = "trace_type", t = "int"}
}
cmd.CMD_S_SwitchScene = {
    {k = "scene_kind", t = "int"},
    {k = "fish_count", t = "int"},
    {k = "fish_kind", t = "int", l = {300}},
    {k = "fish_id", t = "int", l = {300}}
}
cmd.CMD_S_GroupFishTrace = {
    {k = "byIndex", t = "byte"},
    {k = "fish_count", t = "int"},
    {k = "fish_kind", t = "int", l = {250}},
    {k = "fish_red_kind", t = "int", l = {5}},
    {k = "fish_id", t = "int", l = {250}}
}
cmd.CMD_S_FishFinish = {{k = "nOffSetTime", t = "dword"}}
cmd.CMD_S_CatchFish = {
    {k = "wChairID", t = "int"},
    {k = "dwFishID", t = "int"},
    {k = "FishKindscore", t = "int"},
    {k = "lFishScore", t = "int"},
    {k = "m_canSuperPao", t = "bool"},
    {k = "dwUserScore", t = "int"},
    {k = "m_IsBaoJi", t = "bool"}
}
cmd.CMD_S_BulletIonTimeout = {{k = "chair_id", t = "word"}}
cmd.CMD_S_CaptureFish = {
    {k = "wChairID", t = "word"},
    {k = "dwFishID", t = "int"},
    {k = "FishKind", t = "int"},
    {k = "bullet_ion", t = "bool"},
    {k = "lFishScore", t = "score"},
    {k = "fish_caijin_score", t = "score"},
    {k = "app", t = "int"}
}
cmd.CMD_S_Fire = {
    {k = "wChairID", t = "int"},
    {k = "fAngle", t = "float"},
    {k = "nBulletKey", t = "int"},
    {k = "byShootCount", t = "bool"},
    {k = "nBulletScore", t = "int"},
    {k = "dwZidanID", t = "int"},
    {k = "PowerPer", t = "float"},
    {k = "sBullet", t = "score"}
}
cmd.CMD_S_UserFire = {
    {k = "bullet_kind", t = "int"},
    {k = "bullet_id", t = "int"},
    {k = "chair_id", t = "word"},
    {k = "android_chairid", t = "word"},
    {k = "angle", t = "float"},
    {k = "bullet_mulriple", t = "int"},
    {k = "lock_fishid", t = "int"},
    {k = "fish_score", t = "score"},
    {k = "wBulletSpeed", t = "float"}
}
cmd.CMD_S_ExchangeFishScore = {
    {k = "chair_id", t = "word"},
    {k = "swap_fish_score", t = "score"},
    {k = "exchange_fish_score", t = "score"}
}
cmd.CMD_S_BulletLimitCount = {{k = "bullet_limit_count", t = "int"}}
cmd.CMD_S_GameConfig = {
    {k = "exchange_ratio_userscore", t = "int"},
    {k = "exchange_ratio_fishscore", t = "int"},
    {k = "exchange_count", t = "int"},
    {k = "min_bullet_multiple", t = "int"},
    {k = "max_bullet_multiple", t = "int"},
    {k = "bomb_range_width", t = "int"},
    {k = "bomb_range_height", t = "int"},
    {k = "bomb_stock", t = "int"},
    {k = "super_bomb_stock", t = "int"},
    {k = "fish_multiple", t = "int", l = {40}},
    {k = "fish_speed", t = "int", l = {40}},
    {k = "fish_bounding_box_width", t = "int", l = {40}},
    {k = "fish_bounding_box_height", t = "int", l = {40}},
    {k = "fish_hit_radius", t = "int", l = {40}},
    {k = "bullet_speed", t = "int", l = {8}},
    {k = "net_radius", t = "int", l = {8}},
    {k = "RobotScoreMin", t = "int"},
    {k = "RobotScoreMax", t = "int"},
    {k = "RobotBankGet", t = "int"},
    {k = "RobotBankGetBanker", t = "int"},
    {k = "RobotBankStoMul", t = "int"}
}
cmd.CMD_S_Supply = {{k = "wChairID", t = "word"}, {k = "lSupplyCount", t = "score"}, {k = "nSupplyType", t = "int"}}
cmd.CMD_S_Multiple = {{k = "wChairID", t = "int"}, {k = "nMultipleIndex", t = "int"}}
cmd.CMD_S_BeginLaser = {{k = "wChairID", t = "word"}, {k = "ptPos", t = "table", d = cmd.ShortPoint}}
cmd.CMD_S_Laser = {{k = "wChairID", t = "int"}, {k = "IsAndroid", t = "bool"}, {k = "fAngle", t = "float"}}
cmd.CMD_S_ChangeSecene = {{k = "cbBackIndex", t = "int"}, {k = "RmoveID", t = "int"}}
cmd.CMD_S_StayFish = {{k = "nFishKey", t = "int"}, {k = "nStayStart", t = "int"}, {k = "nStayTime", t = "int"}}
cmd.CMD_S_SupplyTip = {{k = "wChairID", t = "word"}}
cmd.CMD_S_AwardTip = {
    {k = "wTableID", t = "word"},
    {k = "wChairID", t = "word"},
    {k = "szPlayName", t = "string", s = 32},
    {k = "nFishType", t = "byte"},
    {k = "nFishMultiple", t = "int"},
    {k = "lFishScore", t = "score"},
    {k = "nScoreType", t = "int"}
}
cmd.CMD_S_UpdateGame = {
    {k = "nMultipleValue", t = "int", l = {cmd.Multiple_Max}},
    {
        k = "nFishMultiple",
        t = "int",
        l = {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2}
    },
    {k = "nBulletVelocity", t = "int"},
    {k = "nBulletCoolingTime", t = "int"},
    {k = "nMaxTipCount", t = "int"}
}
cmd.CMD_S_BankTake = {{k = "wChairID", t = "word"}, {k = "lPlayScore", t = "score"}}
cmd.GameScene = {
    {k = "game_version", t = "dword"},
    {k = "fish_score", t = "score", l = {cmd.GAME_PLAYER}},
    {k = "exchange_fish_score", t = "score", l = {cmd.GAME_PLAYER}},
    {k = "MinShoot", t = "int"},
    {k = "MaxShoot", t = "int"},
    {k = "isYuZhen", t = "bool"}
}
cmd.CMD_S_UpdateAllScore = {
    {k = "wChairID", t = "word"},
    {k = "dwFishID", t = "int"},
    {k = "FishKind", t = "int"},
    {k = "bullet_ion", t = "bool"},
    {k = "lFishScore", t = "score"},
    {k = "fish_caijin_score", t = "score"},
    {k = "app", t = "int"}
}
cmd.CMD_S_CatchSweepFish = {
    {k = "wChairID", t = "word"},
    {k = "dwFishID", t = "int"},
    {k = "bullet_mul", t = "int"},
    {k = "byIndex", t = "byte"}
}
cmd.CMD_S_CatchSweepFishResult = {
    {k = "wChairID", t = "word"},
    {k = "dwFishID", t = "int"},
    {k = "fish_score", t = "score"},
    {k = "catch_fish_count", t = "int"},
    {k = "catch_fish_id", t = "int", l = {300}}
}
cmd.FishScore = {2, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 15, 18, 20, 25, 30, 35, 40, 120, 320, 40, 20, 150, 0, 180, 100}
cmd.FishSpeed = {
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    4,
    4,
    4,
    4,
    4,
    3,
    3,
    3,
    2,
    1,
    2,
    3,
    3,
    3,
    4,
    4,
    4,
    4,
    4,
    4,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5
}
cmd.FishCount = {
    10,
    10,
    8,
    8,
    7,
    6,
    6,
    6,
    6,
    6,
    4,
    4,
    4,
    3,
    3,
    3,
    2,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    2,
    2,
    2,
    2,
    2,
    2,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1
}
cmd.CMD_S_UpdateFishScore = {{k = "nFishKey", t = "int"}, {k = "nFishScore", t = "int"}}
cmd.SUB_C_BEGIN_LASER = 104
cmd.SUB_C_LASER = 68
cmd.SUB_C_SPEECH = 106
cmd.SUB_C_MULTIPLE = 64
cmd.SUB_C_CONTROL = 108
cmd.SUB_C_LOCKFISH = 65
cmd.SUB_C_ADDORDOWNSCORE = 101
cmd.SUB_C_FIRE = 102
cmd.SUB_C_CATCH_FISH = 103
cmd.SUB_C_CATCH_SWEEP_FISH = 104
cmd.CMD_C_CatchSweepFish = {
    {k = "wChairID", t = "word"},
    {k = "dwFishID", t = "int"},
    {k = "catch_fish_count", t = "int"},
    {k = "catch_fish_id", t = "int", l = {300}}
}
cmd.PathIndex = {
    {
        {-100, 260, 10000, 2.05, 95, 0.00, 1},
        {-200, 300, 100, 2, 100, 0.01, 1},
        {-200, 300, 50, 2, 20, -0.02, 1},
        {-200, 300, 130, 2, 100, 0.01, 0},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {1300, 260, 95, 2.05, 200, 0.00, 1},
        {-200, 300, 150, 2, 500, 0.01, 0},
        {-200, 300, 100, 2, 20, -0.01, 1},
        {-200, 300, 130, 2, 10000, 0.01, 0},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {620, -100, 130, 2.0, 200, 0.00, 1},
        {-200, 300, 270, 2, 100, 0.01, 0},
        {-200, 300, 300, 2, 20, -0.01, 0},
        {-200, 300, 350, 2, 10000, 0.01, 0},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {-100, 200, 90, 2.0, 300000, 0.00, 1},
        {-200, 300, 270, 2, 100, 0.01, 0},
        {-200, 300, 300, 2, 20, -0.01, 0},
        {-200, 300, 350, 2, 10000, 0.01, 0},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {560, 920, -18, 2.3, 28000, 0.00, 1},
        {-200, 300, 275, 2, 110, 0.001, 1},
        {-200, 300, 360, 2, 1000, 0.00, 0},
        {-200, 300, 320, 2, 10000, 0.01, 1},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {850, 920, 350, 2.1, 300, 0.00, 1},
        {-200, 300, 120, 2, 200, 0.001, 0},
        {-200, 300, 30, 2, 10, 0.00, 1},
        {-200, 300, 310, 2, 10000, 0.01, 1},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {1350, 280, 280, 2, 50, 0.00, 1},
        {-200, 300, 100, 2, 100, 0.01, 1},
        {-200, 300, 50, 2, 20, -0.02, 1},
        {-200, 300, 130, 2, 100, 0.01, 0},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {500, -100, 180, 2.2, 95000, 0.00, 1},
        {-200, 300, 100, 2, 100, 0.01, 0},
        {-200, 300, 100, 2, 20, -0.01, 1},
        {-200, 300, 130, 2, 10000, 0.01, 0},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {-100, 350, 260, 2, 100, 0.00, 0},
        {-200, 300, 260, 2, 100, 0.01, 0},
        {-200, 300, 310, 2, 20, -0.02, 0},
        {-200, 300, 230, 2, 100, 0.01, 1},
        {-200, 300, 290, 2, 1000, 0, 0}
    },
    {
        {600, 920, 185, 2.3, 28000, 0.00, 1},
        {-200, 300, 275, 2, 110, 0.001, 1},
        {-200, 300, 360, 2, 1000, 0.00, 0},
        {-200, 300, 320, 2, 10000, 0.01, 1},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {600, 920, 25, 2.1, 280, 0.00, 1},
        {-200, 300, 275, 2, 120, 0.001, 1},
        {-200, 300, 360, 2, 1000, 0.00, 0},
        {-200, 300, 320, 2, 10000, 0.01, 1},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {1550, 180, 290, 2.1, 50, 0.00, 1},
        {-200, 300, 110, 2, 130, 0.02, 1},
        {-200, 300, 50, 2, 80, -0.03, 1},
        {-200, 300, 130, 2, 120, 0.01, 0},
        {-200, 300, 80, 2, 1000, 0, 1}
    },
    {
        {300, -100, 220, 2.1, 300, 0.00, 1},
        {-200, 300, 130, 2, 10000, 0.01, 1},
        {-200, 300, 100, 2, 20, -0.01, 1},
        {-200, 300, 130, 2, 10000, 0.01, 0},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {750, -100, 215, 2, 300000, 0.00, 1},
        {-200, 280, 275, 2, 11000, 0.001, 1},
        {-200, 300, 360, 2, 1000, 0.00, 0},
        {-200, 300, 320, 2, 10000, 0.01, 1},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {1, -100, 240, 2.2, 95000, 0.00, 1},
        {-200, 300, 100, 2, 100, 0.01, 0},
        {-200, 300, 100, 2, 20, -0.01, 1},
        {-200, 300, 130, 2, 10000, 0.01, 0},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {1352, 150, 100, 2.3, 95000, 0.00, 1},
        {-200, 300, 100, 2, 100, 0.01, 0},
        {-200, 300, 100, 2, 20, -0.01, 1},
        {-200, 300, 130, 2, 10000, 0.01, 0},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {300, -100, 220, 2.2, 95000, 0.00, 1},
        {-200, 300, 100, 2, 100, 0.01, 0},
        {-200, 300, 100, 2, 20, -0.01, 1},
        {-200, 300, 130, 2, 10000, 0.01, 0},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {10, 300, 260, 2.6, 95000, 0.00, 1},
        {-200, 300, 100, 2, 100, 0.01, 0},
        {-200, 300, 100, 2, 20, -0.01, 1},
        {-200, 300, 130, 2, 10000, 0.01, 0},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {450, 920, 330, 2.3, 300, 0.00, 1},
        {-200, 280, 275, 2, 11000, 0.001, 1},
        {-200, 300, 360, 2, 1000, 0.00, 0},
        {-200, 300, 320, 2, 10000, 0.01, 1},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {1300, 420, 285, 2, 300, 0.00, 1},
        {-200, 300, 95, 2, 270, 0.00, 1},
        {-200, 300, 65, 2, 20000, -0.00, 1},
        {-200, 300, 130, 2, 100, 0.01, 0},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {1, 650, 300, 2.6, 95000, 0.00, 1},
        {-200, 300, 100, 2, 100, 0.01, 0},
        {-200, 300, 100, 2, 20, -0.01, 1},
        {-200, 300, 130, 2, 10000, 0.01, 0},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {950, -100, 180, 2.1, 300000, 0.00, 1},
        {-200, 280, 275, 2, 11000, 0.001, 1},
        {-200, 300, 360, 2, 1000, 0.00, 0},
        {-200, 300, 320, 2, 10000, 0.01, 1},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {850, 920, 345, 2, 200, 0.00, 1},
        {-200, 300, 70, 2, 20, 0.01, 0},
        {-200, 300, 140, 2, 30, 0, 0},
        {-200, 300, 280, 2, 420, 0.01, 1},
        {-200, 300, 110, 2, 1000, 0, 0}
    },
    {
        {550, 920, 350, 2.1, 280, 0.00, 1},
        {-200, 300, 260, 2.1, 10000, 0.01, 1},
        {-200, 300, 250, 2, 100, -0.01, 1},
        {-200, 300, 250, 2, 100000, 0.00, 0},
        {-200, 300, 320, 2, 10000, 0.01, 1}
    },
    {
        {1350, 650, 60, 2.6, 95000, 0.00, 1},
        {-200, 300, 100, 2, 100, 0.01, 0},
        {-200, 300, 100, 2, 20, -0.01, 1},
        {-200, 300, 130, 2, 10000, 0.01, 0},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {1000, -200, 150, 1.9, 300000, 0.00, 1},
        {-200, 280, 275, 2, 11000, 0.001, 1},
        {-200, 300, 360, 2, 1000, 0.00, 0},
        {-200, 300, 320, 2, 10000, 0.01, 1},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {1350, 550, 45, 2.1, 95000, 0.00, 1},
        {-200, 300, 100, 2, 100, 0.01, 0},
        {-200, 300, 100, 2, 20, -0.01, 1},
        {-200, 300, 130, 2, 10000, 0.01, 0},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {-100, 250, 260, 2, 100, 0.00, 0},
        {-200, 300, 260, 2, 100, 0.01, 0},
        {-200, 300, 310, 2, 20, -0.02, 0},
        {-200, 300, 230, 2, 100, 0.01, 1},
        {-200, 300, 290, 2, 1000, 0, 0}
    },
    {
        {1300, 560, 80, 2.5, 95000, 0.00, 1},
        {-200, 300, 100, 2, 100, 0.01, 0},
        {-200, 300, 100, 2, 20, -0.01, 1},
        {-200, 300, 130, 2, 10000, 0.01, 0},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {800, -100, 190, 2.3, 180, 0, 1},
        {-200, 280, 120, 2, 50, 0, 1},
        {-200, 300, 35, 2, 300, 0.00, 1},
        {-200, 300, 130, 2, 100000, 0.001, 1},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {600, 920, 30, 2.3, 28000, 0.00, 1},
        {-200, 300, 275, 2, 110, 0.001, 1},
        {-200, 300, 360, 2, 1000, 0.00, 0},
        {-200, 300, 320, 2, 10000, 0.01, 1},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {1100, -200, 140, 2.2, 250, 0.00, 1},
        {-200, 280, 90, 2, 80, -0.001, 1},
        {-200, 300, 270, 2, 100000, 0.01, 0},
        {-200, 300, 320, 2, 10000, 0.01, 1},
        {-200, 300, 170, 2, 1000, 0, 1}
    },
    {
        {0, -200, 125, 1.9, 300000, 0.00, 1},
        {-200, 280, 275, 2, 11000, 0.001, 1},
        {-200, 300, 360, 2, 1000, 0.00, 0},
        {-200, 300, 320, 2, 10000, 0.01, 1},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {950, 920, 30, 2.1, 400, 0.00, 1},
        {-200, 300, 320, 2, 1000, 0.001, 0},
        {-200, 300, 311, 2, 1000, 0.00, 0},
        {-200, 300, 320, 2, 10000, 0.01, 1},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {
        {1352, 600, 80, 2, 300, 0.00, 1},
        {-200, 300, 120, 2, 50, 0.01, 0},
        {-200, 300, 90, 2, 50, -0.005, 1},
        {-200, 300, 270, 2, 1000, 0.01, 1},
        {-200, 300, 70, 2, 1000, 0, 1}
    },
    {{950, cmd.SCREENHEIGTH / 2, 0, 2, 0, 0, 0}, {-200, 200, 100000, 0, 4000000, 0, 1}},
    {{900, cmd.SCREENHEIGTH / 2, 0, 3, 0, 0, 0}, {-200, 200, 100000, 2, 4000000, 0, 1}},
    {{850, cmd.SCREENHEIGTH / 2, 0, 4, 0, 0, 0}, {-200, 200, 100000, 2, 4000000, 0, 1}},
    {{800, cmd.SCREENHEIGTH / 2, 0, 5, 0, 0, 0}, {-200, 200, 100000, 2, 4000000, 0, 1}},
    {{600, cmd.SCREENHEIGTH / 2, 0, 5, 0, 0, 1}, {-200, 200, 100000, 0, 4000000, 0, 0}},
    {{550, cmd.SCREENHEIGTH / 2, 0, 4, 0, 0, 1}, {-200, 200, 100000, 2, 4000000, 0, 0}},
    {{500, cmd.SCREENHEIGTH / 2, 0, 3, 0, 0, 1}, {-200, 200, 100000, 2, 4000000, 0, 0}},
    {{450, cmd.SCREENHEIGTH / 2, 0, 2, 0, 0, 1}, {-200, 200, 100000, 2, 4000000, 0, 0}},
    {{1020, cmd.SCREENHEIGTH / 2, 0, 0, 0, 0, 1}, {-200, 200, 100000, 2, 4000000, 0, 1}},
    {{380, cmd.SCREENHEIGTH / 2, 0, 0, 0, 0, 0}, {-200, 200, 100000, 2, 4000000, 0, 0}},
    {{1350, cmd.SCREENHEIGTH / 2 - 150, 90, 2, 4000000, 0, 1}, {-200, 200, 100000, 2, 4000000, 0, 0}},
    {{1350, cmd.SCREENHEIGTH / 2 + 150, 90, 2, 4000000, 0, 1}, {-200, 200, 100000, 2, 4000000, 0, 0}},
    {{1350, cmd.SCREENHEIGTH / 2, 90, 2, 4000000, 0, 1}, {-200, 200, 100000, 2, 4000000, 0, 0}}
}
return cmd
