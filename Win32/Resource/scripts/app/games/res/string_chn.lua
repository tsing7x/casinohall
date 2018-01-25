local Hall_String = require("app.res.config")

return {
	str_confirm = Hall_String.str_confirm,--"确定",
    str_cancel = Hall_String.str_cancel,--"取消",
    str_baseAnte = Hall_String.str_baseAnte,--"底注",
    str_male = Hall_String.str_male,--"男",
    str_female = Hall_String.str_female,--"女",

    str_chip_in_min = "MIN: %s",
    str_chip_in_max = "MAX: %s",
    str_chip_in_repeat = "重复上局",
    str_chip_in_addChip = "加注",
    str_chip_in_allIn = "全下",

    str_round_index = "局数：%s/%s局",
    str_room_code = "口令：%s",

    str_operate_yao = "要 牌",
    str_operate_buyao = "不 要",
    str_operate_invite = "邀请好友",
    str_operate_startGame = "开始游戏",

    str_table_tip_1 = "等待闲家下注",
    str_table_tip_2 = "等待庄家续费",

    CARD_TYPE_TIP = 
    {
        [1] = 
        {
            [0] = "0点",
            [1] = "1点",
            [2] = "2点",
            [3] = "3点",
            [4] = "4点",
            [5] = "5点",
            [6] = "6点",
            [7] = "7点",
            [8] = "8点",
            [9] = "9点",
        },
        [2] = "顺子",
        [3] = "同花顺",
        [4] = "三黄",
        [5] = "三张",
        [6] = "博定",
    },
    TOOMUCHTOBET = "下注太多，庄家不够赔",
    ISPLAYING = "牌局正在进行中，请稍后",
    ISWAITING = "等待下一局",
    str_if_exit_room = "是否退出房间？",
    str_cannot_exit_room = "在游戏中，退出房间就托管，是否退出？",
}