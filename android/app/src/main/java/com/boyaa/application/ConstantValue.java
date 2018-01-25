package com.boyaa.application;

import java.io.File;
import java.net.URLDecoder;
import java.util.HashMap;

import android.app.Activity;
import android.app.DownloadManager;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Parcelable;
import android.util.Log;
import android.widget.RemoteViews;

import com.boyaa.core.KeyDispose;
import com.boyaa.entity.common.SDTools;
import com.boyaa.entity.common.SimplePreferences;
import com.boyaa.engine.made.APNUtil;
import com.boyaa.engine.made.AppActivity;
import com.boyaa.hallgame.Game;
import com.boyaa.made.AppHelper;
import com.boyaa.hallgame.R;

//保存一些项目中使用的常量值
public class ConstantValue {
	public static boolean isTest = true; // 是否是测试环境
	// 小包才开启
	public static int isBigBag = 1; // 大包小包配置
	public static int isSdCard = 0; // 手机是否有sd卡 0 没有 1存在
	public static boolean memory_log = false; // 是否开启记录内存cpu的log
	public static String appid = ""; // 渠道appid
	public static String appkey = ""; // 渠道appkey
	public static String api = ""; // 应用api
	public static String model_name = ""; // 设备名称
	public static String imei = ""; // 设备唯一标示
	public static String imsi = ""; // 设备唯一标示
	

	public static String rat = ""; // 分辨率
	public static String phone = ""; // 手机号
	public static String net = ""; // 联网方式
	public static String mac = ""; // 联网mac地址
	public static String simnum = "";// sim序列号
	public static int simType = 0; // 0 没有 1移动卡 2联通 3电信
	public final static  int mobile  = 1;
	public final static  int unicom  = 2;
	public final static  int telecom = 3;
	public static String package_name = "";// 包名称
	public static int versionCode = 0; // 版本号
	public static String versionName = ""; // 版本名称
	public static int isCreateShortcut = 0;// 是否已经创建了快捷方式
	public static boolean isLuaVMready = false; // lua虚拟机是否已经启动
	public static String iGeTuiId = ""; // 个推返回的clientId

	public static final int NO_URL = 0; // 没有url地址
	public static final int NO_SDCARD = 1;// 没有SDCARD
	public static final int SDCARD_SUCCESS = 2;
	public static final int DOWNLOAD_SUCCESS = 2;
	public static final int NO_UPDATE_PLATFORM = 3;// 不用更新的平台
	public static final int WEB_URL = 5; // 地址不是apk安装包地址

	public static DownloadManager moreGameDownloadManager = null;
	public static NotificationManager moreGameNotifyManager = null;
	public static DownloadManager downloadManager;
	public static NotificationManager notifyManager;
	public static int update_control = 0;// 是否强制更新
	public static boolean isInGame = true;// 是否在游戏中
	public static String uriString = "";// 下载完成后的uri地址名称
	public static boolean isUpdating = false;// 是否正在更新
	public static final int ISUPDATING = 4;// 正在更新中
	public static String packageName;
	public static long mDownloadId = 0;

	public static int REQUEST_CODE_START = 0;
	public static int REQUEST_CODE_STORAGE = 1;
	public static int REQUEST_CODE_SMS = 2;
	public static int REQUEST_CODE_LOCATION = 3;
	public static int REQUEST_CODE_CALENDAR = 4;
	public static int REQUEST_CODE_CAMERA = 5;
	public static int REQUEST_CODE_CONTACTS = 6;
	public static int REQUEST_CODE_MICROPHONE = 7;
	public static int REQUEST_CODE_PHONE = 8;
	public static int REQUEST_CODE_SENSORS = 9;
	
	// 资源下载相关参数
	public final static HashMap<Integer, Integer> downloadResult = new HashMap<Integer, Integer>(); // 资源下载结果：0
																									// 未下载
																									// 1
																									// 失败
																									// 2成功

	public final static HashMap<Integer, String> downloadUrl = new HashMap<Integer, String>(); // 资源的下载路径
	public static int tips = 0;
	public static int downloadType = 0;
	public static boolean downloadsound = true; // 是否需要下载声音
	public static boolean downloadface = true; // 是否需要下载表情
	public final static int LOADFACE = 1;
	public final static int LOADSOUND = 2;
	
	public static int faceCanUse = 0; // 表情资源是否可用
	public static int propCanUse = 0; // 道具资源是否可用
	public static int gdmjCanUse = 0; // 广东声音资源是否可用
	public static int shmjCanUse = 0; // 上海声音是否可用
	
	public static int faceSize = 27;
	public static int propSize = 9;
	public static int gdmjSize = 116;
	public static int shmjSize = 157;
	
	public static int resDownload = 1;
	public static String SHARE_APP_NAME = "";
	public static String SHARE_CONTENT = "";
	public static String shareUrlPrefix = "";
	public static String SHARE_USERNAME = "";
	public static Bitmap shareBmp = null;
	public static boolean isWeixinInstalled = false;
	public static String simulatorIp = "";
	public static String simulatorPhone = "";

	public static final String SCREEN_SHOT_CUT_NAME = "screen_shot_cut.png";
	
	
	public final static String KExit = "Exit"; // 结束程序

	// 初始化一些数据 把appid appkey 数据缓存
	public static void initData(Context context) {

		PackageManager packageManager = context.getPackageManager();
		try {
			PackageInfo packageInfo = packageManager.getPackageInfo(context.getPackageName(), 0);
			versionName = packageInfo.versionName;
			versionCode = packageInfo.versionCode;
			packageName = packageInfo.packageName;
		} catch (NameNotFoundException e) {
			Log.i("", e.toString());
		}
		isInGame = true;
		// 判断是否创建了快捷启动方式
		isCreateShortcut = SimplePreferences.getInt(context,"isCreateShortcut", 0);
		// 缓存设置渠道号
		String id = SimplePreferences.getString(context, "appid", "");
		String key = SimplePreferences.getString(context, "appkey", "");
		if ("".equals(id) || "".equals(key)) {
			SimplePreferences.putString(context, "appid", ConstantValue.appid);
			SimplePreferences.putString(context, "appkey", ConstantValue.appkey);
		} else {
			ConstantValue.appid = id;
			ConstantValue.appkey = key;
		}

		imei = APNUtil.getMachineId(context);
		imsi = APNUtil.getSimOperator(context);
		model_name = APNUtil.getMachineName();
		rat = AppHelper.mWidth + "*" + AppHelper.mHeight; // 设置分辨率
		phone = APNUtil.getTelephone(context);
		net = APNUtil.checkNetWork(context);
		mac = APNUtil.getLocalMacAddress(context);
		simnum = APNUtil.getSimSerialNumber(context);
		simType = APNUtil.getSimCardType(context);
		isSdCard = SDTools.isExternalStorageWriteable() ? 1 : 0;
	}

	public static void initResStatus() {
		if( gdmjSoundExist() )
			gdmjCanUse = 1;
		
		if( shmjSoundExist() )
			shmjCanUse = 1;
		
		if( faceExist() )
			faceCanUse = 1;
		
		if( propExist() )
			propCanUse = 1;
	}

	private static boolean propExist() {
		String path = Game.getInstance().getImagePath() + "friendsAnim";
		String itemPath = path + File.separator + "cheers_pin.png";
		return checkResFull(path, itemPath, propSize);
	}

	private static boolean faceExist() {
		String path = Game.getInstance().getImagePath() + "expression";
		String itemPath = path + File.separator + "expression17.png";
		return checkResFull(path, itemPath, faceSize);
	}

	private static boolean shmjSoundExist() {
		String path = Game.getInstance().getAudioPath() + "ogg/shmj";
		String itemPath = path + File.separator + "man_chat0.ogg";
		return checkResFull(path, itemPath, shmjSize);
	}

	private static boolean gdmjSoundExist() {
		String path = Game.getInstance().getAudioPath() + "ogg/gdmj";
		String itemPath = path + File.separator + "man_chat0.ogg";
		return checkResFull(path, itemPath, gdmjSize);
	}

	private static boolean checkResFull(String path, String itemPath,
			int size) {
		File folder = new File(path);
		File file = new File(itemPath);

		int realSize = 0;
		if (folder.list() != null) {
			realSize = folder.list().length;
		}
		if (file.exists())
			System.out.println("文件存在");
		if (realSize >= size)
			System.out.println("数目匹配");
		return file.exists() && realSize >= size;
	}

	/**
	 * 创建快捷启动方式
	 * 
	 * @param act
	 * @param iconResId
	 * @param appnameResId
	 */
	public static void createShortCut(Activity act, int iconResId,
			int appnameResId) {

		if (isCreateShortcut == 1) { // 仅仅创建一次
			return;
		}
		isCreateShortcut = 1;
		SimplePreferences.putInt(act, "isCreateShortcut", 1);
		Intent intent = new Intent();
		intent.setClass(act, act.getClass());
		intent.setAction("android.intent.action.MAIN");
		intent.addCategory("android.intent.category.LAUNCHER");
		Intent addShortcut = new Intent(
				"com.android.launcher.action.INSTALL_SHORTCUT");
		Parcelable icon = Intent.ShortcutIconResource.fromContext(act,
				iconResId);
		// 需要现实的名称
		addShortcut.putExtra(Intent.EXTRA_SHORTCUT_NAME,
				act.getString(appnameResId));
		addShortcut.putExtra(Intent.EXTRA_SHORTCUT_INTENT, intent);
		// 不允许重复创建
		addShortcut.putExtra("duplicate", false);
		// 点击快捷图片，运行的程序主入口
		addShortcut.putExtra(Intent.EXTRA_SHORTCUT_ICON_RESOURCE, icon);
		// 发送广播
		act.sendBroadcast(addShortcut);
	}

	/**
	 * 更新完成后启动Intent替换原有更新
	 */
	public static void updateReplaceVersion(Context context, String uriString) {
		Intent intent2 = new Intent(Intent.ACTION_VIEW);
		intent2.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		intent2.setDataAndType(Uri.parse(uriString),"application/vnd.android.package-archive");
		Notification noti = new Notification();
		noti.flags = Notification.FLAG_INSISTENT;
		String fileName = uriString.substring(uriString.lastIndexOf("/") + 1);
		fileName = URLDecoder.decode(fileName);
		PendingIntent contentIntent = PendingIntent.getActivity(context, 0,intent2, 0);
		//noti.setLatestEventInfo(context, "麻将合集下载完成", fileName, contentIntent);
		noti.contentView = new RemoteViews(Game.getInstance().getPackageName(), R.layout.download_progress);
		noti.icon = R.drawable.hallgame_icon;
		noti.tickerText = "麻将合集下载完成";
		if (ConstantValue.notifyManager != null) {
			ConstantValue.notifyManager.notify(2, noti);
		}
		context.startActivity(intent2);
		if (ConstantValue.update_control == 1) {
			KeyDispose keyDispose = new KeyDispose();
			keyDispose.exit(KExit, "");
		}
	}
}
