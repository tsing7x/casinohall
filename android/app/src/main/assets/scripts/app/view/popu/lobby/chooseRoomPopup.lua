local chooseRoomPopup=
{
	name="chooseRoomPopup",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,
	{
		name="bg",type=1,typeName="Image",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,file="lobby/hall_bg.png"
	},
	{
		name="retBtn",type=1,typeName="Button",time=0,x=22,y=16,width=69,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/chooseRoom/img_ret.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20
	},
	{
		name="room1",type=1,typeName="Button",time=0,x=-149,y=-348,width=265,height=303,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/chooseRoom/img_poker_room1.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
		{
			name="numPic1",type=1,typeName="Image",time=0,x=83,y=136,width=58,height=67,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/chooseRoom/img_num_1.png"
		},
		{
			name="numPic2",type=1,typeName="Image",time=0,x=141,y=136,width=58,height=67,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/chooseRoom/img_num_k.png"
		},
		{
			name="minReqTxt",type=4,typeName="Text",time=0,x=7,y=71,width=150,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[最小进入值 3K]]
		},
		{
			name="maxReqTxt",type=4,typeName="Text",time=0,x=10,y=96,width=161.65,height=38,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[最大进入值 10K]]
		},
		{
			name="imgOnlineFrame",type=1,typeName="Image",time=0,x=3,y=123,width=160,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/chooseRoom/img_online_frame.png",
			{
				name="imgOnlineIcon",type=1,typeName="Image",time=0,x=-48,y=3,width=21,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/chooseRoom/img_online_icon.png"
			},
			{
				name="onlineTxt",type=4,typeName="Text",time=0,x=68,y=1,width=88,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=20,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[2345]]
			}
		}
	},
	{
		name="room2",type=1,typeName="Button",time=0,x=149,y=-348,width=265,height=303,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/chooseRoom/img_poker_room1.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
		{
			name="numPic1",type=1,typeName="Image",time=0,x=83,y=136,width=58,height=67,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/chooseRoom/img_num_1.png"
		},
		{
			name="numPic2",type=1,typeName="Image",time=0,x=141,y=136,width=58,height=67,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/chooseRoom/img_num_k.png"
		},
		{
			name="minReqTxt",type=4,typeName="Text",time=0,x=7,y=71,width=150,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[最小进入值 3K]]
		},
		{
			name="maxReqTxt",type=4,typeName="Text",time=0,x=10,y=96,width=161.65,height=38,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[最大进入值 10K]]
		},
		{
			name="imgOnlineFrame",type=1,typeName="Image",time=0,x=3,y=123,width=160,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/chooseRoom/img_online_frame.png",
			{
				name="imgOnlineIcon",type=1,typeName="Image",time=0,x=-48,y=3,width=21,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/chooseRoom/img_online_icon.png"
			},
			{
				name="onlineTxt",type=4,typeName="Text",time=0,x=68,y=1,width=88,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=20,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[2345]]
			}
		}
	},
	{
		name="room3",type=1,typeName="Button",time=0,x=-149,y=-46,width=265,height=303,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/chooseRoom/img_poker_room1.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
		{
			name="numPic1",type=1,typeName="Image",time=0,x=83,y=136,width=58,height=67,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/chooseRoom/img_num_1.png"
		},
		{
			name="numPic2",type=1,typeName="Image",time=0,x=141,y=136,width=58,height=67,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/chooseRoom/img_num_k.png"
		},
		{
			name="minReqTxt",type=4,typeName="Text",time=0,x=7,y=71,width=150,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[最小进入值 3K]]
		},
		{
			name="maxReqTxt",type=4,typeName="Text",time=0,x=10,y=96,width=161.65,height=38,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[最大进入值 10K]]
		},
		{
			name="imgOnlineFrame",type=1,typeName="Image",time=0,x=3,y=123,width=160,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/chooseRoom/img_online_frame.png",
			{
				name="imgOnlineIcon",type=1,typeName="Image",time=0,x=-48,y=3,width=21,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/chooseRoom/img_online_icon.png"
			},
			{
				name="onlineTxt",type=4,typeName="Text",time=0,x=68,y=1,width=88,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=20,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[2345]]
			}
		}
	},
	{
		name="room4",type=1,typeName="Button",time=0,x=149,y=-46,width=265,height=303,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/chooseRoom/img_poker_room1.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
		{
			name="numPic1",type=1,typeName="Image",time=0,x=83,y=136,width=58,height=67,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/chooseRoom/img_num_1.png"
		},
		{
			name="numPic2",type=1,typeName="Image",time=0,x=141,y=136,width=58,height=67,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/chooseRoom/img_num_k.png"
		},
		{
			name="minReqTxt",type=4,typeName="Text",time=0,x=7,y=71,width=150,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[最小进入值 3K]]
		},
		{
			name="maxReqTxt",type=4,typeName="Text",time=0,x=10,y=96,width=161.65,height=38,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[最大进入值 10K]]
		},
		{
			name="imgOnlineFrame",type=1,typeName="Image",time=0,x=3,y=123,width=160,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/chooseRoom/img_online_frame.png",
			{
				name="imgOnlineIcon",type=1,typeName="Image",time=0,x=-48,y=3,width=21,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/chooseRoom/img_online_icon.png"
			},
			{
				name="onlineTxt",type=4,typeName="Text",time=0,x=68,y=1,width=88,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=20,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[2345]]
			}
		}
	},
	{
		name="room5",type=1,typeName="Button",time=0,x=-149,y=257,width=265,height=303,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/chooseRoom/img_poker_room1.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
		{
			name="numPic1",type=1,typeName="Image",time=0,x=83,y=136,width=58,height=67,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/chooseRoom/img_num_1.png"
		},
		{
			name="numPic2",type=1,typeName="Image",time=0,x=141,y=136,width=58,height=67,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/chooseRoom/img_num_k.png"
		},
		{
			name="minReqTxt",type=4,typeName="Text",time=0,x=7,y=71,width=150,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[最小进入值 3K]]
		},
		{
			name="maxReqTxt",type=4,typeName="Text",time=0,x=10,y=96,width=161.65,height=38,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[最大进入值 10K]]
		},
		{
			name="imgOnlineFrame",type=1,typeName="Image",time=0,x=3,y=123,width=160,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/chooseRoom/img_online_frame.png",
			{
				name="imgOnlineIcon",type=1,typeName="Image",time=0,x=-48,y=3,width=21,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/chooseRoom/img_online_icon.png"
			},
			{
				name="onlineTxt",type=4,typeName="Text",time=0,x=68,y=1,width=88,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=20,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[2345]]
			}
		}
	},
	{
		name="room6",type=1,typeName="Button",time=0,x=149,y=257,width=265,height=303,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/chooseRoom/img_poker_room1.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
		{
			name="numPic1",type=1,typeName="Image",time=0,x=83,y=136,width=58,height=67,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/chooseRoom/img_num_1.png"
		},
		{
			name="numPic2",type=1,typeName="Image",time=0,x=141,y=136,width=58,height=67,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/chooseRoom/img_num_k.png"
		},
		{
			name="minReqTxt",type=4,typeName="Text",time=0,x=7,y=71,width=150,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[最小进入值 3K]]
		},
		{
			name="maxReqTxt",type=4,typeName="Text",time=0,x=10,y=96,width=161.65,height=38,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[最大进入值 10K]]
		},
		{
			name="imgOnlineFrame",type=1,typeName="Image",time=0,x=3,y=123,width=160,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/chooseRoom/img_online_frame.png",
			{
				name="imgOnlineIcon",type=1,typeName="Image",time=0,x=-48,y=3,width=21,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/chooseRoom/img_online_icon.png"
			},
			{
				name="onlineTxt",type=4,typeName="Text",time=0,x=68,y=1,width=88,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=20,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[2345]]
			}
		}
	},
	{
		name="quickStartBtn",type=1,typeName="Button",time=0,x=-3,y=104,width=339,height=130,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="popu/chooseRoom/img_qucik_start_btn.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
		{
			name="qucikStartTxt",type=1,typeName="Image",time=0,x=0,y=0,width=193,height=53,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/chooseRoom/img_qucik_start_txt.png"
		}
	},
	{
		name="bottomBar",type=1,typeName="Image",time=0,x=0,y=0,width=720,height=122,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottom,file="popu/chooseRoom/img_bottom_bar.png"
	},
	{
		name="headBtn",type=1,typeName="Button",time=0,x=27,y=1187,width=192,height=88,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="ui/blank.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
		{
			name="headBg",type=1,typeName="Image",time=0,x=0,y=0,width=92,height=93,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomLeft,file="popu/chooseRoom/img_head_bg.png",
			{
				name="headName",type=4,typeName="Text",time=0,x=105,y=45,width=99,height=37,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=26,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]]
			}
		}
	},
	{
		name="chipBtn",type=1,typeName="Button",time=0,x=246,y=6,width=236,height=69,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomRight,file="ui/blank.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
		{
			name="chipTxtBg",type=1,typeName="Image",time=0,x=32,y=11,width=198,height=42,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="lobby/hall_chip_bg.png"
		},
		{
			name="chipImg",type=1,typeName="Image",time=0,x=0,y=0,width=70,height=68,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="lobby/hall_cash.png"
		},
		{
			name="chipTxt",type=4,typeName="Text",time=0,x=77,y=20,width=134,height=27.8,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]]
		}
	},
	{
		name="cashBtn",type=1,typeName="Button",time=0,x=15,y=6,width=212,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomRight,file="ui/blank.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
		{
			name="cashTxtBg",type=1,typeName="Image",time=0,x=32,y=11,width=175,height=42,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="lobby/hall_chip_bg.png"
		},
		{
			name="cashImg",type=1,typeName="Image",time=0,x=0,y=0,width=70,height=68,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="lobby/hall_chip.png"
		},
		{
			name="cashTxt",type=4,typeName="Text",time=0,x=83,y=20,width=100,height=27.8,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]]
		}
	}
}
return chooseRoomPopup;