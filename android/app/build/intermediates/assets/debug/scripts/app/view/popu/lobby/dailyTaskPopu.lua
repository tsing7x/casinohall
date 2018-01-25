local dailyTaskPopu=
{
	name="dailyTaskPopu",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,
	{
		name="bg_mainPanel",type=1,typeName="Image",time=0,x=0,y=0,width=676,height=859,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/bg_big.png",
		{
			name="bg_titleBar",type=1,typeName="Image",time=0,x=0,y=-418,width=495,height=110,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/img_title.png",
			{
				name="dec_dscTitle",type=1,typeName="Image",time=0,x=0,y=-3,width=220,height=57,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="language/thai/popu/dailyTask/dTask_dscTitle.png"
			}
		},
		{
			name="btn_close",type=1,typeName="Button",time=0,x=320,y=-411,width=64,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/closebtn_ .png"
		},
		{
			name="vb_mainArea",type=0,typeName="View",time=0,x=0,y=42,width=626,height=720,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,
			{
				name="bg_dentMain",type=1,typeName="Image",time=0,x=0,y=0,width=626,height=720,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/img_inner_2.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20
			},
			{
				name="txt_noTaskDataHint",type=4,typeName="Text",time=0,x=0,y=0,width=290,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=32,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[No Task Data Hint]],colorA=1
			}
		}
	}
}
return dailyTaskPopu;