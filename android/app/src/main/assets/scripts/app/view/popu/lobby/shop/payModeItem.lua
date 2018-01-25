local payModeItem=
{
	name="payModeItem",type=0,typeName="View",time=0,x=0,y=0,width=204,height=105,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
	{
		name="btn_tab",type=1,typeName="Button",time=0,x=0,y=0,width=198,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="ui/blank.png",
		{
			name="img_unselect",type=1,typeName="Image",time=0,x=0,y=0,width=198,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/shop/tab_unselect.png",
			{
				name="img_pmode",type=1,typeName="Image",time=0,x=0,y=0,width=126,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/shop/payMode/JMT_0.png"
			}
		},
		{
			name="img_select",type=1,typeName="Image",time=0,x=0,y=0,width=198,height=99,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/shop/tab_select.png",
			{
				name="img_pmode",type=1,typeName="Image",time=0,x=0,y=0,width=85,height=61,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/shop/payMode/JMT_1.png"
			}
		}
	}
}
return payModeItem;