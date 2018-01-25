local ShopData = class(require('app.data.dataList'))

function ShopData:getGoodsInfoByPamount(pamount)
	if not self:getInit() then return end
	for i=1, self:count() do
		local record = self:get(i)
		printInfo("record:getPamount() = "..record:getPamount());
		if record:getPamount() == pamount then
			return i, record
		end
	end
end

function ShopData:getIndexByPamount(pamount)
	local money = {};
	local count = self:count();

	for i = 1, count do
		table.insert(money, self:get(i):getPamount());
	end
	table.sort(money, function ( a, b )
		-- body
		return a < b;
	end)
	for i = 1, #money do
		if money[i] == pamount then
			return i;
		end
	end

	return 1;
end



return ShopData  