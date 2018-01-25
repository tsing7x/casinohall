local buyRecordItem=
{
	name="buyRecordItem",type=0,typeName="View",time=0,x=0,y=0,width=700,height=155,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
	{
		name="Image3",type=1,typeName="Image",time=0,x=0,y=0,width=676,height=145,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/shop/item_bg.png",
		{
			name="text_time",type=4,typeName="Text",time=0,x=230,y=70,width=120,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=82,colorGreen=82,colorBlue=87,string=[[2017-01-01]],colorA=1
		},
		{
			name="text_shop",type=4,typeName="Text",time=0,x=230,y=20,width=77.15,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=26,textAlign=kAlignLeft,colorRed=206,colorGreen=233,colorBlue=250,colorA=1
		},
		{
			name="text_num",type=4,typeName="Text",time=0,x=350,y=20,width=100,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=26,textAlign=kAlignLeft,colorRed=240,colorGreen=194,colorBlue=55,string=[[x1]],colorA=1
		},
		{
			name="View9",type=0,typeName="View",time=0,x=2,y=0,width=160,height=136,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
			{
				name="img_icon",type=1,typeName="Image",time=0,x=0,y=0,width=105,height=105,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/shop/propIcon/shop_chip.png"
			}
		}
	},
	{
		name="status",type=1,typeName="Image",time=0,x=5,y=2,width=169,height=122,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="popu/shop/record/1.png"
	}
}
return buyRecordItem;