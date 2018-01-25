local registerAward=
{
	name="registerAward",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,stageH=0,
	{
		name="img_popuBg",type=1,typeName="Image",time=0,x=0,y=0,width=676,height=859,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/bg_big.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10,
		{
			name="img_title",type=1,typeName="Image",time=0,x=0,y=-38,width=495,height=110,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="popu/img_title.png",
			{
				name="Image14",type=1,typeName="Image",time=0,x=0,y=0,width=351,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/registerAward/img_title.png"
			}
		},
		{
			name="btn_confirm",type=1,typeName="Button",time=0,x=0,y=60,width=241,height=104,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="popu/btn_green.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,effect={shader="gray",grayType=3},
			{
				name="text_confirm",type=4,typeName="Text",time=0,x=0,y=4,width=212,height=57.8,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=50,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[RECEIVE]],colorA=1
			}
		},
		{
			name="Image16",type=1,typeName="Image",time=0,x=0,y=-50,width=596,height=566,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/registerAward/img_tag.png"
		},
		{
			name="btn_close",type=1,typeName="Button",time=0,x=614,y=-7,width=73,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/closebtn_ .png"
		}
	}
}
return registerAward;