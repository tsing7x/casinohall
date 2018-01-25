package com.boyaa.engine.patchupdate;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import com.boyaa.engine.made.AppActivity;
import com.boyaa.engine.made.Dict;
import com.boyaa.engine.made.Sys;

/**
 * 此类用途：<br/>
	 * 1.校验旧apk，patch文件和新apk<br/>
	 * 2.合并patch文件和旧apk，生成新apk<br/>
	 * 3.并输出结果回调Lua<br/>
	 * 使用说明：<br/>
		 * 1.调用Execute()方法前需要Lua传以下参数：<br/>
			   Dict.setString("patchUpdate", "patchPath" , value); --patch全路径<br/>
			   Dict.setString("patchUpdate", "newApkPath" , value);--生成新apk全路径<br/>
			   Dict.setString("patchUpdate", "patchMD5" , value);--patch文件MD5校验值<br/>
			   Dict.setString("patchUpdate", "newApkMD5" , value);--生成新apk的MD5校验值<br/>
		   2.输出结果回调Lua：<br/>
		                       回调数据：Dict.setInt("patchUpdate", "result", value); --回调lua数据.value=1表示生成新apk成功，value=-1表示生成新apk失败<br/>
		                      回调方法：Sys.callLua("event_merge_new_apk"); --回调lua方法：event_merge_new_apk<br/>
 */
public class ApkMerge implements Runnable{

	private final static String KEventResponse = "event_merge_new_apk";//回调Lua函数
	private final static String kstrDictName = "patchUpdate";//回调Lua数据Dict名字
	private final static String kpatchPath = "patchPath";//获取patch路径本地数据Dict key变量名
	private final static String knewApkPath = "newApkPath";//获取newApk路径本地数据Dict key变量名
	private final static String kpatchMD5 = "patchMD5";//获取patchMD5本地数据Dict key变量名
	private final static String knewApkMD5 = "newApkMD5";//获取newApkMD5本地数据Dict key变量名
	private final static String kIsVerifyMD5 = "isVerifyMD5";//获取isVerifyMD5本地数据Dict key变量名
	private final static String kResult = "result";//回调Lua结果设置本地数据key变量名
	private final static int kResultSuccess = 1;//成功状态值
	private final static int kCode = 0;//成功状态值
	private final static int kResultError = -1;//失败状态值 

	private String patchPath;
	private String newApkPath;
	private String patchMD5;
	private String newApkMD5;
	private int isVerifyMD5;
	private int result;
	
	/**
	 * 执行合并生成新apk
	 */
	public void Execute() {
		PatchUpdate.load();
		patchPath = Dict.getString(kstrDictName, kpatchPath);
		newApkPath = Dict.getString(kstrDictName, knewApkPath);
		patchMD5 = Dict.getString(kstrDictName, kpatchMD5);
		newApkMD5 = Dict.getString(kstrDictName, knewApkMD5);
		isVerifyMD5 = Dict.getInt(kstrDictName, kIsVerifyMD5,1);
		new Thread(this).start();
	}
	
	/**
	 * 执行合并生成新apk线程
	 */
	@Override
	public void run() {
		
		result = kResultSuccess;
		String sourceApkDir = AppActivity.getInstance().getApplicationContext().getPackageResourcePath();
		
		do {
			
			// 1.判断用户是不是已经合过一次包了
			File lastApk = new File(newApkPath);
			if (lastApk.exists()) {
				// 存在，验证md5
				if (isVerifyMD5() && MD5Util.verify(newApkPath, newApkMD5)) {
					// md5一致，说明确实合过，不用再合了
					result = kResultSuccess;
					chmod("777", newApkPath);
					break;
				}
			}
			lastApk = null;
			
			//2.找老的APK包
			File file = new File(sourceApkDir);
			if (!file.exists()) {
				result = kResultError;
				break;
			}
			File patchFile = new File(patchPath);
			if (!patchFile.exists()) {
				result = kResultError;
				break;
			}
			
			//3.执行命令打新包
			result=PatchUpdate.bspatchUpdate(sourceApkDir, newApkPath, patchPath);
			if(result != kCode){
				result = kResultError;
				break;
			}
			result = kResultSuccess;
	
			//4.新包是否存在
			File newApkFile = new File(newApkPath);
			if (!newApkFile.exists()) {
				result = kResultError;
				break;
			}
			
			//md5验证patch和newApk
			if(isVerifyMD5() && (!MD5Util.verify(patchPath, patchMD5) ||
					!MD5Util.verify(newApkPath, newApkMD5))){
				result = kResultError;
				break;
			}
			
			chmod("777", newApkPath);
			
		}while(false);
		
		AppActivity.getInstance().runOnLuaThread(new Runnable()
		{
			@Override
			public void run() {
				Dict.setInt(kstrDictName, kResult, result);
				Sys.callLua(KEventResponse);
			}
		});
	}
	
	/**
	 * 是否判断MD5值
	 */
	private boolean isVerifyMD5() {
		if(isVerifyMD5 == 0){
			return false;
		}
		return true;
	}
	
	/**
	 * 设置文件可读、写、运行权限
	 * @param permission 权限值
	 * @param path 本设置文件路径
	 */
	private void chmod(String permission, String path) {
		try {
			String command = "chmod " + permission + " " + path;
			Runtime runtime = Runtime.getRuntime();
			runtime.exec(command);
		} catch (Exception e) {
		}
	}
	
	/**
	 * 校验网络获取文件和合并文件是否正确
	 */
	private static class MD5Util {
		private final static String KEventResponse = "event_verify_md5";
		private final static String kstrDictName = "verifyMD5";
		private final static String kfilePath = "filePath";
		private final static String kfilePathCallback = "filePathCallback";
		private final static String kmd5 = "MD5";
		private final static String kResult = "result";//flag of finish status
		private final static int kResultSame = 1;//验证相同
		private final static int kResultDifference = -1;//验证不同或失败
		
		private static char hexDigits[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
		private static MessageDigest messagedigest = null;
		private static int result;
		static {
			try {
				messagedigest = MessageDigest.getInstance("MD5");
			} catch (NoSuchAlgorithmException e) {
			}
		}
		
		/**
		 * 验证lua传的文件和md5
		 */
		public static void startVerify(){
			final String filePath = Dict.getString(kstrDictName, kfilePath);
			String MD5 = Dict.getString(kstrDictName, kmd5);
		
			if(verify(filePath, MD5)){
				result = kResultSame;
			}else{
				result = kResultDifference;
			}
			AppActivity.getInstance().runOnLuaThread(new Runnable()
			{
				@Override
				public void run() {
					Dict.setInt(kstrDictName, kResult, result);
					Dict.setString(kstrDictName, kfilePathCallback, filePath);
					Sys.callLua(KEventResponse);
				}
			});
		}
		
		/**
		 * 验证文件和md5
		 * @param filepath 校验的文件路径
		 * @param md5 对比的MD5值
		 */
		public static boolean verify(String filepath, String md5) {
			try {
				File file = new File(filepath);
				if(!file.exists()){
					return false;
				}
				String md5Now = getFileMD5String(file);
				if (md5Now.equals(md5)) {
					return true;
				}
			} catch (Exception e) {
			}
			return false;
		}
		
		private static String getFileMD5String(File file) throws IOException {
			InputStream fis;
			fis = new FileInputStream(file);
			byte[] buffer = new byte[1024];
			int numRead = 0;
			while ((numRead = fis.read(buffer)) > 0) {
				messagedigest.update(buffer, 0, numRead);
			}
			fis.close();
			return bufferToHex(messagedigest.digest());
		}
		
		private static String bufferToHex(byte bytes[]) {
			return bufferToHex(bytes, 0, bytes.length);
		}
		
		private static String bufferToHex(byte bytes[], int m, int n) {
			StringBuffer stringbuffer = new StringBuffer(2 * n);
			int k = m + n;
			for (int l = m; l < k; l++) {
				appendHexPair(bytes[l], stringbuffer);
			}
			return stringbuffer.toString();
		}
		
		private static void appendHexPair(byte bt, StringBuffer stringbuffer) {
			char c0 = hexDigits[(bt & 0xf0) >> 4];// 取字节中高 4 位的数字转换
			// 为逻辑右移，将符号位一起右移,此处未发现两种符号有何不同
			char c1 = hexDigits[bt & 0xf];// 取字节中低 4 位的数字转换
			stringbuffer.append(c0);
			stringbuffer.append(c1);
		}
	}
}
