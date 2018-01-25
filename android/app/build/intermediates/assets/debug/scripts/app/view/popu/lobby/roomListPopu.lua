local roomListPopu=
{
	name="roomListPopu",type=0,typeName="View",time=0,x=0,y=20,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="img_popuBg",type=1,typeName="Image",time=0,x=0,y=0,width=676,height=859,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/bg_big.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10,
		{
			name="btn_close",type=1,typeName="Button",time=0,x=614,y=-7,width=73,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="popu/closebtn_ .png"
		},
		{
			name="title_bg",type=1,typeName="Image",time=0,x=0,y=16,width=462,height=78,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="popu/img_title_2.png",
			{
				name="img_title",type=1,typeName="Image",time=0,x=0,y=0,width=190,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="popu/roomList/chip_room_title.png"
			}
		},
		{
			name="view_room_list",type=0,typeName="View",time=0,x=-22,y=-210,width=676,height=859,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
			{
				name="Image53",type=1,typeName="Image",time=0,x=0,y=40,width=602,height=664,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="popu/enterRoom/room_list_bg.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20
			},
			{
				name="sv_room_list",type=0,typeName="ScrollView",time=0,x=0,y=50,width=582,height=644,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom
			}
		}
	}
}
return roomListPopu;