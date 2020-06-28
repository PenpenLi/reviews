
local CardConfig = class("CardConfig")

CardConfig.CardWidth = 150
CardConfig.CardHeight = 208
CardConfig.CardSpace = 68
CardConfig.OutCardScale = 0.55
CardConfig.SmallCardWith = 56
CardConfig.SmallCardHeight = 70

function CardConfig:ctor()
end

function CardConfig:getCardInfoByid(id)
	if CardConfig.CardInfos[id] then	
		return CardConfig.CardInfos[id]
	end
end


CardConfig.CardInfos={}

CardConfig.CardInfos[0x01]={CardId=0x01,Name="方片A",Color=0,Value=1,  engName = "square_a",   CardIcon="lord_poker_square_a"}
CardConfig.CardInfos[0x02]={CardId=0x02,Name="方片2",Color=0,Value=2,  engName = "square_2",   CardIcon="lord_poker_square_2"}
CardConfig.CardInfos[0x03]={CardId=0x03,Name="方片3",Color=0,Value=3,  engName = "square_3",   CardIcon="lord_poker_square_3"}
CardConfig.CardInfos[0x04]={CardId=0x04,Name="方片4",Color=0,Value=4,  engName = "square_4",   CardIcon="lord_poker_square_4"}
CardConfig.CardInfos[0x05]={CardId=0x05,Name="方片5",Color=0,Value=5,  engName = "square_5",   CardIcon="lord_poker_square_5"}
CardConfig.CardInfos[0x06]={CardId=0x06,Name="方片6",Color=0,Value=6,  engName = "square_6",   CardIcon="lord_poker_square_6"}
CardConfig.CardInfos[0x07]={CardId=0x07,Name="方片7",Color=0,Value=7,  engName = "square_7",   CardIcon="lord_poker_square_7"}
CardConfig.CardInfos[0x08]={CardId=0x08,Name="方片8",Color=0,Value=8,  engName = "square_8",   CardIcon="lord_poker_square_8"}
CardConfig.CardInfos[0x09]={CardId=0x09,Name="方片9",Color=0,Value=9,  engName = "square_9",   CardIcon="lord_poker_square_9"}
CardConfig.CardInfos[0x0A]={CardId=0x0A,Name="方片10",Color=0,Value=10,engName = "square_10",  CardIcon="lord_poker_square_10"}
CardConfig.CardInfos[0x0B]={CardId=0x0B,Name="方片J",Color=0,Value=11, engName = "square_j",   CardIcon="lord_poker_square_j"}
CardConfig.CardInfos[0x0C]={CardId=0x0C,Name="方片Q",Color=0,Value=12, engName = "square_q",   CardIcon="lord_poker_square_q"}
CardConfig.CardInfos[0x0D]={CardId=0x0D,Name="方片K",Color=0,Value=13, engName = "square_k",   CardIcon="lord_poker_square_k"}

CardConfig.CardInfos[0x11]={CardId=0x11,Name="梅花A",Color=1,Value=1,  engName = "club_a",     CardIcon="lord_poker_club_a"}
CardConfig.CardInfos[0x12]={CardId=0x12,Name="梅花2",Color=1,Value=2,  engName = "club_2",     CardIcon="lord_poker_club_2"}
CardConfig.CardInfos[0x13]={CardId=0x13,Name="梅花3",Color=1,Value=3,  engName = "club_3",     CardIcon="lord_poker_club_3"}
CardConfig.CardInfos[0x14]={CardId=0x14,Name="梅花4",Color=1,Value=4,  engName = "club_4",     CardIcon="lord_poker_club_4"}
CardConfig.CardInfos[0x15]={CardId=0x15,Name="梅花5",Color=1,Value=5,  engName = "club_5",     CardIcon="lord_poker_club_5"}
CardConfig.CardInfos[0x16]={CardId=0x16,Name="梅花6",Color=1,Value=6,  engName = "club_6",     CardIcon="lord_poker_club_6"}
CardConfig.CardInfos[0x17]={CardId=0x17,Name="梅花7",Color=1,Value=7,  engName = "club_7",     CardIcon="lord_poker_club_7"}
CardConfig.CardInfos[0x18]={CardId=0x18,Name="梅花8",Color=1,Value=8,  engName = "club_8",     CardIcon="lord_poker_club_8"}
CardConfig.CardInfos[0x19]={CardId=0x19,Name="梅花9",Color=1,Value=9,  engName = "club_9",     CardIcon="lord_poker_club_9"}
CardConfig.CardInfos[0x1A]={CardId=0x1A,Name="梅花10",Color=1,Value=10,engName = "club_10",    CardIcon="lord_poker_club_10"}
CardConfig.CardInfos[0x1B]={CardId=0x1B,Name="梅花J",Color=1,Value=11, engName = "club_j",     CardIcon="lord_poker_club_j"}
CardConfig.CardInfos[0x1C]={CardId=0x1C,Name="梅花Q",Color=1,Value=12, engName = "club_q",     CardIcon="lord_poker_club_q"}
CardConfig.CardInfos[0x1D]={CardId=0x1D,Name="梅花K",Color=1,Value=13, engName = "club_k",     CardIcon="lord_poker_club_k"}

CardConfig.CardInfos[0x21]={CardId=0x21,Name="红桃A",Color=2,Value=1,  engName = "hearts_a",   CardIcon="lord_poker_hearts_a"}
CardConfig.CardInfos[0x22]={CardId=0x22,Name="红桃2",Color=2,Value=2,  engName = "hearts_2",   CardIcon="lord_poker_hearts_2"}
CardConfig.CardInfos[0x23]={CardId=0x23,Name="红桃3",Color=2,Value=3,  engName = "hearts_3",   CardIcon="lord_poker_hearts_3"}
CardConfig.CardInfos[0x24]={CardId=0x24,Name="红桃4",Color=2,Value=4,  engName = "hearts_4",   CardIcon="lord_poker_hearts_4"}
CardConfig.CardInfos[0x25]={CardId=0x25,Name="红桃5",Color=2,Value=5,  engName = "hearts_5",   CardIcon="lord_poker_hearts_5"}
CardConfig.CardInfos[0x26]={CardId=0x26,Name="红桃6",Color=2,Value=6,  engName = "hearts_6",   CardIcon="lord_poker_hearts_6"}
CardConfig.CardInfos[0x27]={CardId=0x27,Name="红桃7",Color=2,Value=7,  engName = "hearts_7",   CardIcon="lord_poker_hearts_7"}
CardConfig.CardInfos[0x28]={CardId=0x28,Name="红桃8",Color=2,Value=8,  engName = "hearts_8",   CardIcon="lord_poker_hearts_8"}
CardConfig.CardInfos[0x29]={CardId=0x29,Name="红桃9",Color=2,Value=9,  engName = "hearts_9",   CardIcon="lord_poker_hearts_9"}
CardConfig.CardInfos[0x2A]={CardId=0x2A,Name="红桃10",Color=2,Value=10,engName = "hearts_10",  CardIcon="lord_poker_hearts_10"}
CardConfig.CardInfos[0x2B]={CardId=0x2B,Name="红桃J",Color=2,Value=11, engName = "hearts_j",   CardIcon="lord_poker_hearts_j"}
CardConfig.CardInfos[0x2C]={CardId=0x2C,Name="红桃Q",Color=2,Value=12, engName = "hearts_q",   CardIcon="lord_poker_hearts_q"}
CardConfig.CardInfos[0x2D]={CardId=0x2D,Name="红桃K",Color=2,Value=13, engName = "hearts_k",   CardIcon="lord_poker_hearts_k"}

CardConfig.CardInfos[0x31]={CardId=0x31,Name="黑桃A",Color=3,Value=1,  engName = "spade_a",    CardIcon="lord_poker_spade_a"}
CardConfig.CardInfos[0x32]={CardId=0x32,Name="黑桃2",Color=3,Value=2,  engName = "spade_2",    CardIcon="lord_poker_spade_2"}
CardConfig.CardInfos[0x33]={CardId=0x33,Name="黑桃3",Color=3,Value=3,  engName = "spade_3",    CardIcon="lord_poker_spade_3"}
CardConfig.CardInfos[0x34]={CardId=0x34,Name="黑桃4",Color=3,Value=4,  engName = "spade_4",    CardIcon="lord_poker_spade_4"}
CardConfig.CardInfos[0x35]={CardId=0x35,Name="黑桃5",Color=3,Value=5,  engName = "spade_5",    CardIcon="lord_poker_spade_5"}
CardConfig.CardInfos[0x36]={CardId=0x36,Name="黑桃6",Color=3,Value=6,  engName = "spade_6",    CardIcon="lord_poker_spade_6"}
CardConfig.CardInfos[0x37]={CardId=0x37,Name="黑桃7",Color=3,Value=7,  engName = "spade_7",    CardIcon="lord_poker_spade_7"}
CardConfig.CardInfos[0x38]={CardId=0x38,Name="黑桃8",Color=3,Value=8,  engName = "spade_8",    CardIcon="lord_poker_spade_8"}
CardConfig.CardInfos[0x39]={CardId=0x39,Name="黑桃9",Color=3,Value=9,  engName = "spade_9",    CardIcon="lord_poker_spade_9"}
CardConfig.CardInfos[0x3A]={CardId=0x3A,Name="黑桃10",Color=3,Value=10,engName = "spade_10",   CardIcon="lord_poker_spade_10"}
CardConfig.CardInfos[0x3B]={CardId=0x3B,Name="黑桃J",Color=3,Value=11, engName = "spade_j",    CardIcon="lord_poker_spade_j"}
CardConfig.CardInfos[0x3C]={CardId=0x3C,Name="黑桃Q",Color=3,Value=12, engName = "spade_q",    CardIcon="lord_poker_spade_q"}
CardConfig.CardInfos[0x3D]={CardId=0x3D,Name="黑桃K",Color=3,Value=13, engName = "spade_k",    CardIcon="lord_poker_spade_k"}


CardConfig.CardInfos[0x4F]={CardId=0x4E,Name="大王",Color=4,Value=14,  engName = "bigking",   CardIcon="lord_poker_bigking"}
CardConfig.CardInfos[0x4E]={CardId=0x4F,Name="小王",Color=4,Value=15,  engName = "smallking", CardIcon="lord_poker_smallking"}


return CardConfig