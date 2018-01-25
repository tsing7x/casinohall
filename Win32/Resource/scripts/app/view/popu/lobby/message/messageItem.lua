local messageItem=
{
	name="messageItem",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignBottom,
	{
		name="img_bgPanel",type=1,typeName="Image",time=0,x=0,y=0,width=608,height=118,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomLeft,file="popu/message/msg_bgItem.png",
		{
			name="img_icMail",type=1,typeName="Image",time=0,x=-250,y=0,width=50,height=36,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/message/msg_icMail.png"
		},
		{
			name="tv_msgContTitle",type=5,typeName="TextView",time=0,x=105,y=-15,width=260,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=26,textAlign=kAlignLeft,colorRed=83,colorGreen=85,colorBlue=84,string=[[Msg Cont Title]],colorA=1
		},
		{
			name="img_icChip",type=1,typeName="Image",time=0,x=105,y=20,width=25,height=25,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="popu/message/msg_icChip.png"
		},
		{
			name="txt_chipNum",type=4,typeName="Text",time=0,x=136,y=20,width=200,height=27,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=22,textAlign=kAlignLeft,colorRed=165,colorGreen=90,colorBlue=59,string=[[+0]],colorA=1
		},
		{
			name="txt_msgRcvDate",type=4,typeName="Text",time=0,x=40,y=0,width=115,height=30,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,fontSize=24,textAlign=kAlignLeft,colorRed=84,colorGreen=84,colorBlue=84,string=[[1970/01/01]],colorA=1
		},
		{
			name="btn_action",type=1,typeName="Button",time=0,x=28,y=0,width=196,height=66,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="popu/v210/btn_grey.png",gridLeft=35,gridRight=35,gridTop=30,gridBottom=30,
			{
				name="img_dscAction",type=1,typeName="Image",time=0,x=0,y=-6,width=98,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="language/thai/popu/message/msg_dscDraw.png"
			}
		}
	}
}
return messageItem;