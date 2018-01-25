local gameItem=
{
	name="gameItem",type=0,typeName="View",time=0,x=0,y=0,width=620,height=484,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="bgBtn",type=1,typeName="Button",time=0,x=0,y=0,width=580,height=484,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/blank.png",
		{
			name="img",type=1,typeName="Image",time=0,x=335,y=296,width=580,height=484,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="lobby/hall_game_21.png"
		},
		{
			name="Image5",type=1,typeName="Image",time=0,x=0,y=15,width=206,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="lobby/hall_player_count_bg.png",
			{
				name="Image6",type=1,typeName="Image",time=0,x=20,y=0,width=41,height=37,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="lobby/hall_player_count_icon.png"
			},
			{
				name="countTxt",type=4,typeName="Text",time=0,x=70,y=19,width=112,height=29,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[9999]],colorA=1
			}
		}
	}
}
return gameItem;