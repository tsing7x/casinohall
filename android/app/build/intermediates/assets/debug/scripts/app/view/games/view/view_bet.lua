local view_bet=
{
	name="view_bet",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="img_chipBg",type=1,typeName="Image",time=0,x=0,y=0,width=88,height=25,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="games/common/img_chip_bg.png",
		{
			name="text_bet",type=4,typeName="Text",time=0,x=26,y=0,width=54,height=27.5,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[1,000]]
		},
		{
			name="chipView",type=0,typeName="View",time=0,x=-5,y=0,width=1,height=1,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,
			{
				name="img_chip",type=1,typeName="Image",time=0,x=0,y=0,width=29,height=31,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="games/common/img_tableChip.png"
			}
		}
	}
}
return view_bet;