package com.boyaa.application;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Timer;
import java.util.TimerTask;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;
import android.widget.RemoteViews;

import com.boyaa.hallgame.Game;
import com.boyaa.hallgame.R;

public class PushService extends Service {
	public static final int NOTICE_ID = 101695;
	public static int bank_delay_time = 0;
	public static int fresh_delay_time = 0;
	
		
	// 推送类型
	public static int bank_push = 1;
	public static int fresh_push = 2;
	
	// 新注推送内容
	public static final String fresh_push_tip_1 = "登录就送2元话费！还等什么，快来领取吧！";
	public static final String fresh_push_tip_2 = "赢1局就送1元话费，还有各种实物等你来赢！";
	public static final String fresh_push_tip_3 = "2元话费已到帐，点我领取！";
	public static int fresh_push_step = 0;	// 当前执行新注推送第几步 1,2,3,4,5步
	public static int[] push_time = {1920, 1219, 1920};
	
	// 新注推送5步的开关  0关  1开
	public static int freshPushStep_1 = 0;
	public static int freshPushStep_2 = 0;
	public static int freshPushStep_3 = 0;
	public static int freshPushStep_4 = 0;
	public static int freshPushStep_5 = 0;
	
	public static boolean isBinded;
	private Timer bankTimer;
	private Timer freshTimer_1;
	private Timer freshTimer_2;
	private Timer freshTimer_3;
	private Timer freshTimer_4;
	private Timer freshTimer_5;
	

	@Override
	public IBinder onBind(Intent intent) {
		return null;
	}

	@Override
	public void onCreate() {
		super.onCreate();
		Log.i("push_service", "push_service onCreate");
	}

	@Override
	public int onStartCommand(final Intent intent, int flags, int startId) {

		if (intent == null) {
			if (bankTimer != null)
				bankTimer.cancel();
			if (freshTimer_1 != null)
				freshTimer_1.cancel();
			if (freshTimer_2 != null)
				freshTimer_2.cancel();
			if (freshTimer_3 != null)
				freshTimer_3.cancel();
			return START_NOT_STICKY;
		}
		
		int push_type = intent.getIntExtra("pushType", 1);		
		if (push_type == bank_push) {			
			final int delayTime = intent.getIntExtra("delayTime", 1000);
			bankruptPush(delayTime);
		}else if (push_type == fresh_push) {
			freshPushStep_1 = intent.getIntExtra("freshPushStep_1", 0);
			freshPushStep_2 = intent.getIntExtra("freshPushStep_2", 0);
			freshPushStep_3 = intent.getIntExtra("freshPushStep_3", 0);
			freshPushStep_4 = intent.getIntExtra("freshPushStep_4", 0);
			freshPushStep_5 = intent.getIntExtra("freshPushStep_5", 0);
			freshRegPush();
		}		
		return super.onStartCommand(intent, START_NOT_STICKY, startId);
	}
	
	/**
	 * 破产推送
	 */
	private void bankruptPush(final int delayTime) {
		if (bankTimer == null)
			bankTimer = new Timer();  //创建任务
		else
			bankTimer.cancel();  //停止原来的任务
		
		delayToPush(bankTimer, delayTime, "您的破产补助可以领取啦！");

	}
	
	/**
	 * 新注册用户推送
	 * freshPushStep 当前第几步
	 */
	private void freshRegPush() {
		if (freshTimer_1 == null)
			freshTimer_1 = new Timer();  //创建任务
		else
			freshTimer_1.cancel();  //停止原来的任务
		if (freshTimer_2 == null)
			freshTimer_2 = new Timer();  //创建任务
		else
			freshTimer_2.cancel();  //停止原来的任务
		if (freshTimer_3 == null)
			freshTimer_3 = new Timer();  //创建任务
		else
			freshTimer_3.cancel();  //停止原来的任务
		if (freshTimer_4 == null)
			freshTimer_4 = new Timer();  //创建任务
		else
			freshTimer_4.cancel();  //停止原来的任务
		if (freshTimer_5 == null)
			freshTimer_5 = new Timer();  //创建任务
		else
			freshTimer_5.cancel();  //停止原来的任务
		
		long[] delayTime =  getDiffMills();
		Log.i("PushService", "延时推送 freshPushStep_4 :" + PushService.freshPushStep_4 + " || " + delayTime[3]);
		Log.i("PushService", "延时推送 freshPushStep_5 :" + PushService.freshPushStep_5 + " || " + delayTime[4]);
		
		if (PushService.freshPushStep_1 == 1) {
			delayToPush(freshTimer_1, delayTime[0], fresh_push_tip_1);
		}
		if (PushService.freshPushStep_2 == 1) {
			delayToPush(freshTimer_2, delayTime[1], fresh_push_tip_2);
		}
		if (PushService.freshPushStep_3 == 1) {
			delayToPush(freshTimer_3, delayTime[2], fresh_push_tip_2);
		}
		if (PushService.freshPushStep_4 == 1) {
			delayToPush(freshTimer_4, delayTime[3], fresh_push_tip_3);
		}
		if (PushService.freshPushStep_5 == 1) {
			delayToPush(freshTimer_5, delayTime[4], fresh_push_tip_3);
		}
	}
	
	/**
	 * 延时push
	 * @param timer
	 * @param delayTime
	 * @param pushStr
	 */
	private void delayToPush(Timer timer, long delayTime, final String pushStr) {
		
		timer.schedule(new TimerTask() {
			@Override
			public void run() {
				// 获取到通知管理器
				NotificationManager mNotificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
				// 定义内容
				int notificationIcon = R.drawable.hallgame_icon;
				CharSequence notificationTitle = pushStr;
				Notification notification = new Notification(notificationIcon, notificationTitle, System.currentTimeMillis());
				if (notification != null) {
					notification.defaults |= Notification.DEFAULT_VIBRATE|Notification.DEFAULT_SOUND;
					notification.flags |= Notification.FLAG_AUTO_CANCEL;
					
					Intent intent = new Intent(getApplicationContext(),Game.class);
					PendingIntent pendingIntent = PendingIntent.getActivity(getApplicationContext(), 0, intent, 0);
					//notification.setLatestEventInfo(getApplicationContext(), pushStr, " 麻将全集", pendingIntent);
					notification.contentView = new RemoteViews(getPackageName(), R.layout.broke_notice);
					notification.contentView.setTextViewText(R.id.push_message, pushStr);
					mNotificationManager.notify(NOTICE_ID, notification);
				}
			}
		}, delayTime);
	}

	/**
	 * 获取新注推送的时间
	 * @return
	 */
	private long[] getDiffMills() {
		Date dt=new Date();
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy:MM:dd:HH:mm:ss");
		String dtStr = sdf.format(dt);
		System.out.println("现在时间是:"+dtStr);
		
		String temp[] = dtStr.split(":");
		int hour = Integer.valueOf(temp[3]);
		int min = Integer.valueOf(temp[4]);
		int sec = Integer.valueOf(temp[5]);
		
		int sec_1 = (23-hour)*60*60 + (59-min)*60 + (60-sec);
	    long timeArr[] = {0,0,0,0,0};
		
		// 距离第二天19:20的毫秒数
		timeArr[0] = (sec_1 + 19*60*60 + 20*60)*1000;
		
		// 距离第三天12:19的秒数
		timeArr[1] = (sec_1 + 12*60*60 + 20*60 + 24*60*60)*1000;
		
		// 距离第三天19:20的秒数
		timeArr[2] = (sec_1 + 19*60*60 + 20*60 + 24*60*60)*1000;
		
		// 距离第七天12:19的秒数
		timeArr[3] = (sec_1 + 19*60*60 + 20*60 + 4*24*60*60)*1000;
		
		// 距离第七天19:20的秒数
		timeArr[4] = (sec_1 + 19*60*60 + 20*60 + 4*24*60*60)*1000;
		
		return timeArr;
	}
	
	@Override
	public void onDestroy() {
		super.onDestroy();
		Log.d("PushService", "销毁service");
		if( bankTimer != null )
			bankTimer.cancel();
		if( freshTimer_1 != null )
			freshTimer_1.cancel();
		if (freshTimer_2 != null)
			freshTimer_2.cancel();
		if (freshTimer_3 != null)
			freshTimer_3.cancel();
		if (freshTimer_4 != null)
			freshTimer_4.cancel();
		if (freshTimer_5 != null)
			freshTimer_5.cancel();
	}
}
