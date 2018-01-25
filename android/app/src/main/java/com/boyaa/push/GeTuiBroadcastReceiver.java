package com.boyaa.push;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.boyaa.godsdk.core.GodSDK;
import com.boyaa.godsdk.core.GodSDKPush;

public class GeTuiBroadcastReceiver extends BroadcastReceiver{

	private static final String TAG = "GeTuiBroadcastReceiver";
	@Override
	public void onReceive(Context context, Intent intent) {
		// TODO Auto-generated method stub
		try {
			String broadcastAction = intent.getAction();
			GodSDK.getInstance().getDebugger().i("----->godsdkHelper onReceive: broadcastAction="+broadcastAction);
			Bundle bundle = intent.getExtras();
			if (GodSDKPush.Action.RECEIVE_RAW_DATA.equals(broadcastAction)) {
				String rawDate = bundle.getString(GodSDKPush.BundleKey.RAW_DATA);
				if (rawDate != null) {
					Log.d(TAG, "rawDate = " + rawDate);
				} else {
					Log.d(TAG, "rawDate == null");
				}
			}else if(GodSDKPush.Action.RECEIVE_REGISTRATION_ID.equals(broadcastAction)){
				String clientId = bundle.getString(GodSDKPush.BundleKey.REGISTRATION_ID);
				String pushName = bundle.getString(GodSDKPush.BundleKey.PUSH_NAME);
				if (clientId != null) {
					Log.d(TAG, "clientId = " + clientId);
					
//					Map<String, Object> json = new HashMap<String, Object>();
//                	json.put("clientId", clientId);
//                	final JsonUtil util = new JsonUtil(json);
//                	AppActivity.mActivity.luaCallEvent("postClientId", util.toString());
				} else {
					Log.d(TAG, "clientId == null");
				}
				if (pushName != null) {
					Log.d(TAG, "pushName = " + pushName);
				} else {
					Log.d(TAG, "pushName == null");
				}
			}
			//AppActivity.mActivity.luaCallEvent("MSGInviteSuccess", "");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
