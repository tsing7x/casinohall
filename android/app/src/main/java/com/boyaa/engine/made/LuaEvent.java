package com.boyaa.engine.made;

/**
 * lua调用java入口类
 */
public class LuaEvent {

	/**
	 * lua 调用java httpPost入口
	 * 
	 * @return void
	 */
	public static void HttpPost() {
		AppHttpPost post = new AppHttpPost();
		post.Execute();
	}

	/**
	 * lua 调用java httpGet入口
	 * 
	 * @return void
	 */
	public static void HttpGet() {
		AppHttpGet post = new AppHttpGet();
		post.Execute();
	}
	
	/**
	 * lua 调用 java 功能入口
	 * 
	 * @return ""
	 */
	public static void OnLuaCall() {
		AppActivity.getInstance().OnLuaCall();
	}

	public static void SetOSTimeout() {
		int id = Dict.getInt("OSTimeout", "id",AppActivity.TIMEOUT_MSG_ID_BEGIN);
		int ms = Dict.getInt("OSTimeout", "ms",1);
		AppActivity.SetTimeout(id, ms);
	}
	
	public static void ClearOSTimeout() {
		int id = Dict.getInt("OSTimeout", "id",AppActivity.TIMEOUT_MSG_ID_END);
		AppActivity.ClearTimeout(id);
	}

}
