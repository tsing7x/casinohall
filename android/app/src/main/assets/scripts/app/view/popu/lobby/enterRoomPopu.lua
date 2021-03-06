local enterRoomPopu=
{
	name="enterRoomPopu",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignLeft,
	{
		name="img_popuBg",type=1,typeName="Image",time=0,x=0,y=40,width=720,height=1051,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/bigFrame.png",
		{
			name="title_bg",type=1,typeName="Image",time=0,x=0,y=-7,width=462,height=78,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="popu/img_title_2.png",
			{
				name="img_title",type=1,typeName="Image",time=0,x=0,y=-6,width=123,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/title_enter.png"
			}
		},
		{
			name="btn_bg",type=1,typeName="Image",time=0,x=0,y=-34,width=622,height=795,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/bg_create_room.png",
			{
				name="inputBg",type=1,typeName="Image",time=0,x=43,y=55,width=536,height=103,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/enterRoom/inputBg.png",
				{
					name="divide1",type=1,typeName="Image",time=0,x=89,y=0,width=2,height=89,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="popu/enterRoom/devide.png"
				},
				{
					name="divide2",type=1,typeName="Image",time=0,x=178,y=0,width=2,height=89,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="popu/enterRoom/devide.png"
				},
				{
					name="divide3",type=1,typeName="Image",time=0,x=267,y=0,width=2,height=89,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="popu/enterRoom/devide.png"
				},
				{
					name="divide4",type=1,typeName="Image",time=0,x=356,y=0,width=2,height=89,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="popu/enterRoom/devide.png"
				},
				{
					name="divide5",type=1,typeName="Image",time=0,x=445,y=0,width=2,height=89,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="popu/enterRoom/devide.png"
				},
				{
					name="viewNum",type=0,typeName="View",time=0,x=-42,y=-27,width=1,height=1,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
					{
						name="num1",type=1,typeName="Image",time=0,x=-182,y=34,width=25,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/inputNum/1.png"
					},
					{
						name="num2",type=1,typeName="Image",time=0,x=-92,y=34,width=25,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/inputNum/1.png"
					},
					{
						name="num3",type=1,typeName="Image",time=0,x=-2,y=34,width=25,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/inputNum/1.png"
					},
					{
						name="num4",type=1,typeName="Image",time=0,x=88,y=34,width=25,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/inputNum/1.png"
					},
					{
						name="num5",type=1,typeName="Image",time=0,x=178,y=34,width=25,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/inputNum/1.png"
					},
					{
						name="num6",type=1,typeName="Image",time=0,x=268,y=34,width=25,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/inputNum/1.png"
					}
				}
			},
			{
				name="tip",type=4,typeName="Text",time=0,x=50,y=170,width=242.85,height=46,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=115,colorGreen=114,colorBlue=114,string=[[房号在游戏牌桌上查看]],colorA=1
			},
			{
				name="viewBtn",type=0,typeName="View",time=0,x=0,y=29,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
				{
					name="btnNum1",type=1,typeName="Button",time=0,x=-181,y=-132,width=173,height=116,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/button.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
					{
						name="img",type=1,typeName="Image",time=0,x=0,y=0,width=17,height=43,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/1.png"
					}
				},
				{
					name="btnNum2",type=1,typeName="Button",time=0,x=0,y=-132,width=173,height=116,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/button.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
					{
						name="img",type=1,typeName="Image",time=0,x=0,y=0,width=30,height=44,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/2.png"
					}
				},
				{
					name="btnNum3",type=1,typeName="Button",time=0,x=181,y=-132,width=173,height=116,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/button.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
					{
						name="img",type=1,typeName="Image",time=0,x=0,y=0,width=30,height=45,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/3.png"
					}
				},
				{
					name="btnNum4",type=1,typeName="Button",time=0,x=-181,y=-8,width=173,height=116,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/button.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
					{
						name="img",type=1,typeName="Image",time=0,x=0,y=0,width=33,height=44,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/4.png"
					}
				},
				{
					name="btnNum5",type=1,typeName="Button",time=0,x=0,y=-8,width=173,height=116,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/button.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
					{
						name="img",type=1,typeName="Image",time=0,x=0,y=0,width=29,height=44,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/5.png"
					}
				},
				{
					name="btnNum6",type=1,typeName="Button",time=0,x=181,y=-8,width=173,height=116,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/button.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
					{
						name="img",type=1,typeName="Image",time=0,x=0,y=0,width=31,height=45,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/6.png"
					}
				},
				{
					name="btnNum7",type=1,typeName="Button",time=0,x=-181,y=116,width=173,height=116,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/button.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
					{
						name="img",type=1,typeName="Image",time=0,x=0,y=0,width=31,height=43,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/7.png"
					}
				},
				{
					name="btnNum8",type=1,typeName="Button",time=0,x=0,y=116,width=173,height=116,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/button.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
					{
						name="img",type=1,typeName="Image",time=0,x=0,y=0,width=30,height=45,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/8.png"
					}
				},
				{
					name="btnNum9",type=1,typeName="Button",time=0,x=181,y=116,width=173,height=116,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/button.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
					{
						name="img",type=1,typeName="Image",time=0,x=0,y=0,width=31,height=45,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/9.png"
					}
				},
				{
					name="btnNum0",type=1,typeName="Button",time=0,x=-181,y=240,width=173,height=116,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/button.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
					{
						name="img",type=1,typeName="Image",time=0,x=0,y=0,width=32,height=45,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/0.png"
					}
				},
				{
					name="btnNumC",type=1,typeName="Button",time=0,x=0,y=240,width=173,height=116,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/button.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
					{
						name="img",type=1,typeName="Image",time=0,x=0,y=0,width=57,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/clear.png"
					}
				},
				{
					name="btnNumD",type=1,typeName="Button",time=0,x=181,y=240,width=173,height=116,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/button.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
					{
						name="img",type=1,typeName="Image",time=0,x=0,y=0,width=51,height=28,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/enterRoom/delete.png"
					}
				}
			}
		},
		{
			name="btn_confirm",type=1,typeName="Button",time=0,x=0,y=424,width=262,height=91,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/btn_green.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
			{
				name="text_enterRoom",type=4,typeName="Text",time=0,x=0,y=0,width=182,height=51,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=44,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[进入房间]],colorA=1
			}
		},
		{
			name="btn_close",type=1,typeName="Button",time=0,x=319,y=-490,width=73,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/closebtn_ .png"
		}
	}
}
return enterRoomPopu;