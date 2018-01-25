package com.boyaa.engine.patchupdate;

import java.io.File;

import android.content.Intent;
import android.net.Uri;

import com.boyaa.engine.made.AppActivity;
import com.boyaa.engine.made.Dict;
import com.boyaa.engine.made.Sys;

/**
 * 此类用途：<br/>
 * 	  1.根据传入apk路径安装apk<br/>
 *    2.安装结果回调Lua：<br/>
 *      	回调数据： Dict.setInt("patchUpdate", "result", value); --回调lua数据.value=1表示安装apk成功，value=-1表示安装apk失败<br/>
 *      	回调方法：event_install_apk<br/>
 * 
 */
public class ApkInstall {
	
	private final static String KEventResponse = "event_install_apk";//回调Lua函数
	private final static String kstrDictName = "patchUpdate";//回调Lua数据Dict名字
	private final static String kResult = "result";//回调Lua数据key变量名
	private final static int kResultSuccess = 1;//成功状态值
	private final static int kResultError = -1;//失败状态值
	private int result;//结果状态值
	
	/**
	 * 执行安装apk
	 * @param apkFullPath apk全路径
	 */
	public void startInstall(String apkFullPath){
		result = kResultSuccess;
		File apkFile = new File(apkFullPath);
		if(apkFile.exists()){
			Intent intent = new Intent(Intent.ACTION_VIEW);
			intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			intent.setDataAndType(Uri.parse("file://" + apkFullPath),"application/vnd.android.package-archive");
			AppActivity.getInstance().startActivity(intent);
		}else{
			result = kResultError;
		}
		
		AppActivity.getInstance().runOnLuaThread(new Runnable()
		{
			@Override
			public void run() {
				Dict.setInt(kstrDictName, kResult, result);
				Sys.callLua(KEventResponse);
			}
		});
	}
	
}
