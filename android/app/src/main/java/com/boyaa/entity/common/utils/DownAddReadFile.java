package com.boyaa.entity.common.utils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URL;
import android.annotation.SuppressLint;
import android.util.Log;

import com.boyaa.engine.made.Dict;
import com.boyaa.engine.made.Sys;
import com.boyaa.hallgame.Game;


public class DownAddReadFile implements Runnable {

	private final String kRequestExecute = "request_execute";
	private final String kResponse = "response";
	private final String KEventPrefix = "event_downAddReadFile_response";
	private final String kId = "id";
	private final String kUrl = "url";
	private final String kTimeout = "timeout";
	private final String kRet = "ret";
	private final String kError = "error";
	private final static int kResultSuccess = 1;
	private final static int kResultError = -1;

	private int id;
	private String urlStr;
	private int error;
	private String ret = "";
	private int timeout;

	private static String GetDictName ( int id )
	{
		return "request_" + id;
	}
	
	public void Execute() {
		error = kResultSuccess;
		id = Dict.getInt(kRequestExecute, kId, 0);
        if (id <= 0)
        {
            return;
        }
        String strDictName = GetDictName(id);
        urlStr = Dict.getString(strDictName, kUrl);
        timeout = Dict.getInt(strDictName, kTimeout, 0);
		Log.i("DownAddReadFile", "==========strDictName:" + strDictName);
		Log.i("DownAddReadFile", "==========url:" + urlStr);
		Log.i("DownAddReadFile", "==========timeout:" + timeout);
		new Thread(this).start();
	}

	@Override
	public void run() {

		if (null == urlStr || urlStr.length() < 1) {
			error = kResultError;
			ret = "";
			return;
		}
		if (timeout < 1000) {
			timeout = 1000;
		}
		String line;
		BufferedReader reader = null;
		try {
			URL url = new URL(urlStr);
			reader = new BufferedReader(new InputStreamReader(url.openStream(),
					"UTF-8"));
			while (null != (line = reader.readLine())) {
				ret = line;
			}
		} catch (MalformedURLException e) {
			error = kResultError;
			ret = e.toString();
		} catch (UnsupportedEncodingException e) {
			error = kResultError;
			ret = e.toString();
		} catch (IOException e) {
			error = kResultError;
			ret = e.toString();
		} finally {
			try {
				if (null != reader) {
					reader.close();
				}
			} catch (IOException e) {
				error = kResultError;
				ret = e.toString();
			}
		}

		Game.getInstance().runOnLuaThread(new Runnable() {
			@Override
			public void run() {
				String strDictName = GetDictName(id);
	            Dict.setInt(kResponse, kId, id);
	            Dict.setInt(strDictName, kError, error);
	            Dict.setString(strDictName, kRet, ret);
				Sys.callLua(KEventPrefix);
			}
		});

	}

}
