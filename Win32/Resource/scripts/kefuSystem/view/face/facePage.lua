local UI = require('byui/basic');
local AL = require('byui/autolayout');
local Layout = require('byui/layout');
local class, mixin, super = unpack(require('byui/class'))
local KefuResMap = require('kefuSystem/chat_face')


local facePage = class('facePage', nil, {
	__init__ = function (self,obj,callBack)
		self.m_obj = obj;
		self.m_root = obj:getRoot();
		self.m_callBack = callBack;
		self.m_pageView = UI.PageView {
            dimension = kHorizental,
            max_number = 5,
            is_cache = true,
        }
        self.m_prevPage = 1;
        self.m_gridLayouts = {}

        self.m_pageView:add_rules({
        	AL.width:eq(AL.parent('width')),
	        AL.height:eq(AL.parent('height')-30),
        	})
        self.m_root:add(self.m_pageView);


        self.m_pageView.create_cell = function(pageView,index)
            local page = self:initPage(index);
            return page
        end;


        self.m_pageView.on_page_change = function(obj,index)
        	if self.m_callBack and self.m_obj then
            	self.m_callBack(self.m_obj,index , self.m_prevPage);
            	self.m_prevPage = index;
            end
        end;

        self.m_pageView:update_data();

	end,
	
	setIconEvent = function (self, func)
		self.m_iconFunc = func
	end,

	setDelIconEvent = function (self, func)
		self.m_delIconFunc = func
	end,

	initPage = function(self, index)
		if self.m_gridLayouts[index] then return self.m_gridLayouts[index] end

		local start = (index-1)*20 + 1;
		local num = index * 20;
		if num > 90 then
			num = 90
		end

		local layout = Layout.GridLayout{
	        cols = 7,
	        rows = 3,
	        dimension = kVertical,
	        align = ALIGN.CENTER
	    }
	    self.m_gridLayouts[index] = layout

	    layout:add_rules( {
	        	AL.width:eq(AL.parent('width')),
	            AL.height:eq(AL.parent('height')),
	        })

	    local btnPath = "";
	    local i = start
	    Clock.instance():schedule(function (  )
	    	-- if not self.running then
	    	-- 	print("schedule running--------------------------")
	    	-- 	return true
	    	-- end
	    	if i > num then
	    		local delBtn = Sprite()
	    		delBtn.unit = TextureUnit.load(KefuResMap["appkefu_del_btn_nor.png"])
	    		delBtn.size = Point(58,50)
	           	

	    		 UI.init_simple_event(delBtn,function ( ... )
		        	if self.m_delIconFunc then
		            	self.m_delIconFunc()
		            end
		        end)

		        layout:add(delBtn);
		        layout.cache = true
	    		return true
	    	end


	    	local strIdx = tostring(i)
	    	local index = i
	    	if i < 10 then
	    		strIdx = string.format("00%d", i)
	    	elseif i < 100 then
	    		strIdx = string.format("0%d", i)
	    	end

	        btnPath = string.format('appkefu_f%s.png', strIdx)
	        local faceBtn = Sprite()
	        faceBtn.unit = TextureUnit.load(KefuResMap[btnPath])
	       	faceBtn.size = Point(60,60)
	        
	        UI.init_simple_event(faceBtn,function ( ... )
	        	if self.m_iconFunc then
	            	self.m_iconFunc(index)
	        	end
	        end)

	        -- faceBtn.on_click = function()
	        	
	        	
	        -- end
	        layout:add(faceBtn);
	        i = i +1 
	    end)
	    -- for i=start, num do
	    -- 	local strIdx = tostring(i)
	    -- 	if i < 10 then
	    -- 		strIdx = string.format("00%d", i)
	    -- 	elseif i < 100 then
	    -- 		strIdx = string.format("0%d", i)
	    -- 	end

	    --     btnPath = string.format('face_f%s', strIdx)
	    --     local faceBtn = UI.Button {
	    --         text = '',
	    --         radius = 0,
	    --         image =
	    --         {
	    --             normal = TextureUnit(TextureCache.instance():get(KefuResMap[btnPath])),
	    --         },
	    --         border = 0,
	    --     }

	    --     faceBtn:add_rules({
	    --         AL.width:eq(60),
	    --         AL.height:eq(60),
	    --     })

	    --     faceBtn.on_click = function()
	    --     	if self.m_iconFunc then
	    --         	self.m_iconFunc(i)
	    --     	end
	        	
	    --     end
	    --     layout:add(faceBtn);
	    -- end
	    
	    


	    

	    return layout;
	end,


})

return facePage;