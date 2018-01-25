local gameMsgItem=
{
	name="gameMsgItem",type=0,typeName="View",time=0,x=0,y=0,width=610,height=93,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
	{
		name="Image2",type=1,typeName="Image",time=0,x=0,y=0,width=610,height=93,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/message/item_bg.png",gridLeft=5,gridRight=5,gridTop=5,gridBottom=5,
		{
			name="Image3",type=1,typeName="Image",time=0,x=15,y=0,width=46,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="popu/message/email.png"
		},
		{
			name="view_content",type=0,typeName="View",time=0,x=70,y=0,width=535,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,
			{
				name="text_time",type=4,typeName="Text",time=0,x=0,y=0,width=12,height=27,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,fontSize=24,textAlign=kAlignLeft,colorRed=46,colorGreen=82,colorBlue=160,colorA=1
			},
			{
				name="text_content",type=5,typeName="TextView",time=0,x=0,y=0,width=430,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=24,textAlign=kAlignLeft,colorRed=46,colorGreen=82,colorBlue=160,colorA=1
			}
		},
		{
			name="btn_itemEvt",type=1,typeName="Button",time=0,x=0,y=0,width=610,height=93,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,file="ui/blank.png"
		}
	}
}
return gameMsgItem;