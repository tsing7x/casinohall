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
    str_operate_err_1 = "玩家人数不够",

    str_room_fee_deduct = "已经扣除 %s 房费",

    str_table_tip_1 = "等待闲家下注",
    str_table_tip_2 = "等待庄家续费",

    SysChatArray = 
    {
        [1] = 'สวัสดีค่ะ!';
        [2] = 'ฝากเนื้อฝากตัวด้วยนะคะ';
        [3] = 'รอนานมากแล้วนะ';
        [4] = 'ALL IN!!!';
        [5] = 'เล่นได้เจ๋งมาก!';
        [6] = 'ใจเย็นๆ';
        [7] = 'เดิมพันได้แล้ว';
        [8] = 'ส่งชิปให้หน่อย';
        [9] = 'นี่จะขโมยชิปหรอ';
        [10] = 'เน็ตหลุดอีกละ เน่ามาก!';
    },

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

    BE_REQUEST_DEALER_SUCCESS = "上庄成功，下一局自动上庄";
    BE_REQUEST_DEALER_IN_QUEUE = '对不起，您已经在上庄序列中，请不要重复点击';--302
    BE_REQUEST_DEALER_LESS_THAN_LIMIT = '对不起，您的资产低于%s，未达到上庄要求';--301
    BE_REQUEST_DEALER_LESS_THAN_1_5 = '对不起，您的游戏币小于庄家游戏币，无法抢庄';--303
    BE_REQUEST_DEALER_FULL = '对不起，当前上庄序列已满，请稍后再抢庄';--304
    TO_BEGIN_GAME = "选择开始游戏";
    str_banker_is_reconnect = "庄家已离线，等待庄家重连";
    STR_RETURN = "返回";
    STR_STAND_UP = "站起";
    STR_RULE = "规则";

}