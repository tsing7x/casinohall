local shopItem=
{
	name="shopItem",type=0,typeName="View",time=0,x=0,y=0,width=533,height=160,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
	{
		name="View8",type=0,typeName="View",time=0,x=0,y=0,width=533,height=160,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
		{
			name="Image9",type=1,typeName="Image",time=0,x=0,y=-40,width=502,height=86,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="popu/shop/shelves.png"
		},
		{
			name="btn_buy",type=1,typeName="Button",time=0,x=44,y=20,width=192,height=61,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomRight,file="popu/shop/btn.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
			{
				name="text_price",type=4,typeName="Text",time=0,x=5,y=0,width=161,height=55,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,colorA=1
			}
		},
		{
			name="view_goods",type=0,typeName="View",time=0,x=0,y=0,width=350,height=160,visible=1,fillParentWidth=0,fillParentHeight=1,nodeAlign=kAlignLeft
		},
		{
			name="img_hot",type=1,typeName="Image",time=0,x=1,y=3,width=59,height=74,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="popu/shop/firstPay/icon_hot.png"
		}
	}
}
return shopItem;