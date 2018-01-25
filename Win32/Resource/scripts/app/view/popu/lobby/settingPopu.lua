local settingPopu=
{
	name="settingPopu",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,stageW=0,
	{
		name="img_bgPanel",type=1,typeName="Image",time=0,x=0,y=0,width=720,height=1051,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/v210/bg_superBig.png",
		{
			name="img_decBgTitle",type=1,typeName="Image",time=0,x=0,y=-496,width=527,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/v210/img_title_2.png",
			{
				name="img_dscTitle",type=1,typeName="Image",time=0,x=0,y=-6,width=100,height=52,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="language/thai/popu/setting/setg_dscSetTitle.png"
			}
		},
		{
			name="btn_close",type=1,typeName="Button",time=0,x=292,y=-508,width=113,height=110,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/v210/closebtn_ .png"
		},
		{
			name="img_bgDent1",type=1,typeName="Image",time=0,x=0,y=98,width=620,height=88,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/img_inner.png",gridLeft=18,gridRight=18,gridTop=18,gridBottom=18,
			{
				name="tv_usrName",type=5,typeName="TextView",time=0,x=16,y=0,width=128,height=38,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=26,textAlign=kAlignLeft,colorRed=162,colorGreen=76,colorBlue=49,string=[[Usr Name]],colorA=1
			},
			{
				name="txt_dscFBLoginHint",type=4,typeName="Text",time=0,x=148,y=0,width=205,height=36,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=24,textAlign=kAlignLeft,colorRed=162,colorGreen=76,colorBlue=49,string=[[(FB Login Hint)]],colorA=1
			},
			{
				name="btn_logout",type=1,typeName="Button",time=0,x=197,y=0,width=196,height=68,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/v210/btn_yellow.png",gridLeft=32,gridRight=32,gridTop=28,gridBottom=28,
				{
					name="img_dscLogout",type=1,typeName="Image",time=0,x=0,y=-5,width=130,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="language/thai/popu/setting/setg_dscLogout.png"
				}
			}
		},
		{
			name="img_bgDent2",type=1,typeName="Image",time=0,x=0,y=198,width=620,height=500,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/img_inner.png",gridLeft=18,gridRight=18,gridTop=18,gridBottom=18,
			{
				name="txt_dscCtrlItem1",type=4,typeName="Text",time=0,x=16,y=-207,width=120,height=36,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=26,textAlign=kAlignLeft,colorRed=162,colorGreen=76,colorBlue=49,string=[[Ctrl Item1]],colorA=1
			},
			{
				name="vsdr_sysVolSet",type=0,typeName="Slider",time=0,x=35,y=-207,width=366,height=16,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,bgFile="popu/setting/setg_slirBgLayer.png",fgFile="popu/setting/setg_slirBgFiller.png",buttonFile="popu/setting/setg_slirBtn.png",gridLeft=6,gridRight=6,gridTop=5,gridBottom=5
			},
			{
				name="img_decDivLine1",type=1,typeName="Image",time=0,x=0,y=-166,width=616,height=4,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/setting/setg_divLine.png"
			},
			{
				name="txt_dscCtrlItem2",type=4,typeName="Text",time=0,x=16,y=-125,width=120,height=36,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=26,textAlign=kAlignLeft,colorRed=162,colorGreen=76,colorBlue=49,string=[[Ctrl Item2]],colorA=1
			},
			{
				name="chkBtn_bgm",type=8,typeName="Switch",time=0,x=20,y=-125,width=150,height=48,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,onFile="popu/setting/setg_switch_on.png",offFile="popu/setting/setg_switch_off.png",buttonFile="popu/setting/setg_switchBtn.png"
			},
			{
				name="img_decDivLine2",type=1,typeName="Image",time=0,x=0,y=-84,width=616,height=4,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/setting/setg_divLine.png"
			},
			{
				name="txt_dscCtrlItem3",type=4,typeName="Text",time=0,x=16,y=-43,width=120,height=36,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=26,textAlign=kAlignLeft,colorRed=162,colorGreen=76,colorBlue=49,string=[[Ctrl Item3]],colorA=1
			},
			{
				name="chkBtn_gm",type=8,typeName="Switch",time=0,x=20,y=-43,width=150,height=48,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,onFile="popu/setting/setg_switch_on.png",offFile="popu/setting/setg_switch_off.png",buttonFile="popu/setting/setg_switchBtn.png"
			},
			{
				name="img_decDivLine3",type=1,typeName="Image",time=0,x=0,y=-2,width=616,height=4,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/setting/setg_divLine.png"
			},
			{
				name="txt_dscCtrlItem4",type=4,typeName="Text",time=0,x=16,y=39,width=200,height=36,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=26,textAlign=kAlignLeft,colorRed=162,colorGreen=76,colorBlue=49,string=[[Ctrl Item4]],colorA=1
			},
			{
				name="chkBtn_cdVibr",type=8,typeName="Switch",time=0,x=20,y=41,width=150,height=48,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,onFile="popu/setting/setg_switch_on.png",offFile="popu/setting/setg_switch_off.png",buttonFile="popu/setting/setg_switchBtn.png"
			},
			{
				name="img_decDivLine4",type=1,typeName="Image",time=0,x=0,y=80,width=616,height=4,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/setting/setg_divLine.png"
			},
			{
				name="txt_dscCtrlItem5",type=4,typeName="Text",time=0,x=16,y=121,width=200,height=36,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=26,textAlign=kAlignLeft,colorRed=162,colorGreen=76,colorBlue=49,string=[[Ctrl Item5]],colorA=1
			},
			{
				name="chkBtn_autoSit",type=8,typeName="Switch",time=0,x=20,y=121,width=150,height=48,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,onFile="popu/setting/setg_switch_on.png",offFile="popu/setting/setg_switch_off.png",buttonFile="popu/setting/setg_switchBtn.png"
			},
			{
				name="img_decDivLine5",type=1,typeName="Image",time=0,x=0,y=162,width=616,height=4,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/setting/setg_divLine.png"
			},
			{
				name="txt_dscCtrlItem6",type=4,typeName="Text",time=0,x=16,y=203,width=200,height=36,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=26,textAlign=kAlignLeft,colorRed=162,colorGreen=76,colorBlue=49,string=[[Ctrl Item6]],colorA=1
			},
			{
				name="chkBtn_allowTrace",type=8,typeName="Switch",time=0,x=20,y=203,width=150,height=48,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,onFile="popu/setting/setg_switch_on.png",offFile="popu/setting/setg_switch_off.png",buttonFile="popu/setting/setg_switchBtn.png"
			}
		},
		{
			name="img_bgDent3",type=1,typeName="Image",time=0,x=0,y=308,width=620,height=242,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/img_inner.png",gridLeft=18,gridRight=18,gridTop=18,gridBottom=18,
			{
				name="txt_dscGoFansPage",type=4,typeName="Text",time=0,x=18,y=-78,width=396,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=26,textAlign=kAlignLeft,colorRed=162,colorGreen=76,colorBlue=49,string=[[Go Fans Page]],colorA=1
			},
			{
				name="img_arrowGoFansPage",type=1,typeName="Image",time=0,x=22,y=-75,width=18,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="popu/setting/setg_arrowRight.png"
			},
			{
				name="btn_goFansPage",type=1,typeName="Button",time=0,x=0,y=-81,width=616,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/blank.png"
			},
			{
				name="img_decDivLine1",type=1,typeName="Image",time=0,x=0,y=-39,width=616,height=4,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/setting/setg_divLine.png"
			},
			{
				name="txt_dscGameAbout",type=4,typeName="Text",time=0,x=18,y=0,width=272,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=26,textAlign=kAlignLeft,colorRed=162,colorGreen=76,colorBlue=49,string=[[Game About Terms]],colorA=1
			},
			{
				name="img_arrowGameAbout",type=1,typeName="Image",time=0,x=22,y=0,width=18,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="popu/setting/setg_arrowRight.png"
			},
			{
				name="btn_gameAbout",type=1,typeName="Button",time=0,x=0,y=0,width=616,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/blank.png"
			},
			{
				name="img_decDivLine2",type=1,typeName="Image",time=0,x=0,y=39,width=616,height=4,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/setting/setg_divLine.png"
			},
			{
				name="txt_dscVerCheck",type=4,typeName="Text",time=0,x=18,y=78,width=250,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=26,textAlign=kAlignLeft,colorRed=162,colorGreen=76,colorBlue=49,string=[[Version: V1.0]],colorA=1
			},
			{
				name="img_arrowGameVersion",type=1,typeName="Image",time=0,x=22,y=78,width=18,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="popu/setting/setg_arrowRight.png"
			},
			{
				name="btn_verCheck",type=1,typeName="Button",time=0,x=0,y=81,width=616,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/blank.png"
			}
		}
	}
}
return settingPopu;