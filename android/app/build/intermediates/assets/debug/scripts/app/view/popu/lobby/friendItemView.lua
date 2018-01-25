local friendItemView=
{
	name="friendItemView",type=0,typeName="View",time=0,x=0,y=0,width=626,height=116,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="item_bg",type=1,typeName="Image",time=0,x=0,y=0,width=626,height=112,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/blank.png",
		{
			name="online",type=1,typeName="Image",time=0,x=17,y=0,width=24,height=24,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="popu/friends/online.png"
		},
		{
			name="avatar_bg",type=1,typeName="Image",time=0,x=58,y=0,width=88,height=88,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/white.png"
		},
		{
			name="text_name",type=4,typeName="Text",time=0,x=162,y=-20,width=100,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=30,textAlign=kAlignLeft,colorRed=141,colorGreen=50,colorBlue=24,string=[[Text]],colorA=1
		},
		{
			name="Image7",type=1,typeName="Image",time=0,x=165,y=20,width=26,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="popu/friends/tag_chip.png"
		},
		{
			name="text_chip",type=4,typeName="Text",time=0,x=207,y=20,width=100,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=24,textAlign=kAlignLeft,colorRed=244,colorGreen=254,colorBlue=4,string=[[55214]],colorA=1
		},
		{
			name="sex",type=1,typeName="Image",time=0,x=280,y=-20,width=22,height=22,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="popu/friends/male.png"
		},
		{
			name="btn_follow",type=1,typeName="Button",time=0,x=20,y=0,width=146,height=72,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="common/btn_green_min.png",
			{
				name="Image15",type=1,typeName="Image",time=0,x=0,y=-5,width=108,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/friends/follow.png"
			}
		},
		{
			name="btn_recall",type=1,typeName="Button",time=0,x=20,y=0,width=146,height=72,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="common/btn_yellow_min.png",
			{
				name="Image16",type=1,typeName="Image",time=0,x=0,y=-5,width=74,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/friends/recall.png"
			}
		},
		{
			name="text_ing",type=4,typeName="Text",time=0,x=322,y=-15,width=100,height=26.65,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=22,textAlign=kAlignLeft,colorRed=141,colorGreen=50,colorBlue=24,string=[[0]],colorA=1
		},
		{
			name="text_game",type=4,typeName="Text",time=0,x=322,y=15,width=100,height=26.65,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=205,colorBlue=25,string=[[0]],colorA=1
		},
		{
			name="btn_avatar",type=1,typeName="Button",time=0,x=58,y=0,width=88,height=88,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="ui/blank.png"
		}
	},
	{
		name="line",type=1,typeName="Image",time=0,x=0,y=0,width=624,height=4,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="popu/friends/separate_lines.png"
	}
}
return friendItemView;