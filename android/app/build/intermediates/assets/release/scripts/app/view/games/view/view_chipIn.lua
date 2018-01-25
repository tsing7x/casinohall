local view_chipIn=
{
	name="view_chipIn",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="view_bg",type=0,typeName="View",time=0,x=0,y=0,width=720,height=296,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
		{
			name="Image12",type=1,typeName="Image",time=0,x=0,y=0,width=720,height=296,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="games/pokdeng/chipIn/img_chipView_bg.png"
		},
		{
			name="btn_chip_1",type=1,typeName="Button",time=0,x=34,y=76,width=136,height=140,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="games/pokdeng/chipIn/btn_chip_1.png",
			{
				name="text_chip_1",type=4,typeName="Text",time=0,x=0,y=0,width=61.25,height=51,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=38,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[1M]],colorA=1
			}
		},
		{
			name="btn_chip_2",type=1,typeName="Button",time=0,x=205,y=76,width=136,height=140,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="games/pokdeng/chipIn/btn_chip_2.png",
			{
				name="text_chip_2",type=4,typeName="Text",time=0,x=0,y=0,width=61.25,height=51,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=38,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[1M]],colorA=1
			}
		},
		{
			name="btn_chip_3",type=1,typeName="Button",time=0,x=376,y=76,width=136,height=140,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="games/pokdeng/chipIn/btn_chip_3.png",
			{
				name="text_chip_3",type=4,typeName="Text",time=0,x=0,y=0,width=83.75,height=51,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=38,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[10M]],colorA=1
			}
		},
		{
			name="btn_repeat",type=1,typeName="Button",time=0,x=541,y=172,width=146,height=72,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/btn_green_s.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
			{
				name="text_repeat",type=4,typeName="Text",time=0,x=0,y=0,width=130,height=38,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=32,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[重复上轮]],colorA=1
			}
		},
		{
			name="btn_addChip",type=1,typeName="Button",time=0,x=541,y=79,width=146,height=72,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/btn_yellow_s.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
			{
				name="text_addChip",type=4,typeName="Text",time=0,x=0,y=0,width=128,height=38,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=32,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[加 注]]
			}
		},
		{
			name="text_in_min",type=4,typeName="Text",time=0,x=100,y=12,width=144,height=39,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomLeft,fontSize=24,textAlign=kAlignLeft,colorRed=173,colorGreen=132,colorBlue=50,string=[[MIN : 100]],colorA=1
		},
		{
			name="text_in_max",type=4,typeName="Text",time=0,x=272,y=12,width=192,height=39,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomLeft,fontSize=24,textAlign=kAlignLeft,colorRed=173,colorGreen=132,colorBlue=50,string=[[MAX : 10000]],colorA=1
		}
	}
}
return view_chipIn;