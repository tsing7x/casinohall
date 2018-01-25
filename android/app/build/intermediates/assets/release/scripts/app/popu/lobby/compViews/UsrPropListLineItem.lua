--
-- Author: TsingZhang@boyaa.com
-- Date: 2017-09-25 15:21:16
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: UsrPropListLineItem.lua Created By Tsing7x.
--

local ListComponItem = import(".UsrPropListComponItem")

local UsrPropListLineItem = class(Node)

function UsrPropListLineItem:ctor()
	self.m_lineComponItems = {}

	local itemNumIn1Line = 3
	for i = 1, itemNumIn1Line do
		self.m_lineComponItems[i] = new(ListComponItem)

		local listComponItemSize = self.m_lineComponItems[i]:getListComponItemSize()
		self.m_lineComponItems[i]:pos(listComponItemSize.width * (i - 2), 0)
			:addTo(self)
			:hide()
	end

	self.lineItemSize_ = {
		width = self.m_lineComponItems[1]:getListComponItemSize().width * itemNumIn1Line,
		height = self.m_lineComponItems[1]:getListComponItemSize().height
	}
end

function UsrPropListLineItem:setListLineItemData(itemData)
	-- body
	for i = 1, #itemData do
		self.m_lineComponItems[i]:show()
		self.m_lineComponItems[i]:setItemData(itemData[i])
	end
end

function UsrPropListLineItem:getLineItemContSize()
	-- body
	return self.lineItemSize_
end

function UsrPropListLineItem:dtor()
	-- body
end

return UsrPropListLineItem