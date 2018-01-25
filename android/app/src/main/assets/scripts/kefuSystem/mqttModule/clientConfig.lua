
local ClientConfig = class();
--config
property(ClientConfig,"host","Host",true,true); --string
property(ClientConfig,"port","Port",true,true);--string
property(ClientConfig,"gameId","GameId",true,true);--string
property(ClientConfig,"siteId","SiteId",true,true);--string
property(ClientConfig,"role","Role",true,true);--string
property(ClientConfig,"stationId","StationId",true,true);--string
property(ClientConfig,"avatarUri","AvatarUri",true,true);--string
property(ClientConfig,"host","Host",true,true);--string
property(ClientConfig,"qos","Qos",true,true);--number
property(ClientConfig,"cleanSession","CleanSession",true,true); --boolean
property(ClientConfig,"keepalive","Keepalive",true,true); --number
property(ClientConfig,"timeout","Timeout",true,true); --number 秒
property(ClientConfig,"retain","Retain",true,true); --boolean
property(ClientConfig,"ssl","Ssl",true,true); --boolean
property(ClientConfig,"sslKey","SslKey",true,true);--string
property(ClientConfig,"userName","UserName",true,true);--string
property(ClientConfig,"userPwd","UserPwd",true,true);--string

property(ClientConfig,"service_gid","Service_gid",true,true);--string
property(ClientConfig,"service_sid","Service_sid",true,true);--string
property(ClientConfig,"service_stationId","Service_stationId",true,true);--string
property(ClientConfig,"avatarDownloadUri","AvatarDownloadUri",true,true);--string
property(ClientConfig,"service_nickName","Service_nickName",true,true);--string
property(ClientConfig,"service_avatarUri","Service_avatarUri",true,true);--string
property(ClientConfig,"service_avatarDownloadUri","Service_avatarDownloadUri",true,true);--string
property(ClientConfig,"service_ext","Service_ext",true,true);--string


-- info (avatarUri上面有)
property(ClientConfig,"nickName","NickName",true,true);--string
property(ClientConfig,"vipLevel","VipLevel",true,true);--string
property(ClientConfig,"gameName","GameName",true,true);--string
property(ClientConfig,"accountType","AccountType",true,true);--string
property(ClientConfig,"client","Client",true,true);--string
property(ClientConfig,"userID","UserID",true,true);--string
property(ClientConfig,"deviceType","DeviceType",true,true);--string
property(ClientConfig,"connectivity","Connectivity",true,true);--string
property(ClientConfig,"gameVersion","GameVersion",true,true);--string
property(ClientConfig,"deviceDetail","DeviceDetail",true,true);--string
property(ClientConfig,"mac","Mac",true,true);--string
property(ClientConfig,"ip","Ip",true,true);--string
property(ClientConfig,"browser","Browser",true,true);--string
property(ClientConfig,"screen","Screen",true,true);--string
property(ClientConfig,"OSVersion","OSVersion",true,true);--string
property(ClientConfig,"jailbreak","Jailbreak",true,true);--boolean
property(ClientConfig,"operator","Operator",true,true);--string

--传一个配置表，配置表的字段跟ClientConfig类一样
ClientConfig.ctor = function (self, configTable)
    if configTable == nil or type(configTable) ~= "table" then
        return;
    end
    for k, v in pairs(configTable) do
        self[k] = v;
    end
end

ClientConfig.setClientInfo = function (self, infoTable)
    if infoTable == nil or type(infoTable) ~= "table" then
        return;
    end
    for k, v in pairs(infoTable) do
        self[k] = v;
    end
end



return ClientConfig