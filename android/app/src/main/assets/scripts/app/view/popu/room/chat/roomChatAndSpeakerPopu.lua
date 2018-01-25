local roomChatAndSpeakerPopu=
{
	name="roomChatAndSpeakerPopu",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="img_bg",type=1,typeName="Image",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="ui/blank.png",
		{
			name="img_popuBg",type=1,typeName="Image",time=0,x=21,y=652,width=691,height=593,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/bg_small.png",gridLeft=50,gridRight=50,gridTop=50,gridBottom=50,
			{
				name="view_content",type=0,typeName="View",time=0,x=150,y=52,width=459,height=357,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft
			},
			{
				name="view_expression",type=0,typeName="View",time=0,x=145,y=56,width=498,height=499,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
				{
					name="view_normalList",type=0,typeName="View",time=0,x=0,y=4,width=498,height=499,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
					{
						name="sv_normalList",type=0,typeName="ScrollView",time=0,x=0,y=0,width=498,height=499,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft
					}
				}
			},
			{
				name="view_word",type=0,typeName="View",time=0,x=0,y=0,width=691,height=593,visible=0,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
				{
					name="View1",type=0,typeName="View",time=0,x=147,y=61,width=504,height=396,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
					{
						name="sv_wordUsual",type=0,typeName="ScrollView",time=0,x=154,y=84,width=504,height=396,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft
					}
				}
			},
			{
				name="view_speaker",type=0,typeName="View",time=0,x=139,y=62,width=501,height=390,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
				{
					name="view11",type=0,typeName="View",time=0,x=0,y=-5,width=497,height=405,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
					{
						name="sv_speakerHistory",type=0,typeName="ScrollView",time=0,x=154,y=84,width=497,height=405,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft
					}
				}
			},
			{
				name="view_button",type=0,typeName="View",time=0,x=30,y=25,width=100,height=545,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
				{
					name="img_bg01",type=1,typeName="Image",time=0,x=-1,y=3,width=100,height=537,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="room/chat/button_bg.png",
					{
						name="view_btn_expression",type=0,typeName="View",time=0,x=1,y=-3,width=100,height=180,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,
						{
							name="btn_unselect",type=1,typeName="Button",time=0,x=185,y=122,width=100,height=180,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="room/chat/img_upper.png",
							{
								name="Image1",type=1,typeName="Image",time=0,x=0,y=0,width=56,height=56,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="room/chat/img_smail.png"
							}
						},
						{
							name="img_select",type=1,typeName="Image",time=0,x=-33,y=-28,width=100,height=180,visible=0,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="room/chat/img_selectedUpper.png",
							{
								name="Image2",type=1,typeName="Image",time=0,x=0,y=0,width=66,height=66,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="room/chat/img_smailHover.png"
							}
						}
					},
					{
						name="view_btn_chat",type=0,typeName="View",time=0,x=0,y=0,width=100,height=184,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignCenter,
						{
							name="btn_unselect",type=1,typeName="Button",time=0,x=0,y=0,width=100,height=184,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="room/chat/img_middle.png",
							{
								name="Image1",type=1,typeName="Image",time=0,x=0,y=0,width=56,height=52,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="room/chat/img_dialogBox.png"
							}
						},
						{
							name="img_select",type=1,typeName="Image",time=0,x=0,y=114,width=100,height=184,visible=0,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="room/chat/img_selectedMiddle.png",
							{
								name="Image2",type=1,typeName="Image",time=0,x=0,y=0,width=66,height=62,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="room/chat/img_dialogBoxHover.png"
							}
						}
					},
					{
						name="view_btn_speaker",type=0,typeName="View",time=0,x=1,y=-3,width=100,height=180,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottom,
						{
							name="btn_unselect",type=1,typeName="Button",time=0,x=0,y=0,width=100,height=180,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="room/chat/img_buttom.png",
							{
								name="Image1",type=1,typeName="Image",time=0,x=0,y=0,width=54,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="room/chat/img_speakerIcon.png"
							}
						},
						{
							name="img_select",type=1,typeName="Image",time=0,x=0,y=0,width=100,height=179,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="room/chat/img_selectedButtom.png",
							{
								name="Image2",type=1,typeName="Image",time=0,x=0,y=0,width=64,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="room/chat/img_speakerIconHover.png"
							}
						}
					}
				}
			},
			{
				name="img_frameBg",type=1,typeName="Image",time=0,x=131,y=40,width=529,height=529,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/createRoom/img_inner.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20
			},
			{
				name="btn_close",type=1,typeName="Button",time=0,x=623,y=-15,width=73,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/closebtn_ .png"
			},
			{
				name="img_sendWordBg",type=1,typeName="Image",time=0,x=136,y=460,width=513,height=104,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="ui/blank.png",
				{
					name="img_sendWordBg",type=1,typeName="Image",time=0,x=5,y=16,width=312,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="room/chat/img_inputEditText.png",
					{
						name="et_sendWord",type=7,typeName="EditTextView",time=0,x=5,y=0,width=290,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,colorA=1
					}
				},
				{
					name="btn_sendWord",type=1,typeName="Button",time=0,x=324,y=12,width=184,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="room/chat/img_send.png",
					{
						name="img_speakerIcon",type=1,typeName="Image",time=0,x=14,y=15,width=44,height=47,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="room/chat/img_speaker.png"
					},
					{
						name="img_mark",type=1,typeName="Image",time=0,x=140,y=-11,width=38,height=41,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="room/chat/img_mark.png",
						{
							name="text_num",type=5,typeName="TextView",time=0,x=0,y=0,width=38,height=41,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,fontSize=18,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,colorA=1
						}
					},
					{
						name="img_send",type=1,typeName="Image",time=0,x=0,y=0,width=54,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="room/chat/img_textSend.png"
					}
				}
			}
		}
	}
}
return roomChatAndSpeakerPopu;