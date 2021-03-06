local messagePopu=
{
	name="messagePopu",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="img_popuBg",type=1,typeName="Image",time=0,x=0,y=0,width=676,height=859,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/bg_big.png",
		{
			name="img_title",type=1,typeName="Image",time=0,x=0,y=-50,width=495,height=110,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="popu/img_title.png",
			{
				name="Image8",type=1,typeName="Image",time=0,x=0,y=0,width=178,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/message/title.png"
			}
		},
		{
			name="btn_close",type=1,typeName="Button",time=0,x=-10,y=-10,width=73,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="popu/closebtn_ .png"
		},
		{
			name="img_tabs",type=1,typeName="Image",time=0,x=0,y=60,width=580,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="popu/tab_bg.png",gridLeft=40,gridRight=40,
			{
				name="btn_system",type=1,typeName="Button",time=0,x=3,y=0,width=290,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="ui/blank.png",
				{
					name="Image9",type=1,typeName="Image",time=0,x=0,y=0,width=111,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/message/system1.png"
				},
				{
					name="img_select",type=1,typeName="Image",time=0,x=0,y=0,width=290,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/tab_select.png",gridLeft=40,gridRight=40,
					{
						name="Image10",type=1,typeName="Image",time=0,x=0,y=0,width=120,height=42,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/message/system2.png"
					}
				}
			},
			{
				name="btn_game",type=1,typeName="Button",time=0,x=0,y=0,width=290,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="ui/blank.png",
				{
					name="Image9",type=1,typeName="Image",time=0,x=0,y=0,width=111,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/message/game1.png"
				},
				{
					name="img_select",type=1,typeName="Image",time=0,x=0,y=0,width=290,height=64,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/tab_select.png",gridLeft=40,gridRight=40,
					{
						name="Image10",type=1,typeName="Image",time=0,x=0,y=0,width=120,height=42,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/message/game2.png"
					}
				}
			}
		},
		{
			name="img_sysMsg",type=1,typeName="Image",time=0,x=0,y=20,width=620,height=700,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="popu/frame.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10,
			{
				name="sv_sysMsg",type=0,typeName="ScrollView",time=0,x=0,y=0,width=620,height=700,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter
			},
			{
				name="txt_noSysMsgHint",type=4,typeName="Text",time=0,x=0,y=0,width=234,height=45,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=35,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[No SysMsg Hint]],colorA=1
			}
		},
		{
			name="img_gameMsg",type=1,typeName="Image",time=0,x=0,y=20,width=620,height=700,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="popu/frame.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10,
			{
				name="sv_gameMsg",type=0,typeName="ScrollView",time=0,x=0,y=0,width=620,height=700,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter
			},
			{
				name="txt_noGameMsgHint",type=4,typeName="Text",time=0,x=0,y=0,width=267,height=45,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=35,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[No GameMsg Hint]]
			}
		}
	}
}
return messagePopu;