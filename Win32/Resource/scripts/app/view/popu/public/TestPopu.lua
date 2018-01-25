local TestPopu=
{
	name="TestPopu",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,
	{
		name="Image2",type=1,typeName="Image",time=0,x=0,y=0,width=500,height=300,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="lobby/hall_avator_bg.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10,
		{
			name="text_title",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[弹窗标题]],colorA=1
		},
		{
			name="text_content",type=4,typeName="Text",time=0,x=0,y=0,width=146.65,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignCenter,colorRed=0,colorGreen=255,colorBlue=51,string=[[活动中心]],colorA=1
		}
	}
}
return TestPopu;