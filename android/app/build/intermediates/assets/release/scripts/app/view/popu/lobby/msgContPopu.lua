local msgContPopu=
{
	name="msgContPopu",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="bg_mainPanel",type=1,typeName="Image",time=0,x=0,y=0,width=676,height=592,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/bg_middle.png",
		{
			name="btn_close",type=1,typeName="Button",time=0,x=626,y=-15,width=64,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/closebtn_ .png"
		},
		{
			name="bg_titleBar",type=1,typeName="Image",time=0,x=0,y=18,width=462,height=78,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="popu/img_title_2.png",
			{
				name="img_dscTitle",type=1,typeName="Image",time=0,x=0,y=-3,width=230,height=68,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="3312b8070c548c249a8ed4e7060268ec"
			}
		},
		{
			name="bg_mainContDent",type=1,typeName="Image",time=0,x=0,y=0,width=626,height=340,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/frame.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10,
			{
				name="tv_msgTitle",type=5,typeName="TextView",time=0,x=0,y=-128,width=527,height=48,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignCenter,colorRed=195,colorGreen=214,colorBlue=254,string=[[MsgTitle]],colorA=1
			},
			{
				name="tv_msgCont",type=5,typeName="TextView",time=0,x=0,y=36,width=578,height=242,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=26,textAlign=kAlignTopLeft,colorRed=120,colorGreen=150,colorBlue=222,string=[[MsgCont]],colorA=1
			}
		},
		{
			name="btn_confirm",type=1,typeName="Button",time=0,x=0,y=225,width=268,height=96,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/btn_green.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
			{
				name="txt_confrim",type=4,typeName="Text",time=0,x=0,y=0,width=268,height=96,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=35,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Action]],colorA=1
			}
		}
	}
}
return msgContPopu;