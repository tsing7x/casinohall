local standUpPopu=
{
	name="standUpPopu",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="img_popuBg",type=1,typeName="Image",time=0,x=19,y=350,width=680,height=597,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/bg_superBig.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
		{
			name="btn_close",type=1,typeName="Button",time=0,x=-4,y=-7,width=62,height=62,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="popu/closebtn_ .png"
		},
		{
			name="img_itemBg",type=1,typeName="Image",time=0,x=40,y=118,width=602,height=326,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/createRoom/img_inner.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
			{
				name="img_elephant",type=1,typeName="Image",time=0,x=-8,y=-18,width=354,height=350,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="bankrupt/img_elephant.png"
			},
			{
				name="tv_content01",type=5,typeName="TextView",time=0,x=323,y=80,width=218,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=28,textAlign=kAlignLeft,colorRed=111,colorGreen=146,colorBlue=225,string=[[สินทรัพย์มีไม่พอค่ะ:]],colorA=1
			},
			{
				name="tv_content02",type=5,typeName="TextView",time=0,x=321,y=75,width=263,height=240,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=111,colorGreen=146,colorBlue=225,string=[[ชิปของคุณมีน้อยกว่าชิปเดิมพันต่ำสุดของห้อง กรุณาเลือกห้องเดิมพันที่ต่ำกว่าค่ะ]],colorA=1
			}
		},
		{
			name="title_bg",type=1,typeName="Image",time=0,x=0,y=17,width=462,height=78,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="popu/img_title_2.png",
			{
				name="img_title",type=1,typeName="Image",time=0,x=0,y=0,width=358,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="bankrupt/img_standUpTitle.png"
			}
		},
		{
			name="btn_cancel",type=1,typeName="Button",time=0,x=61,y=462,width=266,height=96,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="bankrupt/btn_cancel.png",
			{
				name="tv_cancel",type=4,typeName="Text",time=0,x=0,y=0,width=113,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=46,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[ยกเลิก]],colorA=1
			}
		},
		{
			name="btn_confirm",type=1,typeName="Button",time=0,x=353,y=465,width=266,height=93,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="bankrupt/btn_confirm.png",
			{
				name="tv_confirm",type=4,typeName="Text",time=0,x=0,y=0,width=102,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=46,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[ยืนยัน]]
			}
		}
	}
}
return standUpPopu;