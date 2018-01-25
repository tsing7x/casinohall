package com.boyaa.engine.common;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import com.boyaa.engine.made.AppActivity;
import com.boyaa.engine.made.Sys;

import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.util.Log;

public class ExternalStorage {
	
	private final static String TAG = "ExternalStorage";
	private static String storageRoot = getStorageUserRoot();

	private static boolean isFirstRun = isFirstRun();

	private static String getStorageUserRoot() {
		return Sys.getString("storage_outer_root");
	}

	private static boolean isFirstRun() {
		try {
			String pkgName = AppActivity.getInstance().getPackageName();
			PackageInfo info = AppActivity.getInstance().getPackageManager().getPackageInfo(pkgName, 0);
			int currentVersion = info.versionCode;
			int lastVersion = getLastVersionCode();
			if (currentVersion != lastVersion) {
				setCurrentVersionCode(currentVersion);
				return true;
			}
			return false;
		} catch (NameNotFoundException e) {
			e.printStackTrace();
			return false;
		}

	}

	// 不删除文件夹
	private static void deleteDir(String path) {
		File file = new File(path);
		if (file.exists() && file.isDirectory()) {
			File[] files = file.listFiles();
			for (int i = 0; i < files.length; i++) {
				doDeleteDir(files[i]);
			}
		}
	}

	private static void doDeleteDir(File dir) {
		if (!dir.exists())
			return;
		if (dir.isDirectory()) {
			File[] files = dir.listFiles();
			for (int i = 0; i < files.length; i++) {
				doDeleteDir(files[i]);
			}
		}
		dir.delete();
	}
	
	/**
	 * android下每次apk升级安装后第一次运行，清除旧版本apk在external storage上scripts文件，默认不清除
	 * @param isClear为true清除，false 不清除
	 */
	public static void clearStorageScriptsWhenAppInstall(boolean isClear) {
		if (isFirstRun && isClear) {
			deleteDir(storageRoot + "scripts");
		}
	}
	
	/**
	 * android下每次apk升级安装后第一次运行，清除旧版本apk在external storage上audio文件，默认不清除
	 * @param isClear为true清除，false 不清除
	 */
	public static void clearStorageAudioWhenAppInstall(boolean isClear) {
		if (isFirstRun && isClear) {
			deleteDir(storageRoot + "audio");
		}
	}
	
	/**
	 * android下每次apk升级安装后第一次运行，清除旧版本apk在external storage上fonts文件，默认不清除
	 * @param isClear为true清除，false 不清除
	 */
	public static void clearStorageFontsWhenAppInstall(boolean isClear) {
		if (isFirstRun && isClear) {
			deleteDir(storageRoot + "fonts");
		}
	}
	
	/**
	 * android下每次apk升级安装后第一次运行，清除旧版本apk在external storage上dic文件，默认不清除
	 * @param isClear为true清除，false 不清除
	 */
	public static void clearStorageDicWhenAppInstall(boolean isClear) {
		if (isFirstRun && isClear) {
			deleteDir(storageRoot + "dic");
		}
	}
	
	/**
	 * android下每次apk升级安装后第一次运行，清除旧版本apk在external storage上dict文件，默认不清除
	 * @param isClear为true清除，false 不清除
	 */
	public static void clearStorageDictWhenAppInstall(boolean isClear) {
		if (isFirstRun && isClear) {
			deleteDir(storageRoot + "dict");
		}
	}
	
	/**
	 * android下每次apk升级安装后第一次运行，清除旧版本apk在external storage上log文件，默认不清除
	 * @param isClear为true清除，false 不清除
	 */
	public static void clearStorageLogWhenAppInstall(boolean isClear) {
		if (isFirstRun && isClear) {
			deleteDir(storageRoot + "log");
		}
	}
	
	/**
	 * android下每次apk升级安装后第一次运行，清除旧版本apk在external storage上temp&tmp文件，默认不清除
	 * @param isClear为true清除，false 不清除
	 */
	public static void clearStorageTempWhenAppInstall(boolean isClear) {
		if (isFirstRun && isClear) {
			deleteDir(storageRoot + "temp"); // 清除老版本
			deleteDir(storageRoot + "tmp"); // 引擎3.0改为tmp
		}
	}
	
	/**
	 * android下每次apk升级安装后第一次运行，清除旧版本apk在external storage上user文件，默认不清除
	 * @param isClear为true删除，false 不清除
	 */
	public static void clearStorageUserWhenAppInstall(boolean isClear) {
		if (isFirstRun && isClear) {
			deleteDir(storageRoot + "user");
		}
	}
	
	/**
	 * android下每次apk升级安装后第一次运行，清除旧版本apk在external storage上images文件，默认不清除
	 * @param isClear为true清除，false 不清除
	 */
	public static void clearStorageImagesWhenAppInstall(boolean isClear) {
		if (isFirstRun && isClear) {
			deleteDir(storageRoot + "images");
		}
	}
	
	/**
	 * android下每次apk升级安装后第一次运行，清除旧版本apk在external storage上update文件，默认不清除
	 * @param isClear为true清除，false 不清除
	 */
	public static void clearStorageUpdateWhenAppInstall(boolean isClear) {
		if (isFirstRun && isClear) {
			deleteDir(storageRoot + "update");
		}
	}
	
	/*
	 * android下每次apk升级安装后第一次运行，清除旧版本apk在external storage上xml文件，默认不清除
	 * @param isClear为true清除，false 不清除
	 */
	public static void clearStorageXmlWhenAppInstall(boolean isClear) {
		if (isFirstRun && isClear) {
			deleteDir(storageRoot + "xml");
		}
	}
	
	public static void clearDirWhenAppInstall(String dirName) {
		if (isFirstRun) {
			deleteDir(storageRoot + dirName);
		}
	}


	// 读取文件中的版本号
	private static int getLastVersionCode() {
		File file = new File(storageRoot + ".version_code");
		FileReader fr = null;
		BufferedReader br = null;
		if (file.exists() && file.isFile()) {
			try {
				fr = new FileReader(file);
				br = new BufferedReader(fr);
				String line = br.readLine();
				return Integer.valueOf(line);
			} catch (Exception e) {
				e.printStackTrace();
			}finally {
				if(null != fr){
					try {
						fr.close();
					} catch (IOException e) {
						Log.e(TAG, e.toString());
					}
				}
				
				if(null != br){
					try {
						br.close();
					} catch (IOException e) {
						Log.e(TAG, e.toString());
					}
				}
			}
		}
		return 0;
	}

	//把新的版本号储存在文件中
	private static void setCurrentVersionCode(int code) {
		File file = new File(storageRoot + ".version_code");
		FileWriter fw = null;
		BufferedWriter bw = null;
		try {
			if (!file.exists()){
				file.createNewFile();
			}
			fw = new FileWriter(file);
			bw = new BufferedWriter(fw);
			bw.write(String.valueOf(code));
			bw.flush();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if(null != fw){
				try {
					fw.close();
				} catch (IOException e) {
					Log.e(TAG, e.toString());
				}
			}
			
			if(null != bw){
				try {
					bw.close();
				} catch (IOException e) {
					Log.e(TAG, e.toString());
				}
			}
		}
	}

}
