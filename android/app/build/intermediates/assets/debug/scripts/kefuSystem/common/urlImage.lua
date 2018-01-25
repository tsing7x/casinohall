local class, mixin, super = unpack(require("byui/class"))
local util = require("kefuSystem/util/util")
local ImageCache = require("kefuSystem/common/imageCache")


local UrlImage = nil
local UrlImageMeta = {}

---@param require #string 	 url  			图片的 url 地址
---@param option  #function  handleDone   	function( UrlImage, imageFileName )
function UrlImageMeta:setUrl( url, handleDone )
	local function _handleImage( filename )
		TextureCache.instance():get_async(filename,function(texture)
				self.unit = TextureUnit(texture)
			end)
		if handleDone then
			handleDone(self, filename)
		end
	end

	if url and url ~=""  and util.FileUtils.getFullPath("images/" .. url) then
		TextureCache.instance():get(url):reload();
		_handleImage(url)
	else
		ImageCache.getInstance():request(url, function( filename )
			if filename then
				_handleImage(filename)
			end
		end)


	end
end

UrlImage = class("UrlImage", Sprite, UrlImageMeta)

return UrlImage
