package com.boyaa.hallgame.gcm;

import java.util.HashMap;
import java.util.Map;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.IBinder;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

import com.boyaa.entity.common.utils.JsonUtil;
import com.boyaa.hallgame.Game;
import com.boyaa.hallgame.R;
//import com.boyaa.made.AppActivity;

/*
 * This service is designed to run in the background and receive messages from gcm. If the app is in the foreground
 * when a message is received, it will immediately be posted. If the app is not in the foreground, the message will be saved
 * and a notification is posted to the NotificationManager.
 */
public class MessageReceivingService extends Service{
    
    private static final String TAG = MessageReceivingService.class.getSimpleName();
    private static String title = "";
    private static String content = "";
    private static String icon = "";
    
    public static void sendToApp(Bundle extras, Context context){
        Intent newIntent = new Intent();
        newIntent.setClass(context, Game.class);
        newIntent.putExtras(extras);
        newIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(newIntent);
    }

    public void onCreate(){
        super.onCreate();
        sendToApp(new Bundle(), this);
    }

    protected static void saveToLog(Bundle extras, final Context context){
        title = extras.getString("gcm.notification.title");
        content = extras.getString("gcm.notification.body");
        icon = extras.getString("gcm.notification.icon");

        if (title != null && title != "" && content != null && content != "") {
            Map<String, Object> json = new HashMap<String, Object>();
            String ruleid = extras.getString("gcm.notification.ruleid");
            if (ruleid != null && (!ruleid.isEmpty()))
            {
                json.put("ruleid", ruleid);
            }
            String extend = extras.getString("gcm.notification.extend");
            if (extend != null && (!extend.isEmpty()))
            {
                json.put("extend", extend);
            }
            final JsonUtil util = new JsonUtil(json);
            Intent newIntent = new Intent(context, Game.class);
            newIntent.putExtra("extra", util.toString());
            newIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            postNotification(newIntent, context);
        }
        String token = extras.getString("registration_id");
        if (token != null && token != "") {
        	Log.d(TAG, "clientId = " + token);
			Map<String, Object> json = new HashMap<String, Object>();
	     	json.put("clientId", token);

	     	final JsonUtil util = new JsonUtil(json);
	     	if (Game.getInstance().isScreen) {
	     		Game.getInstance().callLuaFunc("postClientId", util.toString());
	     	}
        }
    }

    @SuppressWarnings("deprecation")
	protected static void postNotification(Intent intentAction, Context context){
        final NotificationManager mNotificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

//        final PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, intentAction, Notification.DEFAULT_LIGHTS | Notification.FLAG_AUTO_CANCEL);
        final PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, intentAction, PendingIntent.FLAG_UPDATE_CURRENT);
        final Notification notification = new NotificationCompat.Builder(context).setSmallIcon(R.drawable.hallgame_icon)
        		.setContentTitle(title)
                .setContentText(content)
                .setContentIntent(pendingIntent)
                .setAutoCancel(true)
                .setDefaults(Notification.DEFAULT_ALL)
                .getNotification();

        mNotificationManager.notify(R.string.notification_number, notification);
    }

    public IBinder onBind(Intent arg0) {
        return null;
    }

}