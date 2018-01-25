local announcePopu=
{
	name="announcePopu",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="img_popuBg",type=1,typeName="Image",time=0,x=0,y=-42,width=676,height=989,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/bg_superBig.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
		{
			name="view_inner",type=0,typeName="View",time=0,x=55,y=228,width=552,height=687,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
			{
				name="img_notice02",type=1,typeName="Image",time=0,x=-2,y=215,width=502,height=339,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="ui/blank.png",
				{
					name="text_line01",type=4,typeName="Text",time=0,x=10,y=10,width=245,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=42,textAlign=kAlignLeft,colorRed=255,colorGreen=202,colorBlue=29,string=[[เนื้อหาอัพเกรด:]],colorA=1
				},
				{
					name="text_line02",type=4,typeName="Text",time=0,x=45,y=70,width=250,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=30,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[ไพ่ป๊อกเด้ง ชิปคูณสอง]],colorA=1
				},
				{
					name="Image17",type=1,typeName="Image",time=0,x=10,y=76,width=30,height=28,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="msg/star.png"
				},
				{
					name="Image22",type=1,typeName="Image",time=0,x=10,y=124,width=30,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="msg/star.png"
				},
				{
					name="Image23",type=1,typeName="Image",time=0,x=10,y=174,width=30,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="msg/star.png"
				},
				{
					name="Image24",type=1,typeName="Image",time=0,x=10,y=224,width=30,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="msg/star.png"
				},
				{
					name="Image25",type=1,typeName="Image",time=0,x=10,y=276,width=30,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="msg/star.png"
				},
				{
					name="text_line03",type=4,typeName="Text",time=0,x=45,y=120,width=258,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=30,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[รวมสินทรัพย์กับไพ่ดัมมี่]],colorA=1
				},
				{
					name="text_line04",type=4,typeName="Text",time=0,x=45,y=170,width=350,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=30,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[รวมเป็นบัญชีเดียวกันกับไพ่ดัมมี่]],colorA=1
				},
				{
					name="text_line33",type=4,typeName="Text",time=0,x=45,y=220,width=385,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=30,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[ปรับการแข่ง รางวัล และเลเวลเกมส์]],colorA=1
				},
				{
					name="text_line34",type=4,typeName="Text",time=0,x=45,y=270,width=250,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=30,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[รายละเอียดดูได้ที่ข่าว]],colorA=1
				},
				{
					name="Text35",type=4,typeName="Text",time=0,x=10,y=315,width=347,height=27,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=203,colorBlue=21,string=[[( กดปุ่มรับรางวัลทันที ดูรางวัลได้ที่ข่าว )]],colorA=1
				}
			},
			{
				name="img_notice01",type=1,typeName="Image",time=0,x=-2,y=225,width=502,height=232,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="msg/pic01.png"
			}
		},
		{
			name="Image13",type=1,typeName="Image",time=0,x=0,y=-225,width=590,height=406,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="msg/award.png"
		},
		{
			name="btn_confirm",type=1,typeName="Button",time=0,x=0,y=330,width=192,height=78,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="bankrupt/btn_cancel.png",
			{
				name="text_content",type=4,typeName="Text",time=0,x=0,y=0,width=117.5,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=42,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[รับทันที]],colorA=1
			}
		},
		{
			name="img_title",type=1,typeName="Image",time=0,x=0,y=-44,width=495,height=110,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="popu/img_title.png",
			{
				name="Image12",type=1,typeName="Image",time=0,x=0,y=0,width=366,height=66,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="msg/title01.png"
			}
		},
		{
			name="Image14",type=1,typeName="Image",time=0,x=19,y=785,width=638,height=186,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="msg/gold.png"
		}
	},
	{
		name="btn_shadow",type=1,typeName="Button",time=0,x=0,y=0,width=720,height=1280,visible=0,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="ui/blank.png",
		{
			name="Image24",type=1,typeName="Image",time=0,x=-7,y=-46,width=720,height=470,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="msg/getawards.png",gridLeft=50,gridRight=50,gridTop=50,gridBottom=50
		}
	}
}
return announcePopu;