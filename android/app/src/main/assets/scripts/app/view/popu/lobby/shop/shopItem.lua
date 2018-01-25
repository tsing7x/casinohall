local shopItem=
{
	name="shopItem",type=0,typeName="View",time=0,x=0,y=0,width=513,height=135,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
	{
		name="Image4",type=1,typeName="Image",time=0,x=0,y=0,width=513,height=135,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,file="popu/shop/item_bg.png",
		{
			name="btn_buy",type=1,typeName="Button",time=0,x=10,y=0,width=120,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="popu/btn_green.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
			{
				name="text_price",type=4,typeName="Text",time=0,x=0,y=0,width=18.55,height=27.15,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255
			}
		},
		{
			name="view_goods",type=0,typeName="View",time=0,x=20,y=0,width=350,height=135,visible=1,fillParentWidth=0,fillParentHeight=1,nodeAlign=kAlignLeft
		},
		{
			name="img_hot",type=1,typeName="Image",time=0,x=3,y=3,width=73,height=77,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/shop/firstPay/icon_hot.png"
		},
		{
			name="img_firstPay",type=1,typeName="Image",time=0,x=5,y=5,width=73,height=72,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/shop/firstPay/icon_first.png"
		}
	}
}
return shopItem;