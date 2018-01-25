local fbFriendItem=
{
	name="fbFriendItem",type=0,typeName="View",time=0,x=0,y=0,width=132,height=194,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="btn_select",type=1,typeName="Button",time=0,x=0,y=0,width=132,height=194,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,file="ui/blank.png",
		{
			name="img_head",type=1,typeName="Image",time=0,x=0,y=0,width=132,height=132,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="popu/fbinvite/head_mask.png"
		},
		{
			name="view_nick",type=0,typeName="View",time=0,x=0,y=140,width=132,height=24,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="text_nick",type=4,typeName="Text",time=0,x=0,y=0,width=132,height=24,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignLeft,colorRed=138,colorGreen=46,colorBlue=20,colorA=1
			}
		},
		{
			name="text_reward",type=4,typeName="Text",time=0,x=0,y=170,width=132,height=24,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=69,colorBlue=31,colorA=1
		},
		{
			name="icon_select",type=1,typeName="Image",time=0,x=3,y=3,width=38,height=40,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="popu/fbinvite/icon_select.png"
		}
	}
}
return fbFriendItem;