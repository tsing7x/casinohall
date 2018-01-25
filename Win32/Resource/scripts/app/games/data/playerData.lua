local PlayerData = class()

addProperty(PlayerData, "id", 0)
addProperty(PlayerData, "ui", nil) --player ui
addProperty(PlayerData, "seatId", 0) 
addProperty(PlayerData, "chip", 0)--用户总筹码数
addProperty(PlayerData, "nick", "")
addProperty(PlayerData, "bet", 0)--下注筹码数
addProperty(PlayerData, "localSeatId", 0)
addProperty(PlayerData, "cardDealerUi", nil)  --发牌器ui
addProperty(PlayerData, "handCardUi", nil)  --手牌ui
addProperty(PlayerData, "betUi", nil)  --筹码区ui
addProperty(PlayerData, "cardTypeUi", nil)  --牌型ui
addProperty(PlayerData, "giftId", nil)  --礼物id
addProperty(PlayerData, "status", 2)  --，1:游戏中,2:等待下一局
addProperty(PlayerData, "dealAnim", nil)  --发牌动画
addProperty(PlayerData, "openAnim", nil)  --开牌动画
addProperty(PlayerData, "cards", {0,0,0})  --设置牌数据，不立即更新手牌
addProperty(PlayerData, "showCard", false)  --显示手牌
addProperty(PlayerData, "timeAnim", false)  --倒计时动画
addProperty(PlayerData, "timeLeft", nil)  --倒计时动画
addProperty(PlayerData, "turnMoney", 0)  --结算的金币输赢
addProperty(PlayerData, 'shaderVisible', 1)
addProperty(PlayerData, "sex", 1)
addProperty(PlayerData, "headUrl", "")

function PlayerData:clear()
	self.id = 0
	self.chip = 0
	self.bet = 0
	self.status = 2	
	self.cards = {0,0,0}
	self.handCardUi:clear()
end

function PlayerData:add3thCard(cardV)
	self.cards[3] = cardV
	if self.handCardUi then
		self.handCardUi:add3thCard(cardV)
	end
end

return PlayerData