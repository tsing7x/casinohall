local UI = require('byui/basic');
local AL = require('byui/autolayout');
local Layout = require('byui/layout');
local class, mixin, super = unpack(require('byui/class'))
local KefuResMap = require('kefuSystem/chat_face')
local ConstString = require('kefuSystem/common/kefuStringRes')

local bottomPage = class('bottomPage', nil, {
	__init__ = function (self,root,callBack)
		self.m_root = root;
		self.m_callBack = callBack;
        self:initIconWidget();

        self._btn = UI.Button{
        	text = ConstString.btn_send_txt;
        	size = Point(100,50)
    	}
    	self._btn:add_rules({
            AL.right:eq(AL.parent('width') - 14),
            AL.bottom:eq(AL.parent('height') - 14),
        })
        self._btn.zorder = 255
        self.m_root:add(self._btn)
	end,

	initIconWidget = function(self)
		local space = 20
		local wH = 16
		local allSpace = (space+wH)*4+wH
		self.m_ArrImage = {};
		for i=1,5 do
			local sprite = Sprite();
			sprite.unit = TextureUnit.load(KefuResMap["appkefu_page_normal.png"]);
			
	        sprite:add_rules({
	        	AL.width:eq(wH),
	            AL.height:eq(wH),
	            AL.left:eq((AL.parent('width')-allSpace)/2+(i-1)*(space+wH) ),
	            AL.bottom:eq(AL.parent('height')-14),
	        })
	        self.m_ArrImage[i] = sprite;
	        self.m_root:add(sprite);
		end
		self.m_ArrImage[1].unit = TextureUnit.load(KefuResMap["appkefu_page_active.png"]);
	end,

	changeIcon = function(self,index,prevPage)
		index = index or 1;
		prevPage = prevPage or 1;
		self.m_ArrImage[prevPage].unit  = TextureUnit.load(KefuResMap["appkefu_page_normal.png"]);
		self.m_ArrImage[index].unit  = TextureUnit.load(KefuResMap["appkefu_page_active.png"]);
	end,

	setSendEvent = function ( self,func )
		self._btn.on_click = function (  )
			if func then
				func()
			end
		end
	end,

})

return bottomPage;