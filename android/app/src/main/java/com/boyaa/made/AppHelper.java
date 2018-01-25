package com.boyaa.made;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.TreeMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.util.Base64;
import android.util.DisplayMetrics;
import android.util.Log;

import com.boyaa.application.ConstantValue;
import com.boyaa.engine.made.APNUtil;
import com.boyaa.engine.made.AppMusic;
import com.boyaa.engine.made.AppSound;
import com.boyaa.engine.made.Dict;
import com.boyaa.entity.common.OnThreadTask;
import com.boyaa.entity.common.SDTools;
import com.boyaa.entity.common.ThreadTask;
import com.boyaa.entity.common.utils.JsonUtil;
//import com.boyaa.hallgame.AppStartDialog;
import com.boyaa.hallgame.Game;
import com.boyaa.hallgame.LuaCallManager;
import com.boyaa.utils.GZipUtil;

public class AppHelper {
	private static Game mActivity;
	private static AppStartDialog mStartDialog;
	public static int mWidth = 0;
	public static int mHeight = 0;

	public static void init(Game activity) {
		mActivity = activity;
		DisplayMetrics metrics = new DisplayMetrics();
		activity.getWindowManager().getDefaultDisplay().getMetrics(metrics);

		AppHelper.mWidth = metrics.widthPixels;
		AppHelper.mHeight = metrics.heightPixels;
		ConstantValue.initData(activity);
	}

	public static Activity getActivity() {
		return mActivity;
	}

	public static String unCompressString(String data) {
		String result_string = data;
		int result_flag = 0;
		try {
			JSONObject jsData = new JSONObject(data);
			String content = jsData.getString("content");
			String srcCharset = jsData.optString("srcCharset", "ISO-8859-1");
			String outCharset = jsData.optString("outCharset", "utf-8");

			String unBase64ed = new String(Base64.decode(content, Base64.DEFAULT), srcCharset);
			result_flag = 1;
			String unGziped = GZipUtil.unzipString(unBase64ed, srcCharset, outCharset);
			result_string = unGziped;
		} catch (JSONException e) {
			e.printStackTrace();
			result_flag = 0;
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
			result_flag = 0;
		}
		String resString = "";
		try {
			JSONObject jo = new JSONObject();
			jo.put("flag", result_flag);
			jo.put("result", result_string);
			resString = jo.toString();
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return resString;
	}

	public static String compressString(String data) {
		String result_string = data;
		int result_flag = 0;
		try {
			JSONObject jsData = new JSONObject(data);
			String content = jsData.getString("content");
			String srcCharset = jsData.optString("srcCharset", "utf-8");
			String outCharset = jsData.optString("outCharset", "ISO-8859-1");
			String base64ZipedString = new String(Base64.encode(GZipUtil.zipString(content, srcCharset, outCharset), Base64.DEFAULT), outCharset);
			result_flag = 1; // kTrue;
			result_string = base64ZipedString;
		} catch (JSONException e) {
			e.printStackTrace();
			result_flag = 0;
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
			result_flag = 0;
		}
		String resString = "";
		try {
			JSONObject jo = new JSONObject();
			jo.put("flag", result_flag);
			jo.put("result", result_string);
			resString = jo.toString();
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return resString;
	}

	public static void GetInitValue(String data, String key) {
		String appInfo = Game.APP_INFO;

		String versionName 	= Dict.getString(appInfo, "version_name");
		String packages 	= Dict.getString(appInfo, "packages");
		String apk_path 	= Dict.getString(appInfo, "apk_path");
		String lib_path 	= Dict.getString(appInfo, "lib_path");
		String files_path 	= Dict.getString(appInfo, "files_path");
		String sd_path 		= Dict.getString(appInfo, "sd_path");
		String lang 		= Dict.getString(appInfo, "lang");
		String country 		= Dict.getString(appInfo, "country");
		String device_id 	= Dict.getString(appInfo, "device_id");
		String appname 		= Dict.getString(appInfo, "appname");
		String packageName 	= Dict.getString(appInfo, "packageName");
		String modelName 	= Dict.getString(appInfo, "modelName");
		String phone 		= Dict.getString(appInfo, "phoneNumber");
		String net 			= Dict.getString(appInfo, "net");
		String mac 			= Dict.getString(appInfo, "mac");
		String appid 		= Dict.getString(appInfo, "appid");
		String appkey 		= Dict.getString(appInfo, "appkey");
		String rootPath 	= Dict.getString(appInfo, "rootPath");

		String rat = Dict.getString(appInfo, "rat");
		String device_os = Dict.getString(appInfo, "device_os");

		int versionCode = Dict.getInt(appInfo, "version_code", 1);
		int api = Dict.getInt(appInfo, "api", 0x10B04000);
		int isSdCard = Dict.getInt(appInfo, "isSdCard", 0);
		int simType = Dict.getInt(appInfo, "simType", 0);

		JSONObject obj = new JSONObject();
		try {
			//obj.put("currPlatform", com.boyaa.constant.ConstantValue.PLATFORM_CURRENT);
			obj.put("currPlatform", "");
			obj.put("version_code", versionCode);
			obj.put("version_name", versionName);
			obj.put("packages", packages);
			obj.put("apk_path", apk_path);
			obj.put("lib_path", lib_path);
			obj.put("files_path", files_path);
			obj.put("sd_path", sd_path);
			obj.put("root_path", rootPath);
			obj.put("lang", lang);
			obj.put("country", country);
			obj.put("device_id", device_id);
			obj.put("appname", appname);
			obj.put("packageName", packageName);
			obj.put("modelName", modelName);
			obj.put("phone", phone);
			obj.put("net", net);
			obj.put("mac", mac);
			obj.put("appid", appid);
			obj.put("appkey", appkey);
			obj.put("api", api);
			obj.put("isSdCard", isSdCard);
			obj.put("simType", simType);
			obj.put("device_os", device_os);
			obj.put("rat", rat);
			obj.put("imsi", ConstantValue.imsi);
			obj.put("propCanUse", ConstantValue.propCanUse);
			obj.put("faceCanUse", ConstantValue.faceCanUse);
			obj.put("gdmjCanUse", ConstantValue.gdmjCanUse);
			obj.put("shmjCanUse", ConstantValue.shmjCanUse);
			obj.put("isTest", ConstantValue.isTest ? 1 : 0);
			// obj.put("simulatorIp", ConstantValue.simulatorIp);
			// obj.put("simulatorPhone",
			// ConstantValue.simulatorPhone);
			System.out.println("result = " + obj.toString());
			Dict.setString(key, key + LuaCallManager.kResultPostfix, obj.toString());
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

	public static void encodeStr(String data, String key) {
		try {
			data = URLEncoder.encode(data, "UTF-8");
			System.out.println("encode_str" + data);
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		Dict.setString(key, key + LuaCallManager.kResultPostfix, data);
	}

	public static void isFileExist(String data, String key) {
		int status = 0;
		try {
			JSONObject obj = new JSONObject(data);
			String path = obj.optString("path");
			String folder = obj.optString("folder");
			status = SDTools.imageIsExist(folder, path);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		Dict.setInt(key, key + LuaCallManager.kResultPostfix, status);
	}

	public static void onResume() {
	}

	public static void onPause() {
	}

	public static void showStartDialog() {
		if (null == mStartDialog && mActivity != null ) {
			mStartDialog = new AppStartDialog(mActivity);
			mStartDialog.show();
		}
	}


	public static void stopStartDialog(boolean isForce)
	{
		if(isForce) {
			if (mStartDialog != null) {
				mStartDialog.stopForce();
				mStartDialog= null;
			}
		}else {
			dismissStartDialog();
		}
	}

	public static void dismissStartDialog() {
		if (null != mStartDialog && mActivity != null) {
			if (mActivity != null && mStartDialog.isShowing()) {
				if(mStartDialog.requestDismiss()){
					mStartDialog = null;
				}
			}

//			mStartDialog = null;

		}
	}

	public static void loadSoundRes(final String allSound, final String key) {

		ThreadTask.start(Game.getInstance(), "", false, new OnThreadTask() {
			@Override
			public void onThreadRun() {
				JSONObject jsonResult = null;
				try {
					jsonResult = new JSONObject(allSound);
					JSONArray musicArray = jsonResult.optJSONArray("bgMusic");
					for (int i = 0; i < musicArray.length(); i++) {
						String sp = musicArray.getString(i);
//						AppMusic.preloadBackgroundMusic(sp);
					}
					JSONArray array = jsonResult.optJSONArray("soundRes");
					for (int i = 0; i < array.length(); i++) {
						String sp = array.getString(i);
						AppSound.preloadEffect(sp);
					}
				} catch (JSONException e) {
					e.printStackTrace();
				}

			}

			@Override
			public void onAfterUIRun() {

				TreeMap<String, Object> map = new TreeMap<String, Object>();
				map.put("status", 1);
				JsonUtil json = new JsonUtil(map);
				System.out.println("load finished");
				mActivity.callLuaFunc(key, json.toString());
			}

			@Override
			public void onUIBackPressed() {

			}
		});
	}

	public static void GetNetAvaliable(String data, String key) {
		Dict.setInt(key, key + LuaCallManager.kResultPostfix, APNUtil.isNetworkAvailable(mActivity) ? 1 : 0);
	}
}
