local loadingLayout=
{
	name="loadingLayout",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
	{
		name="view_loading",type=0,typeName="View",time=0,x=0,y=32,width=720,height=400,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignCenter,
		{
			name="shade_bg",type=1,typeName="Image",time=0,x=0,y=12,width=720,height=240,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="load/bg.png"
		},
		{
			name="img_loading_tip",type=1,typeName="Image",time=0,x=-2,y=134,width=90,height=90,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="login/img_loading_1.png"
		},
		{
			name="img_loading_tip13",type=1,typeName="Image",time=0,x=-2,y=163,width=38,height=36,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="login/img_loading_2.png"
		},
		{
			name="text_loading_tip",type=4,typeName="Text",time=0,x=0,y=97,width=240,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,fontSize=30,textAlign=kAlignBottom,colorRed=255,colorGreen=255,colorBlue=255,string=[[กำลังโหลด...]],colorA=1
		}
	}
}
return loadingLayout;