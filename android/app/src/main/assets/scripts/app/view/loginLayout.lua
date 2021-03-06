local loginLayout=
{
	name="loginLayout",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="img_bg",type=1,typeName="Image",time=108906194,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopRight,file="login/img_bg.png",
		{
			name="view_login",type=0,typeName="View",time=108906239,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
			{
				name="btn_login_vistor",type=1,typeName="Button",time=0,x=3,y=477,width=530,height=154,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="login/btn_login_vistor.png"
			},
			{
				name="btn_login_fb",type=1,typeName="Button",time=0,x=5,y=277,width=530,height=154,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="login/btn_login_fb.png"
			},
			{
				name="text_tip",type=4,typeName="Text",time=0,x=0,y=12,width=443.35,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,fontSize=30,textAlign=kAlignBottom,colorRed=255,colorGreen=255,colorBlue=255,string=[[ล็อกอินบัญชี FB สินทรัพย์ปลอดภัยกว่า]],colorA=1
			}
		},
		{
			name="debug",type=0,typeName="View",time=0,x=0,y=100,width=300,height=200,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="test",type=1,typeName="Button",time=0,x=0,y=0,width=120,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="ui/button.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
				{
					name="Text10",type=4,typeName="Text",time=0,x=0,y=0,width=120,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[测试]],colorA=1
				}
			},
			{
				name="release",type=1,typeName="Button",time=0,x=0,y=0,width=120,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="ui/button.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
				{
					name="Text10",type=4,typeName="Text",time=0,x=0,y=0,width=120,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[正式]],colorA=1
				}
			},
			{
				name="CHN",type=1,typeName="Button",time=0,x=2,y=87,width=120,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="ui/button.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
				{
					name="Text14",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[中文]],colorA=1
				}
			},
			{
				name="TPE",type=1,typeName="Button",time=0,x=179,y=87,width=120,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="ui/button.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
				{
					name="Text15",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[泰文]]
				}
			}
		}
	}
}
return loginLayout;