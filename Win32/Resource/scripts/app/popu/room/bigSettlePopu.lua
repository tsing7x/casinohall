local GameWindow = require("app.popu.gameWindow")
local BigSettlePopu = class(GameWindow)
local Room_string = require("app.games.pokdeng.res.config")
local ItemView = require(ViewPath.."popu.room.view_bigSettleItem")
local RankItem = class(GameLayer,false)

local resPath = "games/settle/"
local blackPath = "common/blank.png"
local numPath = "games/number/settleRank/"

-- local cIndex = 0
-- local function getIndex()
-- 	cIndex = cIndex + 1
-- 	return cIndex
-- end
local function freshItem(item,data,needScale, isSelf)
	-- data = {
 --            rank = getIndex(),
 --            turnMoney = 60000,
 --            uid = 11238,
 --            userInfo = '{"appid":0,"sex":0,"micon":"","nick":"4.1.1"}'
 --        }
    local userInfo = json.decode(data.userInfo)
   	local img_rank = item:findChildByName("img_rank")
   	local text_rank = item:findChildByName("text_rank")
   	local view_head = item:findChildByName("view_head")
   	local text_name = item:findChildByName("text_name")
   	local tag_chip = item:findChildByName("tag_chip")
   	local text_turn = item:findChildByName("text_turn")

   	if isSelf then
   		img_rank:setFile(resPath.."img_rank_ribbon.png")
   		img_rank:setSize(116, 124)
   		--img_rank:removeAllChildren()
   		text_rank:setText(data.rank)
   	elseif data.rank>3 then
   		img_rank:setFile(resPath.."img_counter_bg.png")
   		img_rank:setSize(72, 72)
   		--img_rank:removeAllChildren()
   		text_rank:setText(data.rank)
   	elseif data.rank>0 then
   		img_rank:setFile(string.format(resPath.."img_rank_%s.png",data.rank))
   		img_rank:setSize(img_rank.m_res.width, img_rank.m_res.height)
   		text_rank:setText("")
   	end
   	-- text_name:setText(userInfo.nick)
   	ToolKit.formatTextLength(userInfo.nick,text_name, text_name:getSize())
   	text_turn:setText(data.turnMoney>0 and ("+"..data.turnMoney) or data.turnMoney)

   	local headData = setProxy(new((require("app.data.headData"))))
   	UIEx.bind(view_head, headData, "headName", function(value)
		local headView = view_head;
		headView:removeAllChildren();
		local width, height = headView:getSize()
		local imgHead = new(ImageMask, value, "games/common/head_mask.png")
					:addTo(headView)
					:size(width-8, height-8)
					:pos(4,4)
	end)
	headData:setHeadUrl(userInfo.micon or "")
	headData:checkHeadAndDownload()

	if needScale then
		img_rank:scale(1.2):_scale_at_anchor_point(true):anchor(0.5,0.5)
		text_name:scale(1.2):_scale_at_anchor_point(true):anchor(0.5,0.5)
		text_turn:scale(1.2):_scale_at_anchor_point(true):anchor(0.5,0.5)
	end
end

function RankItem:ctor(data)
	super(self,ItemView)
	self.m_data = data	
	local dw,dh = self.m_root:findChildByName("view_prefeb"):getSize();
	print("==========",dw,dh)
	GameLayer.setSize(self, dw, dh);
	
	if data then	
		freshItem(self,data)
	end
end

BigSettlePopu.s_controls =
{
	close_btn = 1,
	btn_confirm = 2,
};


function BigSettlePopu:initView(data)
	if not data then return end
	self.callback = data.callback
	self.timeOut = data.timeOut
	self.m_rankData = data.rankData

	self.m_rankList = new(ListView)
	self.m_rankList:setSize(610,500)
	self.m_rankList:setPos(0,10)
	self.m_rankList:setAlign(kAlignBottom)
	self.m_rankList:addTo(self:findChildByName("view_inner"))
	self.m_rankList:setDirection(kVertical)
	local myData = nil
	for k,v in pairs(self.m_rankData) do
		if v.uid==MyUserData:getId() then
			myData = v
			break
		end
	end

	if myData==nil then
		return
	end
	self:setRankListDatas(self.m_rankData)
	freshItem(self:findChildByName("view_myItem"),myData,true, true)
	JLog.d("zcc waitTime", data.waitTime)
	self:showClock(data.waitTime)
end

function BigSettlePopu:showClock(time)
	local text_counter = self:getControl(self.s_controls.btn_confirm):findChildByName("text_counter")
	local text_confirm = self:getControl(self.s_controls.btn_confirm):findChildByName("text_confirm")	
	text_counter:setText(math.floor(time))
	text_confirm:setText(Room_string.str_confirm)
	local acc = 0
	local diff = 0.1
	local m_handler
	local function stop()
		if m_handler then
			m_handler:cancel()
			m_handler = nil
			if type(self.timeOut)=="function" then
				self:timeOut()
			end
		end
	end
	local callback = function()
		if text_counter.m_res==nil then
			stop()
		end
		acc = acc + diff
		time = time - diff
		if math.abs(acc-1)<0.000001 then
			acc = 0
			text_counter:setText(math.floor(time))
		end
		if math.abs(time-0)<0.000001 then
			stop()
		end
	end
	m_handler = Clock.instance():schedule(callback,diff)
end

function BigSettlePopu:setRankListDatas(datas)
	datas = datas or {}

	if not self.m_rankListAdapter then
		self.m_rankListAdapter = new(CacheAdapter,RankItem,datas)
		self.m_rankList:setAdapter(self.m_rankListAdapter)
		-- self.m_rankList:setPage(1,false)
	else
		self.m_rankListAdapter:changeData(datas)
	end

	
end

function BigSettlePopu:onCloseBtnClick()
	self:dismiss(true)
end

function BigSettlePopu:onConfirmBtnClick()
	if type(self.callback)=="function" then
		self.callback()
	end
	self:dismiss()
end

----------------------------  config  --------------------------------------------------------
BigSettlePopu.s_controlConfig = 
{
	[BigSettlePopu.s_controls.close_btn] 	= {"img_popuBg", "btn_close"},
	[BigSettlePopu.s_controls.btn_confirm] 	= {"img_popuBg", "btn_confirm"},
};

BigSettlePopu.s_controlFuncMap = 
{
	[BigSettlePopu.s_controls.close_btn] = BigSettlePopu.onCloseBtnClick;
	[BigSettlePopu.s_controls.btn_confirm] = BigSettlePopu.onConfirmBtnClick;
};

return BigSettlePopu