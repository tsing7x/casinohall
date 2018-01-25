local errorTipBox=
{
	name="errorTipBox",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,
	{
		name="Image4",type=1,typeName="Image",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/bg_superBig.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20
	},
	{
		name="View",type=0,typeName="View",time=0,x=0,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
		{
			name="Text7",type=4,typeName="Text",time=0,x=-50,y=-333,width=200,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=50,textAlign=kAlignBottom,colorRed=255,colorGreen=255,colorBlue=255,string=[[错误提示]]
		},
		{
			name="TextView",type=5,typeName="TextView",time=0,x=0,y=0,width=1200,height=500,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignTopLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[TextView]]
		},
		{
			name="Button",type=1,typeName="Button",time=0,x=-70,y=330,width=241,height=104,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/btn_green.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
			{
				name="Text5",type=4,typeName="Text",time=0,x=70,y=5,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=50,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[确定]]
			}
		}
	}
}
return errorTipBox;