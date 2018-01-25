local view_cardDealer=
{
	name="view_cardDealer",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="view_dealer",type=0,typeName="View",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
		{
			name="img_down",type=1,typeName="Image",time=0,x=30,y=3,width=143,height=75,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="games/common/img_cardDealer_down.png"
		},
		{
			name="card_view",type=0,typeName="View",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,
			{
				name="Image6",type=1,typeName="Image",time=0,x=0,y=0,width=58,height=67,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="games/common/img_cardDealer_card.png"
			}
		},
		{
			name="img_up",type=1,typeName="Image",time=0,x=25,y=9,width=131,height=88,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="games/common/img_cardDealer_up.png"
		}
	}
}
return view_cardDealer;