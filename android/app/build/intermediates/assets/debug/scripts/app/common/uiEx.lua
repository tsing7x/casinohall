-- drawing.lua
-- Author: Lennon Zhao
-- Date: 2013-01-09
-- Last modification : 2015-03-09
-- Description: 将控件绑定数据源，自动监控数据源的变化

--[[
	将某个控件 与 数据源绑定，通过监控数据源的变动来改变控件的显示
	使用示例
	UserData = class()
	property(UserData, "money", "Money", true, true)
	
	-- 创建数据源 并设置代理
	MyUserData = setProxy(new(UserData))

	-- 在某个 scene中
	local moneyText = self:getControl(self.m_ctrl.userMoney)
	UIEx.bind(moneyText, MyUserData, "money", function(value)
		moneyText:setText(value)
	end)

	-- 某个地方调用
	MyUserData:setMoney(1001)
	-- 控件moneyText自动更新，显示为1001
]]

--[[
	为数据源设置代理 
	通过元表控制对数据源的访问
]]
function setProxy(t)
    local proxy = {};
    setmetatable(proxy, {
        __index = function(tb, key)
            return t[key];  --访问的时候直接返回代理表中的值
        end,
        __newindex = function(tb, key, value)  --设置值的时候通知监控对象更新
        	local oldData = t[key]
            t[key] = value;
            -- 添加代理
            key = string.format("%sObserver", key)
            if type(t[key]) == "table" then
                for _,v in pairs(t[key]) do
                	if v.node then
                    	v.callback(value, oldData)
                	end
                end
            end
        end
    })
    return proxy;
end

UIEx = {}
local function unBind(node)
	if node and node.bindData then
		for tb, keyTb in pairs(node.bindData) do
			for _, key in pairs(keyTb) do
				-- tb[key]
				local callbackTb = tb[key]
				for i=#callbackTb, 1, -1 do
					if callbackTb[i].node == node then
						printInfo("移除了监控%s", key)
						table.remove(callbackTb, i)
					end					
				end
			end
		end
	end
end

function UIEx.bind(node, tb, key, callback)
	key = string.format("%sObserver", key)

	if not tb[key] then
		tb[key] = {}  -- 初始化
		table.insert(tb[key], {
			node = node,
			callback = callback,
		})
	else
		local flag = false
		for i=#tb[key], 1, -1 do
			local record = tb[key][i]
			if record.node == node then
				record.callback = callback
				flag = true
				break
			end
		end
		if not flag then
			table.insert(tb[key], {
				node = node, 
				callback = callback,
			})
		end
	end
	if not node.bindData then
		node.bindData = {}
		node.__originDtor = node.dtor
		node.dtor = function(node, ...)
			unBind(node)
			node.__originDtor(node, ...)
		end
	end
	if not node.bindData[tb] then
		node.bindData[tb] = {}
	end
	node.bindData[tb][key] = key
end

function checkAndRemoveOneProp(node, propId)
	if node and node.m_props[propId] then  
		node:removeProp(propId);
	end
end