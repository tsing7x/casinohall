local ClientConfig = require("kefuSystem/mqttModule/clientConfig")
local DataUtils = require("kefuSystem/mqttModule/dataUtils")
local GKefuOnlyOneConstant = require('kefuSystem/common/kefuConstant')
local Log = require('kefuSystem/common/log')

local ActionType_Map =
{
    ["LOGIN"] = 0,
    ["SHIFT"] = 1,
    ["LOGOUT"] = 2,
    ["PREPARE_CHAT"] = 3, --不支持
    ["ACT_SERVER"] = 4, --不支持
    ["CHAT"] = 5, --不支持
    ["RELOGIN"] = 6,
};

-- logout的结束类型,1-用户；2-离线；3-超时；4-客服 */
local LogoutEndType_Map =
{
    ["USER"] = 1, -- 用户
    ["OFFLINE"] = 2, -- 离线
    ["TIMEOUT"] = 3, -- 超时
    ["KEFU"] = 4, -- 客服
};

-- logout的结束类型,1-用户；2-离线；3-超时；4-客服 */
local MqttEvent_Map =
{
    ["MQTT_CONNECT_SUCCESS"] = 1, -- 连接成功
    ["MQTT_CONNECT_FAILURE"] = 2, -- 连接失败
    ["MQTT_SUBSCRIBE_SUCCESS"] = 3, -- 订阅成功
    ["MQTT_SUBSCRIBE_FAILURE"] = 4, -- 订阅失败
    ["MQTT_SEND_MSG_SUCCESS"] = 5, -- 发送成功
    ["MQTT_SEND_MSG_FAILURE"] = 6, -- 发送失败
    ["MQTT_CONNECT_LOST"] = 7, --
    ["MQTT_DELIVERY_COMPLETED"] = 8, --
    ["MQTT_DISCONNECT_SUCCESS"] = 9,
    ["MQTT_DISCONNECT_FAILURE"] = 10,
};

-- 昵称 */
local NICKNAME = "nickname";
-- 头像 */
local AVATAR_URI = "avatarUri";
-- VIP等级 */
local VIP_LEVEL = "vipLevel";
-- 游戏名称 */
local GAME_NAME = "gameName";
-- 账号类型 */
local ACCOUNT_TYPE = "accountType";
-- 客户端 */
local CLIENT = "client";
-- 用户ID */
local USER_ID = "userID";
-- 设备类型 */
local DEVICE_TYPE = "deviceType";
-- 联网方式,wifi、2g、3g、4g */
local CONNECTIVITY = "connectivity";
-- 游戏版本 */
local GAME_VERSION = "gameVersion";
-- 设备详情 */
local DEVICE_DETAIL = "deviceDetail";
-- MAC地址 */
local MAC = "mac";
-- IP地址 */
local IP = "ip";
-- 浏览器 */
local BROWSER = "browser";
-- 屏幕分辨率 */
local SCREEN = "screen";
-- 系统版本 */
local OS_VERSION = "OSVersion";
-- 是否越狱 */
local JAILBREAK = "jailbreak";
-- 运营商 */
local OPERATOR = "operator";

local EXTEND = "extend"

local COLUMN_HOST_CONFIG = "host";
local COLUMN_PROT_CONFIG = "port";
local COLUMN_GID_CONFIG = "gameId";
local COLUMN_SID_CONFIG = "siteId";
local COLUMN_STATIONID_CONFIG = "stationId";
local COLUMN_SSL_CONFIG = "ssl";
local COLUMN_SSLKEY_CONFIG = "sslKey";
local COLUMN_QOS_CONFIG = "qos";
local COLUMN_SESSIONID_CONFIG = "sessionId";
local COLUMN_ROLE_CONFIG = "role";
local COLUMN_UNAME_CONFIG = "userName";
local COLUMN_UPWD_CONFIG = "userPwd";
local COLUMN_UNICKNAME_CONFIG = "nickName";
local COLUMN_UAVATAR_CONFIG = "avatarUri";
local COLUMN_CLEANSESSION_CONFIG = "cleanSession";
local COLUMN_TIMEOUT_CONFIG = "timeout";
local COLUMN_KEEPALIVE_CONFIG = "keepalive";
local COLUMN_RETAIN_CONFIG = "retain";


-- 客户端订阅gid/siteid/stationid/msg/+ 
local SUBSCRIBE_TOPIC_SUFFIX = "/msg/+";
--客户端发布LoginRequest到gid/siteid/stationid/act/login */
local LOGIN_REQUEST_TOPIC_SUFFIX = "/act/login";
--客户端发布LogoutRequest到gid/siteid/stationid/act/logout 登出 */
local LOGOUT_REQUEST_TOPIC_SUFFIX = "/act/logout";
--Client:收到loginresp,如果成功，则向service_gid/service_site_id/service_station_id/msg/chatready
local CHAT_READY_REQUEST_TOPIC_SUFFIX = "/msg/chatready";
-- 此时,玩家可以开始发送消息并且可以收到来自客服的消息了.聊天开始了.客户端发送消息：service_gid/service_site_id/
-- service_station_id/msg/chat;客户端接收消息：gid/siteid/stationid/msg/chat
local CHAT_MESSAGE_TOPIC_SUFFIX = "/msg/chat";
-- 客户端收到ChatMessage后，向来源fid/act/chatack发送ChatMessageAck */
local CHAT_MESSAGE_ACK_TOPIC_SUFFIX = "/act/chatack";



local BoyaaConversation = class();

BoyaaConversation.s_conversations = nil;

BoyaaConversation.ctor = function(self, configTable, infoTable)

    BoyaaConversation.s_conversations = self;
    self.sessionId = "";
    self.destServiceFid = ""; -- 转接的人工service封id
    self.conversationStatus = ConversationStatus_Map.DISCONNECTED; -- 会话状态
    self.requestUri = "";

    self:init(configTable, infoTable);
    self.offsMsg = {};
    self.reconnectTimes = 0;
    self.token = 0;
end

BoyaaConversation.dtor = function(self)
    self.offsMsg = nil;
    self:destroyMqtt();
    self.mqtt = nil;
    BoyaaConversation.s_conversations = nil
end

--每次发送消息调用token
BoyaaConversation.addToken = function(self)
    self.token = self.token + 1;
end

--每次发送消息调用token
BoyaaConversation.getToken = function(self)
    return self.token;
end

--config是 ClientConfig
BoyaaConversation.init = function(self, configTable, infoTable)
    self.userConfig = new(ClientConfig, configTable);
    self.userConfig:setClientInfo(infoTable);
    if package.preload['mqtt'] ~= nil then
        self.mqtt = require "mqtt";
    end
    self:createMqtt();
end

BoyaaConversation.addOffMsg = function(self, seq_id)
    table.insert(self.offsMsg, seq_id);
end

BoyaaConversation.clearOffMsg = function(self)
    self.offsMsg = {};
end

BoyaaConversation.getConversationStatus = function(self)
    return self.conversationStatus;
end

BoyaaConversation.setConversationStatus = function(self, status)
    self.conversationStatus = status;
end


BoyaaConversation.getAvatarDownloadUri = function(self, avatar)
    local downloadUri = "";
    local uri = self.userConfig:getAvatarDownloadUri();
    if uri ~= "" then
        local md5 = md5_string(avatar);
        downloadUri = DataUtils.getInstance():getAvatarUri(md5);
    end
    return downloadUri;
end

BoyaaConversation.generateClientInfo = function(self, avatarUri)
    local info = {};
    info[NICKNAME] = self.userConfig["nickName"];
    info[AVATAR_URI] = avatarUri;
    info[VIP_LEVEL] = self.userConfig[VIP_LEVEL];
    info[GAME_NAME] = self.userConfig[GAME_NAME];
    info[ACCOUNT_TYPE] = self.userConfig[ACCOUNT_TYPE];
    info[CLIENT] = self.userConfig[CLIENT];
    info[USER_ID] = self.userConfig[USER_ID];
    info[DEVICE_TYPE] = self.userConfig[DEVICE_TYPE];
    info[CONNECTIVITY] = self.userConfig[CONNECTIVITY];
    info[GAME_VERSION] = self.userConfig[GAME_VERSION];
    info[DEVICE_DETAIL] = self.userConfig[DEVICE_DETAIL];
    info[MAC] = self.userConfig[MAC];
    info[IP] = self.userConfig[IP];
    info[BROWSER] = self.userConfig[BROWSER];
    info[SCREEN] = self.userConfig[SCREEN];
    info[OS_VERSION] = self.userConfig[OS_VERSION];
    info[JAILBREAK] = self.userConfig[JAILBREAK];
    info[OPERATOR] = self.userConfig[OPERATOR];
    info[EXTEND] = self.userConfig[EXTEND];
    local str = cjson.encode(info);
    return str;
end

BoyaaConversation.getRequestUri = function(self)
    if self.requestUri == nil or self.requestUri == "" then
        local host = self.userConfig:getHost();
        local port = self.userConfig:getPort();
        local ssl = self.userConfig:getSsl();
        if ssl then
            self.requestUri = "ssl://";
        else
            self.requestUri = "tcp://";
        end
        self.requestUri = self.requestUri .. host .. ":" .. port;
    end
    return self.requestUri;
end

-- handle fo the Connection,暂定为 uri + clientId
BoyaaConversation.generateClientHandler = function(self)
    return self:getRequestUri() .. self:getCurrentClientId();
end

BoyaaConversation.getClientHandle = function(self)
    if clientHandle == "" then
        self:setClientHandle(self:generateClientHandler());
    end
    return self.clientHandle;
end

BoyaaConversation.setClientHandle = function(self, handle)
    self.clientHandle = handle;
end

-- 获取当前mqtt用户端唯一标示， 暂定为：gid/site_id/mid
BoyaaConversation.getCurrentClientId = function(self)
    return self.userConfig:getGameId() .. "/" .. self.userConfig:getSiteId() .. "/" .. self.userConfig:getStationId();
end

--[[
* 用于获取优选service fid，用于登录使用，默认获取上一次使用的 service fid
* 
* @return
*/--]]
BoyaaConversation.getPreferServiceFid = function(self)
    return DataUtils.getInstance():getCurrentServiceFid();
end

BoyaaConversation.getCurrentServiceFid = function(self)
    local stationId = self.userConfig:getService_stationId();
    if stationId == nil or self.stationId == "" then
        return "";
    end
    return self.userConfig:getService_gid() .. "/" .. self.userConfig:getService_sid() .. "/" .. self.userConfig:getService_stationId();
end

BoyaaConversation.saveLatelyServiceFid = function(self)
    DataUtils.getInstance():saveCurrentServiceFid(self:getCurrentServiceFid());
end

BoyaaConversation.getDestServiceFid = function(self)
    return self.destServiceFid;
end

BoyaaConversation.setDestServiceFid = function(self, dsfid)
    self.destServiceFid = dsfid;
end

BoyaaConversation.getCurrentUserConfig = function(self)
    return self.userConfig;
end

BoyaaConversation.getSessionId = function(self)
    return self.sessionId;
end

BoyaaConversation.setSessionId = function(self, id)
    self.sessionId = id;
end


BoyaaConversation.generateMqttConfig = function(self)
    local info = {};
    info[COLUMN_HOST_CONFIG] = self.userConfig[COLUMN_HOST_CONFIG];
    info[COLUMN_PROT_CONFIG] = self.userConfig[COLUMN_PROT_CONFIG];
    info[COLUMN_GID_CONFIG] = self.userConfig[COLUMN_GID_CONFIG];
    info[COLUMN_SID_CONFIG] = self.userConfig[COLUMN_SID_CONFIG];
    info[COLUMN_ROLE_CONFIG] = self.userConfig[COLUMN_ROLE_CONFIG];
    info[COLUMN_STATIONID_CONFIG] = self.userConfig[COLUMN_STATIONID_CONFIG];
    info[COLUMN_UAVATAR_CONFIG] = self.userConfig[COLUMN_UAVATAR_CONFIG];
    info[COLUMN_QOS_CONFIG] = self.userConfig[COLUMN_QOS_CONFIG];
    info[COLUMN_CLEANSESSION_CONFIG] = self.userConfig[COLUMN_CLEANSESSION_CONFIG];
    info[COLUMN_KEEPALIVE_CONFIG] = self.userConfig[COLUMN_KEEPALIVE_CONFIG];
    info[COLUMN_TIMEOUT_CONFIG] = self.userConfig[COLUMN_TIMEOUT_CONFIG];
    info[COLUMN_RETAIN_CONFIG] = self.userConfig[COLUMN_RETAIN_CONFIG];
    info[COLUMN_SSL_CONFIG] = self.userConfig[COLUMN_SSL_CONFIG];
    info[COLUMN_SSLKEY_CONFIG] = self.userConfig[COLUMN_SSLKEY_CONFIG];
    info[COLUMN_UNAME_CONFIG] = self.userConfig[COLUMN_UNAME_CONFIG];
    info[COLUMN_UPWD_CONFIG] = self.userConfig[COLUMN_UPWD_CONFIG];
    local str = cjson.encode(info);
    print_string("generateMqttConfig66666:" .. str);
    return str;
end

--[[
* 判读是否当前是由人工转到机器人
* 
* @param new_s_sid
* @return
*/--]]
BoyaaConversation.isShiftToRobot = function(self, new_s_sid)
    if self:isHumanService() then
        return not self:isHumanService(new_s_sid);
    end
    return false;
end

--[[
* {"nickname":"军爷","avatarUri":
* "http://mvussppk02.ifere.com/images/service/1512/d72b1e1f.png","ext":""}
* 
* @param serviceInfo
*            :客服端相关信息
--]]
BoyaaConversation.dealWithServiceInfo = function(self, serviceInfo)
    if serviceInfo == "" then
        return;
    end
    local tab = cjson.decode(serviceInfo);
    local nickname = tab["nickname"];
    local avatarUri = tab["avatarUri"];
    local ext = tab["ext"];
    self.userConfig:setService_nickName(nickname);
    self.userConfig:setService_avatarDownloadUri(avatarUri);
    self.userConfig:setService_ext(ext);
end

--已经成功登录，准备发起聊天请求，请求ok则可以正式进入聊天
BoyaaConversation.prepareChat = function(self)
    local avatar = self:getCurrentUserConfig():getAvatarUri();
    Log.v("uploadAvatarImage prepareChat avatar:" .. avatar);
    local clientInfo = "";
    if avatar == "" then
        clientInfo = self:generateClientInfo("");
        self:sendChatReadyMsg(clientInfo);
    else
        local avatarUri = self:getAvatarDownloadUri(avatar);
        Log.v("uploadAvatarImage cache avatarUri:" .. avatarUri);
        if avatarUri ~= "" then
            clientInfo = self:generateClientInfo(avatarUri);
            self:sendChatReadyMsg(clientInfo);
        else
            -- 用户头像是网络图片时
            local md5 = md5_string(avatar);
            self:getCurrentUserConfig():setAvatarDownloadUri(avatar);
            DataUtils.getInstance():saveAvatarUri(md5, avatar);
            clientInfo = self:generateClientInfo(avatar);
            self:sendChatReadyMsg(clientInfo);
            --TODO:~~~~~~~~~~~~~~
            --剩下的逻辑参考java
            --如果Url不是合法的(是本地文件路径)
            --如果文件不存在 构造clientInfo， sendChatReadyMsg
            --如果文件存在，上传头像文件,构造clientInfo， sendChatReadyMsg
        end
    end
end

BoyaaConversation.parseLoginResponse = function(self, session_id, service_gid, service_site_id, service_station_id)
    self:setSessionId(session_id);
    self:getCurrentUserConfig():setService_gid(service_gid);
    self:getCurrentUserConfig():setService_sid(service_site_id);
    self:getCurrentUserConfig():setService_stationId(service_station_id);
    self:saveLatelyServiceFid();
end


------------------------------------- 分割线-----------------------------------------
-- 以下是mqtt协议接口
-- step1:创建MQTT Client 
BoyaaConversation.createMqtt = function(self)
    self.mqtt.mqtt_create(self:generateMqttConfig(), os.time());
end

--step2:连接服务器，连接时设置遗嘱消息为 LogoutMessage
BoyaaConversation.connect = function(self)
    local ret = self.mqtt.connect(self:getLogoutTopic());
    return ret;
end

-- 只有执行过createMqtt 和 connect 之后才能调用该接口
BoyaaConversation.reConnect = function(self)
    self.mqtt.reconnect();
end

--step3:订阅主题
BoyaaConversation.subscribe = function(self)

    local ret = self.mqtt.subscribe(self:getSubscribeTopic());
    if ret == 0 then
        self:addToken();
    end

    return ret;
end

--step4:登录
BoyaaConversation.login = function(self)
    if not self:isConnected() then
        return;
    end
    return self:sendMessage(ActionType_Map.LOGIN);
end

--step4:发送准备聊天的消息，携带clientinfo
BoyaaConversation.sendChatReadyMsg = function(self, clientinfo)

    local result = self.mqtt.sendChatReadyMsg(clientinfo, self:getSessionId(), self:getPrepareChatTopic());
    --表示已经发送出去了
    if result == 0 then
        self:addToken();
    end
    return result
end

--step5:发送消息
--@param message 消息内容
--@param types   消息类型
BoyaaConversation.sendChatMsg = function(self, message, types)
    print_string('boyaaconversation sendchatmsg msg = ', message)
    local result = self.mqtt.sendChatMsg(message, types, self:getSessionId(), self:getChatTopic());
    if result == 0 then
        self:addToken();
    end
    return result
end

--step6:登出
--@param types   结束类型，LogoutEndType_Map
BoyaaConversation.logout = function(self, end_type)
    local status = self:getConversationStatus();
    if (not self:isConnected()) or status < ConversationStatus_Map.CONNECTED then
        self:destroyMqtt();
        return;
    end
    return self:sendMessage(ActionType_Map.LOGOUT, end_type);
end

--断开服务器
BoyaaConversation.disconnect = function(self)
    self.mqtt.disconnect();
    self.token = 0;
end

--判断是否跟服务器链接
BoyaaConversation.isConnected = function(self)
    return self.mqtt.isConnected();
end

--销毁
BoyaaConversation.destroyMqtt = function(self)
    return self.mqtt.mqtt_destroy();
end

--发送消息
--@param types   动作类型，ActionType_Map,  end_type是给logoutMessage用的
BoyaaConversation.sendMessage = function(self, types, end_type)
    local result;

    if types == ActionType_Map.LOGIN then
        local s_fid = self:getPreferServiceFid();
        local s_dest_fid = self:getCurrentServiceFid();
        result = self.mqtt.sendMessage(types, s_fid, s_dest_fid, self:getLoginTopic());
    elseif types == ActionType_Map.RELOGIN then
        local cur_sfid = self:getCurrentServiceFid();
        result = self.mqtt.sendMessage(types, cur_sfid, self:getLoginTopic());
    elseif types == ActionType_Map.SHIFT then
        local ss_fid = self:getCurrentServiceFid();
        local ss_dest_fid = self:getDestServiceFid();
        if ss_dest_fid ~= "" then
            self:setDestServiceFid("");
        end
        result = self.mqtt.sendMessage(types, ss_fid, ss_dest_fid, self:getLoginTopic());
    elseif types == ActionType_Map.LOGOUT then
        if end_type then
            result = self.mqtt.sendMessage(types, end_type, self:getLogoutTopic());
        else
            result = self.mqtt.sendMessage(types, LogoutEndType_Map.USER, self:getLogoutTopic());
        end
    elseif types == ActionType_Map.PREPARE_CHAT then
        local clientinfo = self:generateClientInfo("");
        local session_id = self:getSessionId();
        result = self.mqtt.sendMessage(types, clientinfo, session_id, self:getPrepareChatTopic());
    elseif types == ActionType_Map.ACT_SERVER then
        --暂时没用
    end

    if result == 0 then
        self:addToken()
    end

    return result;
end

--发送消息，所有离线消息已收到
BoyaaConversation.sendOffMessageAck = function(self)
    if #self.offsMsg == 0 then return; end

    local result = self.mqtt.sendOffMessageAck(self.offsMsg, self:getSessionId(), self:getMessageAckTopic());
    if result == 0 then --成功以后clear
        self.offsMsg = {};
        self:addToken();
    end
    return result;
end


--发送消息，消息收到
BoyaaConversation.sendMessageAck = function(self, seq_id)

    local result = self.mqtt.sendMessageAck(seq_id, self:getSessionId(), self:getMessageAckTopic());

    if result == 0 then
        self:addToken();
    end
end

--生成毫秒时间戳，13位
BoyaaConversation.clock = function(self)
    return self.mqtt.clock();
end


----------------------------------------- 分割线------------------------------------------
--[[
* 客户端发布LogoutMessage到topic为gid/site_id/station_id/act/logout
* @return 
*/--]]
BoyaaConversation.getLogoutTopic = function(self)
    local topic = self:getCurrentClientId() .. LOGOUT_REQUEST_TOPIC_SUFFIX;
    Log.v("getLogoutTopic : " .. topic);
    return topic;
end

--[[
* 客户端发布LoginRequest到gid/siteid/stationid/act/login
*
* @return
*/--]]
BoyaaConversation.getLoginTopic = function(self)
    local topic = self:getCurrentClientId() .. LOGIN_REQUEST_TOPIC_SUFFIX;
    Log.v("getLoginTopic : " .. topic);
    return topic;
end

--[[
* 客户端订阅gid/siteid/stationid/msg/+
*
* @return
*/--]]
BoyaaConversation.getSubscribeTopic = function(self)
    local topic = self:getCurrentClientId() .. SUBSCRIBE_TOPIC_SUFFIX;
    Log.v("getSubscribeTopic : " .. topic);
    return topic;
end

--[[
* Client:收到loginresp,如果成功，则向service_gid/service_site_id/service_station_id/
* msg/chatready
*
* @return
*/--]]
BoyaaConversation.getPrepareChatTopic = function(self)
    local topic = self:getCurrentServiceFid() .. CHAT_READY_REQUEST_TOPIC_SUFFIX;
    Log.v("getPrepareChatTopic : " .. topic);
    return topic;
end

--[[
* 此时,玩家可以开始发送消息并且可以收到来自客服的消息了.聊天开始了.客户端发送消息：
*
* @return
*/--]]
BoyaaConversation.getMessageAckTopic = function(self)
    local topic = self:getCurrentClientId() .. CHAT_MESSAGE_ACK_TOPIC_SUFFIX;
    Log.v("getMessageAckTopic : " .. topic);
    return topic;
end

--[[
* 此时,玩家可以开始发送消息并且可以收到来自客服的消息了.聊天开始了.客户端发送消息： service_gid/service_site_id/
* service_station_id/msg/chat;客户端接收消息：gid/siteid/stationid/msg/chat
*
* @return
*/--]]
BoyaaConversation.getChatTopic = function(self)
    local topic = self:getCurrentServiceFid() .. CHAT_MESSAGE_TOPIC_SUFFIX;
    Log.v("getChatTopic : " .. topic);
    return topic;
end


-------------------------------- 分割线------------------------------------------
-- 以下是c回调lua的函数，不要主动调用

--接收服务器推送的消息
function mqtt_message_arrived(handlerId, tag, ...)
    if tag == nil then return end
    local args = { ... };
    local conversation = BoyaaConversation.s_conversations

    if tag == "loginresp" then
        local loginCode = args[1];
        local loginMsg = args[2];
        local session_id = args[3];
        local service_gid = args[4];
        local service_site_id = args[5];
        local service_station_id = args[6];
        local offmsg_num = args[7];
        local wait_count = args[8];
        if loginCode == 1 then --登录成功
            conversation:setConversationStatus(ConversationStatus_Map.LOGINED);
            conversation:parseLoginResponse(session_id, service_gid, service_site_id, service_station_id);
            --没有离线消息，直接走prepareChat流程
            if offmsg_num <= 0 then
                conversation:prepareChat()
            else
                --不走prepareChat流程，接收离线消息并处理之
            end
        elseif loginCode == 5 then --会话已建立，重复登录了
            conversation:setConversationStatus(ConversationStatus_Map.SESSION);
            conversation:parseLoginResponse(session_id, service_gid, service_site_id, service_station_id);
        end


    elseif tag == "shift" then
        local sShiftToFid = args[1];
        local session_id = args[2];
        conversation:setDestServiceFid(sShiftToFid);
        local result = conversation:sendMessage(ActionType_Map.SHIFT);
        if result then
            print_string("shift login message");
            conversation:setConversationStatus(ConversationStatus_Map.SHIFTED);
        end
        -- 发送目的：client_fid/msg/end
        -- 归档、升级、无效：这三个功能都通过EndSession消息实现
        -- 归档：必须设置archive_class和archive_category
        -- 升级：必须设置archive_class和archive_category，以及设置session_upgraded为1
        -- （升级之前PC客户端需提交工单到工单系统成功）
        -- 无效：设置session_invalid为1（其他字段不设置）
        -- Client收到EndSession后，取消订阅，断开连接，并且提示用户本次会话已经结束，请返回
        -- Server收到EndSession后，将session归档信息插入归档表（mysql）, 删除session_id
    elseif tag == "end" then
        --完成迁移
        conversation:setConversationStatus(ConversationStatus_Map.FINSHED);

    elseif tag == "chat" then
        --完成迁移
        local seq_id = args[1];

        --这两步暂时放在这里
        conversation:sendOffMessageAck();
        conversation:sendMessageAck(seq_id);

    elseif tag == "chatoff" then -- 会话状态和离线消息
        --完成迁移
        local seq_id = args[1];
        local types = args[2];
        local msg = args[3];
        local session_id = args[4];

        --暂时放在这里
        conversation:addOffMsg(seq_id);
    elseif tag == "chatreadyresp" then
        local code = args[1];
        if code == 2 then
            Clock.instance():schedule_once(function()
                conversation:sendMessage(ActionType_Map.LOGIN);
            end, 2)
            return
        end
    end
    EventDispatcher.getInstance():dispatch(GKefuOnlyOneConstant.mqttReceive, tag, ...)
end

--code 是失败代码 
function mqtt_event_callback(handlerId, event, code)

    local conversation = BoyaaConversation.s_conversations;
    --print_string("mqtt_event_callback event: " .. event);
    Log.v("conversation.token", conversation.token == code and "=" or "!=", "plugin.token");
    if event == MqttEvent_Map.MQTT_CONNECT_SUCCESS then
        conversation:subscribe();
        local sControl = require('kefuSystem/conversation/sessionControl')
        sControl.submitStatisticsInfo(conversation.reconnectTimes)
    elseif event == MqttEvent_Map.MQTT_CONNECT_FAILURE then
        --print_string("MQTT_CONNECT_FAILURE code: " .. code);
        if conversation.reconnectTimes and conversation.reconnectTimes < 5 then
            conversation.reconnectTimes = conversation.reconnectTimes + 1;
            conversation:connect();
        end
    elseif event == MqttEvent_Map.MQTT_SUBSCRIBE_SUCCESS then
        -- print_string("=======MQTT_SUBSCRIBE_SUCCESS token: " .. code);
        conversation:login();
    elseif event == MqttEvent_Map.MQTT_SUBSCRIBE_FAILURE then
        -- print_string("=======MQTT_SUBSCRIBE_FAILURE token: " .. code);
    elseif event == MqttEvent_Map.MQTT_SEND_MSG_SUCCESS then
        Log.v("=======MQTT_SEND_MSG_SUCCESS token: " .. code);
        EventDispatcher.getInstance():dispatch(GKefuOnlyOneConstant.msgSendResult, 1, code)
    elseif event == MqttEvent_Map.MQTT_SEND_MSG_FAILURE then
        Log.v("=======MQTT_SEND_MSG_FAILURE token: " .. code);
        EventDispatcher.getInstance():dispatch(GKefuOnlyOneConstant.msgSendResult, 0, code)
    elseif event == MqttEvent_Map.MQTT_CONNECT_LOST then
        --print_string("Connection lost, cause: " .. code);
        EventDispatcher.getInstance():dispatch(GKefuOnlyOneConstant.connectLost)
    elseif event == MqttEvent_Map.MQTT_DISCONNECT_SUCCESS or event == MqttEvent_Map.MQTT_DISCONNECT_FAILURE then
        --print_string("=======MQTT_DISCONNECT token: " .. code);
    end
end


return BoyaaConversation