local class, mixin, super = unpack(require("byui/class"))
local UI = require('byui/basic');
local Anim = require("animation")
local baseView = require('kefuSystem/view/baseView')
local LoadingViewCls = nil
local LoadingViewMeta = {}

LoadingViewMeta._loading = nil



function LoadingViewMeta:__init__()
	super(LoadingViewCls, self).__init__(self)
	self.size = Window.instance().drawing_root.size

	self.zorder = 255
	-- UI.init_simple_event(self, function() end)
	self:add_listener(function (  )end)
	-- self:initId()
	self._loading = UI.Loading{style = 'gray'}
	self._loading.colorf = Colorf.red
	self:add(self._loading)
	self._loading.pos = Point((self.width - self._loading.width)/2,(self.height - self._loading.height)/2)
end


function LoadingViewMeta:start()
	self._loading:start_animating()
	Window.instance().drawing_root:add(self)
end

function LoadingViewMeta:stop(clean)
	self._loading:stop_animating()
	if clean then
		self._loading = nil 
		self:remove_from_parent()
		self:cleanup()
		self = nil
	end
end

LoadingViewCls = class("LoadingViewCls", Widget, LoadingViewMeta)

return LoadingViewCls