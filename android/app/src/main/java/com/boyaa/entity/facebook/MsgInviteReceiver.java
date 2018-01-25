package com.boyaa.entity.facebook;

//import com.boyaa.made.AppActivity;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import com.boyaa.hallgame.Game;

public class MsgInviteReceiver extends BroadcastReceiver {
	public static String MsgInviteFlag = "MsgInviteFlag";
    public void onReceive(Context context, Intent intent) {
            Bundle bundle = intent.getExtras();
            if (bundle != null) {
            	String msg1 = bundle.getString("msgFlag");
            	if(msg1==MsgInviteReceiver.MsgInviteFlag){
            		// 通知Lua端
            		Game.getInstance().callLuaFunc("MSGInviteSuccess", "");
            	}
        }
    }
}