package com.boyaa.core;

import com.boyaa.hallgame.Game;

public class KeyDispose {
	
	public KeyDispose(){
		
	}
	
	public void back(String key , String result){
		Game.getInstance().callLuaFunc(key , result);
	}
	
	public void home(String key , String result){
		Game.getInstance().callLuaFunc(key , result);
	}
	public void exit(String key , String result){
//		AppActivity.terminateProcess();
	}
	
}
