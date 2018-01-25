local brandDescPopu=
{
	name="brandDescPopu",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="img_popuBg",type=1,typeName="Image",time=0,x=0,y=0,width=720,height=1051,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/bigFrame.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
		{
			name="img_title",type=1,typeName="Image",time=0,x=0,y=-6,width=527,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="popu/img_title_2.png",
			{
				name="Image19",type=1,typeName="Image",time=0,x=0,y=-4,width=88,height=38,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="games/pokdeng/brandDesc/title.png"
			}
		},
		{
			name="btn_close",type=1,typeName="Button",time=0,x=607,y=-23,width=113,height=110,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/closebtn_ .png"
		},
		{
			name="Image14",type=1,typeName="Image",time=0,x=0,y=100,width=626,height=850,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/img_inner_2.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
			{
				name="ScrollView24",type=0,typeName="ScrollView",time=0,x=0,y=0,width=626,height=848,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
				{
					name="View10",type=0,typeName="View",time=0,x=0,y=0,width=626,height=1430,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
					{
						name="Image25",type=1,typeName="Image",time=0,x=0,y=15,width=626,height=1400,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="games/pokdeng/brandDesc/desc.png"
					}
				}
			}
		},
		{
			name="Image22",type=1,typeName="Image",time=0,x=0,y=920,width=624,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/img_inner_2_shadow.png"
		}
	}
}
return brandDescPopu;