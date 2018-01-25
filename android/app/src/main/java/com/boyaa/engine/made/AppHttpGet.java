package com.boyaa.engine.made;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.ProtocolException;
import java.util.HashMap;

import org.apache.http.HttpHost;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.params.HttpClientParams;
import org.apache.http.conn.ConnectTimeoutException;
import org.apache.http.conn.params.ConnRoutePNames;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.CoreConnectionPNames;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;

import android.content.Context;
import android.os.Bundle;
import android.os.Message;
import android.text.TextUtils;


/**
 * 1.http get请求处理类<br/>
 * 2.本类只支持Lua http请求
 */
public class AppHttpGet implements Runnable {

	private static HashMap<Integer,Message> mMsgs = new HashMap<Integer,Message>();
	private static Object mSyncMsgs = new Object();
	public static void AddMsg ( int id, Message msg )
	{
		synchronized(mSyncMsgs)
		{
			mMsgs.put(id, msg);
		}
	}
	public static Message RemoveMsg ( int id )
	{
		Message msg = null;
		synchronized(mSyncMsgs)
		{
			if ( mMsgs.containsKey(id ))
			{
				msg = mMsgs.get(id);
				mMsgs.remove(id);
			}
		}
		return msg;
	}
	
	private final static int HTTP_REQUEST_FINISH = 3;//请求当前状态

	private final static String kHttpRequestExecute = "http_request_execute";//获取id的dict名字
	private final static String kHttpResponse = "http_response";//设置id的dict名字
	private final static String KEventPrefix = "event_http_response";//回调lua的默认方法
	private final static String KEventPrefix_ = "event_http_response_";//回调lua的指定方法前缀
	private final static String kId = "id";//dict id key的变量名
	private final static String kStep = "step";//dict 请求当前状态 key的变量名
	private final static String kUrl = "url";//dict url key的变量名
	private final static String kData = "data";//data url key的变量名
	private final static String kTimeout = "timeout";//dict 超时时间  key的变量名
	private final static String kEvent = "event";//回调lua的指定方法后缀
	private final static String kAbort = "abort";//无用
	private final static String kError = "error";//请求完成类型，0--成功；1--失败
	private final static String kCode = "code";//请求http状态码，200--请求成功，其余值请查询http状态码
	private final static String kRet = "ret";//请求结果

	private int id;
	private String url;
	private String data;
	private int timeout;
	private String event;

	// public int abort;
	private String ret;
	private int error;
	private int code;

	private static String GetDictName ( int id )
	{
		return String.format("http_request_%d", id);
	}
	/**
	 * http 请求入口<br/>
	 * http 请求需要的参数：<br/>
	 * id:每一次请求的标识<br/>
	 * event:请求回调Lua方法后缀方法<br/>
	 * timeOut：请求超时时间<br/>
	 * url：请求地址<br/>
	 * data：请求发送的数据
	 */
	public void Execute() {
		id = Dict.getInt(kHttpRequestExecute, kId, 0);
		if (0 == id) {
			return;
		}
		String strDictName = GetDictName(id);
		event = Dict.getString(strDictName, kEvent);
		timeout = Dict.getInt(strDictName, kTimeout, 0);
		url = Dict.getString(strDictName, kUrl);
		data = Dict.getString(strDictName, kData);

		if ( timeout < 1000 ) timeout = 1000;

		Message msg = new Message();
		Bundle bundle = new Bundle();
		bundle.putInt(kId, id);
		bundle.putString(kEvent, event);
		msg.what = AppActivity.HANDLER_HTTPPOST_TIMEOUT;
		msg.setData(bundle);
		AppActivity.getHandler().sendMessageDelayed(msg,timeout);

		AddMsg(id,msg);		
		new Thread(this).start();

	}

	/**
	 * 请求执行线程<br/>
	 * 请求完成回调lua数据：<br/>
	 * id:每一次请求回调的标识<br/>
	 * step:请求完成当前状态值<br/>
	 * error：请求完成类型，0--成功；1--失败<br/>
	 * code：请求http状态码，200--请求成功，其余值请查询http状态码<br/>
	 * ret：请求结果数据
	 */
	@Override
	public void run() {

		ret = "";
		error = 0;
		code = 0;
		HttpGet getRequest = new HttpGet(url);
		HttpClient client = null;
		HttpResponse response = null;

		HttpParams httpParams = new BasicHttpParams();
		HttpConnectionParams.setConnectionTimeout(httpParams, timeout);
		HttpConnectionParams.setSoTimeout(httpParams, timeout);
		HttpConnectionParams.setSocketBufferSize(httpParams, 8 * 1024); // Socket数据缓存默认8K
		HttpConnectionParams.setTcpNoDelay(httpParams, false);
		HttpConnectionParams.setStaleCheckingEnabled(httpParams, false);
		HttpClientParams.setRedirecting(httpParams, false);
		client = new DefaultHttpClient(httpParams);

		setProxy(client);
		try {
			client.getParams().setParameter(HttpConnectionParams.CONNECTION_TIMEOUT, timeout);
			client.getParams().setParameter(HttpConnectionParams.SO_TIMEOUT, timeout);
	
			StringEntity entity = new StringEntity(data, HTTP.UTF_8);
	//				postRequest.setEntity(entity);
	//				postRequest.addHeader("content-type", "application/x-www-form-urlencoded");
	
			response = client.execute(getRequest);
			int code = response.getStatusLine().getStatusCode();
			if (code == HttpURLConnection.HTTP_OK) {
				ret = EntityUtils.toString(response.getEntity());
			} else {
				// same as above ?
				ret = EntityUtils.toString(response.getEntity());
			}
		} catch (IllegalArgumentException e) { //增加对url字符  异常处理 
			error = 1;
			ret = e.toString();
		} catch (MalformedURLException e) {
			error = 1;
			ret = e.toString();
		} catch (ProtocolException e) {
			error = 1;
			ret = e.toString();

		} catch (ConnectTimeoutException e) {
			error = 1;
			ret = e.toString();
		} catch (IOException e) {
			error = 1;
			ret = e.toString();
		} catch (Exception e) {
			error = 1;
			ret = e.toString();
		} finally {
		}
		Message msg = RemoveMsg(id);
		if ( null != msg )
		{
			final String strDictName = GetDictName(id);
			AppActivity.getInstance().runOnLuaThread(new Runnable()
			{
	
				@Override
				public void run() {
					Dict.setInt(kHttpResponse, kId, id);
					Dict.setInt(strDictName, kStep, HTTP_REQUEST_FINISH);
					Dict.setInt(strDictName, kError, error);
					Dict.setInt(strDictName, kCode, code);
					Dict.setString(strDictName, kRet, ret);
					String strFunc;
					if (null == event) {
						strFunc = KEventPrefix;
					} else {
						strFunc = KEventPrefix_ + event;
					}

					Sys.callLua(strFunc);					
				}
			});
		}
		
	}

	
	/**
	 * 请求超时回调Lua<br/>
	 * 请求超时回调数据：<br/>
	 * id:每一次请求的标识<br/>
	 * step:请求当前状态值<br/>
	 * error：请求完成类型，0--成功；1--失败<br/>
	 * code：请求http状态码，200--请求成功，其余值请查询http状态码<br/>
	 * ret：请求结果数据
	 */
	public static void HandleTimeout ( Message msg )
	{
		Bundle bundle = msg.getData();
		final int id = bundle.getInt(kId);
		final String event = bundle.getString(kEvent);
		final String strDictName = GetDictName(id);

		if ( null != RemoveMsg(id) )
		{
			AppActivity.getInstance().runOnLuaThread(new Runnable()
			{
				@Override
				public void run() {
					Dict.setInt(kHttpResponse, kId, id);
					Dict.setInt(strDictName, kStep, HTTP_REQUEST_FINISH);
					Dict.setInt(strDictName, kError, 1);
					Dict.setInt(strDictName, kCode, 0);
					Dict.setString(strDictName, kRet, "timeout");
					String strFunc;
					if (null == event) {
						strFunc = KEventPrefix;
					} else {
						strFunc = KEventPrefix_ + event;
					}

					Sys.callLua(strFunc);					
				}
			});
		}
	}

//	设置代理
	private static void setProxy(HttpClient client) {
		Context context = AppActivity.getInstance().getApplication().getApplicationContext();
		boolean useProxy = APNUtil.hasProxy(context);
		if (useProxy) {
			String proxyIP = APNUtil.getApnProxy(context);
			int proxyPort = APNUtil.getApnPortInt(context);
			if(!TextUtils.isEmpty(proxyIP)){
				HttpHost proxy = new HttpHost(proxyIP, proxyPort);
				client.getParams().setParameter(ConnRoutePNames.DEFAULT_PROXY, proxy);
				return ;
			}
		}
		client.getParams().setParameter(ConnRoutePNames.DEFAULT_PROXY, null);
	}

}
