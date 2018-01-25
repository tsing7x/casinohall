local FileUtils = {}

function FileUtils.exist( path )
	return os.isexist(path)
end

function FileUtils.fileSize( path )
	return os.filesize(path)
end
local kDefaultResSearchPath = {
    sys_get_string("storage_update_root"),
    System.getStorageOuterRoot(),
    System.getStorageUserPath(),
    System.getStorageAppRoot(),
}

function FileUtils.getFullPath( filename )
	for _,path in ipairs(kDefaultResSearchPath) do
        if os.isexist(path .. filename) ~= false then
            return path .. filename
        end
    end
    return nil
end

return FileUtils