package com.boyaa.entity.common.utils;

import java.util.TreeMap;

import org.json.JSONException;
import org.json.JSONObject;

import android.graphics.Bitmap;
import android.os.Message;
import android.util.Log;

import com.boyaa.entity.common.OnThreadTask;
import com.boyaa.entity.common.PHPPost;
import com.boyaa.entity.common.SDTools;
import com.boyaa.entity.common.ThreadTask;
import com.boyaa.hallgame.Game;

public class DownloadImageFile 
{
	public DownloadImageFile(String param, final String key)
	{
		JSONObject upResult = null;
		try {
			upResult = new JSONObject(param);
			final String url 	= upResult.getString("url");
			final int	 id  	= upResult.getInt("id");
			final String folder = upResult.getString("folder");
			final String name 	= upResult.getString("name");
			/* 从URI地址拉图片过来 */
			ThreadTask.start(Game.getInstance(), "", false, new OnThreadTask() {
				boolean savesucess = false;

				@Override
				public void onThreadRun() {
					Bitmap bitmap = PHPPost.loadPic(url);
					if (null != bitmap) {
						savesucess = SDTools.saveBitmap(Game.getInstance(), Game.getInstance().getImagePath() + folder, name, bitmap);
						bitmap.recycle();
						bitmap = null;
					}
				}

				@Override
				public void onAfterUIRun() {
					TreeMap<String, Object> map = new TreeMap<String, Object>();
					map.put("stat", savesucess ? 1 : 0);
					map.put("folder", folder);
					map.put("name", name);
					map.put("id", id);
					Game.getInstance().callLuaFunc(key, new JSONObject(map).toString());
				}

				@Override
				public void onUIBackPressed() {
				}
			});
			
		} catch (JSONException e) {
			e.printStackTrace();
			
		}
	}
}
