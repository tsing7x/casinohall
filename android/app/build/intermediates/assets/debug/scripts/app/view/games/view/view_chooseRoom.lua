local view_chooseRoom=
{
	name="view_chooseRoom",type=0,typeName="View",time=0,x=0,y=0,width=265,height=303,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
	{
		name="bg",type=1,typeName="Image",time=0,x=0,y=0,width=265,height=303,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/chooseRoom/img_poker_room1.png"
	},
	{
		name="numPic1",type=1,typeName="Image",time=0,x=48,y=136,width=58,height=67,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/chooseRoom/img_num_1.png"
	},
	{
		name="numPic2",type=1,typeName="Image",time=0,x=106,y=136,width=58,height=67,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/chooseRoom/img_num_k.png"
	},
	{
		name="numPic3",type=1,typeName="Image",time=0,x=164,y=136,width=58,height=67,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/chooseRoom/img_num_k.png"
	},
	{
		name="minReqTxt",type=4,typeName="Text",time=0,x=8,y=70,width=150,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[最小进入值 3K]]
	},
	{
		name="maxReqTxt",type=4,typeName="Text",time=0,x=11,y=93,width=161.65,height=38,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[最大进入值 10K]]
	},
	{
		name="imgOnlineFrame",type=1,typeName="Image",time=0,x=2,y=123,width=160,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/chooseRoom/img_online_frame.png",
		{
			name="imgOnlineIcon",type=1,typeName="Image",time=0,x=-48,y=3,width=21,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/chooseRoom/img_online_icon.png"
		},
		{
			name="onlineTxt",type=4,typeName="Text",time=0,x=68,y=1,width=88,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=20,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[2345]]
		}
	},
	{
		name="chooseRoomBtn",type=1,typeName="Button",time=0,x=0,y=0,width=265,height=303,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="ui/blank.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20
	}
}
return view_chooseRoom;