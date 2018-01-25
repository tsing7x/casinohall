local UI = require('byui/basic');
local AL = require('byui/autolayout');
local Layout = require('byui/layout');
local class, mixin, super = unpack(require('byui/class'))
local FacePage = require('kefuSystem/view/face/facePage')
local BottomPage = require('kefuSystem/view/face/bottomPage')

local faceView
faceView = class('faceView', nil, {
	__init__ = function (self, root)
		self.m_root = root
		self.m_bottomPage = BottomPage(self.m_root);
		self.m_facePage = FacePage(self,self.callBack);
		
	end,

	getRoot = function(self)
		return self.m_root;
	end,

	setIconEvent = function (self, func)
		self.m_facePage:setIconEvent(func)	
	end,

	setDelIconEvent = function (self, func)
		self.m_facePage:setDelIconEvent(func)
	end,

	setSendEvent = function ( self,func )
		self.m_bottomPage:setSendEvent(func);
	end,
	
	callBack = function(self,index,prevPage)
		self.m_bottomPage:changeIcon(index , prevPage);
	end,


})


return faceView