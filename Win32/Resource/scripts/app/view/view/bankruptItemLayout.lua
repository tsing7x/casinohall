local bankruptItemLayout=
{
	name="bankruptItemLayout",type=0,typeName="View",time=0,x=0,y=0,width=598,height=130,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="img_item",type=1,typeName="Image",time=0,x=0,y=0,width=598,height=130,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="bankrupt/Item_bg.png",
		{
			name="img_icon",type=1,typeName="Image",time=0,x=8,y=8,width=114,height=112,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="bankrupt/img_fansPage.png"
		},
		{
			name="btn_attend",type=1,typeName="Button",time=0,x=435,y=24,width=151,height=78,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="room/userInfo/btn_addfriend.png"
		},
		{
			name="tv_content02",type=5,typeName="TextView",time=0,x=136,y=42,width=290,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=245,colorGreen=200,colorBlue=44,string=[[ชิงรหัสโบนัสลุ้นรางวัล]],colorA=1
		},
		{
			name="img_unclick",type=1,typeName="Image",time=0,x=435,y=24,width=151,height=78,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="room/userInfo/img_notAddFriend.png"
		},
		{
			name="tv_content01",type=5,typeName="TextView",time=0,x=136,y=14,width=283,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=32,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[ติดตามแฟนเพจ]],colorA=1
		},
		{
			name="tv_click",type=4,typeName="Text",time=0,x=435,y=24,width=151,height=78,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[ติดตาม]],colorA=1
		}
	}
}
return bankruptItemLayout;