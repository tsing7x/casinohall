
Music = {
	AudioHallBack = "hall",
	AudioGameBack = "game",
	AudioGame3hBack = "game3h",
	AudioGameMakhosBack = "makhos",
}

Effects = {
	AudioCall 		 = "audio_call",
	AudioButtonClick = "audio_button_click",
	AudioDiceClose 	 = "audio_diceclose",
	AudioDiceDrop 	 = "audio_dicedrop",
	AudioDiceMove 	 = "audio_dicemove",
	AudioDiceShake 	 = "audio_diceshake",
	AudioBeginBet 	 = "audio_beginbet",
	AudioEndBet 	 = "audio_endbet",
	AudioDiceOpen 	 = "audio_diceopen",
	AudioTimeWarning = 'audio_timewarning',
	AudioWin 		 = 'audio_win',
	AudioChipDrop 	 = 'audio_chipdropping',
	AudioChipMove 	 = 'audio_chipmove',
	AudioH3Shake 	 = 'audio_h3shake',

    -- 动画
    AudioBomb        = 'Bomb',
    AudioDog         = 'Dog',
    AudioFlower      = 'Flower',
    AudioHammer      = 'Hammer',
    AudioPourWater   = 'PourWater',
    AudioToast       = 'Toast',
    AudioTomato      = 'Tomato',
    AudioKiss        = 'Kiss',
    AudioTissure     = 'tissure',
    AudioEgg         = 'Egg',
	AudioLose 		 = 'lose',
    AudioGhost       = 'ghost',
    AudioPumpkin     = 'pumpkin',
    AudioWaterGun    = 'waterGun',

	AudioChatCommon1 = 'chat_common_1',
	AudioChatCommon2 = 'chat_common_2',
	AudioChatCommon3 = 'chat_common_3',
	AudioChatCommon4 = 'chat_common_4',
	AudioChatCommon5 = 'chat_common_5',
	AudioChatCommon6 = 'chat_common_6',
	AudioChatCommon7 = 'chat_common_7',
	AudioChatCommon8 = 'chat_common_8',
	AudioChatCommon9 = 'chat_common_9',
	AudioChatCommon10 = 'chat_common_10',
	AudioChatCommon11 = 'chat_common_11',
	AudioChatCommon12 = 'chat_common_12',
	AudioChatCommon13 = 'chat_common_13',
	AudioChatCommon14 = 'chat_common_14',
	AudioChatCommon15 = 'chat_common_15',
	AudioChatMakhos1  = 'AudioChatMakhos1',
	AudioChatMakhos2  = 'AudioChatMakhos2',
	AudioChatMakhos3  = 'AudioChatMakhos3',
	AudioChatMakhos4  = 'AudioChatMakhos4',
	AudioMakhosChessSelect = 'audio_chess_select',
	AudioMakhosChessMove = 'audio_move_chess',
	AudioMakhosChessEat = 'audio_move_eat',

	--双十添加
	AudioMTWin		= 'mixedTen_win',
	AudioMTLose		= 'mixedTen_lose',
	AudioEvertCard	= 'evert_card',
	AudioGetChip	= 'mixedTen_getChip',
	AudioSelectCard	= 'selectCard',
	AudioOutCard	= 'outCard',
	AudioCurrentPlayer	= 'mixedTen_current',
}

require("gameBase/gameMusic");
require("gameBase/gameEffect");

kMusicPlayer=GameMusic.getInstance();
kEffectPlayer=GameEffect.getInstance();

local prefix, extName
if System.getPlatform() == kPlatformAndroid then
	prefix ="ogg/"
	extName=".ogg"
else
	prefix ="mp3/"
	extName=".mp3"
end
kMusicPlayer:setPathPrefixAndExtName(prefix, extName);
kEffectPlayer:setPathPrefixAndExtName(prefix, extName);
