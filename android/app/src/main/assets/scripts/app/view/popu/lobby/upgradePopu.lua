local upgradePopu=
{
	name="upgradePopu",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,
	{
		name="img_bgPanel",type=1,typeName="Image",time=0,x=0,y=0,width=720,height=886,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/v210/bg_big.png",
		{
			name="img_decTop",type=1,typeName="Image",time=0,x=0,y=-249,width=662,height=330,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/upgrade/upgrd_bgDecTop.png",gridLeft=50,gridRight=50,gridTop=50,gridBottom=5,
			{
				name="img_decStar",type=1,typeName="Image",time=0,x=0,y=0,width=546,height=330,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/upgrade/upgrd_decShinyStar.png"
			},
			{
				name="img_dscTitle",type=1,typeName="Image",time=0,x=0,y=-110,width=212,height=55,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="language/thai/popu/upgrade/upgrd_dscTitle.png"
			},
			{
				name="vb_usrLv",type=0,typeName="View",time=0,x=0,y=-43,width=280,height=65,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter
			},
			{
				name="img_usrHead",type=1,typeName="Image",time=0,x=0,y=79,width=136,height=136,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="lobby/hall_avator_bg.png",
				{
					name="img_bgDecName",type=1,typeName="Image",time=0,x=0,y=0,width=132,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="popu/upgrade/upgrd_bgUsrName.png",
					{
						name="txt_usrName",type=4,typeName="Text",time=0,x=0,y=0,width=132,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=25,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Usr Name]],colorA=1
					}
				}
			}
		},
		{
			name="btn_close",type=1,typeName="Button",time=0,x=310,y=-416,width=113,height=110,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/v210/closebtn_ .png"
		},
		{
			name="img_decDscRewTitle",type=1,typeName="Image",time=0,x=84,y=-48,width=139,height=29,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="language/thai/popu/upgrade/upgrd_dscGetRew.png"
		},
		{
			name="img_decRewTitle",type=1,typeName="Image",time=0,x=75,y=-21,width=159,height=6,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="popu/upgrade/upgrd_decRewTitleDivLine.png"
		},
		{
			name="img_icRewChip",type=1,typeName="Image",time=0,x=-78,y=51,width=88,height=88,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/upgrade/upgrd_icChip.png"
		},
		{
			name="txt_chipRewNum",type=4,typeName="Text",time=0,x=355,y=51,width=280,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=27,textAlign=kAlignLeft,colorRed=4,colorGreen=126,colorBlue=189,string=[[Chip Num]],colorA=1
		},
		{
			name="img_decDivLineRew1",type=1,typeName="Image",time=0,x=0,y=110,width=579,height=6,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/upgrade/upgrd_decDivLine.png"
		},
		{
			name="img_icRewProp",type=1,typeName="Image",time=0,x=-78,y=173,width=88,height=88,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/upgrade/upgrd_icPropDef.png"
		},
		{
			name="txt_propRewNum",type=4,typeName="Text",time=0,x=355,y=173,width=280,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=27,textAlign=kAlignLeft,colorRed=242,colorGreen=126,colorBlue=87,string=[[Prop Num]],colorA=1
		},
		{
			name="img_decDivLineRew2",type=1,typeName="Image",time=0,x=0,y=234,width=579,height=6,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/upgrade/upgrd_decDivLine.png"
		},
		{
			name="btn_share",type=1,typeName="Button",time=0,x=0,y=66,width=256,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="popu/v210/btn_green.png",gridLeft=35,gridRight=35,gridTop=30,gridBottom=30,
			{
				name="img_dscShare",type=1,typeName="Image",time=0,x=0,y=-3,width=83,height=47,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="language/thai/popu/upgrade/upgrd_dscShare.png"
			}
		}
	}
}
return upgradePopu;