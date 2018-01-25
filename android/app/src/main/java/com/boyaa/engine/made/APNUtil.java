package com.boyaa.engine.made;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.location.Location;
import android.location.LocationManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Proxy;
import android.net.Uri;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.provider.Settings;
import android.support.v4.content.ContextCompat;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.util.Log;

import com.boyaa.entity.common.SdkVersion;

import java.util.UUID;

/**
 * APN工具类
 */
public class APNUtil {
	private static final String TAG = "APNUtil";
	/**
	 * cmwap
	 */
	public static final int MPROXYTYPE_CMWAP = 1;
	/**
	 * wifi
	 */
	public static final int MPROXYTYPE_WIFI = 2;
	/**
	 * cmnet
	 */
	public static final int MPROXYTYPE_CMNET = 4;
	/**
	 * uninet服务器列表
	 */
	public static final int MPROXYTYPE_UNINET = 8;
	/**
	 * uniwap服务器列表
	 */
	public static final int MPROXYTYPE_UNIWAP = 16;
	/**
	 * net类服务器列表
	 */
	public static final int MPROXYTYPE_NET = 32;
	/**
	 * wap类服务器列表
	 */
	public static final int MPROXYTYPE_WAP = 64;
	/**
	 * 默认服务器列表
	 */
	public static final int MPROXYTYPE_DEFAULT = 128;
	/**
	 * cmda net
	 */
	public static final int MPROXYTYPE_CTNET = 256;
	/**
	 * cmda wap
	 */
	public static final int MPROXYTYPE_CTWAP = 512;

	public static final String ANP_NAME_WIFI = "wifi"; // 中国移动wap APN名称
	public static final String ANP_NAME_CMWAP = "cmwap"; // 中国移动wap APN名称
	public static final String ANP_NAME_CMNET = "cmnet"; // 中国移动net APN名称
	public static final String ANP_NAME_UNIWAP = "uniwap"; // 中国联通wap APN名称
	public static final String ANP_NAME_UNINET = "uninet"; // 中国联通net APN名称
	public static final String ANP_NAME_WAP = "wap"; // 中国电信wap APN名称
	public static final String ANP_NAME_NET = "net"; // 中国电信net APN名称
	public static final String ANP_NAME_CTWAP = "中国电信ctwap服务器列表"; // wap APN名称
	public static final String ANP_NAME_CTNET = "中国电信ctnet服务器列表"; // net APN名称
	public static final String ANP_NAME_NONE = "none"; // net APN名称

	// apn地址
	private static Uri PREFERRED_APN_URI = Uri
			.parse("content://telephony/carriers/preferapn");

	// apn属性类型
	public static final String APN_PROP_APN = "apn";
	// apn属性代理
	public static final String APN_PROP_PROXY = "proxy";
	// apn属性端口
	public static final String APN_PROP_PORT = "port";

	public static final byte APNTYPE_NONE = 0;// 未知类型
	public static final byte APNTYPE_CMNET = 1;// cmnet
	public static final byte APNTYPE_CMWAP = 2;// cmwap
	public static final byte APNTYPE_WIFI = 3;// WiFi
	public static final byte APNTYPE_UNINET = 4;// uninet
	public static final byte APNTYPE_UNIWAP = 5;// uniwap
	public static final byte APNTYPE_NET = 6;// net类接入点
	public static final byte APNTYPE_WAP = 7;// wap类接入点
	public static final byte APNTYPE_CTNET = 8; // ctnet
	public static final byte APNTYPE_CTWAP = 9; // ctwap
	// jce接入点类型
	public static final int JCE_APNTYPE_UNKNOWN = 0;
	public static final int JCE_APNTYPE_DEFAULT = 1;
	public static final int JCE_APNTYPE_CMNET = 2;
	public static final int JCE_APNTYPE_CMWAP = 4;
	public static final int JCE_APNTYPE_WIFI = 8;
	public static final int JCE_APNTYPE_UNINET = 16;
	public static final int JCE_APNTYPE_UNIWAP = 32;
	public static final int JCE_APNTYPE_NET = 64;
	public static final int JCE_APNTYPE_WAP = 128;
	public static final int JCE_APNTYPE_CTWAP = 512;
	public static final int JCE_APNTYPE_CTNET = 256;

	/**
	 * 获取jce协议的接入点类型 老协议的
	 * 
	 * @param context
	 * @return
	 */
	public static int getJceApnType(Context context) {
		int netType = getMProxyType(context);
		if (netType == MPROXYTYPE_WIFI) {
			return JCE_APNTYPE_WIFI;
		} else if (netType == MPROXYTYPE_CMWAP) {
			return JCE_APNTYPE_CMWAP;
		} else if (netType == MPROXYTYPE_CMNET) {
			return JCE_APNTYPE_CMNET;
		} else if (netType == MPROXYTYPE_UNIWAP) {
			return JCE_APNTYPE_UNIWAP;
		} else if (netType == MPROXYTYPE_UNINET) {
			return JCE_APNTYPE_UNINET;
		} else if (netType == MPROXYTYPE_WAP) {
			return JCE_APNTYPE_WAP;
		} else if (netType == MPROXYTYPE_NET) {
			return JCE_APNTYPE_NET;
		} else if (netType == MPROXYTYPE_CTWAP) {
			return JCE_APNTYPE_CTWAP;
		} else if (netType == MPROXYTYPE_CTNET) {
			return JCE_APNTYPE_CTNET;
		}
		return JCE_APNTYPE_DEFAULT;
	}

	/**
	 * 将jce定义的接入点类型转化为普通(老协议定义的)接入点类型
	 * 
	 * @param jceApnType
	 * @return
	 */
	public static byte jceApnTypeToNormalapnType(int jceApnType) {
		if (jceApnType == JCE_APNTYPE_UNKNOWN) {
			return APNTYPE_NONE;
		} else if (jceApnType == JCE_APNTYPE_DEFAULT) {
			return JCE_APNTYPE_CMWAP;
		} else if (jceApnType == JCE_APNTYPE_CMNET) {
			return APNTYPE_CMNET;
		} else if (jceApnType == JCE_APNTYPE_CMWAP) {
			return APNTYPE_CMWAP;
		} else if (jceApnType == JCE_APNTYPE_WIFI) {
			return APNTYPE_WIFI;
		} else if (jceApnType == JCE_APNTYPE_UNINET) {
			return APNTYPE_UNINET;
		} else if (jceApnType == JCE_APNTYPE_UNIWAP) {
			return APNTYPE_UNIWAP;
		} else if (jceApnType == JCE_APNTYPE_NET) {
			return APNTYPE_NET;
		} else if (jceApnType == JCE_APNTYPE_WAP) {
			return APNTYPE_WAP;
		} else if (jceApnType == JCE_APNTYPE_CTWAP) {
			return APNTYPE_CTNET;
		} else if (jceApnType == JCE_APNTYPE_CTNET) {
			return APNTYPE_CTWAP;
		}
		return APNTYPE_NONE;
	}

	/**
	 * 将普通(老协议定义的)接入点类型转化为jce定义的接入点类型 老协议的
	 * 
	 * @param apnType
	 * @return
	 */
	public static int normalApnTypeToJceApnType(byte apnType) {
		if (apnType == APNTYPE_NONE) {
			return JCE_APNTYPE_UNKNOWN;
		} else if (apnType == JCE_APNTYPE_CMWAP) {
			return JCE_APNTYPE_DEFAULT;
		} else if (apnType == APNTYPE_CMNET) {
			return JCE_APNTYPE_CMNET;
		} else if (apnType == APNTYPE_CMWAP) {
			return JCE_APNTYPE_CMWAP;
		} else if (apnType == APNTYPE_WIFI) {
			return JCE_APNTYPE_WIFI;
		} else if (apnType == APNTYPE_UNINET) {
			return JCE_APNTYPE_UNINET;
		} else if (apnType == APNTYPE_UNIWAP) {
			return JCE_APNTYPE_UNIWAP;
		} else if (apnType == APNTYPE_NET) {
			return JCE_APNTYPE_NET;
		} else if (apnType == APNTYPE_WAP) {
			return JCE_APNTYPE_WAP;
		} else if (apnType == APNTYPE_CTWAP) {
			return JCE_APNTYPE_CTWAP;
		} else if (apnType == APNTYPE_CTNET) {
			return JCE_APNTYPE_CTNET;
		}
		return JCE_APNTYPE_UNKNOWN;
	}

	/**
	 * 获取自定义APN名称
	 * 
	 * @param context
	 * @return
	 */
	public static String getApnName(Context context) {
		int netType = getMProxyType(context);

		if (netType == MPROXYTYPE_WIFI) {
			return ANP_NAME_WIFI;
		} else if (netType == MPROXYTYPE_CMWAP) {
			return ANP_NAME_CMWAP;
		} else if (netType == MPROXYTYPE_CMNET) {
			return ANP_NAME_CMNET;
		} else if (netType == MPROXYTYPE_UNIWAP) {
			return ANP_NAME_UNIWAP;
		} else if (netType == MPROXYTYPE_UNINET) {
			return ANP_NAME_UNINET;
		} else if (netType == MPROXYTYPE_WAP) {
			return ANP_NAME_WAP;
		} else if (netType == MPROXYTYPE_NET) {
			return ANP_NAME_NET;
		} else if (netType == MPROXYTYPE_CTWAP) {
			return ANP_NAME_CTWAP;
		} else if (netType == MPROXYTYPE_CTNET) {
			return ANP_NAME_CTNET;
		}
		// 获取系统apn名称
		String apn = getApn(context);
		if (apn != null && apn.length() != 0)
			return apn;
		return ANP_NAME_NONE;
	}

	public static boolean IsBroadband(Context context) {
		int netType = getMProxyType(context);
		if (netType == MPROXYTYPE_WIFI) {
			return true;
		} else if (netType == MPROXYTYPE_CMWAP) {
			return false;
		} else if (netType == MPROXYTYPE_CMNET) {
			return false;
		} else if (netType == MPROXYTYPE_UNIWAP) {
			return false;
		} else if (netType == MPROXYTYPE_UNINET) {
			return false;
		} else if (netType == MPROXYTYPE_WAP) {
			return false;
		} else if (netType == MPROXYTYPE_NET) {
			return false;
		} else if (netType == MPROXYTYPE_CTWAP) {
			return false;
		} else if (netType == MPROXYTYPE_CTNET) {
			return false;
		} else {
			return true;
		}
	}

	/**
	 * 获取自定义apn类型
	 * 
	 * @param context
	 * @return
	 */
	public static byte getApnType(Context context) {
		int netType = getMProxyType(context);

		if (netType == MPROXYTYPE_WIFI) {
			return APNTYPE_WIFI;
		} else if (netType == MPROXYTYPE_CMWAP) {
			return APNTYPE_CMWAP;
		} else if (netType == MPROXYTYPE_CMNET) {
			return APNTYPE_CMNET;
		} else if (netType == MPROXYTYPE_UNIWAP) {
			return APNTYPE_UNIWAP;
		} else if (netType == MPROXYTYPE_UNINET) {
			return APNTYPE_UNINET;
		} else if (netType == MPROXYTYPE_WAP) {
			return APNTYPE_WAP;
		} else if (netType == MPROXYTYPE_NET) {
			return APNTYPE_NET;
		} else if (netType == MPROXYTYPE_CTWAP) {
			return APNTYPE_CTWAP;
		} else if (netType == MPROXYTYPE_CTNET) {
			return APNTYPE_CTNET;
		}
		return APNTYPE_NONE;
	}

	/**
	 * 获取系统APN
	 * 
	 * @param context
	 * @return
	 */
	public static String getApn(Context context) {
		String apn = null;
		Cursor c = null;
		try {
			c = context.getContentResolver().query(PREFERRED_APN_URI, null,
					null, null, null);
			if (null != c) {
				c.moveToFirst();
				if (c.isAfterLast()) {
					return null;
				}
				apn = c.getString(c.getColumnIndex(APN_PROP_APN));
			}
		} catch (java.lang.SecurityException e) {
		} catch (Exception e) {
		} finally {
			if (null != c) {
				try {
					c.close();
				} catch (Exception e) {

				}
			}
		}
		return apn;

	}

	/**
	 * 获取系统APN代理IP
	 * 
	 * @param context
	 * @return
	 */
	public static String getApnProxy(Context context) {
		Cursor c = null;
		String proxy = null;
		try {
			c = context.getContentResolver().query(PREFERRED_APN_URI, null,
					null, null, null);
			if (null != c) {
				c.moveToFirst();
				if (c.isAfterLast()) {
					proxy = Proxy.getDefaultHost();
				}
				proxy = c.getString(c.getColumnIndex(APN_PROP_PROXY));
			} else {
				proxy = Proxy.getDefaultHost();
			}
		} catch (java.lang.SecurityException e) {
			proxy = Proxy.getDefaultHost();
		} catch (Exception e) {
			// android4.0以上系统，使用用wap网络请求时可能报需要apn写出权限错误，此时重新对ip、port赋值
			proxy = Proxy.getDefaultHost();
		} finally {
			if (null != c) {
				try {
					c.close();
				} catch (Exception e) {

				}
			}
		}
		return proxy;
	}

	/**
	 * 获取系统APN代理端口
	 * 
	 * @param context
	 * @return
	 */
	public static String getApnPort(Context context) {
		Cursor c = null;
		String value = null;
		try {
			c = context.getContentResolver().query(PREFERRED_APN_URI, null,
					null, null, null);
			if (null != c) {
				c.moveToFirst();
				if (c.isAfterLast()) {
					return null;
				}
				value = c.getString(c.getColumnIndex(APN_PROP_PROXY));
			}
		} catch (java.lang.SecurityException e) {
		} catch (Exception e) {
		} finally {
			if (null != c) {
				try {
					c.close();
				} catch (Exception e) {

				}
			}
		}
		return value;
	}

	/**
	 * 获取系统APN代理端口
	 * 
	 * @param context
	 * @return
	 */
	public static int getApnPortInt(Context context) {
		Cursor c = null;
		int port = -1;
		try {
			c = context.getContentResolver().query(PREFERRED_APN_URI, null,
					null, null, null);
			if (null != c) {
				c.moveToFirst();
				if (c.isAfterLast()) {
					port = Proxy.getDefaultPort() == -1 ? 80 : Proxy
							.getDefaultPort();
				}
				port = c.getInt(c.getColumnIndex(APN_PROP_PORT));
			}
		} catch (java.lang.SecurityException e) {
			// 4.0以上系统使用android.permission.WRITE_SETTINGS权限会报异常
			port = Proxy.getDefaultPort() == -1 ? 80 : Proxy.getDefaultPort();
		} catch (Exception e) {
			// android4.0以上系统，使用用wap网络请求时可能报需要apn写出权限错误，此时重新对ip、port赋值
			port = Proxy.getDefaultPort() == -1 ? 80 : Proxy.getDefaultPort();
		} finally {
			if (null != c) {
				try {
					c.close();
				} catch (Exception e) {

				}
			}
		}
		return port;
	}

	/**
	 * 是否有网关代理
	 * 
	 * @param context
	 * @return
	 */
	public static boolean hasProxy(Context context) {
		int netType = getMProxyType(context);
		// #if ${polish.debug}
		// #endif
		if (netType == MPROXYTYPE_CMWAP || netType == MPROXYTYPE_UNIWAP
				|| netType == MPROXYTYPE_WAP || netType == MPROXYTYPE_CTWAP) {
			return true;
		}
		return false;
	}

	/**
	 * 获取自定义当前联网类型
	 * 
	 * @param act
	 *            当前活动Activity
	 * @return 联网类型 -1表示未知的联网类型, 正确类型： MPROXYTYPE_WIFI | MPROXYTYPE_CMWAP |
	 *         MPROXYTYPE_CMNET
	 */
	public static int getMProxyType(Context act) {

		int type = MPROXYTYPE_DEFAULT;
		ConnectivityManager cm = (ConnectivityManager) act
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo info = cm.getActiveNetworkInfo();
		if (null != info) {
			String typeName = info.getTypeName();// never null
			String extraInfo = info.getExtraInfo();// maybe null
			if (null == extraInfo) {
				extraInfo = "unknown";
			} else {
				extraInfo = extraInfo.toLowerCase();
			}

			if (typeName.toUpperCase().equals("WIFI")) { // wifi网络
				type = MPROXYTYPE_WIFI;
			} else {
				if (extraInfo.startsWith("cmwap")) { // cmwap
					type = MPROXYTYPE_CMWAP;
				} else if (extraInfo.startsWith("cmnet")
						|| extraInfo.startsWith("epc.tmobile.com")) { // cmnet
					type = MPROXYTYPE_CMNET;
				} else if (extraInfo.startsWith("uniwap")) {
					type = MPROXYTYPE_UNIWAP;
				} else if (extraInfo.startsWith("uninet")) {
					type = MPROXYTYPE_UNINET;
				} else if (extraInfo.startsWith("wap")) {
					type = MPROXYTYPE_WAP;
				} else if (extraInfo.startsWith("net")) {
					type = MPROXYTYPE_NET;
				} else if (extraInfo.startsWith("#777")) { // cdma
					String proxy = getApnProxy(act);
					if (proxy != null && proxy.length() > 0) {
						type = MPROXYTYPE_CTWAP;
					} else {
						type = MPROXYTYPE_CTNET;
					}
				} else if (extraInfo.startsWith("ctwap")) {
					type = MPROXYTYPE_CTWAP;
				} else if (extraInfo.startsWith("ctnet")) {
					type = MPROXYTYPE_CTNET;
				} else {
				}

			}
		}
		return type;
	}

	/**
	 * @param context
	 * @return
	 */
	public static String getNetWorkName(Context context) {
		ConnectivityManager cm = (ConnectivityManager) context
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo info = cm.getActiveNetworkInfo();
		if (info != null)
			return info.getTypeName();
		else
			return "MOBILE";
	}

	/**
	 * 检测是否有网络
	 * 
	 * @param c
	 * @return
	 */
	public static boolean isNetworkAvailable(Context act) {
		ConnectivityManager cm = (ConnectivityManager) act
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo info = cm.getActiveNetworkInfo();
		if (info != null && info.getState() == NetworkInfo.State.CONNECTED)
			return true;
		return false;
	}

	/**
	 * 活动网络是否有效
	 * 
	 * @param ctx
	 * @return
	 */
	public static boolean isActiveNetworkAvailable(Context ctx) {
		ConnectivityManager cm = (ConnectivityManager) ctx
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo info = cm.getActiveNetworkInfo();
		if (info != null)
			return info.isAvailable();
		return false;
	}



	//===============================旧代码移植==============================
	//=======================================================================

	/**
	 * 获得手机imei
	 *
	 * @param ctx
	 * @return
	 */
	public static String getTmei(Context ctx) {
		if (ContextCompat.checkSelfPermission(ctx, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED){
			return "";
		}
		TelephonyManager phoneMgr = (TelephonyManager) ctx.getSystemService(Context.TELEPHONY_SERVICE);
		String imei = phoneMgr.getDeviceId();
		if (imei == null) {
			imei = "";
		}
		return imei;
	}

	public static String getMachineName() {
		String model = android.os.Build.MODEL;
		String name = "Guest_";
		if (model != null) {
			String names[] = model.split(" ");
			int length = names.length;
			if (length >= 3) {
				name = names[length - 2] + " " + names[length - 1];
			} else {
				name = model;
			}
		}
		return name;
	}

	public static String getMachineOS() {
		String model = android.os.Build.VERSION.SDK+"==-=="+android.os.Build.VERSION.RELEASE;

		return model;
	}

	public static String getUUID(Context ctx)
	{
		SharedPreferences uuidFile = ctx.getSharedPreferences("boyaa_uuid", Context.MODE_PRIVATE);
		String uuid = uuidFile.getString("uuid", "");
		//uuid存在，用老的uuid
		if (uuid != null && !uuid.isEmpty()){
			Log.d("zyh", "uuid exist "+uuid);
			return uuid;
		}
		else{
			SharedPreferences.Editor uuidEdit = uuidFile.edit();
			String newUUid = UUID.randomUUID().toString();
			uuidEdit.putString("uuid", newUUid);
			uuidEdit.commit();
			Log.d("zyh", "uuid not exist " + newUUid);
			return newUUid;
		}
	}
	/**
	 * 获得imei，如果无法获得会返回wifi mac。如果都没有，返回""
	 */
	public static String getMachineId(Context ctx) {
		Log.d("zyh", "getMachineId");
		String imei = null;
		if (ContextCompat.checkSelfPermission(ctx, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED){
			return getUUID(ctx);
		}
		Log.d("zyh", "getMachineId has permission");
		TelephonyManager telephonyManager = (TelephonyManager) ctx.getSystemService(Context.TELEPHONY_SERVICE);
		if (telephonyManager != null) {
			imei = telephonyManager.getDeviceId();
		}
		if (imei == null) {
			Log.d("zyh", "imei is null");
			//安卓6以下用mac，以上的mac地址是常量，用andoird id，此值也是可能重复的
			if (SdkVersion.Below23())
			{
				Log.d("zyh", "sdk version below 23");
				WifiManager mgr = (WifiManager) ctx.getSystemService(Context.WIFI_SERVICE);
				if (mgr != null) {
					WifiInfo wifiinfo = mgr.getConnectionInfo();
					if (wifiinfo != null) {
						imei = wifiinfo.getMacAddress();
						Log.d("zyh", "wifiinfo is not null and mac is " + imei);
					}
				}
			}
			else{
				Log.d("zyh", "sdk version higer 23");
				String androidId = Settings.Secure.getString(ctx.getContentResolver(), Settings.Secure.ANDROID_ID);
				if (androidId != null && (! androidId.isEmpty()))
				{
					imei = androidId;
					Log.d("zyh", "androidId not null and not empty is " + imei);
				}
			}
		}
		if (imei == null) {
			//最终为空，那就用UUID了
			return getUUID(ctx);
		}
		Log.d("zyh", "final return imei " + imei);
		return imei;
	}

	/**
	 * 获得手机号码
	 *
	 * @param ctx
	 * @return
	 */
	public static String getTelephone(Context ctx) {
		if (ContextCompat.checkSelfPermission(ctx, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED){
			return "";
		}
		TelephonyManager phoneMgr = (TelephonyManager) ctx.getSystemService(Context.TELEPHONY_SERVICE);
		String phone = phoneMgr.getLine1Number();
		if (phone == null) {
			phone = "";
		}
		return phone;
	}

	/**
	 * 获得sim卡序列号
	 *
	 * @param ctx
	 * @return
	 */
	public static String getSimSerialNumber(Context ctx) {
		if (ContextCompat.checkSelfPermission(ctx, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED){
			return "";
		}
		TelephonyManager phoneMgr = (TelephonyManager) ctx.getSystemService(Context.TELEPHONY_SERVICE);
		String simSerialNumber = phoneMgr.getSimSerialNumber();
		if (simSerialNumber == null) {
			simSerialNumber = "";
		}
		return simSerialNumber;
	}

	/**
	 * 获得mac地址
	 *
	 * @param ctx
	 * @return
	 */
	public static String getLocalMacAddress(Context ctx) {
//		WifiManager wifi = (WifiManager) ctx.getSystemService(Context.WIFI_SERVICE);
//		WifiInfo info = wifi.getConnectionInfo();
//		String mac = info.getMacAddress();
//		if (mac == null) {
//			mac = "";
//		}
//		return mac;
		return GetMacFunction.getMacAddr(ctx);
	}

	/**获取手机的imsi号 */
	public static String getSimOperator(Context ctx) {
		if (ContextCompat.checkSelfPermission(ctx, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED){
			return "";
		}
		TelephonyManager tm = (TelephonyManager) ctx.getSystemService(Context.TELEPHONY_SERVICE);
		String imsi = tm.getSubscriberId();
		if(imsi != null){
			return imsi;
		}
		return "";
	}

	/** SIM卡是中国移动 */
	public static boolean isChinaMobile(Context ctx) {
		String imsi = getSimOperator(ctx);
		if (imsi == null)
			return false;
		return imsi.startsWith("46000") || imsi.startsWith("46002") || imsi.startsWith("46007");
	}

	/** SIM卡是中国联通 */
	public static boolean isChinaUnicom(Context ctx) {
		String imsi = getSimOperator(ctx);
		if (imsi == null)
			return false;
		return imsi.startsWith("46001");
	}

	/** SIM卡是中国电信 */
	public static boolean isChinaTelecom(Context ctx) {
		String imsi = getSimOperator(ctx);
		if (imsi == null)
			return false;
		return imsi.startsWith("46003");
	}

	public static int getSimCardType(Context ctx) {
		int simtype = 0;
		if (isChinaMobile(ctx)) {
			simtype = 1;
		} else if (isChinaUnicom(ctx)) {
			simtype = 2;
		} else if (isChinaTelecom(ctx)) {
			simtype = 3;
		}
		return simtype;
	}

	/** 获取手机IMSI号码 */
	public static TelephonyManager getTelephonyManager() {
		TelephonyManager tm = (TelephonyManager) AppActivity.getInstance().getApplication().getSystemService(
				Context.TELEPHONY_SERVICE);
		return tm;
	}


	/*获取GPS位置*/
	public static Location getLocation(Context ctx) {
		if (ContextCompat.checkSelfPermission(ctx, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED ||
				ContextCompat.checkSelfPermission(ctx, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED	){
			return null;
		}
		LocationManager locationManager = (LocationManager) ctx.getSystemService(Context.LOCATION_SERVICE);
		Location gpsLoc = null, netLoc = null;
		if (locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER))
		{
			gpsLoc = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);
		}
		else if (locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER))
		{
			netLoc = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
		}
		if (gpsLoc != null)
		{
			return gpsLoc;
		}
		if (netLoc != null)
		{
			return netLoc;
		}

		return null;
	}
	// 得到网络类型
	public static String checkNetWork(Context context) {

		ConnectivityManager mConnectivity = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
		// TelephonyManager mTelephony =
		// (TelephonyManager)context.getSystemService(Activity.TELEPHONY_SERVICE);
		// // 检查网络连接，如果无网络可用，就不需要进行连网操作等
		NetworkInfo info = mConnectivity.getActiveNetworkInfo();

		if (info == null || !mConnectivity.getBackgroundDataSetting()) {
			return "nonet";
		}
		// 判断网络连接类型，只有在2G/3G/wifi里进行一些数据更新。
		int netType = info.getType();
		int netSubtype = info.getSubtype();

		if (netType == ConnectivityManager.TYPE_WIFI) {
			return "wifi";
		} else if (netSubtype == TelephonyManager.NETWORK_TYPE_GPRS || netSubtype == TelephonyManager.NETWORK_TYPE_EDGE || netSubtype == TelephonyManager.NETWORK_TYPE_CDMA) {
			return "2g";
		} else if (netSubtype == TelephonyManager.NETWORK_TYPE_UMTS || netSubtype == TelephonyManager.NETWORK_TYPE_HSDPA || netSubtype == TelephonyManager.NETWORK_TYPE_HSPA || netSubtype == TelephonyManager.NETWORK_TYPE_HSUPA) {
			return "联通3g";
		} else if (netSubtype == TelephonyManager.NETWORK_TYPE_EVDO_0 || netSubtype == TelephonyManager.NETWORK_TYPE_EVDO_A) {
			return "电信3g";
		} else {
			return "unknow";
		}
	}
}