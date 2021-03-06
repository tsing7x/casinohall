local bigSettlePopu=
{
	name="bigSettlePopu",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="img_popuBg",type=1,typeName="Image",time=0,x=0,y=0,width=720,height=886,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/midFrame.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10,
		{
			name="img_title",type=1,typeName="Image",time=0,x=0,y=-7,width=527,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="popu/img_title_2.png",
			{
				name="img_title_content",type=1,typeName="Image",time=0,x=0,y=-7,width=150,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="games/settle/img_title.png"
			}
		},
		{
			name="btn_confirm",type=1,typeName="Button",time=0,x=0,y=49,width=260,height=90,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="popu/btn_green.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
			{
				name="text_confirm",type=4,typeName="Text",time=0,x=14,y=0,width=170,height=48.75,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,fontSize=42,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[继续游戏]]
			},
			{
				name="img_counterBg",type=1,typeName="Image",time=0,x=15,y=-2,width=54,height=54,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="games/settle/img_counter_bg.png",
				{
					name="text_counter",type=4,typeName="Text",time=0,x=0,y=0,width=36.65,height=41.65,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[78]],colorA=1
				}
			}
		},
		{
			name="btn_close",type=1,typeName="Button",time=0,x=612,y=-25,width=73,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/closebtn_ .png"
		},
		{
			name="view_inner",type=0,typeName="View",time=0,x=0,y=-32,width=620,height=640,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
			{
				name="img_inner",type=1,typeName="Image",time=0,x=312,y=219,width=620,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="common/img_inner.png",gridLeft=18,gridRight=18,gridTop=18,gridBottom=18
			},
			{
				name="view_myItem",type=0,typeName="View",time=0,x=0,y=8,width=606,height=122,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
				{
					name="itemBg",type=1,typeName="Image",time=0,x=0,y=0,width=606,height=122,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,file="games/settle/img_item_bg_1.png",gridLeft=20,gridRight=20
				},
				{
					name="view_rank",type=0,typeName="View",time=0,x=72,y=0,width=1,height=1,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,
					{
						name="img_rank",type=1,typeName="Image",time=0,x=0,y=0,width=89,height=65,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="games/settle/img_rank_1.png",
						{
							name="text_rank",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=48,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255
						}
					}
				},
				{
					name="view_head",type=0,typeName="View",time=0,x=138,y=0,width=82,height=82,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft
				},
				{
					name="text_name",type=4,typeName="Text",time=0,x=246,y=0,width=145,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=34,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],colorA=1
				},
				{
					name="tag_chip",type=1,typeName="Image",time=0,x=408,y=0,width=29,height=31,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="games/common/img_tableChip.png"
				},
				{
					name="text_turn",type=4,typeName="Text",time=0,x=30,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],colorA=1
				}
			}
		}
	}
}
return bigSettlePopu;