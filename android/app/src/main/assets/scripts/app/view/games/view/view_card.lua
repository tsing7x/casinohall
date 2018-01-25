local view_card=
{
	name="view_card",type=0,typeName="View",time=0,x=100,y=100,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="img_bg",type=1,typeName="Image",time=0,x=0,y=0,width=184,height=236,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="games/card/bg.png",
		{
			name="img_btype",type=1,typeName="Image",time=0,x=0,y=0,width=184,height=236,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="games/card/b_2.png"
		},
		{
			name="img_stype",type=1,typeName="Image",time=0,x=2,y=68,width=60,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="games/card/s_2.png"
		},
		{
			name="img_value",type=1,typeName="Image",time=0,x=3,y=10,width=60,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="games/card/2_2.png"
		},
		{
			name="img_back",type=1,typeName="Image",time=0,x=0,y=0,width=184,height=236,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="games/card/back.png"
		}
	}
}
return view_card;