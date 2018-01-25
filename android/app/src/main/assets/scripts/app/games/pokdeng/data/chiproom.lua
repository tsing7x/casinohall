local ChipRoom = class()
addProperty(ChipRoom, "level", 0)--场次
addProperty(ChipRoom, "ante", 0)--底注
addProperty(ChipRoom, "minChip", 0)
addProperty(ChipRoom, "dealerMinChip", 0)--庄家门槛
addProperty(ChipRoom, "downDealerChip", 0)--（踢）下庄值
addProperty(ChipRoom, "fee", 0)--小费
addProperty(ChipRoom, "maxChip", 0)
addProperty(ChipRoom, "tableFee", 0)--台费
addProperty(ChipRoom, "chipList", {})


function ChipRoom:init( data )
	-- body
	self:setLevel(data[1] or 0);
	self:setAnte(data[2] or 0);
	self:setMinChip(data[3] or 0);
	self:setDealerMinChip(data[4] or 0);
	self:setDownDealerChip(data[5] or 0);
	self:setFee(data[6] or 0);
	self:setMaxChip(data[7] or 0);
	self:setTableFee(data[8] or 0);
	self:setChipList({data[9], data[10], data[11], data[12]});
end

return ChipRoom
