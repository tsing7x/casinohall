-- 博定比牌逻辑
-- Author: LeoLuo
-- Date: 2015-05-07 16:41:13
--
-- 0x01 0x02  ... 0x0a 0x0b 0x0c 0x0d 梅花 A ~ K
-- 0x11 0x12  ... 0x1a 0x1b 0x1c 0x1d 方块
-- 0x21 0x22  ... 0x2a 0x2b 0x2c 0x2d 红桃
-- 0x31 0x32  ... 0x3a 0x3b 0x3c 0x3d 黑桃

require("libs.bit")

local POKER_TYPE_ALL = {}
POKER_TYPE_ALL.POINT_CARD     = 1 --点牌
POKER_TYPE_ALL.STRAIGHT       = 2 --顺子
POKER_TYPE_ALL.STRAIGHT_FLUSH = 3 --同花顺
POKER_TYPE_ALL.THREE_YELLOW   = 4 --三黄
POKER_TYPE_ALL.THREE_KIND     = 5 --三张
POKER_TYPE_ALL.POKDENG        = 6 --博定

-- 获得花色
local function getPokerColor(card)
    return bit.band(card, 0xF0)
end

-- 获得牌值
local function getPokerValue(card)
    return bit.band(card, 0x0F)
end

-- 花色比较 0:c1与c2花色相同，>0 :c1花色>c2花色，<0 :c1花色<c2花色
local function colorCompare(c1, c2)
    return c1 - c2
end

-- 获得点数
local function getPokerPoint(card)
    local value = getPokerValue(card)
    if value < 0xA then
        return value
    else
        return 0
    end
end

local Logic = class()
function Logic:ctor()
    self.cards_ = {0,0,0}
    self.point_ = 0  -- 牌点数
    self.type_ = 1   -- 牌型
end

function Logic:reset()
        
    self.point_ = 0
    for _,v in ipairs(self.cards_) do
        self.point_ = self.point_ + getPokerPoint(v)
    end
    self.point_ = self.point_ % 10

    if self:isPokdeng_() then
        self.type_ = POKER_TYPE_ALL.POKDENG
    elseif self:isThreeKind_() then
        self.type_ = POKER_TYPE_ALL.THREE_KIND
    elseif self:isThreeYellow_() then
        self.type_ = POKER_TYPE_ALL.THREE_YELLOW
    elseif self:isStraightFlush_() then
        self.type_ = POKER_TYPE_ALL.STRAIGHT_FLUSH
    elseif self:isStraight_() then
        self.type_ = POKER_TYPE_ALL.STRAIGHT   
    else 
        self.type_ = POKER_TYPE_ALL.POINT_CARD
    end
end

--获取牌数量
function Logic:getCount(cards)
    cards = cards or self.cards_
    local acc = 0
    for i=1,3 do
        if cards[i]>0 then
            acc = acc + 1
        end
    end
    return acc
end


-- 牌型
function Logic:getType()
    self:reset()
    return self.type_
end

-- 牌点
function Logic:getPoint()
    self:reset()
    return self.point_
end

function Logic:isBadType()
    return self.type_ == POKER_TYPE_ALL.POINT_CARD
end

-- 是否需要第三张牌
function Logic:needPoker()
    return self:isBadType() and self.point_ < 4 
end

-- 手牌
function Logic:getCards()
    return self.cards_
end

-- 起手牌
function Logic:setCards(cards)
    cards = cards or {0,0,0}
    if cards[1]<=0 or cards[2]<=0 then
        return
    end
    for i=1,3 do
        self.cards_[i] = cards[i] or 0
    end
    self:reset()
end

--能否要第三张牌
function Logic:canGetCard()
    return (not self:isPokdeng_()) and self:getCount() == 2
end

-- 加第三张牌
function Logic:add3thCard(card)
    self.cards_[3] = card   
    self:reset()
end


function Logic:isPokdeng_()
    if self:getCount() ~= 2 then
        return false
    end
    return self.point_ > 7
end

function Logic:isThreeKind_()
    if self:getCount() ~= 3 then
        return false
    end
    return getPokerValue(self.cards_[1]) == getPokerValue(self.cards_[2]) and getPokerValue(self.cards_[2]) == getPokerValue(self.cards_[3])
end

function Logic:isStraightFlush_()
    local color1 = getPokerColor(self.cards_[1])
    local color2 = getPokerColor(self.cards_[2])
    local color3 = getPokerColor(self.cards_[3])
    if color1 == color2 and color2 == color3 then
        return self:isStraight_()
    end
    return false
end

function Logic:isStraight_()
    if self:getCount() ~= 3 then
        return false
    end
    local cards = {}
    cards[1] = self.cards_[1]
    cards[2] = self.cards_[2]
    cards[3] = self.cards_[3]
    table.sort(cards, function(card1, card2)
        return getPokerValue(card1) > getPokerValue(card2)
    end)
    local val1 = getPokerValue(cards[1])
    local val2 = getPokerValue(cards[2])
    local val3 = getPokerValue(cards[3])  
    -- 排除3 , 2 , 1 
    if val1 ~= 0x3 and val1 - 1 == val2 and val2 - 1 == val3 then
        return true
    end
    -- AKQ
    if val1 == 0xd and val2 == 0xc and val3 == 0x1 then
        return true
    end
    return false
end

function Logic:isThreeYellow_()
    if self:getCount() ~= 3 then
        return false
    end
    local val1 = getPokerValue(self.cards_[1])
    local val2 = getPokerValue(self.cards_[2])
    local val3 = getPokerValue(self.cards_[3])

    local color1 = getPokerColor(self.cards_[1])
    local color2 = getPokerColor(self.cards_[2])
    local color3 = getPokerColor(self.cards_[3])
    if val1 > 0xa and val2 > 0xa and val3 > 0xa then
        if color1 ~= color2 or color2 ~= color3 or color3 ~= color1 then
            return true
        end
    end
    return false
end

function Logic:isPointCard_()
    if not self:isPokdeng_() and not self:isThreeKind_() and not self:isStraight_() and not self:isThreeYellow_() then
        return true
    end
    return false
end

-- 获得倍数
function Logic:getX()
    local bigHand = self
    -- 算倍数
    local ret = 0
    if bigHand ~= nil then
       ret = 1
       if bigHand:getType() == POKER_TYPE_ALL.POKDENG then
           -- 博定同花和队子是2倍
           if getPokerColor(bigHand:getCards()[1]) == getPokerColor(bigHand:getCards()[2]) or getPokerValue(bigHand:getCards()[1]) == getPokerValue(bigHand:getCards()[2]) then
                ret = 2
           end
       elseif bigHand:getType() == POKER_TYPE_ALL.THREE_KIND then
            ret = 5
       elseif bigHand:getType() == POKER_TYPE_ALL.THREE_YELLOW then
            ret = 3
       elseif bigHand:getType() == POKER_TYPE_ALL.STRAIGHT_FLUSH then
            ret = 5
       elseif bigHand:getType() == POKER_TYPE_ALL.STRAIGHT then
            ret = 3       
       else
            --点牌同花 3张是3倍 2张是2倍            
            local cards = bigHand:getCards()
            if getPokerValue(cards[3]) ~= 0x0 then
                ret = 3
            else
                ret = 2 
            end

            local color = getPokerColor(cards[1])
            for i=2,3 do
                if getPokerValue(cards[i]) ~= 0x0 and color ~= getPokerColor(cards[i])  then
                    ret = 1 -- 不是同花色
                    break
                end
            end        

            --jaywillou-20170109-add:普通对子也翻倍
            if getPokerValue(cards[1]) == getPokerValue(cards[2]) and getPokerValue(cards[3]) == 0x0 then
                ret = 2
            end   
            
       end       
    end
   
    return ret
end

-- 比牌
-- 返回值： -5 ~ -1 0 +1 ~ +5  
-- 说明： < 0 小于参数手牌， 0 一样大  > 0 大于参数手牌； 对应数值为倍数
function Logic:compare(Logic)   
    local bigHand = nil --记录较大的手牌    
    if self:getType() > Logic:getType() then
        bigHand = self
    elseif self:getType() < Logic:getType() then
        bigHand = Logic
    else 
        -- 牌型相同
        if self:getType() == POKER_TYPE_ALL.POKDENG then
            if self:getPoint() > Logic:getPoint()  then
                bigHand = self
            elseif self:getPoint() < Logic:getPoint() then
                bigHand = Logic
            end
        elseif self:getType() == POKER_TYPE_ALL.THREE_KIND then
            local val1 = getPokerValue(self:getCards()[1])
            local val2 = getPokerValue(Logic:getCards()[1])
            -- 三张 A最大最先判断
            if val1 == 0x1 then
                bigHand = self
            elseif val2 == 0x1 then
                bigHand = Logic
            elseif val1 > val2 then
                bigHand = self
            elseif val2 > val1 then
                bigHand = Logic
            end
        elseif self:getType() == POKER_TYPE_ALL.THREE_YELLOW then
            -- 三黄依次比较牌面大小
            if getPokerValue(self:getCards()[1]) > getPokerValue(Logic:getCards()[1]) then
                bigHand = self
            elseif getPokerValue(self:getCards()[1]) < getPokerValue(Logic:getCards()[1]) then
                bigHand = Logic
            elseif getPokerValue(self:getCards()[2]) > getPokerValue(Logic:getCards()[2]) then
                bigHand = self
            elseif getPokerValue(self:getCards()[2]) < getPokerValue(Logic:getCards()[2]) then
                bigHand = Logic
            elseif getPokerValue(self:getCards()[3]) > getPokerValue(Logic:getCards()[3]) then
                bigHand = self
            elseif getPokerValue(self:getCards()[3]) < getPokerValue(Logic:getCards()[3]) then
                bigHand = Logic
            end
        elseif self:getType() == POKER_TYPE_ALL.STRAIGHT_FLUSH or  self:getType() == POKER_TYPE_ALL.STRAIGHT then
            if getPokerValue(self:getCards()[1]) == getPokerValue(Logic:getCards()[1]) and 
               getPokerValue(self:getCards()[2]) == getPokerValue(Logic:getCards()[2]) and 
               getPokerValue(self:getCards()[3]) == getPokerValue(Logic:getCards()[3]) then               
               if self:getType() == POKER_TYPE_ALL.STRAIGHT_FLUSH then
                   -- 同花顺， 顺子相同比花色
                   if getPokerColor(self:getCards()[1]) > getPokerColor(Logic:getCards()[1]) then
                       bigHand = self
                   else
                       bigHand = Logic
                   end
               end
            else  --A顺只可能是 AKQ 所以直接有A最大
                if getPokerValue(self:getCards()[3]) == 0x1 then
                    bigHand = self
                elseif getPokerValue(Logic:getCards()[3]) == 0x1 then
                    bigHand = Logic
                elseif getPokerValue(self:getCards()[1]) > getPokerValue(Logic:getCards()[1]) then
                    bigHand = self
                else
                    bigHand = Logic
                end
            end        
        else --点牌 直接比点
            if self:getPoint() > Logic:getPoint()  then
                bigHand = self
            elseif self:getPoint() < Logic:getPoint() then
                bigHand = Logic
            end
        end        
    end

    -- 算倍数
    local ret = 0
    if bigHand ~= nil then
       ret = 1
       if bigHand:getType() == POKER_TYPE_ALL.POKDENG then
           -- 博定同花和队子是2倍
           if getPokerColor(bigHand:getCards()[1]) == getPokerColor(bigHand:getCards()[2]) or getPokerValue(bigHand:getCards()[1]) == getPokerValue(bigHand:getCards()[2]) then
                ret = 2
           end
       elseif bigHand:getType() == POKER_TYPE_ALL.THREE_KIND then
            ret = 5
       elseif bigHand:getType() == POKER_TYPE_ALL.THREE_YELLOW then
            ret = 3
       elseif bigHand:getType() == POKER_TYPE_ALL.STRAIGHT_FLUSH then
            ret = 5
       elseif bigHand:getType() == POKER_TYPE_ALL.STRAIGHT then
            ret = 3       
       else
            --点牌同花 3张是3倍 2张是2倍            
            local cards = bigHand:getCards()
            if getPokerValue(cards[3]) ~= 0x0 then
                ret = 2
            else
                ret = 3 
            end

            local color = getPokerColor(cards[1])
            for i=2,3 do
                if getPokerValue(cards[i]) ~= 0x0 and color ~= getPokerColor(cards[i])  then
                    ret = 1 -- 不是同花色
                    break
                end
            end           
            
       end       
    end
    if bigHand ~= self and ret ~= 0 then
        ret = -1 * ret
    end
    return ret
end

return Logic
