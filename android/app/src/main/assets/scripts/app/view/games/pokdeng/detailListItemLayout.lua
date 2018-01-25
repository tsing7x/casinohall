local detailListItemLayout=
{
	name="detailListItemLayout",type=0,typeName="View",time=0,x=0,y=0,width=510,height=120,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="btn_bg",type=1,typeName="Button",time=0,x=0,y=0,width=510,height=120,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="games/pokdeng/detailPopu/item_other.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
		{
			name="img_head_bg",type=1,typeName="Image",time=0,x=20,y=0,width=96,height=96,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="games/pokdeng/detailPopu/head_bg.png",
			{
				name="view_head",type=0,typeName="View",time=0,x=0,y=0,width=85,height=85,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter
			}
		},
		{
			name="txt_name",type=4,typeName="Text",time=0,x=128,y=14,width=159.35,height=41,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=30,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=252,colorA=1,string=[[Robter]]
		},
		{
			name="img_chip_icon",type=1,typeName="Image",time=0,x=121,y=59,width=50,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="games/pokdeng/detailPopu/hall_chip.png"
		},
		{
			name="text_chip",type=4,typeName="Text",time=0,x=173,y=65,width=136,height=43,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=205,colorBlue=25,string=[[10000]],colorA=1
		},
		{
			name="txt_win_money",type=4,typeName="Text",time=0,x=326,y=29,width=163.35,height=62,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=30,textAlign=kAlignRight,colorRed=251,colorGreen=206,colorBlue=22,colorA=1,string=[[+20000]]
		}
	}
}
return detailListItemLayout;