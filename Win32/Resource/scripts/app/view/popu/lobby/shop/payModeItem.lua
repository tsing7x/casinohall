local payModeItem=
{
	name="payModeItem",type=0,typeName="View",time=0,x=0,y=0,width=164,height=90,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
	{
		name="img_unselect",type=1,typeName="Image",time=0,x=0,y=0,width=164,height=90,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/shop/tab_unselect.png",
		{
			name="img_pmode",type=1,typeName="Image",time=0,x=0,y=0,width=126,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/shop/payMode/google_0.png"
		}
	},
	{
		name="img_select",type=1,typeName="Image",time=0,x=-2,y=0,width=180,height=101,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/shop/tab_select.png",
		{
			name="View7",type=0,typeName="View",time=0,x=0,y=0,width=164,height=90,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
			{
				name="img_pmode",type=1,typeName="Image",time=0,x=0,y=0,width=85,height=61,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/shop/payMode/google_1.png"
			}
		}
	},
	{
		name="btn_tab",type=1,typeName="Button",time=0,x=0,y=0,width=176,height=90,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="ui/blank.png"
	}
}
return payModeItem;