package com.boyaa.entity.images;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.Map;

import org.json.JSONException;
import org.json.JSONObject;

import android.os.AsyncTask;
import android.util.Log;

import com.boyaa.entity.common.utils.JsonUtil;
import com.boyaa.entity.php.PHPResult;
import com.boyaa.hallgame.Game;

public class UploadImage {	
	private static final String TAG = "UploadImage";
	
	public static void toUploadImage(final Game activity, final String imageName , final String api , final String url , final String strDicName, final int type, final String mid, final String sid, final String time, final String sig, final String upload) {
		Log.i(TAG, "toUploadImage");
		new AsyncTask<Void, Void, Void>() {
			private PHPResult uploadResult = new PHPResult();
			@Override
			protected Void doInBackground(Void... params) 
			{
				UploadImage.doUploadImage(imageName , url , api ,uploadResult, type, mid, sid, time, sig, upload);
				return null;
			}

			@Override
			protected void onPostExecute(Void var) 
			{
				super.onPostExecute(var);
				if (uploadResult.code == PHPResult.SUCCESS){
					JSONObject upResult = null;
					try {
						upResult = new JSONObject(uploadResult.json);
						String code = upResult.getString("code");
						String iconname = null;
						if (upResult.has("iconname")){
							iconname = upResult.getString("iconname");
						}

						Log.e(TAG, "code = " + code + ",iconname = " + iconname);
						Map<String, Object> jsonResult = new HashMap<String, Object>();
						jsonResult.put("code", code);
						jsonResult.put("iconname", iconname);
						final JsonUtil util = new JsonUtil(jsonResult);
						if(util != null)
						{
							Game.getInstance().callLuaFunc(strDicName, util.toString());
						}
						//AppActivity.getHandler().luaCallEvent(strDicName, uploadResult.json);
						Log.d("TAG", "uploadResult.json = " + uploadResult.json);
					} catch (JSONException e) {
						e.printStackTrace();
					}
				}else{
					Game.getInstance().callLuaFunc(strDicName, null);
				} 
			}
		}.execute();

	}
	
	/**
	 * 上传游客头像,完成之后，phpinfo中的icon,big,middle信息会更新，请做相应处理
	 * 
	 * @param filePath
	 * @return
	 */
//	@SuppressWarnings("rawtypes")
	public static boolean doUploadImage(String imageName,  String surl , String api , PHPResult result,int type, String mid, String sid, String time, String sig, String upload) {
		HttpURLConnection connection = null;
		DataOutputStream outStream = null;

		String lineEnd = "\r\n";
		String twoHyphens = "--";
		String boundary = "*****";

		int bytesRead, bytesAvailable, bufferSize;

		byte[] buffer;

		int maxBufferSize = 1 * 1024 * 1024;

		try {
			FileInputStream fileInputStream = null;
			try {
				String filePath = Game.getInstance().getImagePath() + imageName;
				File file = new File(filePath);
				Log.i(TAG, "file path：" + file.getAbsolutePath());
				fileInputStream = new FileInputStream(file);
				Log.i(TAG, "file size：" + fileInputStream.available());
			} catch (FileNotFoundException e) {
				Log.e("DEBUG", "[FileNotFoundException]");
				result.code = PHPResult.JSON_ERROR;
				return false;
			}
			Log.i(TAG, "url:" + surl);
			URL url = new URL(surl);
			connection = (HttpURLConnection) url.openConnection();
			connection.setConnectTimeout(10000);
			connection.setDoInput(true);
			connection.setDoOutput(true);
			connection.setUseCaches(false);

			connection.setRequestMethod("POST");
			connection.setRequestProperty("Connection", "Keep-Alive");
			connection.setRequestProperty("Content-Type",
					"multipart/form-data;boundary=" + boundary);

			outStream = new DataOutputStream(connection.getOutputStream());
//			String api = new PHPPost().getApi(new TreeMap(),METHOD_VISITOR_UPLOADICON);
			
			Log.i(TAG, "param：" + api);
			outStream.writeBytes(addParam("api", api, twoHyphens, boundary,lineEnd));
			outStream.writeBytes(addParam("mid", mid, twoHyphens, boundary,lineEnd));
			outStream.writeBytes(addParam("sid", sid, twoHyphens, boundary,lineEnd));
			outStream.writeBytes(addParam("time", time, twoHyphens, boundary,lineEnd));
			outStream.writeBytes(addParam("sig", sig, twoHyphens, boundary,lineEnd));
			//outStream.writeBytes(addParam("upload", upload, twoHyphens, boundary,lineEnd));
			outStream.writeBytes(twoHyphens + boundary + lineEnd);
			if (type == 1) {
				Log.i(TAG, "feedback");
				outStream.writeBytes("Content-Disposition: form-data; name=\"pfile\";filename=\"feedback.png"
								+ "\""
								+ lineEnd
								+ "Content-Type: "
								+ "application/octet-stream"
								+ lineEnd
								+ "Content-Transfer-Encoding: binary" + lineEnd);
			} else {
				Log.i(TAG, "user portrait");
				outStream.writeBytes("Content-Disposition: form-data; name=\"upload\";filename=\"icon.jpg"
								+ "\""
								+ lineEnd
								+ "Content-Type: "
								+ "application/octet-stream"
								+ lineEnd
								+ "Content-Transfer-Encoding: binary" + lineEnd);
			}
			outStream.writeBytes(lineEnd);

			bytesAvailable = fileInputStream.available();
			
			bufferSize = Math.min(bytesAvailable, maxBufferSize);
			buffer = new byte[bufferSize];

			bytesRead = fileInputStream.read(buffer, 0, bufferSize);

			while (bytesRead > 0) {
				Log.e("xxxxxx", "bytesRead = " + bytesRead );
				outStream.write(buffer, 0, bufferSize);
				bytesAvailable = fileInputStream.available();
				bufferSize = Math.min(bytesAvailable, maxBufferSize);
				bytesRead = fileInputStream.read(buffer, 0, bufferSize);
			}

			outStream.writeBytes(lineEnd);
			outStream.writeBytes(twoHyphens + boundary + twoHyphens + lineEnd);

			fileInputStream.close();
			outStream.flush();
			outStream.close();
			Log.i(TAG, "post data finish");
		} catch (MalformedURLException e) {
			result.code = PHPResult.JSON_ERROR;
			Log.e(TAG, "[MalformedURLException while sending a picture]");
			return false;
		} catch (IOException e) {
			result.code = PHPResult.JSON_ERROR;
			Log.e(TAG, "[IOException while sending a picture]");
			return false;
		}

		int responseCode;
		try {
			responseCode = connection.getResponseCode();
			StringBuilder response = new StringBuilder();
			Log.i(TAG, "上传图片，服务器返回：" + responseCode);
			if (responseCode == HttpURLConnection.HTTP_OK) {
				InputStream urlStream = connection.getInputStream();
				BufferedReader bufferedReader = new BufferedReader(
						new InputStreamReader(urlStream));
				String sCurrentLine = "";
				while ((sCurrentLine = bufferedReader.readLine()) != null) {
					response.append(sCurrentLine);
				}
				bufferedReader.close();
				Log.i(TAG, "读数据完成");
				connection.disconnect();
				Log.i(TAG, "结果：" + response.toString());
				result.code = PHPResult.SUCCESS;
				result.json = response.toString();
				return true;
			} else {
				result.code = PHPResult.NETWORK_ERROR;
			}
		} catch (IOException e) {
			e.printStackTrace();
			result.code = PHPResult.JSON_ERROR;
			Log.i(TAG, "读数据 IOException"+e.toString());
		}

		return false;
	}

	// 用当前时间给取得的图片命名
	public static String getImageName() {
		Date date = new Date(System.currentTimeMillis());
		SimpleDateFormat dateFormat = new SimpleDateFormat("'IMG'_yyyyMMdd_HHmmss");
		return dateFormat.format(date) + ".jpg";
	}
	
	private static final String addParam(String key, String value,
			String twoHyphens, String boundary, String lineEnd) {
		return twoHyphens + boundary + lineEnd
				+ "Content-Disposition: form-data; name=\"" + key + "\""
				+ lineEnd + lineEnd + value + lineEnd;
	}	
}
