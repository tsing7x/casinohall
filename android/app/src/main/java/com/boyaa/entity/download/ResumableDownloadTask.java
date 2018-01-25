package com.boyaa.entity.download;

import android.os.AsyncTask;
import android.os.Environment;
import android.util.Log;
import android.webkit.URLUtil;

import com.boyaa.entity.common.utils.UtilTool;
import com.boyaa.entity.download.ResumableDownloadManager.DownloadEventListener;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.RandomAccessFile;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

public class ResumableDownloadTask extends AsyncTask<Object, Long, Integer> {
	
	public static final String TAG = ResumableDownloadTask.class.getSimpleName();
	
	public static final String PARAM_TAG_URL = "url";
	public static final String PARAM_TAG_LISTENER = "listener";
	
	private static final int NOTIFY_LISTENER_THRESHOLD = 100 * 1024;

	private static final int RECONNECT_TIMEOUT = 6 * 1000;
	
	private static final int RET_CODE_NETWORK_ERROR = -5;
	
	private static final int RET_CODE_FILE_IO_ERROR = -4;
	
	private static final int RET_CODE_NO_SDCARD = -3;
	
	private static final int RET_CODE_OTHER_ERROR = -2;

	private static final int RET_CODE_ALREADY_DONE = -1;

	private static final int RET_CODE_PAUSED = 0;
	
	private static final int RET_CODE_FINISHED = 1;

	private boolean mContinuable = true;
	
	private String mUrl;
	private DownloadEventListener mDownloadEventListener;
	
	private long mFileSize = 0;
	private int mStep = 0;

	private long mDownloadedBytes = 0;

	private String mFileName;
	
	
	/**
	 * first is url
	 * second is listener
	 */
	@Override
	protected Integer doInBackground(Object... params) {
		mUrl = (String) params[0];
		mDownloadEventListener = (DownloadEventListener) params[1];
		mFileName = getFileNameFromUrl(mUrl);
		
		Log.d(TAG, "Jonathan: mUrl = " + mUrl);	
		return doDownload();
	}
	
	

	@Override
	protected void onPostExecute(Integer result) {
		super.onPostExecute(result);
		
		if (mDownloadEventListener != null) {
			if (result == RET_CODE_FINISHED || result == RET_CODE_ALREADY_DONE) {
				mDownloadEventListener.onProgressUpdate(mUrl, 100);
				mDownloadEventListener.onFinish(mUrl, mFileName);
			} else if (result == RET_CODE_PAUSED) {
				mDownloadEventListener.onPause(mUrl);
			} else {
				mDownloadEventListener.onError(mUrl, (int)result);
			}
		}

		// notify the manager to remove task reference
		ResumableDownloadManager.getInstance().onDownloadTaskFinish(mUrl);
	}



	@Override
	protected void onProgressUpdate(Long... values) {
		super.onProgressUpdate(values);
		Log.d(TAG, "Jonathan: downloadedBytes = " + values[0]);
		Log.d(TAG, "Jonathan: mFileSize = " + mFileSize);
		
		if (mFileSize != 0) {
			
			long downloadedSize = values[0];
			long tmp = downloadedSize * 100;
			
			int progress = (int) (tmp / mFileSize);
			
			if (mDownloadEventListener != null) {
				mDownloadEventListener.onProgressUpdate(mUrl, progress);
			}
		}
	}

	/**
	 *  
	 * @return -1 for already finished, 0 for paused, 1 for normally done
	 */
	private int doDownload() {
		
		// Fetch file length everytime the task is launched and update the file length in the shared preference 
		HttpURLConnection connection = null;
		try {
			URL url = new URL(mUrl);
			connection = (HttpURLConnection) url.openConnection();
			connection.setConnectTimeout(RECONNECT_TIMEOUT);
			connection.setRequestProperty("Accept-Encoding", "identity");
			connection.setRequestProperty("Range", "bytes=" + 0 + "-");
			connection.connect();
			
			mFileSize = connection.getContentLength();
			
			Log.d(TAG, "Jonathan: mFileSize is obtained. mFileSize = " + mFileSize);
			if (mFileSize <= 0) {
				return RET_CODE_NETWORK_ERROR;
			}
			
			ResumableDownloadManager manager = ResumableDownloadManager.getInstance();
			if (manager != null) {
				manager.onFileSize(mUrl, mFileSize);
			}
		} catch (MalformedURLException e1) {
			e1.printStackTrace();
			return RET_CODE_NETWORK_ERROR;
		} catch (IOException e) {
			e.printStackTrace();
			return RET_CODE_NETWORK_ERROR;
		} finally {
			if (connection != null) {
				connection.disconnect();
			}
		}
		
		mDownloadedBytes = 0;
		mDownloadedBytes = (int) ResumableDownloadManager.getInstance()
				.queryDownloadedLength(mUrl);
		Log.d("Ouyang", "1Starting mDownloadedBytes is " + mDownloadedBytes);

		Log.d(TAG, "Jonathan: Starting mDownloadedBytes is " + mDownloadedBytes);

		// if it has already been downloaded
		if (mFileSize == mDownloadedBytes) {
			Log.d(TAG, "Jonathan: Already finished!");
			return RET_CODE_ALREADY_DONE;
		} else if (mFileSize < mDownloadedBytes) {
			Log.d(TAG, "Jonathan: mFileSize is less than mDownloadedBytes. It's an error");
			return RET_CODE_OTHER_ERROR;
		}
		
		if (mDownloadEventListener != null) {
			mDownloadEventListener.onStart(mUrl);
		}
		
		HttpURLConnection conn = null;
		InputStream is = null;
		try {
			URL myUrl = new URL(mUrl);
			Log.d("Ouyang", "2Starting mDownloadedBytes is " + mDownloadedBytes);
			conn = (HttpURLConnection) myUrl.openConnection();
			conn.setConnectTimeout(RECONNECT_TIMEOUT);
			conn.setRequestProperty("Range", "bytes=" + mDownloadedBytes + "-");
			conn.setDoInput(true);
			conn.connect();
			
			if (!Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
				Log.d(TAG, "Jonathan: SD card not mounted");
				return RET_CODE_NO_SDCARD;
			}

			String dir = ResumableDownloadManager.getInstance().getDownloadDir();
			String filePath = dir + mFileName;
			File file = new File(filePath);
			if (!file.exists()) {
				try {
					file.createNewFile();
				} catch (IOException e) {
					e.printStackTrace();
					return RET_CODE_FILE_IO_ERROR;
				}
			}
			RandomAccessFile randomFile = new RandomAccessFile(file, "rw");
			randomFile.seek(mDownloadedBytes);
			Log.d("Ouyang", "3Starting mDownloadedBytes is " + mDownloadedBytes);
			
			byte[] temp = new byte[1024];
			int i = 0;
			is = conn.getInputStream();
			while ((i = is.read(temp)) > 0) {
				try {
					randomFile.write(temp, 0, i);
				} catch (IOException e) {
					e.printStackTrace();
					return RET_CODE_FILE_IO_ERROR;
				}
				mDownloadedBytes += i;
				mStep += i;
				
				// notify the listeners of the progress if the threshold is reached
				if (mStep >= NOTIFY_LISTENER_THRESHOLD) {
					mStep = 0;
					onProgressUpdate(mDownloadedBytes);
				}
				
				synchronized (this) {
					if (!mContinuable) {
						Log.d(TAG, "Jonathan: task stopped");
						return RET_CODE_PAUSED;
					}
				}
			}
			randomFile.close();
			is.close();
			conn.disconnect();
			
		} catch (MalformedURLException e) {
			e.printStackTrace();
			return RET_CODE_OTHER_ERROR;
		} catch (FileNotFoundException e) {
			e.printStackTrace();
			return RET_CODE_FILE_IO_ERROR;
		} catch (IOException e) {
			e.printStackTrace();
			return RET_CODE_NETWORK_ERROR;
		} finally {
			if (conn != null) {
				conn.disconnect();
			}
			
			try {
				if (is != null) {
					is.close();
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		
		return RET_CODE_FINISHED;
	}

	private String getFileNameFromUrl(String url) {
		String fileName = URLUtil.guessFileName(url, null, null);
		
		if (fileName == null || fileName.equals("")) {
			fileName = UtilTool.encodeString(UtilTool.MD5, url);
		}
		
		return fileName;
	}
	
	public void stop() {
		
		Log.d(TAG, "Jonathan: in stop. trying to stop task");
		
		synchronized (this) {
			mContinuable = false;
		}
	}

}
