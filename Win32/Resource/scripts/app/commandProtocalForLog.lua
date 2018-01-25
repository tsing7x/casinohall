commandProtocalForLog = {}

--私人房协议
commandProtocalForLog['0x0114'] = '用户请求创建私人房(弃用)'
commandProtocalForLog['0x0115'] = '用户请求进入私人房(输口令)'
commandProtocalForLog['0x0117'] = '用户请求进入私人房(随机加入)'
commandProtocalForLog['0x0127'] = '用户请求创建私人房'
commandProtocalForLog['0x0128'] = '用户续费'
commandProtocalForLog['0x0129'] = '返回续费操作结果'
commandProtocalForLog['0x0210'] = '返回用户进入房间'
commandProtocalForLog['0x0212'] = '返回用户进入私人房间'
commandProtocalForLog['0x0218'] = 'server返回私人房间列表'
commandProtocalForLog['0x0219'] = '房间剩余时间'
commandProtocalForLog['0x1005'] = '登陆错误'
commandProtocalForLog['0x1025'] = '向私人房广播剩余有效时间或是用户充值'
commandProtocalForLog['0x1038'] = '获取私人房实时账单'
commandProtocalForLog['0x1039'] = '用户退出私人房时账单信息'
--commandProtocalForLog['0x1058'] = '私人房账单信息'
--commandProtocalForLog['0x1059'] = '用户退出私人房时账单信息'
commandProtocalForLog['0x0220'] = '私人房时间到期，需要等到玩家游戏结束之后执行踢人操作'

--博定场协议
commandProtocalForLog['0x0116'] = '登录大厅'
commandProtocalForLog['0x0202'] = '登录大厅返回'
commandProtocalForLog['0x0118'] = '请求分配桌子ID'
commandProtocalForLog['0x0123'] = '跟随用户请求进入桌子'
commandProtocalForLog['0x0214'] = '跟随用户请求进入桌子失败返回'
commandProtocalForLog['0x1001'] = '请求登录游戏'
commandProtocalForLog['0x2001'] = '服务器返回登陆成功，兼容重连'
commandProtocalForLog['0x2011'] = '服务器返回登陆失败'
commandProtocalForLog['0x1002'] = '用户请求离开房间'
commandProtocalForLog['0x1008'] = '服务器返回离开房间'
commandProtocalForLog['0x1013'] = '用户请求坐下'
commandProtocalForLog['0x2003'] = '用户坐下返回'
commandProtocalForLog['0x1004'] = '用户请求站起'
commandProtocalForLog['0x2004'] = '服务器返回请求站起'
commandProtocalForLog['0x1010'] = '用户请求第三张牌'
commandProtocalForLog['0x1038'] = '庄家请求开始游戏'
commandProtocalForLog['0x1058'] = '请求开始返回'
commandProtocalForLog['0x1059'] = '提示庄家可以开始牌局'
commandProtocalForLog['0x2005'] = '服务器返回第三张牌'
commandProtocalForLog['0x1006'] = '用户下注'
commandProtocalForLog['0x2006'] = '服务器返回用户下注'
commandProtocalForLog['0x1003'] = '用户请求房间内聊天/服务器广播房间内聊天'
commandProtocalForLog['0x2008'] = '通知玩家手牌'
commandProtocalForLog['0x6002'] = '服务器广播用户登出'
commandProtocalForLog['0x6003'] = '服务器广播用户坐下'
commandProtocalForLog['0x6004'] = '服务器广播用户站起'
commandProtocalForLog['0x6006'] = '服务器广播游戏开始'
commandProtocalForLog['0x6007'] = '服务器广播牌局结束，结算结果'
commandProtocalForLog['0x6008'] = '服务器广播玩家下注'
commandProtocalForLog['0x6009'] = '服务器广播可以开始获取第三张牌'
commandProtocalForLog['0x6010'] = '服务器广播用户操作获取第三张牌结果'
commandProtocalForLog['0x6011'] = '服务器广播用户亮牌'
commandProtocalForLog['0x6012'] = '服务器广播前两张牌'
commandProtocalForLog['0x1050'] = '请求在桌子广播'
commandProtocalForLog['0x6013'] = '服务器桌子广播'
commandProtocalForLog['0x1034'] = '请求上庄'
commandProtocalForLog['0x1054'] = '请求上庄返回'
commandProtocalForLog['0x1035'] = '请求获取上庄列表'
commandProtocalForLog['0x1055'] = '请求获取上庄列表返回'
commandProtocalForLog['0x1036'] = '请求获取所有玩家信息'
commandProtocalForLog['0x1056'] = '请求获取所有玩家信息返回'
commandProtocalForLog['0x1037'] = '请求下庄'
commandProtocalForLog['0x1057'] = '请求下庄返回'
commandProtocalForLog['0x7052'] = '单播接口(充值等功能使用)'
commandProtocalForLog['0x7854'] = '桌子上广播接口'
commandProtocalForLog['0x7852'] = 'php 推送广播客户端消息'
commandProtocalForLog['0x1014'] = '发送表情/用户私聊桌子广播'
commandProtocalForLog['0x6014'] = '一轮后广播玩家输赢排名情况'
commandProtocalForLog['0x1060'] = 'server广播庄家处于离线状态'
commandProtocalForLog['0x011a'] = '客户端请求登录房间'

function printSocket(cmd, isSnd)
	cmd = string.format("0x%04x", cmd)

	if not commandProtocalForLog[cmd] then
		print('casinohall socket: 不存在命令' .. cmd)
		return
	end

	if cmd == '0x6006' then
		print("casinohall socket: ========================================================================")
	end

	if isSnd then 
		print('casinohall socket: 发送命令-------- ' .. cmd .. ' --------' .. commandProtocalForLog[cmd])
	else
		print('casinohall socket: 处理命令-------- ' .. cmd .. ' --------' .. commandProtocalForLog[cmd])
	end

end