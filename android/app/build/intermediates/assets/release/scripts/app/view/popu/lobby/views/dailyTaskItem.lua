local dailyTaskItem=
{
	name="dailyTaskItem",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignBottomLeft,
	{
		name="bg_item",type=1,typeName="Image",time=0,x=0,y=0,width=614,height=144,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomLeft,file="popu/dailyTask/dTask_bgListItem.png",
		{
			name="ic_task",type=1,typeName="Image",time=0,x=-13,y=0,width=150,height=142,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/dailyTask/dTask_icWin1st.png"
		},
		{
			name="txt_taskName",type=4,typeName="Text",time=0,x=128,y=-42,width=102,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=22,textAlign=kAlignLeft,colorRed=167,colorGreen=210,colorBlue=255,colorA=1,string=[[Task Name]]
		},
		{
			name="tv_rewDsc",type=5,typeName="TextView",time=0,x=128,y=0,width=280,height=53,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=22,textAlign=kAlignTopLeft,colorRed=167,colorGreen=210,colorBlue=255,string=[[Reward Dsc]],colorA=1
		},
		{
			name="txt_target",type=4,typeName="Text",time=0,x=128,y=41,width=250,height=30,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=22,textAlign=kAlignLeft,colorRed=167,colorGreen=210,colorBlue=255,string=[[Task Target Dsc]],colorA=1
		},
		{
			name="txt_taskProgress",type=4,typeName="Text",time=0,x=262,y=-42,width=129,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=209,colorBlue=48,string=[[(Progress Info)]],colorA=1
		},
		{
			name="btn_itemAction",type=1,typeName="Button",time=0,x=200,y=0,width=172,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/btn_rightAnglGrey.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
			{
				name="txt_btnAction",type=4,typeName="Text",time=0,x=0,y=0,width=166,height=68,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=28,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Action]],colorA=1
			}
		}
	}
}
return dailyTaskItem;