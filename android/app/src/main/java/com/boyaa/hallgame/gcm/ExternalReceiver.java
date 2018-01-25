package com.boyaa.hallgame.gcm;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

public class ExternalReceiver extends BroadcastReceiver {

    public void onReceive(Context context, Intent intent) {
        Log.d("zyh ", "onReceive " + intent.toString());
        if(intent!=null){
            Bundle extras = intent.getExtras();
            MessageReceivingService.saveToLog(extras, context);
        }
        else
        {
            Log.d("zyh", "intent is null");
        }
    }
}

