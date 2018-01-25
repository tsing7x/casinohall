local updatePopu=
{
	name="updatePopu",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="img_popuBg",type=1,typeName="Image",time=0,x=0,y=0,width=676,height=592,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/bg_middle.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10,
		{
			name="img_title",type=1,typeName="Image",time=0,x=0,y=-38,width=495,height=110,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="popu/img_title.png",
			{
				name="text_title",type=4,typeName="Text",time=0,x=0,y=-4,width=340,height=57,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=50,textAlign=kAlignTop,colorRed=102,colorGreen=102,colorBlue=0,string=[[Find new version]],colorA=1
			}
		},
		{
			name="btn_cancel",type=1,typeName="Button",time=0,x=64,y=439,width=241,height=104,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/btn_blue.png",
			{
				name="text_cancel",type=4,typeName="Text",time=0,x=0,y=4,width=200,height=57,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=50,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[下次更新]],colorA=1
			}
		},
		{
			name="btn_confirm",type=1,typeName="Button",time=0,x=377,y=439,width=241,height=104,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/btn_green.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
			{
				name="text_confirm",type=4,typeName="Text",time=0,x=0,y=4,width=200,height=57,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=50,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[立即更新]]
			}
		},
		{
			name="view_content",type=0,typeName="View",time=0,x=0,y=160,width=580,height=320,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,
			{
				name="view_updateInfo",type=0,typeName="ScrollView",time=0,x=0,y=0,width=580,height=220,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottom
			},
			{
				name="text_version",type=4,typeName="Text",time=0,x=0,y=0,width=250,height=31.65,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=26,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[更新版本: 1.0.2]],colorA=1
			},
			{
				name="text_size_tip",type=4,typeName="Text",time=0,x=0,y=40,width=111.65,height=31.65,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=26,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[更新大小:]],colorA=1,
				{
					name="text_size",type=4,typeName="Text",time=0,x=120,y=0,width=50,height=31.65,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=26,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=0,string=[[10M]],colorA=1
				}
			}
		}
	}
}
return updatePopu;