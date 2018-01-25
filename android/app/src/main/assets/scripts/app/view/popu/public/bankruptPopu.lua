local bankruptPopu=
{
	name="bankruptPopu",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="img_popuBg",type=1,typeName="Image",time=0,x=25,y=331,width=682,height=661,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/bg_superBig.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
		{
			name="title_bg",type=1,typeName="Image",time=0,x=0,y=-50,width=496,height=110,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="bankrupt/bankruptTitle_bg.png",
			{
				name="img_title",type=1,typeName="Image",time=0,x=0,y=0,width=370,height=76,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="bankrupt/img_bankruptTitle.png"
			}
		},
		{
			name="btn_close",type=1,typeName="Button",time=0,x=-15,y=-15,width=73,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="popu/closebtn_ .png"
		},
		{
			name="img_itemBg",type=1,typeName="Image",time=0,x=29,y=85,width=626,height=534,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/createRoom/img_inner.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
			{
				name="view_loading",type=0,typeName="View",time=0,x=0,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter
			},
			{
				name="sv_inner",type=0,typeName="ScrollView",time=0,x=14,y=7,width=603,height=516,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft
			}
		}
	}
}
return bankruptPopu;