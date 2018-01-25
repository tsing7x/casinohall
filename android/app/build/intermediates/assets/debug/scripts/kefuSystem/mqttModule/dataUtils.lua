
local DataUtils = class();
local TABLE_BOYAA_IM_CONFIGS = "configs_im_boyaa_table";
local TAG_SERVICE_FID = "service_fid_tag";

DataUtils.getInstance = function()
	if not DataUtils.s_instance then 
		DataUtils.s_instance = new(DataUtils);
	end
	return DataUtils.s_instance;
end

function DataUtils:ctor()
    self.dict = new(Dict, TABLE_BOYAA_IM_CONFIGS);
    self.dict:load();
end

function DataUtils:dtor()
    self.dict:save();
    delete(self.dict);
    self.dict = nil;
end


function DataUtils:save()
    self.dict:save();
end




function DataUtils:saveCurrentServiceFid(sfid)
    self.dict:setString(TAG_SERVICE_FID, sfid);
    self:save();
end

function DataUtils:getCurrentServiceFid()
    return self.dict:getString(TAG_SERVICE_FID);
end




--[[
/**
* 
* @param context
* @param md5
*            : 用本地file生成md5值
* @param uri
*            : 上传文件服务器之后，服务器下载的下载download uri
* @return
*/
--]]
function DataUtils:getAvatarUri(md5)
    return self.dict:getString(md5);
end
--[[
/**
* 做优化处理，比如该图片以上传过之后，就不用上传了
* 
* @param context
* @param md5
* @param uri
*/
--]]
function DataUtils:saveAvatarUri(md5, uri)
    self.dict:setString(md5, uri);
    self:save();
end


return DataUtils
	

