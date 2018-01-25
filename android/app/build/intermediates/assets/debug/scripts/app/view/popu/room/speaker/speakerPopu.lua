local speakerPopu=
{
	name="speakerPopu",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="img_popuBg",type=1,typeName="Image",time=0,x=0,y=0,width=676,height=592,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/bg_middle.png",gridLeft=50,gridRight=50,gridTop=50,gridBottom=50,
		{
			name="btn_close",type=1,typeName="Button",time=0,x=-10,y=-5,width=73,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="popu/closebtn_ .png"
		},
		{
			name="img_tabBg",type=1,typeName="Image",time=0,x=0,y=30,width=450,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="popu/tab_bg.png",gridLeft=40,gridRight=40,
			{
				name="btn_speaker",type=1,typeName="Button",time=0,x=2,y=0,width=220,height=62,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="ui/blank.png",
				{
					name="Image7",type=1,typeName="Image",time=0,x=0,y=0,width=148,height=38,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/speaker/text_sendSpeaker1.png"
				},
				{
					name="img_select",type=1,typeName="Image",time=0,x=0,y=0,width=220,height=62,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/tab_select.png",gridLeft=40,gridRight=40,
					{
						name="Image9",type=1,typeName="Image",time=0,x=0,y=0,width=158,height=48,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/speaker/text_sendSpeaker2.png"
					}
				}
			},
			{
				name="btn_record",type=1,typeName="Button",time=0,x=2,y=0,width=220,height=62,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="ui/blank.png",
				{
					name="Image11",type=1,typeName="Image",time=0,x=0,y=0,width=208,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/speaker/text_speakerRecord1.png"
				},
				{
					name="img_select",type=1,typeName="Image",time=0,x=0,y=0,width=220,height=62,visible=0,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/tab_select.png",gridLeft=40,gridRight=40,
					{
						name="Image13",type=1,typeName="Image",time=0,x=0,y=0,width=216,height=42,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/speaker/text_speakerRecord2.png"
					}
				}
			}
		},
		{
			name="view_speaker",type=0,typeName="View",time=0,x=0,y=25,width=600,height=450,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,
			{
				name="Image14",type=1,typeName="Image",time=0,x=0,y=0,width=600,height=250,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,file="popu/speaker/input_bg.png",gridLeft=5,gridRight=5,gridTop=5,gridBottom=5,
				{
					name="et_speaker",type=7,typeName="EditTextView",time=0,x=5,y=8,width=584,height=230,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=30,textAlign=kAlignTopLeft,colorRed=78,colorGreen=110,colorBlue=188,colorA=1
				}
			},
			{
				name="text_tips",type=5,typeName="TextView",time=0,x=0,y=250,width=600,height=80,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=28,textAlign=kAlignLeft,colorRed=223,colorGreen=181,colorBlue=64,colorA=1
			},
			{
				name="btn_send",type=1,typeName="Button",time=0,x=0,y=10,width=241,height=104,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="popu/btn_green.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
				{
					name="text_btn",type=4,typeName="Text",time=0,x=0,y=0,width=93,height=68,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=80,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,colorA=1
				},
				{
					name="img_msg_num",type=1,typeName="Image",time=0,x=-8,y=-8,width=48,height=48,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/speaker/remind.png",
					{
						name="text_msg_num",type=4,typeName="Text",time=0,x=0,y=0,width=48,height=48,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[0]],colorA=1
					}
				}
			}
		},
		{
			name="view_record",type=0,typeName="View",time=0,x=0,y=25,width=600,height=450,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,
			{
				name="Image21",type=1,typeName="Image",time=0,x=-151,y=-88,width=600,height=450,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,file="popu/speaker/input_bg.png",gridLeft=5,gridRight=5,gridTop=5,gridBottom=5,
				{
					name="sv_record",type=0,typeName="ScrollView",time=0,x=0,y=0,width=600,height=450,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter
				}
			}
		}
	}
}
return speakerPopu;