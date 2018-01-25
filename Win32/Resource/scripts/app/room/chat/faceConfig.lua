 -- file: ''
-- desc:
-- require("room/faceb_res");
require("app/room/chat/faceq_res");

-- begin declare
local faceConfig = {};
faceConfig[1] = {};

faceQConfigArray = faceConfig[1];
faceQConfigArray.imgInfo = "expression"; 	--显示在表情框中的表情按钮的图片名字的前缀
faceQConfigArray.namePrefix = faceq_res_map;    		--显示在表情框中的表情按钮的图片的存储路径或拼图
faceQConfigArray.expressInfo = "expression";			--播放的表情图片的名字前缀
faceQConfigArray.expNamePrefix = "animation/expression/";	--播放的表情图片的存储路径或拼图

tempConfigArray = {};
tempConfigArray.imgCount =2;
tempConfigArray.playCount =7;
tempConfigArray.ms =300;
faceQConfigArray[1] = tempConfigArray;

tempConfigArray = {};
tempConfigArray.imgCount =8;
tempConfigArray.playCount =2;
tempConfigArray.ms =1000;
faceQConfigArray[2] = tempConfigArray;

tempConfigArray = {};
tempConfigArray.imgCount =9;
tempConfigArray.playCount =2;
tempConfigArray.ms =1000;
faceQConfigArray[3] = tempConfigArray;

tempConfigArray = {};
tempConfigArray.imgCount =2;
tempConfigArray.playCount =7;
tempConfigArray.ms =300;
faceQConfigArray[4] = tempConfigArray;

tempConfigArray = {};
tempConfigArray.imgCount =2;
tempConfigArray.playCount =7;
tempConfigArray.ms =300;
faceQConfigArray[5] = tempConfigArray;

tempConfigArray = {};
tempConfigArray.imgCount =8;
tempConfigArray.playCount =2;
tempConfigArray.ms =1000;
faceQConfigArray[6] = tempConfigArray;

tempConfigArray = {};
tempConfigArray.imgCount =6;
tempConfigArray.playCount =2;
tempConfigArray.ms =900;
faceQConfigArray[7] = tempConfigArray;

tempConfigArray = {};
tempConfigArray.imgCount =9;
tempConfigArray.playCount =2;
tempConfigArray.ms =1000;
faceQConfigArray[8] = tempConfigArray;

tempConfigArray = {};
tempConfigArray.imgCount =3;
tempConfigArray.playCount =5;
tempConfigArray.ms =450;
faceQConfigArray[9] = tempConfigArray;

tempConfigArray = {};
tempConfigArray.imgCount =4;
tempConfigArray.playCount =4;
tempConfigArray.ms =600;
faceQConfigArray[10] = tempConfigArray;

tempConfigArray = {};
tempConfigArray.imgCount =12;
tempConfigArray.playCount =1;
tempConfigArray.ms =2000;
faceQConfigArray[11] = tempConfigArray;

tempConfigArray = {};
tempConfigArray.imgCount =4;
tempConfigArray.playCount =3;
tempConfigArray.ms =600;
faceQConfigArray[12] = tempConfigArray;

tempConfigArray = {};
tempConfigArray.imgCount =4;
tempConfigArray.playCount =4;
tempConfigArray.ms =600;
faceQConfigArray[13] = tempConfigArray;

tempConfigArray = {};
tempConfigArray.imgCount =14;
tempConfigArray.playCount =2;
tempConfigArray.ms =1000;
faceQConfigArray[14] = tempConfigArray;

tempConfigArray = {};
tempConfigArray.imgCount =5;
tempConfigArray.playCount =4;
tempConfigArray.ms =500;
faceQConfigArray[15] = tempConfigArray;
tempConfigArray = {};

tempConfigArray.imgCount =4;
tempConfigArray.playCount =4;
tempConfigArray.ms =600;
faceQConfigArray[16] = tempConfigArray;

tempConfigArray = {};
tempConfigArray.imgCount =3;
tempConfigArray.playCount =5;
tempConfigArray.ms =450;
faceQConfigArray[17] = tempConfigArray;
tempConfigArray = {};

tempConfigArray.imgCount =4;
tempConfigArray.playCount =4;
tempConfigArray.ms =600;
faceQConfigArray[18] = tempConfigArray;

tempConfigArray = {};
tempConfigArray.imgCount =2;
tempConfigArray.playCount =7;
tempConfigArray.ms =300;
faceQConfigArray[19] = tempConfigArray;
tempConfigArray = {};

tempConfigArray.imgCount =2;
tempConfigArray.playCount =7;
tempConfigArray.ms =300;
faceQConfigArray[20] = tempConfigArray;

tempConfigArray = {};
tempConfigArray.imgCount =2;
tempConfigArray.playCount =7;
tempConfigArray.ms =300;
faceQConfigArray[21] = tempConfigArray;

tempConfigArray = {};
tempConfigArray.imgCount =7;
tempConfigArray.playCount =2;
tempConfigArray.ms =1000;
faceQConfigArray[22] = tempConfigArray;
tempConfigArray = {};

tempConfigArray.imgCount =5;
tempConfigArray.playCount =3;
tempConfigArray.ms =750;
faceQConfigArray[23] = tempConfigArray;

tempConfigArray = {};
tempConfigArray.imgCount =9;
tempConfigArray.playCount =2;
tempConfigArray.ms =1000;
faceQConfigArray[24] = tempConfigArray;

tempConfigArray = {};
tempConfigArray.imgCount =4;
tempConfigArray.playCount =4;
tempConfigArray.ms =600;
faceQConfigArray[25] = tempConfigArray;
tempConfigArray = {};

tempConfigArray.imgCount =8;
tempConfigArray.playCount =3;
tempConfigArray.ms =800;
faceQConfigArray[26] = tempConfigArray;

tempConfigArray = {};
tempConfigArray.imgCount =3;
tempConfigArray.playCount =5;
tempConfigArray.ms =450;
faceQConfigArray[27] = tempConfigArray;

tempConfigArray = {};

return faceConfig