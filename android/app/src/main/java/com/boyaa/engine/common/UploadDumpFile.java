package com.boyaa.engine.common;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import android.content.Context;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.Log;

import com.boyaa.engine.made.AppActivity;
import com.boyaa.engine.made.Sys;

/**
 * 上传dump文件类.<br/>
 * dump文件是应用crash后生成的日志文件，用于排查问题。
 */
public class UploadDumpFile implements Runnable{

	//TAG
	private static final String TAG = "UploadDumpFile";
	/*dump 上传压缩格式*/
	private static final String kFileSuffix=".zip";
	/*dump 上传url地址*/
	private static final String URL = "http://mvusspus01.boyaagame.com/report3.php";
	/*dump 集合*/
	private List<String> dumps = new ArrayList<String>();
	private String filePath;
	private int count502 = 0;
	private AppActivity mAppActivity;
	private static UploadDumpFile mUploadDumpFile;
	private String appid;
	/**
	 * 上传dump文件类 构造函数
	 * @param appActivity activity
	 */
	public UploadDumpFile(){
		
	}
	
	/**
	 * 获取单例UploadDumpFile 对象
	 * @param appActivity activity
	 */
	public static UploadDumpFile getInstance() {
		if(null == mUploadDumpFile){
			mUploadDumpFile = new UploadDumpFile();
		}
		return mUploadDumpFile;
	}
	
	
	/**
	 * 执行上传dump文件
	 * @param AppActivity activity
	 * @param String appid 项目对应id
	 */
	public void execute(AppActivity appActivity , String appid){
		this.mAppActivity = appActivity;
		this.appid = appid;
		if(null == appid || appid.equals("")) return;
		if(!isWifi()) return;
		filePath = getDumpPath(Sys.getString("storage_outer_root"));
		if (filePath != null && !filePath.equals("")) {
			new Thread(this).start();
		}
	}
	
	
	/**
	 * 执行上传dump文件线程
	 */
	@Override
	public void run() {
		String zipFilePath = getZipFilePath(filePath);
		String zipResult = zipFile(filePath, zipFilePath);
		if(null == zipResult){
			return;
		}
		upload(zipFilePath);
		deleteFile(zipFilePath);
	}
	
	/**
	 * 上传到指定的网络地址
	 * @param zipPath
	 */
	private void upload(String zipPath) {
		HttpURLConnection connection = null;
		int bytesAvailable;
		int bufferSize;
		byte[] buffer;
		int maxBufferSize = 1 * 1024 * 1024;
		DataOutputStream outStream = null;
		FileInputStream fStream = null;
		BufferedReader bufferedReader = null;
		InputStream inStream = null;
		try {
			fStream = new FileInputStream(zipPath);
			PackageManager pm = AppActivity.getInstance().getApplicationContext().getPackageManager(); 
			String pkgName = AppActivity.getInstance().getApplicationContext().getPackageName();
			String version  = pm.getPackageInfo(pkgName, 0).versionName;
			String appName = (String) pm.getApplicationLabel(pm.getApplicationInfo(pkgName, 0));
			appName = URLEncoder.encode(appName, "UTF-8");
			String urlStr = URL + "?version=" + version +"&appid=" + this.appid +"&project_name=" + appName;
			Log.i(TAG, "请求url:" + urlStr );
			URL url = new URL(urlStr);
			connection = (HttpURLConnection) url.openConnection();
			connection.setConnectTimeout(500);
			connection.setReadTimeout(500);
			connection.setDoInput(true);
			connection.setDoOutput(true);
			connection.setUseCaches(false);
			connection.setRequestMethod("POST");
			connection.setRequestProperty("Connection", "Keep-Alive");
			outStream = new DataOutputStream(connection.getOutputStream());
			bytesAvailable = fStream.available();
			Log.i(TAG , "文件大小：" + bytesAvailable);
			bufferSize = Math.min(bytesAvailable, maxBufferSize);
			buffer = new byte[bufferSize];
			while (fStream.read(buffer, 0, bufferSize) > 0) {
				outStream.write(buffer, 0, bufferSize);
				bytesAvailable = fStream.available();
				bufferSize = Math.min(bytesAvailable, maxBufferSize);
			}
			long startTime = System.nanoTime(); 
			outStream.flush();
			Log.i(TAG, "向服务器写数据完成");
			int code = connection.getResponseCode();
			long consumingTime = System.nanoTime() - startTime;
			Log.i(TAG, "上传文件服务器返回 responseCode：" + code + ",耗时：" + consumingTime/1000000 + "ms");
			if (code == HttpURLConnection.HTTP_OK) {
				StringBuilder response = new StringBuilder();
				inStream = connection.getInputStream();
				bufferedReader = new BufferedReader(
						new InputStreamReader(inStream));
				String line = "";
				while ((line = bufferedReader.readLine()) != null) {
					response.append(line);
				}
				connection.disconnect();
				Log.i(TAG, "response : " + response);
				if (response.toString().equals("1") || response.toString().equals("1-1")){
					for (String dump : dumps) {
						deleteFile(dump);
					}
					dumps.clear();
				}
			}else if(code == HttpURLConnection.HTTP_BAD_GATEWAY) {
				Log.i(TAG, "502times:" + count502);
				if (count502 == 3){
					return;
				}
				count502 += 1;
				upload(zipPath);
			}
		} catch (Exception e) {
			Log.e(TAG, e.toString());
		} finally {
			if(null != outStream){
				try {
					outStream.close();
				} catch (IOException e) {
					Log.i(TAG, "e : " + e.toString());
				}
			}
			
			if(null != fStream){
				try {
					fStream.close();
				} catch (IOException e) {
					Log.i(TAG, "e : " + e.toString());
				}
			}
			
			if(null != bufferedReader){
				try {
					bufferedReader.close();
				} catch (IOException e) {
					Log.i(TAG, "e : " + e.toString());
				}
			}
			
			if(null != inStream){
				try {
					inStream.close();
				} catch (IOException e) {
					Log.i(TAG, "e : " + e.toString());
				}
			}
			
		}
	}
	
	/**
	 * 获取zip压缩文件
	 * @param filePath 文件路径
	 * @return 压缩文件路径
	 */
	private String getZipFilePath(String filePath){
		return getFilePathPrefix(filePath) + kFileSuffix;
	}
	
	/**
	 * 获取dump文件名
	 * @param filePath 文件路径
	 * @return dump文件名
	 */
	private String getFilePathPrefix(String filePath){
		String filePathPrefix = "";
		int lenPrefix = filePath.lastIndexOf(".");
		if (lenPrefix != -1) {
			filePathPrefix = filePath.substring(0, lenPrefix);
		} else {
			Log.i(TAG, "文件名异常 filePath:" + filePath);
		}
		return filePathPrefix;
	}
	
	/**
	 * 获取dump文件后缀
	 * @param filePath 文件路径
	 * @return dump文件后缀
	 */
	private String getFilePathSuffix(String filePath){
		String filePathPrefix = "";
		int lenPrefix = filePath.lastIndexOf(".");
		if (lenPrefix != -1) {
			filePathPrefix = filePath.substring(lenPrefix, filePath.length());
		} else {
			Log.i(TAG, "文件名异常 filePath:" + filePath);
		}
		return filePathPrefix;
	}
	
	/**
	 * 获取zip文件名
	 * @param filePath 文件路径
	 * @return zip文件名
	 */
	@SuppressWarnings("unused")
	private String getZipFileName(String filePath){
		String filePath2 = getFilePathPrefix(filePath);
		int fileIndexOf = filePath2.lastIndexOf("/");
		String fileName = "";
		if (fileIndexOf != -1){
			fileName = filePath2.substring(fileIndexOf+1) + kFileSuffix;
		}else {
			Log.i(TAG, "文件名异常 filePath:" + filePath);
		}
		return fileName;
	}
	
	/**
	 * 把dump打成zip包
	 * @param filePath dump文件路径 ，zipFilePath 压缩文件路径
	 * @return zip文件全路径
	 */
	private String zipFile(String filePath ,String zipFilePath) {
		File file = new File(filePath);
		FileInputStream fis;
		try {
			fis = new FileInputStream(file);
			BufferedInputStream bis = new BufferedInputStream(fis);
			byte[] buf = new byte[1024];
			int len;
			FileOutputStream fos = new FileOutputStream(zipFilePath);
			BufferedOutputStream bos = new BufferedOutputStream(fos);
			ZipOutputStream zos = new ZipOutputStream(bos);// 压缩包
			ZipEntry ze = new ZipEntry(file.getName());// 这是压缩包名里的文件名
			zos.putNextEntry(ze);// 写入新的 ZIP 文件条目并将流定位到条目数据的开始处
			while ((len = bis.read(buf)) != -1) {
				zos.write(buf, 0, len);
				zos.flush();
			}
			bis.close();
			zos.close();
		} catch (FileNotFoundException e) {
			Log.i(TAG, e.toString());
			return null;
		} catch (IOException e) {
			Log.i(TAG, e.toString());
			return null;
		}
		return zipFilePath;
	}
	
	/**
	 * 获取最有一个dump文件路径
	 * @param path 所有dump文件(dump文件见用分号隔开)
	 * @return dump文件路径
	 */
	private String getDumpPath(String path) {
		if (path == null || path.equals(""))
			return null;
		File root = new File(path);
	    File[] files = root.listFiles();
	    if (files == null)
	    	return null;
	    for(File file:files){     
	    	if(file.isFile() && getFilePathSuffix(file.getAbsolutePath()).equals(".dmp")){
			  dumps.add(file.getAbsolutePath());
	    	}     
		 }
		return dumps.size() > 0 ? dumps.get(dumps.size() - 1) : "";
	}

	/**
	 * 删除文件
	 * @param filePath
	 * @return true 删除成功；false 删除失败
	 */
	private boolean deleteFile(String filePath)
	{
		File file=new File(filePath);
		if(file.exists())
		{
			return file.delete();
		}
		return false;
		
	}
	
	/**
	 * 判断是否是wifi网络
	 * @return true wifi网络；false 其他网络
	 */
	private boolean isWifi() {  
	    ConnectivityManager connectivityManager = (ConnectivityManager) this.mAppActivity  
	            .getSystemService(Context.CONNECTIVITY_SERVICE);  
	    NetworkInfo activeNetInfo = connectivityManager.getActiveNetworkInfo();  
	    if (activeNetInfo != null  
	            && activeNetInfo.getType() == ConnectivityManager.TYPE_WIFI) {  
	        return true;  
	    }  
	    return false;  
	}  
}
	
