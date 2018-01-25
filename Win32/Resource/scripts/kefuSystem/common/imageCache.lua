local class, mixin, super = unpack(require("byui/class"))
local util = require("kefuSystem/util/util")
local GKefuNetWorkControl = require('kefuSystem/conversation/netWorkControl')

local kCacheImageRootPath = System.getStorageImagePath()
local kCacheFileName = "NewImageCache.lua"

local ImageCacheMeta = {}

ImageCacheMeta._cachesFile = nil

function ImageCacheMeta:__init__()
	self:loadData(10)
end

function ImageCacheMeta:loadData( validDay )
	self._cachesFile = util.Serialize(kCacheFileName, 10)
    self._cachesFile:load()

    local curTime = os.time()
    local validTime = validDay*24*60*60

    local newCache = {}
    self._cachesFile:lookup(function(url, filename)
    	local path = kCacheImageRootPath..filename
    	if util.FileUtils.exist(path) then
	    	local time = tonumber(string.sub(filename, 1, 10))
	    	if curTime - time >= validTime then
	    		os.remove(path)
	    	else
	    		newCache[url] = filename
	    	end
	    end
    end)
    self._cachesFile:update(newCache)
end

local tempCache = {}
local function _getImageName( self, url)
	local curTime = os.time()

	if tempCache.timeCur ~= curTime then
		tempCache.count = 0
		tempCache.timeCur = curTime
	end
	tempCache.count = tempCache.count + 1 

	return tostring(curTime).."_"..tostring(tempCache.count)..".png"
end

local function _createTempImageName( self )
	local curTime = os.time()

	if tempCache.timeCur ~= curTime then
		tempCache.count = 0
		tempCache.timeCur = curTime
	end
	tempCache.count = tempCache.count + 1 

	return tostring(curTime).."_"..tostring(tempCache.count).."_temp.png"
end

local function _doCallBack( func, owner, ... )
	if owner ~= nil then
		func(owner, ...)
	else
		func(...)
	end
end

function ImageCacheMeta:request( url, callback, owner, ... )
	--if string.isEmpty(url) then
	--	log.w("the image url is empty")
	--	return;
	--end

	local args = { ... }

	local file = self._cachesFile:get(url)
	if file ~= nil then
		_doCallBack(callback, owner, file, unpack(args) )
        return;
	end

	local tempName = _createTempImageName(self)
	GKefuNetWorkControl.downLoadFile(url,kCacheImageRootPath..tempName,function()
        local imageName = self._cachesFile:get(url)
        if imageName == nil then
            imageName = _getImageName(url)
            os.rename(kCacheImageRootPath..tempName, kCacheImageRootPath..imageName);
            self._cachesFile:set(url, imageName)
            self._cachesFile:save()
        end
        _doCallBack(callback, owner, imageName, unpack(args))
    end)
end

local ImageCache = {}
local s_instance = nil

function ImageCache.getInstance()
	if s_instance == nil then
		s_instance = class("ImageCache", nil, ImageCacheMeta)()
	end

	return s_instance
end

return ImageCache
