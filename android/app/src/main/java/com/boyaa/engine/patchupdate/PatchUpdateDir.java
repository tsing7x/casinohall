package com.boyaa.engine.patchupdate;

import java.io.File;

import com.boyaa.engine.made.Dict;

/**
 * 此类用途：创建合并生成的新apk目录<br/>
 * 使用说明：<br/>
 *     调用createDir()方法前需要Lua传以下参数：<br/>
	   Dict.setString("patchUpdate", "dirPath" , value); --patch全路径<br/>
 */
public class PatchUpdateDir {

	private final static String kstrDictName = "patchUpdate";//本地数据Dict名字
	private final static String kdirPath = "dirPath";//获取patch目录的本地数据Dict key变量名
	
	/**
	 *创建目录
	 */
	public static void createDir() {
		String patchDirPath = Dict.getString(kstrDictName, kdirPath);
		File dir = new File(patchDirPath);
		if (!dir.exists()) {
			dir.mkdirs();
		} else {
			delFileOneWeekAgo(dir);
		}
	}
	
	private static final long ONE_WEEK_MILLIS = 7 * 24 * 3600 * 1000;
	private static void delFileOneWeekAgo(File folder) {
		File[] files = folder.listFiles();
		if (files != null) {
			for (File file : files) {
				try {
					
					if (file.isFile() && file.exists()) {
						long afterModified = System.currentTimeMillis() - file.lastModified();
						if (afterModified > ONE_WEEK_MILLIS) {
							file.delete();
						}
					}
				} catch (Exception e) {
				}
			}
		}
	}
}
