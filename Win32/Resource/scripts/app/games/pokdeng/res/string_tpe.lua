local Hall_String = require("app.res.config")

return {
	str_confirm = Hall_String.str_confirm,--"ยืนยัน",
    str_cancel = Hall_String.str_cancel,--"ยกเลิก",
    str_baseAnte = Hall_String.str_baseAnte,--"เดิมพัน",
    str_male = Hall_String.str_male,--"ชาย",
    str_female = Hall_String.str_female,--"หญิง",

    str_chip_in_min = "MIN: %s",
    str_chip_in_max = "MAX: %s",
    str_chip_in_repeat = "แทงเท่าเดิม",
    str_chip_in_addChip = "เกทับ",
    str_chip_in_allIn = "ลงทั้งหมด",

    str_round_index = "รอบไพ่: %s/%sรอบ",
    str_room_code = "รหัสห้อง：%s",

    str_operate_yao = "จั่วไพ่",
    str_operate_buyao = "ไม่จั่ว",
    str_operate_invite = "เชิญเพื่อน",
    str_operate_startGame = "เริ่มเกมส์",
    str_operate_err_1 = "ผู้เล่นมีไม่พอเริ่มเกมส์ค่ะ",

    str_room_fee_deduct = "หักค่าห้อง %s ชิปแล้ว",

    str_table_tip_1 = "รอผู้เล่นเดิมพัน",
    str_table_tip_2 = "รอเจ้ามือจ่ายค่าห้อง",

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
            [0] = "0แต้ม",
            [1] = "1แต้ม",
            [2] = "2แต้ม",
            [3] = "3แต้ม",
            [4] = "4แต้ม",
            [5] = "5แต้ม",
            [6] = "6แต้ม",
            [7] = "7แต้ม",
            [8] = "8แต้ม",
            [9] = "9แต้ม",
        },
        [2] = "ไพ่เรียง",
        [3] = "ไพ่เรียงดอก",
        [4] = "ไพ่สามเหลือง",
        [5] = "ไพ่ตอง",
        [6] = "ไพ่ป๊อก",
    },
    TOOMUCHTOBET = "เดิมพันมากไป เจ้ามือไม่พอจ่ายค่ะ",
    ISPLAYING = "รอบไพ่กำลังเล่นอยู่ รอสักครู่ค่ะ",
    ISWAITING = "รอรอบต่อไป",
    str_if_exit_room = "คุณยืนยันที่จะออกจากเกมส์?",
    str_cannot_exit_room = "หากออกจากห้องตอนเล่นอยู่ ระบบเล่นต่ออัตโนมัติ ยืนยันจะออกจากห้อง?",

    BE_REQUEST_DEALER_SUCCESS = "เป็นเจ้าสำเร็จ รอบหน้าเป็นเจ้าอัตโนมัติ";
    BE_REQUEST_DEALER_IN_QUEUE = 'คุณอยู่ในรายชื่อการชิงเป็นเจ้ามือแล้ว จบรอบนี้ระบบจะเลือกเจ้ามือใหม่ตามจำนวนชิปค่ะ';
    BE_REQUEST_DEALER_LESS_THAN_1_5 = 'ขอโทษค่ะ คุณมีชิปน้อยกว่าเจ้ามือ ไม่สามารถชิงเป็นเจ้ามือได้';--303
    BE_REQUEST_DEALER_LESS_THAN_LIMIT = 'ชิปของคุณมีไม่พอเป็นเจ้าค่ะ';
    BE_REQUEST_DEALER_FULL = 'ขอโทษค่ะ รายชื่อการชิงเป็นเจ้ามือเต็มแล้ว กรุณารอรอบต่อไปค่ะ';
    TO_BEGIN_GAME = "เลือกเริ่มเกมส์";
    str_banker_is_reconnect = "สถานะเน็ตของเจ้ามือออฟไลน์แล้ว รอสักครู่ หากเชื่อมเน็ตไม่ได้ห้องนี้จะถูกยกเลิกค่ะ";
    STR_RETURN = "กลับ";
    STR_STAND_UP = "ลุกขึ้น";
    STR_RULE = "กติกา";

}