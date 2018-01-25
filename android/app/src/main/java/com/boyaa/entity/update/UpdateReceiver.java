package com.boyaa.entity.update;

import java.util.TreeMap;

import android.annotation.SuppressLint;
import android.app.DownloadManager;
import android.app.DownloadManager.Query;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.Cursor;

import com.boyaa.application.ConstantValue;
import com.boyaa.entity.common.utils.JsonUtil;
import com.boyaa.entity.sysInfo.SystemInfo;
import com.boyaa.hallgame.Game;
import com.boyaa.hallgame.LuaCallManager;
//import com.boyaa.made.AppActivity;
//import com.boyaa.made.GameHandler;

public class UpdateReceiver extends BroadcastReceiver{
	@SuppressLint("NewApi")
	@Override
	public void onReceive(Context context, Intent intent) {
		String action = intent.getAction();
		if(DownloadManager.ACTION_DOWNLOAD_COMPLETE.equals(action) &&  ConstantValue.downloadManager != null){
			DownloadManager dm = ConstantValue.downloadManager;
			ConstantValue.isUpdating = false;
			long downloadId = intent.getLongExtra(DownloadManager.EXTRA_DOWNLOAD_ID, 0);
			Query query = new Query();
			query.setFilterById(downloadId);
			Cursor cursor = null;
			try{
				cursor = dm.query(query);
				if(cursor != null){
					if(cursor.moveToFirst()){
						int columnIndex = cursor.getColumnIndex(DownloadManager.COLUMN_STATUS);
						if(DownloadManager.STATUS_SUCCESSFUL == cursor.getInt(columnIndex)){
							String uriString = cursor.getString(cursor.getColumnIndex(DownloadManager.COLUMN_LOCAL_URI));
							SharedPreferences userInfo = Game.getInstance().getSharedPreferences("downloadInfo", 0);
							userInfo.edit().putLong("downloadInfo", 0).commit();
							ConstantValue.uriString = uriString;
							TreeMap<String, Object> map = new TreeMap<String, Object>();
							if(ConstantValue.isInGame)
								ConstantValue.updateReplaceVersion(context, uriString);
							map.put("downloadSize", SystemInfo.m_totalSize);
							map.put("totalSize", SystemInfo.m_totalSize);
							JsonUtil progressJson = new JsonUtil(map);
							
							final String progressStr = progressJson.toString();
							
							Game.getInstance().callLuaFunc(LuaCallManager.kUpdateSuccess, progressStr);
							
							
							
						}
					}
				}
			}finally{
				if(cursor != null){
					cursor.close();
					cursor = null;
				}
			}
			
		}
	}
}
