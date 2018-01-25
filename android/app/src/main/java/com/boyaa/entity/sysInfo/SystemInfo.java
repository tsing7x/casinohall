package com.boyaa.entity.sysInfo;

import java.io.File;
import java.util.TreeMap;

import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.app.DownloadManager;
import android.app.DownloadManager.Request;
import android.app.NotificationManager;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.widget.Toast;

import com.boyaa.application.ConstantValue;
import com.boyaa.core.KeyDispose;
import com.boyaa.entity.common.utils.JsonUtil;
import com.boyaa.hallgame.Game;
import com.boyaa.hallgame.LuaCallManager;


public class SystemInfo {
	private DownloadManager downloadManager = null;
	private NotificationManager notifyManager = null;
	public static final String LOG_RECORD = "BoyaaSichuan";
	private long mDownloadId;
	private int step = 1000;
	private QueryRunnable runnable = new QueryRunnable();
	public static int m_downloadSize = 0;
	public static int m_totalSize = 0;
	private Handler mhandler;
	private String downloadStr;
	public static final String DOWNLOAD_RUNNING = "0";
	public static final String DOWNLOAD_SUCCESSFUL = "1";
	public static final String DOWNLOAD_FAILED = "2";
	public static final int UPDATE_FAILED = 1;
	public static final int UPDATE_NORMAL = 0;
	public static final int UPDATE_VERSION_RUNNING = 0x111;

	public SystemInfo() {

	}

	public void updateVersionInWebView(String url) {
		Intent intent = new Intent(Intent.ACTION_VIEW);
		intent.setData(Uri.parse(url));
		intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		Game.getInstance().startActivity(intent);
		Game.getInstance().finish();
	}
	
	public int updateVersion(String updateData) {
		JSONObject jsonUpdateData = null;
		String update_url = null;
		int update_control = 0;
		try {
			jsonUpdateData = new JSONObject(updateData);
			update_url = jsonUpdateData.getString("url");
			update_control = jsonUpdateData.getInt("force");
			String fileName = update_url.substring(update_url.lastIndexOf("/") + 1);
			if (!fileName.contains(".apk")) {  
				downloadStr = update_url;
				orignDownload();
				return ConstantValue.ISUPDATING;
			} else {
				return updateVersion(update_url, update_control);
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return ConstantValue.NO_URL;
	}
	
	public boolean checkDownloaded(String urlData)
	{
		JSONObject jsonUpdateData = null;
		String url = null;
		try {
			jsonUpdateData = new JSONObject(urlData);
			url = jsonUpdateData.getString("url");
			
			String fileName = url.substring(url.lastIndexOf("/") + 1);
			File file = new File(Environment.getExternalStorageDirectory()
					+ File.separator + Environment.DIRECTORY_DOWNLOADS
					+ File.separator + fileName);
			// 安装包是否已经下载完成
			return  file.exists() && (file.length() >= m_totalSize) && m_totalSize > 0;
			
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return false;
		
		
	}

	@SuppressLint("NewApi")
	public int updateVersion(String update_url, int update_control) {
		mhandler = new Handler() {
			@Override
			public void handleMessage(Message msg) {
				if (msg.what == UPDATE_VERSION_RUNNING) {
					TreeMap<String, Object> map = new TreeMap<String, Object>();
					map.put("downloadSize", m_downloadSize);
					map.put("totalSize", m_totalSize);
					// 如果是更新
					JsonUtil progressJson = new JsonUtil(map);
					final String progressStr = progressJson.toString();
					Game.getInstance().callLuaFunc(LuaCallManager.kUpdateVersion, progressStr);
					
				}
				super.handleMessage(msg);
			}
		};

		if (update_url == null || "".equals(update_url)) {
			ConstantValue.isUpdating = false;
			return ConstantValue.NO_URL;
		}
		String url = update_url;
		downloadStr = url;
		ConstantValue.update_control = update_control;

		// 判断环境
		if (Environment.getExternalStorageState().equals(
				Environment.MEDIA_MOUNTED)) {
			if (Build.VERSION.SDK_INT < Build.VERSION_CODES.GINGERBREAD) {
				// 使用原生态
				System.out.println("使用了原生态下载");
				orignDownload();
				return ConstantValue.SDCARD_SUCCESS;
			}
			SharedPreferences userInfo = Game.getInstance()
					.getSharedPreferences("downloadInfo", 0);
			// 下载服务的取得
			if (downloadManager == null) {
				downloadManager = (DownloadManager) Game.getInstance()
						.getSystemService(Game.DOWNLOAD_SERVICE);
				ConstantValue.downloadManager = downloadManager;
			}
			// 消息服务的取得
			if (notifyManager == null) {
				notifyManager = (NotificationManager) Game.getInstance()
						.getSystemService(Game.NOTIFICATION_SERVICE);
				ConstantValue.notifyManager = notifyManager;
			}
			Uri uri = Uri.parse(url);
			String fileName = url.substring(url.lastIndexOf("/") + 1);
			File file = new File(Environment.getExternalStorageDirectory()
					+ File.separator + Environment.DIRECTORY_DOWNLOADS
					+ File.separator + fileName);
			// 安装包是否已经下载完成
			if (file.exists() && (file.length() >= m_totalSize) && m_totalSize > 0) {
				Intent intent2 = new Intent(Intent.ACTION_VIEW);
				intent2.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				intent2.setDataAndType(Uri.fromFile(file), "application/vnd.android.package-archive");
				Game.getInstance().startActivity(intent2);
				return ConstantValue.SDCARD_SUCCESS;
			} 
			
			// 正在更新
			if (ConstantValue.isUpdating) {
				TreeMap<String, Object> map = new TreeMap<String, Object>();
				map.put("msg", "正在更新中");
				map.put("updateCode", 1);
				JsonUtil progressJson = new JsonUtil(map);
				final String errorStr = progressJson.toString();
				
				Game.getInstance().callLuaFunc(LuaCallManager.kUpdating, errorStr);
				
				return ConstantValue.ISUPDATING;
			}
			// 由于没有做断点功能，重新下载（在上次没下载完毕的时候，重启应用会出现）
			if( file.exists() )
				file.delete();
			ConstantValue.isUpdating = true;
			Request request = new Request(uri);
			request.setAllowedNetworkTypes(
					DownloadManager.Request.NETWORK_MOBILE
							| DownloadManager.Request.NETWORK_WIFI)
					.setAllowedOverRoaming(false)
					.setTitle("正在下载麻将全集")
					.setDescription(fileName)
					.setDestinationInExternalPublicDir(
							Environment.DIRECTORY_DOWNLOADS, fileName);
			mDownloadId = downloadManager.enqueue(request);
			ConstantValue.mDownloadId = mDownloadId;
			userInfo.edit().putLong("downloadInfo", mDownloadId).commit();
			
			TreeMap<String, Object> map = new TreeMap<String, Object>();
			map.put("msg", "开始下载更新包");
			map.put("updateCode", 1);
			JsonUtil progressJson = new JsonUtil(map);
			Game.getInstance().callLuaFunc(LuaCallManager.kUpdating, progressJson.toString());
			
			startQuery(mDownloadId);
			return ConstantValue.SDCARD_SUCCESS;
		} else {
			ConstantValue.isUpdating = false;
			return ConstantValue.NO_SDCARD;
		}
	}

	private void orignDownload() {
		Intent intent = new Intent(Intent.ACTION_VIEW);
		intent.setData(Uri.parse(downloadStr));
		intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		Game.getInstance().startActivity(intent);
		KeyDispose keyDispose = new KeyDispose();
		keyDispose.exit(LuaCallManager.KExit, "");
	}

	@SuppressLint("NewApi")
	private void executeRecord() {
		Cursor cursor = null;
		try {
			DownloadManager.Query query = new DownloadManager.Query()
					.setFilterById(mDownloadId);
			cursor = downloadManager.query(query);
			if (cursor != null && cursor.moveToFirst()) {
				m_downloadSize = cursor
						.getInt(cursor
								.getColumnIndexOrThrow(DownloadManager.COLUMN_BYTES_DOWNLOADED_SO_FAR));
				m_totalSize = cursor
						.getInt(cursor
								.getColumnIndexOrThrow(DownloadManager.COLUMN_TOTAL_SIZE_BYTES));
				if (m_downloadSize > m_totalSize) {
					m_downloadSize = m_totalSize;
				}
				Message msg = new Message();
				msg.what = UPDATE_VERSION_RUNNING;
				mhandler.sendMessage(msg);
			}

		} finally {
			if (cursor != null) {
				cursor.close();
				cursor = null;
			}

		}
	}

	private class QueryRunnable implements Runnable {
		public long DownId;

		@Override
		public void run() {
			queryState(DownId);
			mhandler.postDelayed(runnable, step);
		}
	}

	private void startQuery(long downloadId) {
		if (downloadId != 0) {
			runnable.DownId = downloadId;
			mhandler.postDelayed(runnable, step);
		}
	}

	@SuppressLint("NewApi")
	private void queryState(long downId) {
		Cursor cursor = downloadManager.query(new DownloadManager.Query()
				.setFilterById(downId));
		if (cursor == null) {
			ConstantValue.isUpdating = false;
			return;
		} else {
			if (!cursor.moveToFirst()) {
				cursor.close();
				return;
			}
		}
		if (cursor != null) {
			try {
				int st = cursor.getInt(cursor.getColumnIndex(DownloadManager.COLUMN_STATUS));
				if (DOWNLOAD_SUCCESSFUL.equals(statusMessage(st))) {
					return;
				}
				if (!DOWNLOAD_RUNNING.equals(statusMessage(st))
						&& DOWNLOAD_SUCCESSFUL.equals(statusMessage(st))) {
					Toast.makeText(Game.getInstance().getApplicationContext(), statusMessage(st),
							Toast.LENGTH_LONG).show();
				}
			} finally {
				cursor.close();
			}
		}
	}

	private String statusMessage(int st) {
		switch (st) {
		case DownloadManager.STATUS_RUNNING:
			System.out.println("计算下载进度");
			executeRecord();
			return DOWNLOAD_RUNNING;
		case DownloadManager.STATUS_SUCCESSFUL:
			return DOWNLOAD_SUCCESSFUL;
		}
		return "其他错误";
	}
}
