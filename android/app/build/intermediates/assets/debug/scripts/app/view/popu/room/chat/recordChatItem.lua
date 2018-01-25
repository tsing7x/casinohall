local recordChatItem=
{
	name="recordChatItem",type=0,typeName="View",time=0,x=0,y=0,width=500,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="img_head",type=1,typeName="Image",time=0,x=0,y=0,width=88,height=88,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/chat/frame_head.png"
	},
	{
		name="img_wordBg",type=1,typeName="Image",time=0,x=92,y=30,width=500,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/chat/frame_other.png",gridLeft=20,gridRight=10,gridTop=40,gridBottom=10
	},
	{
		name="text_nick",type=4,typeName="Text",time=0,x=100,y=0,width=51,height=27,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=103,colorGreen=136,colorBlue=206,colorA=1
	}
}
return recordChatItem;