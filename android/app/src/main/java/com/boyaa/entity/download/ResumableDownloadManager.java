package com.boyaa.entity.download;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.util.Log;

import com.boyaa.entity.common.utils.JsonUtil;
import com.boyaa.hallgame.Game;


import java.io.File;
import java.util.HashMap;
import java.util.TreeMap;

/**
 * A manager that is in charge of download operations including launch new
 * download task, query download status, delete task.
 *
 * @author HuapingLi
 *
 */
public class ResumableDownloadManager {
	public static final String TAG = ResumableDownloadManager.class
			.getSimpleName();

	// Statuses for download task
	public static final int DOWNLOAD_STATUS_NOT_STARTED = 0;
	public static final int DOWNLOAD_STATUS_DOWNLOADING = 1;
	public static final int DOWNLOAD_STATUS_PAUSED = 2;
	public static final int DOWNLOAD_STATUS_FINISHED = 3;

	// Task info is saved in SharedPreferences
	private static final String SHARED_PREFERENCE_NAME = TAG;

	private static final String DOWNLOAD_DIR = "updateAPK";

	// A HashMap that keeps references to alive download tasks
	private HashMap<String, ResumableDownloadTask> mAliveTaskMap = new HashMap<String, ResumableDownloadTask>();

	private Context mContext;

	private static ResumableDownloadManager sInstance = null;

	private ResumableDownloadManager(Context context) {
		mContext = context;
	}

	public static ResumableDownloadManager getInstance() {
		if (sInstance == null) {
			sInstance = new ResumableDownloadManager(Game.getInstance());
		}

		return sInstance;
	}

	public boolean launchNewDownloadTask(String url) {
		// if a task instance is already in the map, return
		if (mAliveTaskMap.get(url) != null) {
			Log.d(TAG, "Jonathan: a task instance is already running. so do nothing and return");
			return false;
		}

		DownloadEventListener listener = new DownloadEventListener() {
			@Override
			public void onStart(final String url) {
				Log.d("zyh", "downloadTask start " + url);
				TreeMap<String, Object> map = new TreeMap<String, Object>();
				map.put("status", 0);
				map.put("url", url);
				final JsonUtil util = new JsonUtil(map);
				Game.getInstance().callLuaFunc("downloadApk", util.toString());
			}

			@Override
			public void onProgressUpdate(final String url, final int progress) {
//                Log.d("Ouyang", "launchNewDownloadTask onProgressUpdate：" + progress);
				Log.d("zyh", "downloadTask onProgressUpdate " + url + " progress " + progress);
				TreeMap<String, Object> map = new TreeMap<String, Object>();
				map.put("status", 1);
				map.put("url", url);
				map.put("progress", progress);
				final JsonUtil util = new JsonUtil(map);
				Game.getInstance().callLuaFunc("downloadApk", util.toString());
			}

			@Override
			public void onPause(final String url) {
//                Log.d("Ouyang", "launchNewDownloadTask onPause：" + url);
				Log.d("zyh", "downloadTask onPause " + url);
				TreeMap<String, Object> map = new TreeMap<String, Object>();
				map.put("status", 2);
				map.put("url", url);
				final JsonUtil util = new JsonUtil(map);
				Game.getInstance().callLuaFunc("downloadApk", util.toString());
			}

			@Override
			public void onFinish(final String url, final String fileName) {
//                Log.d("Ouyang", "launchNewDownloadTask onFinish：" + url);
				Log.d("zyh", "downloadTask onFinish " + url + " fileName " + fileName);
				TreeMap<String, Object> map = new TreeMap<String, Object>();
				map.put("status", 3);
				map.put("url", url);
				map.put("fileName", fileName);
				final JsonUtil util = new JsonUtil(map);
				Game.getInstance().callLuaFunc("downloadApk", util.toString());
			}

			@Override
			public void onError(final String url, final int errorCode) {
//                Log.d("Ouyang", "launchNewDownloadTask onError：" + errorCode);
				Log.d("zyh", "downloadTask onError " + url + " errorCode " + errorCode);
				TreeMap<String, Object> map = new TreeMap<String, Object>();
				map.put("status", 4);
				map.put("url", url);
				map.put("errorCode", errorCode);
				final JsonUtil util = new JsonUtil(map);
				Game.getInstance().callLuaFunc("downloadApk", util.toString());
			}
		};

		ResumableDownloadTask task = new ResumableDownloadTask();
		task.execute(url, listener);
		mAliveTaskMap.put(url, task);

		return true;
	}

	private String getFileNameFromUrl(String url) {
		String[] splitParts = url.split("/");
		String fileName = splitParts[splitParts.length - 1];
		return fileName;
	}

	public boolean pauseDownloadTask(String url) {

		// to pause is to terminate task, to resume is to launch a new one
		ResumableDownloadTask task = mAliveTaskMap.get(url);
		if (task != null) {
			task.stop();
			mAliveTaskMap.remove(url);
			return true;
		} else {
			return false;
		}

	}

	public int queryDownloadStatus(String url) {
		SharedPreferences sharedPreferences = mContext.getSharedPreferences(
				SHARED_PREFERENCE_NAME, Context.MODE_PRIVATE);
		
		long fileSize = sharedPreferences.getInt(url, 0);
		long downloadedLen = ResumableDownloadManager.getInstance().queryDownloadedLength(url);
		
		Log.d(TAG, "Jonathan: fileSize = " + fileSize + ", downloadedLen = " + downloadedLen);
		
		if (fileSize == 0) {
			
			// delete file. 重置应用数据的时候会导致这种情况，fileSize为0而已经下载的size不为0
			String fileName = getFileNameFromUrl(url);
			File file = new File(getDownloadDir() + fileName);
			file.delete();
			
			return DOWNLOAD_STATUS_NOT_STARTED;
		} else if (fileSize == downloadedLen) {
			return DOWNLOAD_STATUS_FINISHED;
		} else {
			return DOWNLOAD_STATUS_PAUSED;
		}
	}

	public int queryDownloadProgress(String url) {

		// if it is a not-started task, return 0
		if (queryDownloadStatus(url) == DOWNLOAD_STATUS_NOT_STARTED) {
			return 0;
		} else {
			// get file size
			SharedPreferences sharedPreferences = mContext
					.getSharedPreferences(SHARED_PREFERENCE_NAME,
							Context.MODE_PRIVATE);
			long fileSize = sharedPreferences.getInt(url, 0);
			if (fileSize == 0) {
				return 0;
			}
			
			// get length of downloaded bytes
			long downloadedBytes = queryDownloadedLength(url);
			
			int progress = (int) (downloadedBytes * 100 / fileSize);
			
			return progress;
		}
	}

	protected long queryDownloadedLength(String url) {
		long downloadedBytes = 0;
		String fileName = getFileNameFromUrl(url);
		File file = new File(getDownloadDir() + fileName);
		if (!file.exists()) {
			return 0;
		} else {
			downloadedBytes = file.length();
		}
		Log.d("Ouyang","queryDownloadedLength fileName:"+fileName);
		Log.d("Ouyang","queryDownloadedLength downloadedBytes:"+downloadedBytes);
		return downloadedBytes;
	}

	public boolean deleteDownloadTask(String url) {
		// delete task
		mAliveTaskMap.remove(url);
		
		// delete file
		String fileName = getFileNameFromUrl(url);
		File file = new File(getDownloadDir() + fileName);
		file.delete();
		
		// delete info
		SharedPreferences preferences = mContext.getSharedPreferences(
				SHARED_PREFERENCE_NAME, Context.MODE_PRIVATE);
		Editor editor = preferences.edit();
		editor.remove(url);
		editor.commit();
		
		return true;
	}

	public static abstract class DownloadEventListener {

		public abstract void onStart(String url);

		public abstract void onPause(String url);

		public abstract void onProgressUpdate(String url, int progress);

		public abstract void onFinish(String url, String mFileName);
		
		public abstract void onError(String url, int errorCode);
	}

	/**
	 * callback exposed to ResumableDownloadTask
	 * 
	 * @param url
	 * @param mFileSize
	 * 之所以要保存这个文件长度，仅仅是为了能够让lua层能够快速的查询文件下载进度，如果不保存的话，每次lua层来查询文件下载进度时，都要
	 * 去网络上要文件的长度，那么就不能做到同步调用了。每次下载的时候使用的文件长度不是从这里取的，而是动态从网上获取。所以这里的文件长度
	 * 只给查询文件下载状态或者进度时使用。
	 */
	protected void onFileSize(String url, long mFileSize) {
		SharedPreferences sharedPreferences = mContext.getSharedPreferences(
				SHARED_PREFERENCE_NAME, Context.MODE_PRIVATE);

		if (sharedPreferences.getInt(url, 0) == 0) {
			Editor editor = sharedPreferences.edit();
			editor.putInt(url, (int) mFileSize);
			editor.commit();
		}
	}

	/**
	 * callback exposed to ResumableDownloadTask
	 * 
	 * @param url
	 */
	protected void onDownloadTaskFinish(String url) {
		mAliveTaskMap.remove(url);
	}

	public String getDownloadDir() {
		File file = mContext.getExternalFilesDir(null);
		
		// take care! External Storage could be not mounted yet
		if (file == null) {
			return null;
		}
		// make sure that directory exists
		String path = Game.getInstance().getUpdateApkPath();
		File dir = new File(path);

		if (!dir.exists()) {
			dir.mkdirs();
		}
		
		return path;
	}
}
