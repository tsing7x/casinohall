package com.boyaa.engine.made;

import java.util.Locale;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Environment;
import android.preference.PreferenceManager;
import android.telephony.TelephonyManager;
import android.app.ActivityManager;

/**
 * 系统信息类
 */
public class SystemInfo {
	
	/**
	 * 获取应用安装包路径(/data/app/包名.apk)
	 * @return 应用安装包路径
	 */
	public static String getAppPath() {
		return AppActivity.getInstance().getApplicationContext().getPackageResourcePath();
	}
	
	/**
	 * 获取应用版本号
	 * @return 应用版本号
	 */
	public static String getAppVersion() {
		int versionCode = 0;
		PackageInfo info = getPackageInfo();
		if(null != info){
			versionCode = info.versionCode;
		}
		return String.valueOf(versionCode);
	}
	
	/**
	 * 获取data/data/包名/ 目录
	 * @return data/data/包名/
	 */
	public static String getAppHomePath() {
		return AppActivity.getInstance().getApplicationInfo().dataDir + "/";
	}
	
	/**
	 * 获取data/data/包名/files/ 目录
	 * @return data/data/包名/files/
	 */
	public static String getInnerStoragePath() {
		return AppActivity.getInstance().getApplication().getFilesDir().getAbsolutePath() + "/";
	}
	
	/**
	 * 获取SD卡根目录
	 * @return SD卡根目录/
	 */
	public static String getOuterStoragePath() {
		if (!hasOuterStorage()) {
			return getInnerStoragePath();
		}
		return Environment.getExternalStorageDirectory().getAbsolutePath() + "/";
	}
	
	/**
	 * 判断SD是否可用
	 * @return true 可用；false 不可用
	 */
	public static boolean hasOuterStorage() {
		String state = Environment.getExternalStorageState();
		return state != null && state.equals(Environment.MEDIA_MOUNTED);
	}
	
	/**
	 * 获取uuid
	 * @return uuid
	 */
	public static String getUUID() {
		SharedPreferences preference = PreferenceManager.getDefaultSharedPreferences(AppActivity.getInstance().getApplication());
		String identity = preference.getString("identity", null);
		if (identity == null) {
			identity = java.util.UUID.randomUUID().toString();
			preference.edit().putString("identity", identity);
		}
		return identity;
	}
	
	/**
	 * 获取应用包名
	 * @return 包名
	 */
	public static String getAppID() {
		return AppActivity.getInstance().getPackageName();
	}
	
	/**
	 * 获取PackageInfo对象，如果获取不到返回null
	 * @return PackageInfo
	 */
	public static PackageInfo getPackageInfo() {
		PackageInfo info = null;

		PackageManager manager = AppActivity.getInstance().getPackageManager();
		Context context = AppActivity.getInstance().getApplicationContext();
		try {
			info = manager.getPackageInfo(context.getPackageName(), 0);
		} catch (PackageManager.NameNotFoundException e) {

		}

		return info;
	}
	
	/**
	 * 获取ApplicationInfo对象，如果获取不到返回null
	 * @return ApplicationInfo
	 */
	public static ApplicationInfo getApplicationInfo() {
		ApplicationInfo appInfo = null;

		PackageManager manager = AppActivity.getInstance().getPackageManager();
		Context context = AppActivity.getInstance().getApplicationContext();
		try {
			appInfo = manager.getApplicationInfo(context.getPackageName(), 0);
		} catch (PackageManager.NameNotFoundException e) {

		}

		return appInfo;
	}
	
	/**
	 * 获取应用版本号
	 * @return 返回应用版本号或者0;
	 */
	public static int getVersionCode() {
		int versionCode = 0;
		PackageInfo info = getPackageInfo();
		if(null != info){
			versionCode = info.versionCode;
		}
		return versionCode;
	}
	
	/**
	 * 获取应用名
	 * @return 返回应用名或者"";
	 */
	public static String getVersionName() {
		String versionName = "";
		PackageInfo info = getPackageInfo();
		if(null != info){
			versionName = info.versionName;
		}
		return versionName;
	}
	
	/**
	 * 获取安装这个包后的存放位置
	 * @return data/app/包.apk
	 */
	public static String getApkFilePath() {
		String apkFilePath = "";
		ApplicationInfo appInfo = getApplicationInfo();
		if(null != appInfo){
			apkFilePath = appInfo.sourceDir;
		}
		return apkFilePath;
	}
	
	/**
	 * 获取data/data/包名/lib 目录
	 * @return data/data/包名/lib
	 */
	public static String getLibraryPath() {
		return AppActivity.getInstance().getApplicationInfo().dataDir + "/lib";
	}
	
	/**
	 * 获取data/data/包名/files 目录
	 * @return data/data/包名/files
	 */
	public static String getFilePath() {
		return AppActivity.getInstance().getApplication().getFilesDir().toString();
	}
	
	/**
	 * 获取当前系统语言
	 * @return 返回语言编码或者"";
	 */
	public static String getLang() {
		return Locale.getDefault().getLanguage();
	}
	
	/**
	 * 获取当前系统国家
	 * @return 返回国家编码或者"";
	 */
	public static String getCountry() {
		return Locale.getDefault().getCountry();
	}
	
	/**
	 * 获取设备id
	 * @return 返回设备id或者"";
	 */
	public static String getDeviceId() {
		String deviceId = "";
		try {
			TelephonyManager telephonyManager = (TelephonyManager) AppActivity.getInstance()
					.getApplication().getSystemService(
							Context.TELEPHONY_SERVICE);
			if (null != telephonyManager) {
				deviceId = telephonyManager.getDeviceId();
			}
		} catch (SecurityException e) {
			e.printStackTrace();
		}
		return deviceId;
	}
	
	/**
	 * 结束应用进程
	 */
	public static void terminalProcess() {
		AppActivity.getInstance().onBeforeKillProcess();
		System.exit(0);
	}
	
	/**
	 * 获取android引擎版本号
	 * @return android引擎版本号
	 */
	public static String getNativeVersion(){
		return "3.0.7.6";
	}

    public static long getTotalMemory() {
        ActivityManager.MemoryInfo mi = new ActivityManager.MemoryInfo();
        ActivityManager activityManager = (ActivityManager) AppActivity.getInstance()
            .getApplication().getSystemService(Context.ACTIVITY_SERVICE);
        activityManager.getMemoryInfo(mi);
        return mi.totalMem;
    }
}; 
