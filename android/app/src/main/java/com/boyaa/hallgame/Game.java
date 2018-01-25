package com.boyaa.hallgame;

import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.os.Bundle;
import android.os.Environment;
import android.os.Process;
import android.preference.PreferenceManager;
import android.util.Log;

import com.boyaa.application.ConstantValue;
import com.boyaa.engine.common.UploadDumpFile;
import com.boyaa.engine.made.APNUtil;
import com.boyaa.engine.made.AppActivity;
import com.boyaa.engine.made.Dict;
import com.boyaa.engine.made.GhostLib;
import com.boyaa.engine.made.Sys;
import com.boyaa.entity.ad.AppsFlyManager;
import com.boyaa.entity.common.SDTools;
import com.boyaa.entity.common.utils.JsonUtil;
import com.boyaa.entity.facebook.FBEntityEx;
import com.boyaa.godsdk.callback.CallbackStatus;
import com.boyaa.godsdk.callback.IAPListener;
import com.boyaa.godsdk.core.ActivityAgent;
import com.boyaa.godsdk.core.GodSDK;
import com.boyaa.godsdk.core.GodSDK.IGodSDKIterator;
import com.boyaa.godsdk.core.GodSDKIAP;
import com.boyaa.made.AppHelper;
import com.boyaa.made.GameHandler;
import com.boyaa.utils.PackageInfoUtil;
import com.google.android.gms.gcm.GoogleCloudMessaging;
import com.umeng.analytics.MobclickAgent;

import java.io.File;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

/**
 * 1.AppActivity 子类<br/>
 * 2.二次开发人员操作Activity类
 */
public class Game extends AppActivity implements IAPListener{

//	private AppStartDialog mStartDialog;//APP启动画面Dialog对象
	public final static int HANDLER_CLOSE_START_DIALOG = 1;

	private String mUpdatePath = "";
	private String mUpdateZipPath = "";
	private String mUpdateApkPath = "";
	private String mImagePath = "";
	private String mAudioPath = "";
	private String mApkFilesPath = "";

	public static final String APP_INFO = "android_app_info";
	public static String mUUID = UUID.randomUUID().toString();
	public static boolean isScreen = false;
	private GoogleCloudMessaging gcm;

	private static Game mThis;
	private static GameHandler mGameHandle;
	/**
	 * 当Activity程序启动之后会首先调用此方法。<br/>
	 * 在这个方法体里，你需要完成所有的基础配置<br/>
	 * 这个方法会传递一个保存了此Activity上一状态信息的Bundle对象
	 * @param savedInstanceState 保存此Activity上一次状态信息的Bundle对象 
	 */
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		PackageInfoUtil.getKeyCode(this, "com.boyaa.casinohall");

		getGLView().queueEvent(new Runnable() {
			@Override
			public void run() {
				GhostLib.setOrientation(Configuration.ORIENTATION_PORTRAIT);
			}
		});
		UploadDumpFile.getInstance().execute(this,"");
		mThis = this;
		AppHelper.init(this);
		if (null == savedInstanceState) {
			AppHelper.showStartDialog();
		} else {
			AppHelper.dismissStartDialog();
		}
		mGameHandle = new GameHandler(this);

		MobclickAgent.setDebugMode(true);
		MobclickAgent.openActivityDurationTrack(true);
//		MobclickAgent.updateOnlineConfig(this);
		FBEntityEx.getInstance().onCreate(this);
		AppsFlyManager.getInstance(this);

		GodSDK.getInstance().setDebugMode(true);
		GodSDKIAP.getInstance().setDebugMode(true);

		//god pay
		boolean b = GodSDK.getInstance().initSDK(this, new IGodSDKIterator<Integer>() {
			private int i = 20000;
			private final int end = 20100;

			@Override
			public Integer next() {
				i = i + 1;
				return i;
			}

			@Override
			public boolean hasNext() {
				if (i < end) {
					return true;
				} else {
					return false;
				}
			}
		});

		GodSDKIAP.getInstance().setIAPListener(this);

	}
	/**
	 * 获取Game对象
	 * @return Game 对象
	 */
	public static Game getInstance() {
		return mThis;
	}
	
	/**
	 * 获取Handler
	 * @return Handler 对象
	 */
	public GameHandler getGameHandler(){
		return mGameHandle;
	}
	
	/**
	 * 所有在UI线程中调用引擎c接口的,都需要使用此函数将调用放入到render线程执行
	 */
	@Override
	public void runOnLuaThread(Runnable ra) {
		super.runOnLuaThread(ra);
	}
	
	/**
	 *  android下每次apk升级安装后第一次运行，清除旧版本apk在external storage上的目录.
	 */
	@Override
	public void clearAllExternalStorageWhenInstall() {
		super.clearAllExternalStorageWhenInstall();
	}
	
	/**
	 * 本函数是在Lua的event_load之前被执行,是在Lua线程被调用
	 */
	@Override
	public void OnBeforeLuaLoad() {
		super.OnBeforeLuaLoad();
		setEnviroment();
		File f = new File(mUpdatePath);
		if( !f.exists()) {
			f.mkdirs();
		}
		System.out.println("mUpdatePath路径" + mUpdatePath);

//		mImagePath = Sys.getString("storage_images");
//		if (null != mImagePath && mImagePath.length() > 0) {
//			mImagePath += File.separator;
//		}
		f = new File(mImagePath);
		if( !f.exists()) {
			f.mkdirs();
		}
		System.out.println("图片文件路径" + mImagePath);

//		mAudioPath = Sys.getString("storage_audio");
//		if (null != mAudioPath && mAudioPath.length() > 0) {
//			mAudioPath += File.separator;
//		}
		f = new File(mAudioPath);
		if( !f.exists()) {
//			System.out.println("创建audio路径");
			f.mkdir();
		}
		ConstantValue.initResStatus();
		System.out.println("音效文件路径" + mAudioPath);
//		mHandler.OnBeforeLuaLoad();
	}
	public String getUpdatePath() { return mUpdatePath; }
	public String getUpdateZipPath() {
		return mUpdateZipPath;
	}
	public String getImagePath() { return mImagePath; }
	public String getUpdateApkPath() { return mUpdateApkPath; }

	public String getAudioPath() {
		return mAudioPath;
	}
	public String getApkFilesPath() { return mApkFilesPath; }
	
	/**
	 * 1.本函数是在Lua的event_load之前被执行,是在Lua线程被调用
	 * 2.设置信息
	 */
//	@Override
//	public void onSetEnv(){
//		super.onSet
//	}

	public void setEnviroment() {
		// TODO Auto-generated method stub
		super.OnSetEnv();
		String strPackageName = getPackageName();
		ApplicationInfo appInfo = null;
		PackageInfo packInfo = null;
		PackageManager packMgmr = getApplication().getPackageManager();
		String appid = "", appkey = "", api = "";
		String apkFilePath = "";
		try {
			appInfo = packMgmr.getApplicationInfo(strPackageName, 0);
			apkFilePath = appInfo.sourceDir;
			packInfo = packMgmr.getPackageInfo(strPackageName, 0);
			appInfo = packMgmr.getApplicationInfo(strPackageName, PackageManager.GET_META_DATA);
			/*Object value = appInfo.metaData.get("CHANNEL");
			if (value != null && !"".equals(value)) {
				String[] channel = value.toString().split("-");
				appid = channel[0] == null ? "" : channel[0];
				appkey = channel[1] == null ? "" : channel[1];
				api = channel[2] == null ? "" : channel[2];
			}*/
		} catch (PackageManager.NameNotFoundException e) {
		}

		int versionCode = packInfo.versionCode;
		String versionName = packInfo.versionName;
		String packageName = packInfo.packageName;

		String libraryPath = getApplicationInfo().dataDir + "/lib";
		String strFilePath = getApplication().getFilesDir().toString();
		String strSDPath = Environment.getExternalStorageDirectory().getAbsolutePath();
		String strLang = Locale.getDefault().getLanguage();
		String strCountry = Locale.getDefault().getCountry();
		String device_id = APNUtil.getMachineId(this);
		//String imsi = APNUtil.getTelephonyManager().getSubscriberId();
		String imsi = APNUtil.getSimOperator(this);
		String imei = device_id;
		String iccid = APNUtil.getSimSerialNumber(this);
		String appname = getResources().getString(R.string.app_name);
		String modelName = APNUtil.getMachineName();
		String phone = APNUtil.getTelephone(this);
		String net = APNUtil.checkNetWork(this);
		String mac = APNUtil.getLocalMacAddress(this);

		String device_os = APNUtil.getMachineOS();
		String rat = ConstantValue.rat;


		int simType = APNUtil.getSimCardType(this);
		File cacheDir = this.getCacheDir();
		int isSdCard = SDTools.isExternalStorageWriteable() ? 1 : 0;
		String cache = cacheDir.getAbsolutePath();
		String rootPath=Environment.getExternalStorageDirectory().getPath()+"/."+getPackageName();
		String androidId = android.provider.Settings.Secure.getString(mThis.getContentResolver(), android.provider.Settings.Secure.ANDROID_ID);
		String phoneModel = android.os.Build.MODEL;
		mUpdatePath = getApplication().getFilesDir().toString() + File.separator;
		mUpdateZipPath = rootPath + File.separator + "updateV1" + File.separator;
		mImagePath = rootPath + File.separator + "images" + File.separator;
		mAudioPath = rootPath + File.separator + "audio" + File.separator;
		mUpdateApkPath = rootPath + File.separator + "updateAPK" + File.separator;
		mApkFilesPath = getApplication().getFilesDir().toString() + File.separator;
		System.out.println("getApplication().getFilesDir()" + getApplication().getFilesDir());

		System.out.println("Environment.getExternalStorageDirectory().getPath()" + Environment.getExternalStorageDirectory().getPath());

		Dict.setInt(APP_INFO, "version_code", versionCode);
		Dict.setString(APP_INFO, "version_name", versionName);
		Dict.setString(APP_INFO, "packages", strPackageName);
		Dict.setString(APP_INFO, "apk_path", apkFilePath);
		Dict.setString(APP_INFO, "lib_path", libraryPath);
		Dict.setString(APP_INFO, "files_path", strFilePath);
		Dict.setString(APP_INFO, "sd_path", strSDPath);
		Dict.setString(APP_INFO, "lang", strLang);
		Dict.setString(APP_INFO, "country", strCountry);
		Dict.setString(APP_INFO, "uuid", mUUID);
		Dict.setString(APP_INFO, "device_id", device_id);
		Dict.setString(APP_INFO, "cache", cache);
		Dict.setString(APP_INFO, "rootPath", rootPath);
		Dict.setString(APP_INFO,"imsi", imsi);
		Dict.setString(APP_INFO,"imei",imei);
		Dict.setString(APP_INFO,"iccid",iccid);
		Dict.setString(APP_INFO,"phoneNumber", phone);
		Dict.setString(APP_INFO,"androidId",androidId);
		Dict.setString(APP_INFO,"phoneModel",phoneModel);

		Dict.setString(APP_INFO, "appname", appname);
		Dict.setString(APP_INFO, "packageName", packageName);
		Dict.setString(APP_INFO, "modelName", modelName);
		Dict.setString(APP_INFO, "net", net);
		Dict.setString(APP_INFO, "mac", mac);
		Dict.setString(APP_INFO, "appid", appid);
		Dict.setString(APP_INFO, "appkey", appkey);
		Dict.setInt(APP_INFO, "api", 0);//Integer.parseInt(api, 16));
		Dict.setInt(APP_INFO, "isSdCard", isSdCard);
		Dict.setInt(APP_INFO, "simType", simType);
		Dict.setString(APP_INFO, "device_os", device_os);
		Dict.setString(APP_INFO, "rat", rat);
		Dict.setString(APP_INFO, "macAddr", rat);


		Sys.setString("call_native_class_name", "LuaEvent");
	}
	
	/**
	 * 在结束应用进程前调用
	 */
	@Override
	public void onBeforeKillProcess() {
		super.onBeforeKillProcess();
	}

	@Override
	public void OnLuaCall() {
		super.OnLuaCall();
		LuaCallManager.getInstance().execute();
	}

	public void callLuaFunc(final String luaFunc,final String jsonStrPrams){
		runOnLuaThread(new Runnable() {
			public void run() {
				Dict.setString(LuaCallManager.kluaCallEvent, LuaCallManager.kluaCallEvent, luaFunc); //函数名
				Dict.setInt(luaFunc, LuaCallManager.kCallResult, 0);
				Dict.setString(luaFunc, luaFunc + LuaCallManager.kResultPostfix, jsonStrPrams);
				Sys.callLua(LuaCallManager.kCallLuaEvent);
			}
		});
	}
	@Override
	protected void onRestart() {
		super.onRestart();

	}

	@Override
	protected void onResume() {
		super.onResume();
		ActivityAgent.onResume(this);
		MobclickAgent.onResume(this);
	}

	@Override
	protected void onPause() {
		super.onPause();
		MobclickAgent.onPause(this);
	}

	@Override
	protected void onStop() {
		super.onStop();
		AppHelper.stopStartDialog(true);
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		if(mGameHandle != null){
			mGameHandle.OnDestory();
		}
		isScreen = false;
	}

	@Override
	public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
		for (PreferenceManager.OnActivityResultListener listener : this.getGameHandler().getOnActivityResultPermissionsListeners()) {
			if (listener.onActivityResult(requestCode,  grantResults[0] == PackageManager.PERMISSION_GRANTED ? RESULT_OK : RESULT_CANCELED, null)){
				return;
			}
		}
		super.onRequestPermissionsResult(requestCode, permissions,  grantResults);
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode,Intent data)
	{
		super.onActivityResult(requestCode, resultCode, data);
		FBEntityEx.getInstance().onActivityResult(requestCode, resultCode, data);
		ActivityAgent.onActivityResult(this, requestCode, resultCode, data);
		for (PreferenceManager.OnActivityResultListener listener : this.getGameHandler().getOnActivityResultListeners()) {
			if (listener.onActivityResult(requestCode, resultCode, data)){
				return;
			}
		}
	}
	@Override
	public void finish()
	{
		GodSDK.getInstance().release(getInstance());
		//AdDataManagement.getInstance().destroy();
		super.finish();
	}
//	/**
//	 * 启动应用画面Dialog
//	 */
//	public void showStartDialog() {
//		if (null == mStartDialog) {
//			mStartDialog = new AppStartDialog(this);
//			mStartDialog.show();
//		}
//	}
	
//	/**
//	 * 销毁应用启动画面Dialog
//	 */
//	public void dismissStartDialog() {
//		if (null != mStartDialog) {
//			if (mStartDialog.isShowing()) {
//				mStartDialog.dismiss();
//			}
//			mStartDialog = null;
//		}
//	}

	@Override
	protected void onStart() {
		super.onStart();
//		if (null != mStartDialog ){
//			mStartDialog.show();
//		}
	}


	//GOD支付回调
	@Override
	public void onPaySuccess(CallbackStatus status, String pmode) {
		Log.e("", "game onPaySuccess");
		Map<String, String> jsonResult = new HashMap<String, String>();
		jsonResult.put("status", "0");
		jsonResult.put("pmode", pmode);
		if(pmode.equals("12")){
			//获取OriginalJson和Signature两个参数方法
			Map<String, String> map = status.getExtras();
			if (map != null)
			{
				Log.e("", "OriginalJson="+map.get("OriginalJson"));
				Log.e("", "Signature="+map.get("Signature"));
				jsonResult.put("signedData", map.get("OriginalJson"));
				jsonResult.put("signature", map.get("Signature"));
			}
		}
		final JsonUtil util = new JsonUtil(jsonResult);
		getInstance().callLuaFunc(GameHandler.kPay, util.toString());
	}

	@Override
	public void onPayFailed(CallbackStatus status, String pmode) {
		Log.e("", "game onPayFailed");
		Map<String, String> jsonResult = new HashMap<String, String>();
		jsonResult.put("status", "1");
		jsonResult.put("mainStatus", ""+status.getMainStatus());
		jsonResult.put("subStatus", ""+status.getSubStatus());
		jsonResult.put("errmsg", ""+status.getMsg());
		jsonResult.put("pmode",pmode);

		final JsonUtil util = new JsonUtil(jsonResult);
		getInstance().callLuaFunc(GameHandler.kPay, util.toString());
	}


	//===================================旧代码移植=====================================
	public static void terminateProcess() {

		if (null != mThis) {
			mThis.finish();
		}

		Process.killProcess(Process.myPid());
	}

	public GoogleCloudMessaging getGcm(){
		if (gcm == null) {
			gcm = GoogleCloudMessaging.getInstance(getBaseContext());
		}
		return gcm;
	}
}
