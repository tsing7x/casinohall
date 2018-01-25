package com.boyaa.entity.core;

import android.os.Message;

import com.boyaa.engine.made.AppActivity;
import com.boyaa.hallgame.Game;
import com.umeng.analytics.MobclickAgent;

public class HandMachine {
	public final static String KExit = "Exit"; // 退出游戏
	
	public void callLua(final String key, final String result){
		AppActivity.getHandler().sendMessage(Message.obtain(AppActivity.getHandler(), new Runnable() {
			@Override
			public void run() {
				Game.getInstance().callLuaFunc(key, result);
			}
		}));
	}
	
	public void exit(){
		MobclickAgent.onKillProcess(Game.getInstance());
		Game.getInstance().terminateProcess();
	}
}
