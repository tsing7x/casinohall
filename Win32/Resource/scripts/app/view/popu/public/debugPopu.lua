local debugPopu=
{
	name="debugPopu",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="img_popuBg",type=1,typeName="Image",time=0,x=0,y=0,width=600,height=400,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/img_inner.png",gridLeft=18,gridRight=18,gridTop=18,gridBottom=18,
		{
			name="img_inputBg",type=1,typeName="Image",time=0,x=0,y=0,width=600,height=400,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/img_inner.png",gridLeft=18,gridRight=18,gridTop=18,gridBottom=18,
			{
				name="edit_text",type=7,typeName="EditTextView",time=0,x=0,y=0,width=600,height=400,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignTopLeft,colorRed=255,colorGreen=255,colorBlue=255,colorA=1,string=[[AlarmTip.play("运行调试代码")]]
			}
		},
		{
			name="btn_execute",type=1,typeName="Button",time=0,x=-3,y=406,width=80,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="popu/btn_blue.png",
			{
				name="Text4",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,colorA=1,string=[[执行]]
			}
		},
		{
			name="btn_close",type=1,typeName="Button",time=0,x=566,y=-22,width=50,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/closebtn_ .png"
		}
	}
}
return debugPopu;