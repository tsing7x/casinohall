local DataList = class()

addProperty(DataList, "init", false)
addProperty(DataList, "version", 0)

function DataList:ctor()
	self.mData = {};
end

function DataList:add(data)
	self.mData[#self.mData + 1] = data;
end
function DataList:remove(index)
	table.remove(self.mData, index);
end

function DataList:get(index)
	return self.mData[index];
end

function DataList:count()
	return #self.mData;
end
function DataList:clear()
	self.mData = {};
	self:setInit(false)
end

function DataList:sort(sortFunc)
	table.sort(self.mData, sortFunc)
end

function DataList:getData()
	return self.mData
end

return DataList  