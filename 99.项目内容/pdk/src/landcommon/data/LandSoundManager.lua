-- LandSoundManager
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 跑得快声音处理

require("src.app.game.pdk.src.landcommon.data.StringConfig")
local LandGlobalDefine = require("src.app.game.pdk.src.landcommon.data.LandGlobalDefine")
local LandSoundManager = class("LandSoundManager")

LandSoundManager.LandGameType4Sound = 
{
	[LandGlobalDefine.CLASSIC_LAND_TYPE] = "classic_land",
	[LandGlobalDefine.HAPPLY_LAND_TYPE] = "happy_land",
	[LandGlobalDefine.LAIZI_LAND_TYPE] = "laizi_land",
	[LandGlobalDefine.TP_LAND_TYPE] = "twoman_land"
}


LandSoundManager.MUSIC_TYPE_SOURCE = {}
LandSoundManager.EFFEBOY_TYPE_SOURCE = {}

--将游戏的音效类型的key value反转
LandSoundManager.EFFEBOY_TYPE_SOURCE_NAME = {}


-- 游戏的背景音乐类型
LandSoundManager.MUSIC_TYPE =
{
	MUSIC_TYPE_BACKGROUND = "0",
	MUSIC_TYPE_BACKGROUND_HAPPY = "1",
	MUSIC_TYPE_BACKGROUND_LAIZI = "2",
	MUSIC_TYPE_BACKGROUND_TPO = "3",
}

LandSoundManager.LandGameBGMusic = 
{
	[LandGlobalDefine.CLASSIC_LAND_TYPE] = "MUSIC_TYPE_BACKGROUND",
	[LandGlobalDefine.HAPPLY_LAND_TYPE] = "MUSIC_TYPE_BACKGROUND_HAPPY",
	[LandGlobalDefine.LAIZI_LAND_TYPE] = "MUSIC_TYPE_BACKGROUND_LAIZI",
	[LandGlobalDefine.TP_LAND_TYPE] = "MUSIC_TYPE_BACKGROUND_TP"
}


--游戏的音效类型
LandSoundManager.EFFEBOY_TYPE =
{
	--男声
	BOY_BEGIN = "0",

	BOY_BUJIABEI = "1",
	BOY_JIABEI = "2",
	BOY_THREE = "3",
	BOY_SINGLE_LINE = "4",
	BOY_DOUBLE_LINE = "5",
	BOY_THREE_LINE = "6",
	BOY_THREE_TAKE_ONE = "7",
	BOY_THREE_TAKE_TWO = "8",
	BOY_FOUR_LINE_TAKE_ONE = "9",
	BOY_FOUR_LINE_TAKE_TWO = "10",
	BOY_FOUR_TAKE_THREE = "BOY_FOUR_TAKE_THREE",
	BOY_BOMB_CARD = "11",
	BOY_MISSILE_CARD = "12",
	BOY_FEIJI = "13",
	BOY_FEIJI_TAKE_ONE_OR_TWO = "14",
	BOY_SANSHUN = "15",
	BOY_SINGLE_1 = "16",
	BOY_SINGLE_2 = "17",
	BOY_SINGLE_3 = "18",
	BOY_SINGLE_4 = "19",
	BOY_SINGLE_5 = "20",
	BOY_SINGLE_6 = "21",
	BOY_SINGLE_7 = "22",
	BOY_SINGLE_8 = "23",
	BOY_SINGLE_9 = "24",
	BOY_SINGLE_10 = "25",
	BOY_SINGLE_11 = "26",
	BOY_SINGLE_12 = "27",
	BOY_SINGLE_13 = "28",
	BOY_SINGLE_14 = "29",
	BOY_SINGLE_15 = "30",
	--
	BOY_DOUBLE_BEGIN = "31",
	BOY_DOUBLE_1 = "32",
	BOY_DOUBLE_2 = "33",
	BOY_DOUBLE_3 = "34",
	BOY_DOUBLE_4 = "35",
	BOY_DOUBLE_5 = "36",
	BOY_DOUBLE_6 = "37",
	BOY_DOUBLE_7 = "38",
	BOY_DOUBLE_8 = "39",
	BOY_DOUBLE_9 = "40",
	BOY_DOUBLE_10 = "41",
	BOY_DOUBLE_11 = "42",
	BOY_DOUBLE_12 = "43",
	BOY_DOUBLE_13 = "44",
	BOY_DOUBLE_14 = "45",

	BOY_BUYIAO = "46",
	BOY_BUYIAO_2 = "47",
	BOY_BUYIAO_3 = "48",
	BOY_BUYIAO_4 = "49",

	BOY_SCORE_BEGIN = "50",
	BOY_SCORE_1 = "51",
	BOY_SCORE_2 = "52",
	BOY_SCORE_3 = "53",
	BOY_SCORE_BUJIAO = "54",
	BOY_SPRING = "55",

	--BOY_SHARE
	ET_BOMB = "60",
	ET_CLOCK = "61",
	ET_FEIJI = "62",
	ET_FEIJI_TAKE_ONE_OR_TWO = "62",
	ET_GAMESTART = "63",
	ET_CHUPAI = "64",
	ET_ROCKET = "65",
	ET_SENDCARD = "66",
	ET_GAMEFAIL = "67",
	ET_GAMEWIN = "68",

	--BOY_CALL
	BOY_CALLSCORE_MINGPAI = "70",	
	BOY_CALLSCORE_JIAO = "71",	
	BOY_CALLSCORE_BUJIAO = "72",	
	BOY_CALLSCORE_QIANG = "73",	
	BOY_CALLSCORE_BUQIANG = "74",	
	BOY_CALLSCORE_DOUBLE = "75",	
	BOY_CALLSCORE_NOTDOUBLE = "76",	
	BOY_CALLSCORE_WQ = "77",	

	--GIRL SOUNDS
	GIRL_BEGIN = "100",
	GIRL_BUJIABEI = "101",
	GIRL_JIABEI = "102",
	GIRL_THREE = "103",
	GIRL_SINGLE_LINE = "104",
	GIRL_DOUBLE_LINE = "105",
	GIRL_THREE_LINE = "106",
	GIRL_THREE_TAKE_ONE = "107",
	GIRL_THREE_TAKE_TWO = "108",
	GIRL_FOUR_LINE_TAKE_ONE = "109",
	GIRL_FOUR_LINE_TAKE_TWO = "110",
	GIRL_FOUR_TAKE_THREE = "GIRL_FOUR_TAKE_THREE",
	GIRL_BOMB_CARD = "111",
	GIRL_MISSILE_CARD = "112",
	GIRL_FEIJI_TAKE_ONE = "113",
	GIRL_FEIJI_TAKE_TWO = "114",
	GIRL_SANSHUN = "115",
	GIRL_SINGLE_1 = "116",
	GIRL_SINGLE_2 = "117",
	GIRL_SINGLE_3 = "118",
	GIRL_SINGLE_4 = "119",
	GIRL_SINGLE_5 = "120",
	GIRL_SINGLE_6 = "121",
	GIRL_SINGLE_7 = "122",
	GIRL_SINGLE_8 = "123",
	GIRL_SINGLE_9 = "124",
	GIRL_SINGLE_10 = "125",
	GIRL_SINGLE_11 = "126",
	GIRL_SINGLE_12 = "127",
	GIRL_SINGLE_13 = "128",
	GIRL_SINGLE_14 = "129",
	GIRL_SINGLE_15 = "130",
	--
	GIRL_DOUBLE_BEGIN = "131",
	GIRL_DOUBLE_1 = "132",
	GIRL_DOUBLE_2 = "133",
	GIRL_DOUBLE_3 = "134",
	GIRL_DOUBLE_4 = "135",
	GIRL_DOUBLE_5 = "136",
	GIRL_DOUBLE_6 = "137",
	GIRL_DOUBLE_7 = "138",
	GIRL_DOUBLE_8 = "139",
	GIRL_DOUBLE_9 = "140",
	GIRL_DOUBLE_10 = "141",
	GIRL_DOUBLE_11 = "142",
	GIRL_DOUBLE_12 = "143",
	GIRL_DOUBLE_13 = "144",
	GIRL_DOUBLE_14 = "145",

	GIRL_BUYIAO = "146",
	GIRL_BUYIAO_2 = "147",
	GIRL_BUYIAO_3 = "148",
	GIRL_BUYIAO_4 = "149",

	GIRL_SCORE_BEGIN = "150",
	GIRL_SCORE_1 = "151",
	GIRL_SCORE_2 = "152",
	GIRL_SCORE_3 = "153",
	GIRL_SCORE_BUJIAO = "154",
	GIRL_SPRING = "155",

	--GIRL_SHARE
	GIRL_BOMB = "160",
	GIRL_CLOCK = "161",
	GIRL_FEIJI = "162",
	GIRL_GAMESTART = "163",
	GIRL_CHUPAI = "164",
	GIRL_ROCKET = "165",
	GIRL_SENDCARD = "166",
	GIRL_GAMEFAIL = "167",
	GIRL_GAMEWIN = "168",

	--GIRL_CALL
	GIRL_CALLSCORE_MINGPAI = "170",	
	GIRL_CALLSCORE_JIAO = "171",	
	GIRL_CALLSCORE_BUJIAO = "172",	
	GIRL_CALLSCORE_QIANG = "173",	
	GIRL_CALLSCORE_BUQIANG = "174",	
	GIRL_CALLSCORE_DOUBLE = "175",	
	GIRL_CALLSCORE_NOTDOUBLE = "176",	
	GIRL_CALLSCORE_WQ = "177",

	-- COMMON
	LAST_TWO_POKET = "178",
	LAST_ONE_POKET = "179",	
}

LandSoundManager.isEffectMute = false
LandSoundManager.instance = nil

function LandSoundManager:ctor()
   self.landGameType = LandGlobalDefine.CLASSIC_LAND_TYPE
   self:initWithSoundSource()
   self:initLandSoundState()
end

function LandSoundManager:initLandSoundState()

end

function LandSoundManager:setLandGameType( _LandGameType )
	self.landGameType = _LandGameType
end

-- 获取跑得快声音管理的单例
function LandSoundManager:getInstance()
    if LandSoundManager.instance == nil then
       LandSoundManager.instance = LandSoundManager.new()
    end
    return LandSoundManager.instance
end

function LandSoundManager:initWithSoundSource()
	local m_valueMap = {}
    m_valueMap = cc.FileUtils:getInstance():getValueMapFromFile("config/sound.plist")
    for key, value in pairs(m_valueMap) do  
	    if key == "Music" then
	    	print(key)
	    	if value then
	    		LandSoundManager.MUSIC_TYPE_SOURCE = value
	    	end
	    elseif key == "Effect" then
	    	print(key)
	    	if value then
	    		LandSoundManager.EFFEBOY_TYPE_SOURCE = value
	    	end
	    end
	end 
end


function LandSoundManager:setEffectMute(val)
	LandSoundManager.isEffectMute = val
end
-- 背景音乐
--function LandSoundManager:getLandGameBgMusicStatus()
--	local land_game_name = LandSoundManager.LandGameType4Sound[ self.landGameType ]
--	return g_GameMusicUtil:getMusicStatus()
--end

--function LandSoundManager:setLandGameBgMusicStatus( isOpen )
--	local land_game_name = LandSoundManager.LandGameType4Sound[ self.landGameType ]
--	g_GameMusicUtil:setMusicStatus( isOpen )
--end
---- 音效
--function LandSoundManager:getLandGameEffectSoundStatus()
--	local land_game_name = LandSoundManager.LandGameType4Sound[ self.landGameType ]
--	return g_GameMusicUtil:getSoundStatus()
--end

--function LandSoundManager:setLandGameEffectSoundStatus( isOpen )
--	local land_game_name = LandSoundManager.LandGameType4Sound[ self.landGameType ]
--	g_GameMusicUtil:setSoundStatus( isOpen )
--end


--播放音乐和音效
function LandSoundManager:playEffect( effect_type )
	local soundPath = self:getEffectPath(effect_type)
	LogINFO("LandSoundManager:playEffect",effect_type,soundPath)
	g_AudioPlayer:playEffect(soundPath, false)
end

function LandSoundManager:playBgMusic( music_type )
	local soundPath = self:getMusicPath(music_type)
	local land_game_name = LandSoundManager.LandGameType4Sound[ self.landGameType ]
	print("Sound.playBgMusic = ".. soundPath)
	--if not audio.isMusicPlaying() then
	--	if g_GameMusicUtil:getMusicStatus() then 
		   g_AudioPlayer:playMusic(soundPath, true)
	--	end
	--end
end

function LandSoundManager:getMusicPath( music_type )
	local m_strFileName = ""
	local n = tonumber(music_type)
	if n then
 		-- n就是得到数字
 		--print(n)
 		m_strFileName = LandSoundManager.MUSIC_TYPE_SOURCE[tostring(music_type)]
	else
 		-- 转数字失败,不是数字, 这时n == nil
 		--print(n)
 		m_strFileName = LandSoundManager.MUSIC_TYPE_SOURCE[LandSoundManager.MUSIC_TYPE[music_type]]
	end
	return m_strFileName
end

function LandSoundManager:getEffectPath( effect_type )
	local m_strFileName = ""
	-- 如果带判断是一个字符串,要判断是否可以转成数字, 则
	-- local n = tonumber(effect_type);
	-- if n then
 -- 		-- n就是得到数字
 -- 		--print(n)
 -- 		m_strFileName = Sound.EFFEBOY_TYPE_SOURCE[tostring(effect_type)]
	-- else
 -- 		-- 转数字失败,不是数字, 这时n == nil
 -- 		--print(n)
 -- 		m_strFileName = Sound.EFFEBOY_TYPE_SOURCE[Sound.EFFEBOY_TYPE[effect_type]]
	-- end
	if type(effect_type) == "number" then
		m_strFileName = LandSoundManager.EFFEBOY_TYPE_SOURCE[tostring(effect_type)]
	else
		m_strFileName = LandSoundManager.EFFEBOY_TYPE_SOURCE[LandSoundManager.EFFEBOY_TYPE[effect_type]]
	end
	-- 4+3
	if effect_type == "BOY_FOUR_TAKE_THREE" then
		m_strFileName = "res/sounds/landboy/sidaisan.mp3"
	end
	if effect_type == "GIRL_FOUR_TAKE_THREE" then
		m_strFileName = "res/sounds/landgirl/sidaisan.mp3"
	end
	-- print("Sound.getEffectPath"..m_strFileName)
	return m_strFileName
end

function LandSoundManager:preloadSoundRes()
    for key, value in pairs(LandSoundManager.MUSIC_TYPE_SOURCE) do
        if value then
            audio.preloadMusic(value)
        end
    end
    for key, value in pairs(LandSoundManager.EFFEBOY_TYPE_SOURCE) do
        if value then
            audio.preloadSound(value)
        end
    end
end

function LandSoundManager:onDestory()
    LandSoundManager.instance = nil
end

return LandSoundManager