local pokdengLayout=
{
	name="pokdengLayout",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="img_room_bg",type=1,typeName="Image",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="games/pokdeng/room_bg.png",
		{
			name="btn_back",type=1,typeName="Button",time=0,x=10,y=10,width=70,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="games/common/btn_back.png"
		},
		{
			name="btn_face",type=1,typeName="Button",time=0,x=10,y=10,width=66,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomLeft,file="games/common/btn_face.png"
		},
		{
			name="btn_feedback",type=1,typeName="Button",time=0,x=95,y=10,width=70,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="games/common/btn_feedback.png"
		},
		{
			name="btn_help",type=1,typeName="Button",time=0,x=10,y=10,width=66,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="games/common/btn_help.png"
		},
		{
			name="btn_chat",type=1,typeName="Button",time=0,x=95,y=10,width=66,height=60,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomLeft,file="games/common/btn_chat.png"
		},
		{
			name="btn_shop",type=1,typeName="Button",time=0,x=170,y=10,width=70,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="games/common/btn_addchip.png"
		},
		{
			name="btn_detail",type=1,typeName="Button",time=0,x=10,y=80,width=66,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomLeft,file="games/common/btn_detail.png"
		}
	},
	{
		name="view_table",type=0,typeName="View",time=0,x=0,y=30,width=670,height=1100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
		{
			name="img_table",type=1,typeName="Image",time=0,x=0,y=0,width=670,height=1100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="games/pokdeng/room_table.png"
		},
		{
			name="image_logo",type=1,typeName="Image",time=0,x=209,y=259,width=252,height=86,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="games/pokdeng/ogo.png"
		},
		{
			name="view_dealer",type=0,typeName="View",time=0,x=0,y=0,width=100,height=100,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="btn_fee",type=1,typeName="Button",time=0,x=-100,y=-67,width=78,height=68,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="games/common/img_fee.png"
			},
			{
				name="img_dealer",type=1,typeName="Image",time=0,x=0,y=0,width=172,height=197,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="games/common/dealer.png"
			}
		},
		{
			name="view_info",type=0,typeName="View",time=0,x=0,y=160,width=147,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="text_round",type=4,typeName="Text",time=0,x=0,y=0,width=147,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=47,colorGreen=127,colorBlue=201,string=[[局数：0/10]],colorA=1
			},
			{
				name="text_baseAnte",type=4,typeName="Text",time=0,x=0,y=29,width=147,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=47,colorGreen=127,colorBlue=201,string=[[底注：100]],colorA=1
			},
			{
				name="text_roomCode",type=4,typeName="Text",time=0,x=0,y=58,width=147,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=47,colorGreen=127,colorBlue=201,string=[[口令：123456]],colorA=1
			}
		},
		{
			name="view_inct",type=0,typeName="View",time=0,x=0,y=0,width=1,height=1,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
			{
				name="img_inct",type=1,typeName="Image",time=0,x=0,y=0,width=132,height=418,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="games/common/img_pointer.png"
			}
		},
		{
			name="view_players",type=0,typeName="View",time=0,x=0,y=0,width=670,height=1100,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft
		},
		{
			name="view_tableTip",type=0,typeName="View",time=0,x=0,y=200,width=300,height=80,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,
			{
				name="Image34",type=1,typeName="Image",time=0,x=36,y=45,width=300,height=80,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="common/img_inner.png",gridLeft=18,gridRight=18,gridTop=18,gridBottom=18
			},
			{
				name="text_tableTip",type=4,typeName="Text",time=0,x=0,y=0,width=220,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[等待闲家下注]],colorA=1
			}
		},
		{
			name="view_banker",type=0,typeName="View",time=0,x=30,y=-50,width=119,height=89,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomRight,
			{
				name="btn_up_banker",type=1,typeName="Button",time=0,x=0,y=0,width=119,height=89,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="games/pokdeng/btn_up_banker.png"
			},
			{
				name="btn_down_banker",type=1,typeName="Button",time=0,x=0,y=0,width=119,height=89,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="games/pokdeng/btn_down_banker.png"
			}
		}
	},
	{
		name="view_operate",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignBottom,
		{
			name="thirdCard",type=0,typeName="View",time=0,x=0,y=0,width=720,height=100,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottom,
			{
				name="view_inner",type=0,typeName="View",time=0,x=0,y=0,width=720,height=100,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignBottom,
				{
					name="btn_buyao",type=1,typeName="Button",time=0,x=10,y=-5,width=180,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomLeft,file="popu/btn_blue.png",
					{
						name="text_buyao",type=4,typeName="Text",time=0,x=0,y=0,width=113.35,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=50,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[要 牌]],colorA=1
					}
				},
				{
					name="btn_yao",type=1,typeName="Button",time=0,x=10,y=-5,width=180,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomRight,file="popu/btn_green.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
					{
						name="text_yao",type=4,typeName="Text",time=0,x=0,y=0,width=113.35,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=50,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[要 牌]]
					}
				}
			}
		},
		{
			name="bankerStart",type=0,typeName="View",time=0,x=0,y=300,width=720,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
			{
				name="btn_invite",type=1,typeName="Button",time=0,x=175,y=5,width=170,height=90,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomLeft,file="popu/btn_blue.png",
				{
					name="text_invite",type=4,typeName="Text",time=0,x=0,y=0,width=146.65,height=41.65,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[邀请好友]],colorA=1
				}
			},
			{
				name="btn_startGame",type=1,typeName="Button",time=0,x=0,y=0,width=170,height=90,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/btn_green.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
				{
					name="text_startGame",type=4,typeName="Text",time=0,x=0,y=0,width=146.65,height=41.65,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[开始游戏]]
				}
			}
		}
	}
}
return pokdengLayout;