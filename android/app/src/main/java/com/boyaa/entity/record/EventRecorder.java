package com.boyaa.entity.record;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.TreeMap;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.boyaa.engine.made.Dict;
import com.boyaa.engine.made.Sys;
import com.boyaa.entity.common.utils.JsonUtil;
//import com.boyaa.made.AppActivity;
import com.boyaa.hallgame.Game;
import com.boyaa.hallgame.LuaCallManager;

import android.app.Instrumentation;
import android.os.SystemClock;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;

/**
 * 
 * 屏幕触摸与按键事件的录制与回放
 * 
 * @author TonyZzp
 * 
 */
public class EventRecorder {
	private static class TouchEvent {
		private int action;
		private float x;
		private float y;
		private int metaState;
	}

	private static class Key {
		private int action;
		private int code;
		private int repeat;
	}

	private static class Event {
		private TouchEvent touch;
		private Key key;
		private long time;
		private long delta;
	}

	private static EventRecorder instance;
	

	private List<Event> events = new ArrayList<Event>();

	private boolean start  		 = false;
	private long startTime 		 = 0;
	private volatile boolean stopPlayBack = false;

	public static EventRecorder getInstance() {
		if (instance == null) {
			instance = new EventRecorder();
		}
		return instance;
	}

	/**
	 * 在AppGLSurfaceView.onTouchEvent中调用
	 * 
	 * @param event
	 */
	public void onTouchEvent(MotionEvent event) {
		if (!start) {
			return;
		}
		
		TouchEvent touch = new TouchEvent();
		touch.action = event.getAction();
		touch.x = event.getX();
		touch.y = event.getY();
		touch.metaState = event.getMetaState();

		Event e = new Event();
		e.touch = touch;
		e.time = System.currentTimeMillis();
		if (events.isEmpty()) {
			e.delta = e.time - startTime;
		} else {
			Event last = events.get(events.size() - 1);
			e.delta = e.time - last.time;
		}
		events.add(e);
	}

	/**
	 * 
	 * 在AppGLSurfaceView.onKeyDown中调用
	 * 
	 * @param keyCode
	 * @param event
	 */
	public void onKeyEvent(int keyCode, KeyEvent event) {
		if (!start) {
			return;
		}
		
		Key key = new Key();
		key.action = event.getAction();
		key.code = event.getKeyCode();
		key.repeat = event.getRepeatCount();

		Event e = new Event();
		e.key = key;
		e.time = System.currentTimeMillis();
		if (events.isEmpty()) {
			e.delta = e.time - startTime;
		} else {
			Event last = events.get(events.size() - 1);
			e.delta = e.time - last.time;
		}
		events.add(e);
	}

	/**
	 * 开始录制
	 */
	public void startRecord() {
		events.clear();
		startTime = System.currentTimeMillis();
		start = true;
	}

	/**
	 * 停止录制
	 */
	public void stopRecord() {
		start = false;
		writeEvents();
	}
	
	public void writeEvents()
	{
		
		JSONArray jsonArray = new JSONArray();
		
		//save event
		for (Event e : events) {
			if (e.touch != null) {
				JSONObject jsonObj  = new JSONObject();
				
				try {
					jsonObj.put("type", 	0);
					jsonObj.put("time", 	e.time);
					jsonObj.put("delta", 	e.delta);
					jsonObj.put("action", 	e.touch.action);
					jsonObj.put("x", 		e.touch.x);
					jsonObj.put("y", 		e.touch.y);
					jsonObj.put("metaState",e.touch.metaState);
					jsonArray.put(jsonObj);
				} catch (JSONException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
				
				
			} else {
				
					JSONObject jsonObj  = new JSONObject();
				
				try {
					jsonObj.put("type", 	1);
					jsonObj.put("time", 	e.time);
					jsonObj.put("delta", 	e.delta);
					jsonObj.put("action", 	e.key.action);
					jsonObj.put("code", 	e.key.code);
					jsonObj.put("repeat", 	e.key.repeat);
					jsonArray.put(jsonObj);
				} catch (JSONException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
			}
		}
		
		String fileName = Game.getInstance().getImagePath() + "record.json";
		
		try {
			FileOutputStream fos = new FileOutputStream(new File(fileName));
			fos.write(jsonArray.toString().getBytes());
			fos.close();
		} catch (FileNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		
		events.clear();
	}
	
	public void readEvents() throws JSONException
	{
		events.clear();
		
		String jsonString = null;
		
		String fileName = Game.getInstance().getImagePath() + "record.json";
		
		try {
			File file = new File(fileName);
			Long filelength = file.length();
			byte[] filecontent = new byte[filelength.intValue()];
			FileInputStream in = new FileInputStream(file);
			in.read(filecontent, 0, filecontent.length);
			in.close();
			jsonString = new String(filecontent);
		} catch (FileNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		
		JSONArray jsonArray = new JSONArray(jsonString);
		int count = jsonArray.length();
		for(int i = 0; i < count; ++i)
		{
			
			JSONObject json = jsonArray.getJSONObject(i);
			Event e = new Event();
			e.time = json.getLong("time");
			e.delta= json.getLong("delta");
			if(json.getInt("type") == 0)
			{
				TouchEvent touch = new TouchEvent();
				touch.action 	= json.getInt("action");
				touch.x 		= (float)json.getDouble("x");
				touch.y 		= (float)json.getDouble("y");
				touch.metaState = json.getInt("metaState");
				e.touch = touch;
				events.add(e);
			}
			else if(json.getInt("type") == 1)
			{
				Key key = new Key();
				key.action 		= json.getInt("action");
				key.repeat 		= json.getInt("repeat");
				key.code 		= json.getInt("code");
				e.key = key;
				events.add(e);
			}
		}
	}

	/**
	 * 停止录制
	 */
	public void stopPlayBack() {
		stopPlayBack = true;
	}

	/**
	 * 开始回放上一次的录制
	 */
	public void playBack() {
		try {
			readEvents();
		} catch (JSONException e1) {
			// TODO Auto-generated catch block
			events.clear();
			e1.printStackTrace();
		}
		stopPlayBack = false;
		//final long delta = time - startTime;
		new Thread() {
			@Override
			public void run() {
				for (Event e : events) {
					if(stopPlayBack)
					{
						break;
					}
					SystemClock.sleep(e.delta);
					Instrumentation ins = new Instrumentation();
					if (e.touch != null) {
						MotionEvent touch = MotionEvent.obtain(SystemClock.uptimeMillis(), 
								SystemClock.uptimeMillis(),
								e.touch.action, e.touch.x, e.touch.y,
								e.touch.metaState);
						ins.sendPointerSync(touch);
					} else {
						KeyEvent key = new KeyEvent(SystemClock.uptimeMillis(), SystemClock.uptimeMillis(), e.key.action,
								e.key.code, e.key.repeat);
						ins.sendKeySync(key);
						
					}
				}
				SystemClock.sleep(2000);
				TreeMap<String, Object> map = new TreeMap<String, Object>();
				map.put("status", 1);
				JsonUtil json = new JsonUtil(map);
				final String jsonStr = json.toString();
				
				Game.getInstance().runOnLuaThread(new Runnable() {
					public void run() {
						Dict.setString(LuaCallManager.kluaCallEvent, LuaCallManager.kluaCallEvent, "playBack");
						Dict.setInt("playBack", LuaCallManager.kCallResult, 0);
						Dict.setString("playBack", "playBack" + LuaCallManager.kResultPostfix, jsonStr);
						Sys.callLua(LuaCallManager.kCallLuaEvent);
					}
				});
			};
		}.start();
	}
}