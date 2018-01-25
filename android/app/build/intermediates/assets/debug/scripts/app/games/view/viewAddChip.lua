local viewAddChip = class(Node)
local Room_string = require("app.games.res.config")

local viewPath = "games/pokdeng/chipIn/"
local numOfItems = 5

--{callback}
function viewAddChip:ctor(data)
	self.min = 1
	self.max = 10
	self.lastProgress = 0

	self.callback = data.callback
	local screenW = System.getScreenScaleWidth();
  	local screenH = System.getScreenScaleHeight();
  	self:setSize(screenW,screenH)
  	self:setEventTouch(self,function(obj, finger_action)
  		if finger_action == kFingerDown then
	  		self:hideDown()
	  	end
  	end)

  	self.m_shadeBg = UIFactory.createImage("ui/shade2.png")
  		:addTo(self)
  	self.m_shadeBg:setFillParent(true, true)
	
	local view = new(Node)
		:addTo(self)
		:align(kAlignBottomRight)
		:pos(10,190)
	self.m_bg = new(Image,viewPath.."img_addChip_bg.png")
			:addTo(view)
	local bgW,bgH = self.m_bg:getSize()
	view:setSize(bgW,bgH)
	view:setEventTouch(self,function ()
	end)

	self.sliderBg = new(Image, viewPath.."slider_bg_2.png")
				:align(kAlignRight)
				:pos(30,0)
				:addTo(self.m_bg)

	self.slider = new(VerticalSlider,nil,nil,viewPath.."slider_bg.png",viewPath.."slider_fg.png",viewPath.."slider_btn.png",nil,nil,nil,nil,true)
				:align(kAlignCenter)
				--:pos(20,0)
				:addTo(self.sliderBg)
	
	self.slider:setOnChange(self,self.scrollChange)
	self.slider:setBtnOnClick(self,self.scrollClick)

	local btn_allIn = new(Button, viewPath.."btn_allin.png")
			:pos(0, 10)
			:align(kAlignTop)
			:addTo(self.m_bg)
			:setOnClick(self,function()
				if self.callback and type(self.callback)=="function" then
					local myMoney = MyUserData:getCashPoint()
					if G_CUR_GAME_ID == tonumber(GAME_ID.Casinohall) then
						myMoney = MyUserData:getMoney()
					end
					self.callback(myMoney)
				end
			end)

	local btn_pos = {x=20,y=55}
	local offsetY = (bgH-24 - numOfItems*51)/8
	
	for i=numOfItems,1,-1 do
		local btn = new(Button, "common/blank.png")
			:addTo(self.m_bg)
			:name("btn_"..i)
		btn:setOnClick(self,function()
			self:selectIndex(i,true)
			if self.callback and type(self.callback)=="function" then
				-- local acc = math.floor((self.max-self.min)/6)
				-- local chipNum = self.min+(i-1)*acc
				self.callback(self.m_chipNum)
			end
			-- self:hideDown()
		end)
		local img_normal = new(Image,viewPath.."img_add_normal.png")
			:addTo(btn)
			:align(kAlignCenter)
			:name("img_normal")
		local img_select = new(Image,viewPath.."img_add_select.png")
			:addTo(btn)
			:align(kAlignCenter)
			:name("img_select")
		local img_gray = new(Image,viewPath.."img_add_select.png")
			:addTo(btn)
			:align(kAlignCenter)
			:name("img_gray")
			:hide()
		img_gray:setGray(true)
		local text_chip = new(Text, "", 0, h, kAlignCenter,"", 24, 64, 97, 135)
				:addTo(btn)
				:align(kAlignCenter)
				:name("text_chip")

		local w,h = img_normal:getSize()
		btn:setSize(w,h)
		btn:setPos(btn_pos.x,btn_pos.y)
		btn_pos.y = btn_pos.y+h+offsetY
	end
	
	self:setMinMaxChip(1, 10)
	--self:freshBtns()

end

function viewAddChip:setLastChip(lastChip)
	--local progress = (lastChip-self.min)/(self.max-self.min)
	self.slider:setProgress(self.lastProgress)
	self:scrollChange(self.lastProgress)
end

function viewAddChip:setMinMaxChip(minChip,maxChip)
	self.min = minChip
	self.max = maxChip

	self.valListData = {}
	if self.max <= 100 then
		self.valListData[0] = {2, 4, 6, 8, 10}
		self.valListData[10] = {2, 4, 6, 8, 10}
		self.valListData[50] = {10, 20, 30, 40, 50}
		self.valListData[100] = {20, 40, 60, 80, 100}
	else
		local acc = math.floor((self.max-self.min)/(numOfItems - 1))
		self.valListData[self.max] = {}
		for i=1,numOfItems do
			self.valListData[self.max][i] = self.min+(i-1)*acc
		end
	end

	print("self.min",self.min,"self.max",self.max,"============")
	self:freshBtns()
	self:setLastChip(minChip)
end


function viewAddChip:selectIndex(index,needAdjust)
	self.m_chipNum = self.valListData[self.max][index]
	for i=1,numOfItems do		
		local btn = self.m_bg:findChildByName("btn_"..i)
		btn:findChildByName("img_normal"):show()
		btn:findChildByName("img_select"):hide()
		
		btn:findChildByName("text_chip"):setColor(64,97,135)
	end
	local btn = self.m_bg:findChildByName("btn_"..index)
	if btn then
		btn:findChildByName("img_normal"):hide()
		btn:findChildByName("img_select"):show()
		btn:findChildByName("text_chip"):setColor(201, 92, 0)

		if needAdjust then
			self.slider:setProgress((index-1)/(numOfItems - 1))
		end
	end
end

local function grayBtn(btn,isGray)
	btn:findChildByName("img_gray"):setVisible(isGray)
end

function viewAddChip:freshBtns()
	self.maxSelect = nil
	for i=1,numOfItems do
		local tmpValue = self.valListData[self.max][i]
		local btn = self.m_bg:findChildByName("btn_"..i) 

		local valForShow = tonumber(tmpValue)
		if valForShow > 1000 and valForShow < 1000000 then
			valForShow = valForShow/1000 .. 'K'
		elseif valForShow > 1000000 and valForShow < 100000000 then
			valForShow = valForShow/1000000 .. 'M'
		elseif valForShow > 100000000 then 
			valForShow = valForShow/100000000 .. 'B'
		end

		btn:findChildByName("text_chip"):setText(valForShow)

		local myMoney = 0
		if G_CUR_GAME_ID == tonumber(GAME_ID.PokdengCash) then
			myMoney = MyUserData:getCashPoint()
		elseif G_CUR_GAME_ID == tonumber(GAME_ID.Casinohall) then
			myMoney = MyUserData:getMoney()
		end

		if myMoney < tmpValue then
			btn:setEnable(false)
			btn:findChildByName("img_normal"):hide()
			btn:findChildByName("img_select"):show()
			grayBtn(btn,true)
		else
			self.maxSelect = i
			btn:setEnable(true)
			grayBtn(btn,false)
		end
	end

	if not self.maxSelect then 
		self.maxSelect = numOfItems
	end
	self.slider:setMaxProgress((self.maxSelect-1)/(numOfItems - 1))
end

function viewAddChip:showUp()
	self:show()
	self:freshBtns()
	local w,h = self.m_bg:getSize()
	local time = 0.2
	self.m_bg:runAction({{"opacity",0,1,time},{"x",w,0,time}},{loopType=kAnimNormal,order="spawn"})
	self.m_shadeBg:runAction({"opacity",0,0.8,time})
end

function viewAddChip:hideDown()
	local w,h = self.m_bg:getSize()
	local time = 0.4
	self.m_bg:runAction({{"opacity",1,0,time},{"x",0,w,time}},{loopType=kAnimNormal,order="spawn",onComplete=function()
			self:hide()
		end})
	self.m_shadeBg:runAction({"opacity",0.8,0,time})
end


function viewAddChip:scrollChange(progress)
	if progress <= 0 then
		progress = 0.01
	elseif progress >= 1 then
		progress = 1
	end
	self.lastProgress = progress

	local lastNum = #self.valListData[self.max]
	local index = math.ceil(lastNum * progress)
	local value = self.valListData[self.max][index]

	local distance = 10000000
	local selectIndex = nil
	for i=numOfItems,1,-1 do
		local tmpValue = self.valListData[self.max][i]--self.min+(i-1)*acc
		if math.abs(tmpValue-value)<distance then
			selectIndex = i
			distance = math.abs(tmpValue-value)
		end
	end
	if selectIndex then
		self:selectIndex(selectIndex)
	end
end

function viewAddChip:scrollClick(progress)
	self:scrollChange(progress)
	if self.callback and type(self.callback)=="function" then
		self.callback(self.m_chipNum)
	end
	-- self:hideDown()
end


return viewAddChip