local CashRoom = class()
addProperty(CashRoom, "level", 0)--场次
addProperty(CashRoom, "ante", 0)--底注
addProperty(CashRoom, "minChip", 0)--闲家最小值
addProperty(CashRoom, "dealerMinChip", 0)--庄家门槛
addProperty(CashRoom, "downDealerChip", 0)--（踢）下庄值
addProperty(CashRoom, "fee", 0)--小费
addProperty(CashRoom, "tableFee", 0)--台费
addProperty(CashRoom, "roundList", {})--可选择的轮数
addProperty(CashRoom, "chipList", {})


function CashRoom:init( data )
	-- body
	self:setLevel(data[1] or 0);
	self:setAnte(data[2] or 0);
	self:setMinChip(data[3] or 0);
	self:setDealerMinChip(data[4] or 0);
	self:setDownDealerChip(data[5] or 0);
	self:setFee(data[6] or 0);
	self:setTableFee(data[7] or 0);
	self:setRoundList({data[8],data[9], data[10]});
	self:setChipList({data[11], data[12], data[13], data[14]});
end

return CashRoom
