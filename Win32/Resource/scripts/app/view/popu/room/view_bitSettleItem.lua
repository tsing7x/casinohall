local view_bitSettleItem=
{
	name="view_bitSettleItem",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="view_prefeb",type=0,typeName="View",time=0,x=0,y=0,width=610,height=95,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
		{
			name="itemBg",type=1,typeName="Image",time=0,x=0,y=0,width=610,height=95,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,file="games/settle/img_item_bg_2.png",gridLeft=20,gridRight=20
		},
		{
			name="img_rank",type=1,typeName="Image",time=0,x=18,y=0,width=89,height=65,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="games/settle/img_rank_1.png"
		},
		{
			name="view_head",type=0,typeName="View",time=0,x=130,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft
		},
		{
			name="text_name",type=4,typeName="Text",time=0,x=256,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]]
		},
		{
			name="tag_chip",type=1,typeName="Image",time=0,x=408,y=0,width=29,height=31,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="games/common/img_tableChip.png"
		},
		{
			name="text_turn",type=4,typeName="Text",time=0,x=30,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]]
		}
	}
}
return view_bitSettleItem;