package com.boyaa.engine.made;

import java.util.HashMap;

import android.app.Activity;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.KeyEvent;

/**
 * activity 子类<br/>
 * 初始化GLSurfaceView视图，监听按键等
 */
public class AppActivity extends Activity {

	// 与引擎Lua层/core/constants.lua相同
	public static final int kTrue = 1;
	public static final int kFalse = 0;
	public static final int kNone = -1;
	protected final static int HANDLER_HTTPPOST_TIMEOUT = 1;
	private AppGLSurfaceView mGLView = null;
	private static AppActivity mThis;
	private static Handler mHandler = null;
	protected static final int TIMEOUT_MSG_ID_BEGIN = 1000;
	protected static final int TIMEOUT_MSG_ID_END = 2000;
	private static HashMap<Integer, Integer> mTimeoutMsgIds = new HashMap<Integer, Integer>();
	private static Object mSyncMsgIds = new Object();
	
	/**
	 * 获取 AppActivity 对象
	 * @return AppActivity 对象
	 */
	public static AppActivity getInstance() {
		return mThis;
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		Log.e("Application", "JAR version:" + SystemInfo.getNativeVersion());
		mThis = this;
		mGLView = new AppGLSurfaceView(getApplication(), true, 0, 8);
		mGLView.setBackgroundColor(Color.TRANSPARENT);
		setContentView(mGLView);
		mHandler = new AppHandler();
        CallLuaHelper.init(mGLView);
	}

	public AppGLSurfaceView getGLView() {
		return mGLView;
	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		final int key = keyCode;
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			mGLView.queueEvent(new Runnable() {
				@Override
				public void run() {
					GhostLib.onKeyDown(key);
				}
			});
			return true;
		}
		return super.onKeyDown(key, event);
	}
	
	/**
	 * 1.在Renderer线程执行<br/>
	 * 2.在lua_load前执行<br/>
	 * 3.设置信息
	 */
	public void OnSetEnv() {
		clearAllExternalStorageWhenInstall();
	}

	/**
	 *android下每次apk升级安装后第一次运行，清除旧版本apk在external storage上的目录.
	 */
	public void clearAllExternalStorageWhenInstall() {
		
	}

	/**
	 * 所有在UI线程中调用引擎接口,都需要使用此函数将调用放入到render线程执行
	 */
	public void runOnLuaThread(Runnable ra) {
		if (null != mGLView) {
			mGLView.runOnGLThread(ra);
		}
	}

	/**
	 * 1.在Lua线程调用<br/>
	 * 2在Lua的event_load之前被执行
	 */
	public void OnBeforeLuaLoad() {

	}

	@Override
	public void onLowMemory() {
		mGLView.queueEvent(new Runnable() {
			
			@Override
			public void run() {
				GhostLib.onLowMemory();
			}
		});
	}

	/**
	 * 1.Lua调Java OnLuaCall 方法<br/>
	 * 2.此方法可作为所有Lua调Java方法统一入口，用获取的值来区分访问实现函数<br/>
	 * 示例：<br/>
	 * lua: <br/>
	       function callJava()<br/>
	            dict_set_string("funcName","funcKey","uploadImage"); //java 实现函数<br/>
	            call_native("OnLuaCall");//Lua调Java统一方法入口<br/>
	       end<br/>
	 *<br/>     
	 * java:<br/>
	        @Override<br/>
	 		public void OnLuaCall() {<br/>
				super.OnLuaCall();<br/>
				String func = dict_get_string("funcName","funcKey"); //获取java 实现函数<br/>
				if(func = "uploadImage"){ //判断实现函数，执行函数<br/>
					uploadImage();<br/>
				}<br/>
			}<br/>
	 *       
	 */
	public void OnLuaCall() {

	}
	
	public static void SetScreenOrientation(final boolean flag) {
        if (mThis == null) {
            return;
        }
        mThis.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (true == flag){
                    //设置水平
                    mThis.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
                }
                else {
                    //设置为垂直
                    mThis.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
                }
            }
        });
	}
	
	
	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		// TODO Auto-generated method stub
		super.onConfigurationChanged(newConfig);
	}
	
	@Override
	protected void onResume() {
		super.onResume();
		if (null != mGLView) {
			mGLView.onResume();
		}
	}

	@Override
	protected void onPause() {
		super.onPause();
		if (null != mGLView) {
			mGLView.onPause();
		}
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
	}
	
	/**
	 * 在结束应用进程前调用
	 */
	public void onBeforeKillProcess() {
		AppSound.end();
	}
	
	/**
	 * 1.在Lua线程被调用<br/>
	 * 2.用于lua在java中设置定时器
	 * @param id 定时器id
	 * @param ms 时长
	 * @return void
	 */
	public static void SetTimeout(int id, long ms) {
		if (id < TIMEOUT_MSG_ID_BEGIN || id >= TIMEOUT_MSG_ID_END) {
			return;
		}
		synchronized (mSyncMsgIds) {
			AppActivity.mTimeoutMsgIds.put(id, id);
		}
		mHandler.sendEmptyMessageDelayed(id, ms);

	}

	/**
	 * 1.在Lua线程被调用<br/>
	 * 2.用于lua在java中销毁定时器<br/>
	 * @param id 定时器id
	 * @return void
	 */
	public static void ClearTimeout(int id) {
		synchronized (mSyncMsgIds) {
			if (AppActivity.mTimeoutMsgIds.containsKey(id)) {
				AppActivity.mTimeoutMsgIds.remove(id);
				mHandler.removeMessages(id);
			}
		}
	}
	
	/**
	 * 获取handler
	 * @return handler
	 */
	public static Handler getHandler() {
		return mHandler;
	}
	
	/**
	 * 重写Handler
	 */
	private static class AppHandler extends Handler {
		@Override
		public void handleMessage(Message msg) {
			synchronized (mSyncMsgIds) {
				if (mTimeoutMsgIds.containsKey(msg.what)) {
					final int id = msg.what;
					mTimeoutMsgIds.remove(id);
					AppActivity.getInstance().runOnLuaThread(new Runnable() {
						@Override
						public void run() {
							Dict.setInt("SystemTimer", "Id", id);
							Sys.callLua("event_system_timer");
						}
					});
				}
			}
			switch (msg.what) {

			case HANDLER_HTTPPOST_TIMEOUT:
				AppHttpPost.HandleTimeout(msg);
				break;
			default:
			}
			super.handleMessage(msg);
		}
	}
	public static boolean checkThread() {
		try {
			if (mThis.mGLView != null) {
				if (mThis.mGLView.isGLThread()) {
					return true;
				}
			}
			return false;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
}
