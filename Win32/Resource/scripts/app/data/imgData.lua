local ImgData = class()

addProperty(ImgData, "imgUrl", "")
addProperty(ImgData, "imgName", "")
addProperty(ImgData, "md5Name", nil)

function ImgData:setImgUrl(imgUrl)
	self.imgUrl = imgUrl
	local md5Name = nil
	if ToolKit.isValidString(imgUrl) then
		md5Name = ToolKit.getMd5ImageName("icon", "", imgUrl)
	end
	self:setMd5Name(md5Name)
	self:setImgName(self:getImgName())
	self:checkImgAndDownload()
end

function ImgData:checkImg()
	local md5Name = self:getMd5Name()
	if ToolKit.isValidString(md5Name) then
		if NativeEvent.getInstance():isFileExist(md5Name, kIconImageFolder) == 1 then
			return true
		else
			return false, md5Name, self:getImgUrl()
		end
	end
	return false
end

function ImgData:getImgName()
	local md5Name = self:getMd5Name()
	local defaultImg = ""
	if ToolKit.isValidString(md5Name) then
		return kIconImageFolder..md5Name
	end
	return defaultImg
end

function ImgData:checkImgAndDownload()
    
	local success, imageName, imageUrl = self:checkImg()
	if success then 
		return 
	end

	if not success and not imageName then 
		return
	end

	MyUpdate:downloadImage(imageUrl, kIconImageFolder, imageName, function(status, folder, name)
		if status ~= 1 then 
			return
		end
		if name ~= self:getMd5Name() then
			return 
		end
        self:setImgName("")
		self:setImgName(folder..name)
	end)
end

return ImgData