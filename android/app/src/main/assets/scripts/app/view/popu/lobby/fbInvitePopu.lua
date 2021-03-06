local fbInvitePopu=
{
	name="fbInvitePopu",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignRight,
	{
		name="img_popuBg",type=1,typeName="Image",time=0,x=22,y=210,width=676,height=859,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/bg_big.png",
		{
			name="img_myInfo",type=1,typeName="Image",time=0,x=0,y=160,width=560,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="17f1a8bff11805e09528f8df59f48136",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10,
			{
				name="text_inviteCode",type=4,typeName="Text",time=0,x=0,y=0,width=138,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[我的邀请码:1]]
			},
			{
				name="text_money",type=4,typeName="Text",time=0,x=0,y=0,width=150,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[奖励累计:8888]]
			}
		},
		{
			name="text_inviteReward",type=4,typeName="Text",time=0,x=0,y=230,width=180,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[邀请人后奖励500]],colorA=1
		},
		{
			name="img_titleBg",type=1,typeName="Image",time=0,x=0,y=90,width=620,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="popu/tab_bg.png",gridLeft=40,gridRight=40,
			{
				name="btn_fbInvite",type=1,typeName="Button",time=0,x=0,y=0,width=205,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="ui/blank.png",
				{
					name="text_fbDard",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[FB邀请]],colorA=1
				},
				{
					name="img_select",type=1,typeName="Image",time=0,x=0,y=0,width=204,height=62,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/tab_select.png",gridLeft=40,gridRight=40,
					{
						name="text_fb",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[FB邀请]]
					}
				}
			},
			{
				name="btn_friend",type=1,typeName="Button",time=0,x=0,y=0,width=205,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="ui/blank.png",
				{
					name="text_inviteDark",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[好友邀请]]
				},
				{
					name="img_select",type=1,typeName="Image",time=0,x=0,y=0,width=204,height=62,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/tab_select.png",gridLeft=40,gridRight=40,
					{
						name="text_invite",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[好友邀请]]
					}
				}
			},
			{
				name="btn_callback",type=1,typeName="Button",time=0,x=0,y=0,width=205,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="ui/blank.png",
				{
					name="text_callbackDark",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[好友召回]]
				},
				{
					name="img_select",type=1,typeName="Image",time=0,x=0,y=0,width=204,height=62,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/tab_select.png",gridLeft=40,gridRight=40,
					{
						name="text_callback",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontName="",textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[好友召回]],fontSize=24
					}
				}
			}
		},
		{
			name="img_money",type=1,typeName="Image",time=0,x=0,y=15,width=640,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="07b5f31abf7e992ad72edfe669d92e15"
		},
		{
			name="view_fbFriend",type=0,typeName="View",time=0,x=0,y=20,width=630,height=550,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,
			{
				name="img_friendList",type=1,typeName="Image",time=0,x=0,y=0,width=630,height=500,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,file="popu/frame.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10
			},
			{
				name="btn_invite",type=1,typeName="Button",time=0,x=0,y=0,width=180,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomRight,file="e90cf9269bfc171e5ecde61332c44d2a",
				{
					name="Text29",type=4,typeName="Text",time=0,x=-20,y=0,width=48,height=27,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[邀请]]
				},
				{
					name="Image30",type=1,typeName="Image",time=0,x=40,y=0,width=50,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="6d3df4278f48bb3692b50cacf263e974",
					{
						name="text_selectNum",type=4,typeName="Text",time=0,x=0,y=0,width=44,height=27,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[0]]
					}
				}
			},
			{
				name="view_selectAll",type=0,typeName="View",time=0,x=0,y=0,width=120,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,
				{
					name="text_selectAll",type=4,typeName="Text",time=0,x=50,y=0,width=48,height=27,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,fontSize=24,textAlign=kAlignRight,colorRed=255,colorGreen=255,colorBlue=255,string=[[全选]],colorA=1
				},
				{
					name="btn_selectAll",type=1,typeName="Button",time=0,x=0,y=0,width=44,height=44,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="popu/fbinvite/search_bg.png",
					{
						name="img_select",type=1,typeName="Image",time=0,x=0,y=0,width=44,height=44,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/fbinvite/selectAll.png"
					}
				}
			}
		},
		{
			name="view_callback",type=0,typeName="View",time=0,x=0,y=20,width=630,height=550,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,
			{
				name="img_callbackList",type=1,typeName="Image",time=0,x=0,y=0,width=630,height=500,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="popu/frame.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10
			},
			{
				name="view_selectAll",type=0,typeName="View",time=0,x=0,y=0,width=120,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,
				{
					name="text_selectAll",type=4,typeName="Text",time=0,x=50,y=0,width=48,height=27,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,fontSize=24,textAlign=kAlignRight,colorRed=255,colorGreen=255,colorBlue=255,string=[[全选]],colorA=1
				},
				{
					name="btn_selectAll",type=1,typeName="Button",time=0,x=0,y=0,width=44,height=44,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="popu/fbinvite/search_bg.png",
					{
						name="img_select",type=1,typeName="Image",time=0,x=0,y=0,width=44,height=44,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/fbinvite/selectAll.png"
					}
				}
			},
			{
				name="btn_callback",type=1,typeName="Button",time=0,x=0,y=0,width=180,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomRight,file="e90cf9269bfc171e5ecde61332c44d2a",
				{
					name="Text29",type=4,typeName="Text",time=0,x=-20,y=0,width=48,height=27,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[召回]]
				},
				{
					name="Image30",type=1,typeName="Image",time=0,x=40,y=0,width=50,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="6d3df4278f48bb3692b50cacf263e974",
					{
						name="text_selectNum",type=4,typeName="Text",time=0,x=0,y=0,width=44,height=27,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[0]]
					}
				}
			}
		}
	}
}
return fbInvitePopu;