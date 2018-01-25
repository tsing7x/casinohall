package com.boyaa.hallgame;

import android.os.Message;
import android.util.Log;

import com.boyaa.engine.made.Dict;
import com.boyaa.made.AppHelper;

public class LuaCallManager {

	public static final String TAG = "LuaCallManager";
	private static LuaCallManager luaCallManager;

	public final static String kluaCallEvent = "LuaCallEvent"; // lua调用java,获得 指令值的key
	public final static String kCallLuaEvent = "event_call"; //java调用lua
	public final static String kCallResult = "CallResult";
	public final static String kResultPostfix = "_result";
	public final static String kparmPostfix = "_parm";

	public final static String kUpdateSuccess 	= "UpdateSuccess"; // 更新
	public static final String kUpdateVersion 	= "UpdateVersion";
	public final static String kUpdating 		= "Updating";
	public final static String KExit = "Exit"; // 结束程序

	public static LuaCallManager getInstance() {
		if (null == luaCallManager) {
			luaCallManager = new LuaCallManager();
		}
		return luaCallManager;
	}

	public void execute() {
		String methodName = Dict.getString(kluaCallEvent, kluaCallEvent);
		String prama = getParm(methodName);
		Game.getInstance().getGameHandler().OnLuaCall();
	}

	/**
	 * 获取参数值
	 */
	public String getParm(String key) {
		String param = Dict.getString(key, key + kparmPostfix);
		Log.i(TAG, "获取参数值： " + param);
		return param;
	}

	public String invokeMethod(final String methodStr,final String prama) {

		if (methodStr.equals("CloseStartScreen")) {
			CloseStartScreen();
		} else if(methodStr.equals("GetInitValue"))
		{
            AppHelper.GetInitValue(prama,methodStr);
		}
		
		return "";
	}




	
	protected void CloseStartScreen() {
		AppHelper.dismissStartDialog();
	}

	
}
