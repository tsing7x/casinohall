NativeEvent.callNativeEvent = function(self, keyParm , data)
end

-- 拍照
NativeEvent.takePhoto = function(self, str)
end

--选择图片
NativeEvent.pickPhoto = function(self, str)
end

NativeEvent.chooseFeedBackImg = function(self)
	-- body
end

--上传图片
NativeEvent.uploadImage = function(self, str)
end

--打开网页
NativeEvent.openWeb = function(self, url)
end

--打开网页
NativeEvent.closeWeb = function(self)
end

--打开条款
NativeEvent.openRule = function(self, ruleUrl)
end

--关闭条款
NativeEvent.closeRule = function(self)
end
--打开粉丝页
NativeEvent.openLink = function(self, url)
end
--打开第三方登录
NativeEvent.login = function(self, param)
end
--注销
NativeEvent.logout = function(self, param)
end
--获取Facebook好友
NativeEvent.getFbFriend = function(self, param)
	printInfo("getFbFriend")
	local str = [=[
		[{"id":"AVmjI90L648dW1C_NMwit_gjHrEBfRpzVo9ccML2lN6uKO17ov7t_2MOxztrWuhNaQCo0ICU6MbGUWX4YbIp_8Twz9m97xUbWh7ciniSvhtUEw","name":"钟雨宏","picture":{"data":{"is_silhouette":false,"url":"https:\/\/fb-s-b-a.akamaihd.net\/h-ak-fbx\/v\/t1.0-1\/p50x50\/14479651_312256335816022_1472149478071580439_n.jpg?oh=ce3f6e0bfa5a22950eabda4741c7d04e&oe=59F95009&__gda__=1506001982_2db122cae7fda3fc94a7eaf9c3d24878"}}},{"id":"AVkzO77RFhv4WfgpcWjqXkidiFpnKo608d-h-VKKrNzYKLMOVla-4bYX0D-ljPElYhQa1qS3BqL9tiNR7T7iwmGJmev-BOpaC54Wi1EpWKuWsw","name":"Doria Wu1","picture":{"data":{"is_silhouette":false,"url":"https:\/\/fb-s-d-a.akamaihd.net\/h-ak-fbx\/v\/t1.0-1\/c0.0.50.50\/p50x50\/12187799_121760811518494_2861490128523898475_n.jpg?oh=d49676793803077d2e52ebc22bae2305&oe=59C5B534&__gda__=1510163501_7659e192d8c6b5143a2689cdf0784f2a"}}},{"id":"AVkzO77RFhv4WfgpcWjqXkidiFpnKo608d-h-VKKrNzYKLMOVla-4bYX0D-ljPElYhQa1qS3BqL9tiNR7T7iwmGJmev-BOpaC54Wi1EpWKuWsw","name":"Doria Wu2","picture":{"data":{"is_silhouette":false,"url":"https:\/\/fb-s-d-a.akamaihd.net\/h-ak-fbx\/v\/t1.0-1\/c0.0.50.50\/p50x50\/12187799_121760811518494_2861490128523898475_n.jpg?oh=d49676793803077d2e52ebc22bae2305&oe=59C5B534&__gda__=1510163501_7659e192d8c6b5143a2689cdf0784f2a"}}},{"id":"AVkzO77RFhv4WfgpcWjqXkidiFpnKo608d-h-VKKrNzYKLMOVla-4bYX0D-ljPElYhQa1qS3BqL9tiNR7T7iwmGJmev-BOpaC54Wi1EpWKuWsw","name":"Doria Wu3","picture":{"data":{"is_silhouette":false,"url":"https:\/\/fb-s-d-a.akamaihd.net\/h-ak-fbx\/v\/t1.0-1\/c0.0.50.50\/p50x50\/12187799_121760811518494_2861490128523898475_n.jpg?oh=d49676793803077d2e52ebc22bae2305&oe=59C5B534&__gda__=1510163501_7659e192d8c6b5143a2689cdf0784f2a"}}},{"id":"AVkzO77RFhv4WfgpcWjqXkidiFpnKo608d-h-VKKrNzYKLMOVla-4bYX0D-ljPElYhQa1qS3BqL9tiNR7T7iwmGJmev-BOpaC54Wi1EpWKuWsw","name":"Doria Wu4","picture":{"data":{"is_silhouette":false,"url":"https:\/\/fb-s-d-a.akamaihd.net\/h-ak-fbx\/v\/t1.0-1\/c0.0.50.50\/p50x50\/12187799_121760811518494_2861490128523898475_n.jpg?oh=d49676793803077d2e52ebc22bae2305&oe=59C5B534&__gda__=1510163501_7659e192d8c6b5143a2689cdf0784f2a"}}},{"id":"AVkzO77RFhv4WfgpcWjqXkidiFpnKo608d-h-VKKrNzYKLMOVla-4bYX0D-ljPElYhQa1qS3BqL9tiNR7T7iwmGJmev-BOpaC54Wi1EpWKuWsw","name":"Doria Wu5","picture":{"data":{"is_silhouette":false,"url":"https:\/\/fb-s-d-a.akamaihd.net\/h-ak-fbx\/v\/t1.0-1\/c0.0.50.50\/p50x50\/12187799_121760811518494_2861490128523898475_n.jpg?oh=d49676793803077d2e52ebc22bae2305&oe=59C5B534&__gda__=1510163501_7659e192d8c6b5143a2689cdf0784f2a"}}},{"id":"AVkzO77RFhv4WfgpcWjqXkidiFpnKo608d-h-VKKrNzYKLMOVla-4bYX0D-ljPElYhQa1qS3BqL9tiNR7T7iwmGJmev-BOpaC54Wi1EpWKuWsw","name":"Doria Wu6","picture":{"data":{"is_silhouette":false,"url":"https:\/\/fb-s-d-a.akamaihd.net\/h-ak-fbx\/v\/t1.0-1\/c0.0.50.50\/p50x50\/12187799_121760811518494_2861490128523898475_n.jpg?oh=d49676793803077d2e52ebc22bae2305&oe=59C5B534&__gda__=1510163501_7659e192d8c6b5143a2689cdf0784f2a"}}},{"id":"AVkzO77RFhv4WfgpcWjqXkidiFpnKo608d-h-VKKrNzYKLMOVla-4bYX0D-ljPElYhQa1qS3BqL9tiNR7T7iwmGJmev-BOpaC54Wi1EpWKuWsw","name":"Doria Wu7","picture":{"data":{"is_silhouette":false,"url":"https:\/\/fb-s-d-a.akamaihd.net\/h-ak-fbx\/v\/t1.0-1\/c0.0.50.50\/p50x50\/12187799_121760811518494_2861490128523898475_n.jpg?oh=d49676793803077d2e52ebc22bae2305&oe=59C5B534&__gda__=1510163501_7659e192d8c6b5143a2689cdf0784f2a"}}},{"id":"AVkzO77RFhv4WfgpcWjqXkidiFpnKo608d-h-VKKrNzYKLMOVla-4bYX0D-ljPElYhQa1qS3BqL9tiNR7T7iwmGJmev-BOpaC54Wi1EpWKuWsw","name":"Doria Wu8","picture":{"data":{"is_silhouette":false,"url":"https:\/\/fb-s-d-a.akamaihd.net\/h-ak-fbx\/v\/t1.0-1\/c0.0.50.50\/p50x50\/12187799_121760811518494_2861490128523898475_n.jpg?oh=d49676793803077d2e52ebc22bae2305&oe=59C5B534&__gda__=1510163501_7659e192d8c6b5143a2689cdf0784f2a"}}},{"id":"AVkzO77RFhv4WfgpcWjqXkidiFpnKo608d-h-VKKrNzYKLMOVla-4bYX0D-ljPElYhQa1qS3BqL9tiNR7T7iwmGJmev-BOpaC54Wi1EpWKuWsw","name":"Doria Wu9","picture":{"data":{"is_silhouette":false,"url":"https:\/\/fb-s-d-a.akamaihd.net\/h-ak-fbx\/v\/t1.0-1\/c0.0.50.50\/p50x50\/12187799_121760811518494_2861490128523898475_n.jpg?oh=d49676793803077d2e52ebc22bae2305&oe=59C5B534&__gda__=1510163501_7659e192d8c6b5143a2689cdf0784f2a"}}},{"id":"AVkzO77RFhv4WfgpcWjqXkidiFpnKo608d-h-VKKrNzYKLMOVla-4bYX0D-ljPElYhQa1qS3BqL9tiNR7T7iwmGJmev-BOpaC54Wi1EpWKuWsw","name":"Doria Wu10","picture":{"data":{"is_silhouette":false,"url":"https:\/\/fb-s-d-a.akamaihd.net\/h-ak-fbx\/v\/t1.0-1\/c0.0.50.50\/p50x50\/12187799_121760811518494_2861490128523898475_n.jpg?oh=d49676793803077d2e52ebc22bae2305&oe=59C5B534&__gda__=1510163501_7659e192d8c6b5143a2689cdf0784f2a"}}},{"id":"AVkzO77RFhv4WfgpcWjqXkidiFpnKo608d-h-VKKrNzYKLMOVla-4bYX0D-ljPElYhQa1qS3BqL9tiNR7T7iwmGJmev-BOpaC54Wi1EpWKuWsw","name":"Doria Wu11","picture":{"data":{"is_silhouette":false,"url":"https:\/\/fb-s-d-a.akamaihd.net\/h-ak-fbx\/v\/t1.0-1\/c0.0.50.50\/p50x50\/12187799_121760811518494_2861490128523898475_n.jpg?oh=d49676793803077d2e52ebc22bae2305&oe=59C5B534&__gda__=1510163501_7659e192d8c6b5143a2689cdf0784f2a"}}},{"id":"AVkzO77RFhv4WfgpcWjqXkidiFpnKo608d-h-VKKrNzYKLMOVla-4bYX0D-ljPElYhQa1qS3BqL9tiNR7T7iwmGJmev-BOpaC54Wi1EpWKuWsw","name":"Doria Wu12","picture":{"data":{"is_silhouette":false,"url":"https:\/\/fb-s-d-a.akamaihd.net\/h-ak-fbx\/v\/t1.0-1\/c0.0.50.50\/p50x50\/12187799_121760811518494_2861490128523898475_n.jpg?oh=d49676793803077d2e52ebc22bae2305&oe=59C5B534&__gda__=1510163501_7659e192d8c6b5143a2689cdf0784f2a"}}},{"id":"AVkzO77RFhv4WfgpcWjqXkidiFpnKo608d-h-VKKrNzYKLMOVla-4bYX0D-ljPElYhQa1qS3BqL9tiNR7T7iwmGJmev-BOpaC54Wi1EpWKuWsw","name":"Doria Wu13","picture":{"data":{"is_silhouette":false,"url":"https:\/\/fb-s-d-a.akamaihd.net\/h-ak-fbx\/v\/t1.0-1\/c0.0.50.50\/p50x50\/12187799_121760811518494_2861490128523898475_n.jpg?oh=d49676793803077d2e52ebc22bae2305&oe=59C5B534&__gda__=1510163501_7659e192d8c6b5143a2689cdf0784f2a"}}},{"id":"AVkzO77RFhv4WfgpcWjqXkidiFpnKo608d-h-VKKrNzYKLMOVla-4bYX0D-ljPElYhQa1qS3BqL9tiNR7T7iwmGJmev-BOpaC54Wi1EpWKuWsw","name":"Doria Wu14","picture":{"data":{"is_silhouette":false,"url":"https:\/\/fb-s-d-a.akamaihd.net\/h-ak-fbx\/v\/t1.0-1\/c0.0.50.50\/p50x50\/12187799_121760811518494_2861490128523898475_n.jpg?oh=d49676793803077d2e52ebc22bae2305&oe=59C5B534&__gda__=1510163501_7659e192d8c6b5143a2689cdf0784f2a"}}},{"id":"AVkzO77RFhv4WfgpcWjqXkidiFpnKo608d-h-VKKrNzYKLMOVla-4bYX0D-ljPElYhQa1qS3BqL9tiNR7T7iwmGJmev-BOpaC54Wi1EpWKuWsw","name":"Doria Wu15","picture":{"data":{"is_silhouette":false,"url":"https:\/\/fb-s-d-a.akamaihd.net\/h-ak-fbx\/v\/t1.0-1\/c0.0.50.50\/p50x50\/12187799_121760811518494_2861490128523898475_n.jpg?oh=d49676793803077d2e52ebc22bae2305&oe=59C5B534&__gda__=1510163501_7659e192d8c6b5143a2689cdf0784f2a"}}},{"id":"AVkzO77RFhv4WfgpcWjqXkidiFpnKo608d-h-VKKrNzYKLMOVla-4bYX0D-ljPElYhQa1qS3BqL9tiNR7T7iwmGJmev-BOpaC54Wi1EpWKuWsw","name":"Doria Wu16","picture":{"data":{"is_silhouette":false,"url":"https:\/\/fb-s-d-a.akamaihd.net\/h-ak-fbx\/v\/t1.0-1\/c0.0.50.50\/p50x50\/12187799_121760811518494_2861490128523898475_n.jpg?oh=d49676793803077d2e52ebc22bae2305&oe=59C5B534&__gda__=1510163501_7659e192d8c6b5143a2689cdf0784f2a"}}},{"id":"AVkzO77RFhv4WfgpcWjqXkidiFpnKo608d-h-VKKrNzYKLMOVla-4bYX0D-ljPElYhQa1qS3BqL9tiNR7T7iwmGJmev-BOpaC54Wi1EpWKuWsw","name":"Doria Wu17","picture":{"data":{"is_silhouette":false,"url":"https:\/\/fb-s-d-a.akamaihd.net\/h-ak-fbx\/v\/t1.0-1\/c0.0.50.50\/p50x50\/12187799_121760811518494_2861490128523898475_n.jpg?oh=d49676793803077d2e52ebc22bae2305&oe=59C5B534&__gda__=1510163501_7659e192d8c6b5143a2689cdf0784f2a"}}}]
		]=]
	self:onGetFbFriendCallback(json.decode_node(str))
end
--邀请好友
NativeEvent.inviteFbFriend = function(self, param)
end
--邀请短信好友
NativeEvent.inviteSmsFriend = function(self, param)
end
--本地更新
NativeEvent.UpdateByLocal = function(self, url, force)
end
--友盟更新
NativeEvent.UpdateByUmeng = function(self, isActUpdata, isDeltaUpdate, isForceUpdate, isCheckForProcess)
end
--检测更新
NativeEvent.CheckPackByLocal = function(self, url)
end
--头像下载
NativeEvent.downloadImage = function(self, param)
end
--重命令头像
NativeEvent.renameImage = function(self, oldName, newName, url)
end
--下载文件
NativeEvent.downloadFile = function(self, type, url, file, tag)
	printInfo("开始下载文件")
end

--解压文件
NativeEvent.unzip = function(self, type, path, file, tag)
end
--解压游戏
NativeEvent.unzipGame = function(self, file)
end
-- 立即返回结果的的操作
NativeEvent.encodeStr = function(self, str)
	return str
end

NativeEvent.compressString = function(self, str)
end

NativeEvent.unCompressString = function(self, str)
end

NativeEvent.isFileExist = function(self, str)
	return 1
end
NativeEvent.collectByUmeng = function(self, param)
end
--推广
NativeEvent.loadAdData = function(self, param)
end
NativeEvent.showAd = function(self, param)
end
NativeEvent.openActivity = function(self, param)
end
--录制及回放
NativeEvent.startRecord = function(self)
end
NativeEvent.stopRecord = function(self)
end
NativeEvent.playBack = function(self)
end
NativeEvent.stopPlayBack = function(self)
end
-- 涉及ui的操作 放在消息队列中执行
--延时释放 defualt png , 解决 Android 游戏启动时屏幕黑一下的问题
NativeEvent.CloseStartScreen = function(self)
end

NativeEvent.GetInitValue =function(self)
end

NativeEvent.GetNetAvaliable = function(self)
	return 1
end

NativeEvent.PreloadAllSound = function(self, musicsMap, effectsMap)
end

NativeEvent.ReportLuaError = function(self, faultInfo)
end

NativeEvent.Exit = function(self)
end

--	NativeEvent.StartUnitePay = function(self, param_data)
--	end

--传支付配置
NativeEvent.payConfig = function(self,param)
end

--下单支付
NativeEvent.startPay = function(self,param)
end

--支付
NativeEvent.pay = function(self, param)
end

--分享
NativeEvent.share = function(self, param)
end

--cid
NativeEvent.getClientId = function(self, param)
end

--评分
NativeEvent.score = function(self, param)
end

NativeEvent.boyaaAd = function(self, param)
end

NativeEvent.shareToMessenger = function(self, param)
end
NativeEvent.shareToMessenger = function(self, param)
end

NativeEvent.isMessengerExist = function(self)
	return 0
end

--获取启动方式，默认0是点击图标启动，1是从fb messenger启动，用于统计启动方式
NativeEvent.getStartWay = function(self)
	return ""
end
NativeEvent.getAllUpdateFile = function(self, param)
	return ""
end
NativeEvent.getNetworkType = function(self)
	return 0
end

NativeEvent.backupScripts = function(self)
	return 1
end
NativeEvent.updateGameFinish = function(self)
	return 0
end
NativeEvent.deleteFile = function(self, param)
end
NativeEvent.getLocation = function(self)
	return ""
end
NativeEvent.checkUnfinishIAP = function(self)
end
NativeEvent.consumeProduct = function(self, param)
end
NativeEvent.getFileMD5 = function(self, param)
	return ""
end
NativeEvent.getPermission = function(self, param)
	return "success"
end
NativeEvent.downloadUpdateApk = function(self, param)
end
NativeEvent.pauseDownloadUpdateApk = function(self, param)
end
NativeEvent.installUpdateApk = function(self, param)
end
NativeEvent.queryDownloadProgress = function(self, param)
	return 0
end
NativeEvent.queryDownloadStatus = function(self, param)
	return 0
end
NativeEvent.deleteDownloadTask = function(self, param)
	return 1
end
NativeEvent.getSystemVersion = function(self, param)
	return ""
end
