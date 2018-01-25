package com.boyaa.entity.common;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

import com.boyaa.hallgame.Game;
//import com.boyaa.made.AppActivity;

public class SDTools {

	public static final String PNG_SUFFIX = ".png";

	private static byte[] sync = new byte[0];

	// 保存png 图片
	public static boolean saveBitmap(Context context, String folder, String fileName, Bitmap bmp) {
		synchronized (sync) {

			if (null == fileName || 0 == fileName.length())
				return false;
			if (null == bmp)
				return false;
			if (bmp.isRecycled())
				return false;
			File file = new File(folder);
			if( !file.exists() ) file.mkdirs();
			
			if( !fileName.endsWith(PNG_SUFFIX) ) fileName = fileName + PNG_SUFFIX;
			// 生成新的
			File imageFile = new File(folder, fileName);
			try {
				imageFile.createNewFile();
			} catch (IOException e) {
				Log.e("SDTools", e.toString());
				return false;
			}
			FileOutputStream fOut = null;
			try {
				fOut = new FileOutputStream(imageFile);
			} catch (FileNotFoundException e) {
				Log.e("SDTools", e.toString());
				return false;
			}
			bmp.compress(Bitmap.CompressFormat.PNG, 100, fOut);
			try {
				fOut.flush();
				fOut.close();
				fOut = null;
			} catch (IOException e) {
				Log.e("SDTools", e.toString());
				return false;
			} finally {
				try {
					if (null != fOut)
						fOut.close();
				} catch (Exception e) {
					return false;
				}
			}
			return true;
		}
	}

	// 删除文件
	private static boolean deleteFile(String name) {
		File file = new File(name);
		if (file.exists()) {
			return file.delete();
		}
		return false;
	}

	/**
	 * sd卡是否可写
	 * 
	 * @return
	 */
	public static boolean isExternalStorageWriteable() {

		return Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED);
	}

	public static int imageIsExist(String folder, String path) {
		{
			File file = new File(Game.getInstance().getImagePath() + folder, path);
			if (null != file && file.exists() && file.canWrite() && file.isFile()) {
				System.out.println("图片名称" + path + "已经存在了");
				return 1;
			}
		}
		{
			File file = new File(Game.getInstance().getApkFilesPath() + "images/"+ folder, path);
			if (null != file && file.exists() && file.canWrite() && file.isFile()) {
				System.out.println("图片名称" + path + "已经存在了");
				return 1;
			}
		}
		
		
		return 0;
	}

	// url下载的地址 filepath 下载存放路径+名称
	public static void download(Activity activity, final String url, final String filePath, final ICallBackListener callBack, final Handler handler) {
		Log.i("downloadres", "url : " + url);
		Log.i("downloadres", "filePath : " + filePath);
		OnThreadTask ott = new OnThreadTask() {
			@Override
			public void onUIBackPressed() {
			}

			@Override
			public void onThreadRun() {
				try {
					URL uri = new URL(url);
					URLConnection urlConnection = uri.openConnection();
					urlConnection.connect();
					InputStream ins = urlConnection.getInputStream();
					int fileLength = urlConnection.getContentLength();
					int length = 512;
					byte[] buffer = new byte[length];
					int readNum;
					int downLength = 0;
					OutputStream os = new FileOutputStream(filePath);
					int arg1 = 0;
					int arg2 = 0;
					while ((readNum = ins.read(buffer, 0, length)) != -1) {
						if (handler != null) {
							downLength += readNum;
							arg2 = downLength * 100 / fileLength;
							if (arg2 > arg1) {
								arg1 = arg2;
								Message msg = new Message();
								msg.arg1 = arg2;
								handler.sendMessage(msg);
							}
						}
						os.write(buffer, 0, readNum);
					}
					os.close();
					ins.close();

				} catch (MalformedURLException e) {
					Log.i("downloadres", "onNetWorkError");
					callBack.onNetWorkError(e.getMessage());
				} catch (IOException e) {
					Log.i("downloadres", "onUserDefineError");
					callBack.onUserDefineError(0, e.getMessage());
				}
			}

			@Override
			public void onAfterUIRun() {
				File file = new File(filePath);
				if (file.exists()) {
					Log.i("downloadres", "onSucceed");
					callBack.onSucceed();
				} else {
					Log.i("downloadres", "onFailed");
					callBack.onFailed();
				}
			}

		};
		ThreadTask.start(activity, null, false, ott);
	}

	/**
	 * 判断SD卡是否存在
	 * 
	 * @return
	 */
	public static boolean isSDCardAvailable() {
		if (Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
			return true;
		}
		return false;
	}

	/** 获取外部存储根目录（mnt/sdcard） */
	public static String getExternalStorageRootDirectory() {
		return Environment.getExternalStorageDirectory().getAbsolutePath();
	}

	/** 如果不存在此目录便生成此目录 */
	public static void createDirectoryIfNotExist(String directoryPath) {
		File file = new File(directoryPath);
		if (file != null && !file.exists() || !file.isDirectory()) {
			file.mkdirs();
		}
	}

	/** 如果文件不存在，创建新文件 */
	public static File createFileIfNotExist(String filePath) throws IOException {
		File file = new File(filePath);
		if (file != null && !file.exists() || !file.isFile()) {
			file.createNewFile();
		}
		return file;
	}
}
