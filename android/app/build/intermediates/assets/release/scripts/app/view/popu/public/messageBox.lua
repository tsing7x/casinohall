local messageBox=
{
	name="messageBox",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,
	{
		name="img_popuBg",type=1,typeName="Image",time=0,x=0,y=0,width=676,height=472,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/bg_small.png",gridLeft=50,gridRight=50,gridTop=50,gridBottom=50,
		{
			name="text_title",type=4,typeName="Text",time=0,x=-2,y=57,width=176,height=51,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=44,textAlign=kAlignTop,colorRed=255,colorGreen=255,colorBlue=255,string=[[弹窗标题]],colorA=1
		},
		{
			name="btn_left",type=1,typeName="Button",time=0,x=-160,y=132,width=241,height=104,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/btn_blue.png",
			{
				name="text_left",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=57,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=50,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[取消]],colorA=1
			}
		},
		{
			name="btn_right",type=1,typeName="Button",time=0,x=162,y=132,width=241,height=104,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/btn_green.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
			{
				name="text_right",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=57,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=50,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[确定]]
			}
		},
		{
			name="btn_close",type=1,typeName="Button",time=0,x=618,y=-7,width=60,height=63,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/closebtn_ .png"
		},
		{
			name="text_content",type=5,typeName="TextView",time=0,x=2,y=-39,width=577,height=165,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignCenter,colorRed=0,colorGreen=255,colorBlue=51,string=[[弹窗内容]],colorA=1
		}
	}
}
return messageBox;