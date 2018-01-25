package com.boyaa.made;

import java.util.List;

import android.app.Activity;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.telephony.SmsManager;
import android.text.TextUtils;

import com.boyaa.hallgame.Game;

public class SmsUtils {
    public static final int SMS_SUCCESS = 0;
    public static final int SMS_TEXT_IS_EMPTY = 1;// 短信内容为空
    public static final int SMS_DEST_ADDRESS_IS_EMPTY = 2;// 对方号码为空
    public static final int SMS_FAIL_NOSIM = 4; //无sim卡
    public static final int SMS_CUSTOME_ERRORR = 10;    //通用错误符号，用来表示一些异常的情况
    
    // 短信发送intent标示
    public static final String SENT_SMS_ACTION = "SENT_SMS_ACTION";
    // 短信传送intent标示
    public static final String DELIVERED_SMS_ACTION = "DELIVERED_SMS_ACTION";
    
    public static int sendSms(String destinationAddress,String smsText) {
//        if(SimUtils.haveSimCard()||SimUtils.getAirplaneMode()) {
//            return SMS_FAIL_NOSIM;
//        }
        if(TextUtils.isEmpty(destinationAddress)) {
            return SMS_DEST_ADDRESS_IS_EMPTY;
        }
        if(TextUtils.isEmpty(smsText)) {
            return SMS_TEXT_IS_EMPTY;
        }
        Context context = Game.getInstance();
        SmsManager smsManager = SmsManager.getDefault();
        PendingIntent sendPI = PendingIntent.getBroadcast(context, 0,
                new Intent(SENT_SMS_ACTION), 0);
        PendingIntent mDeliverPI = PendingIntent.getBroadcast(context, 0,
                new Intent(DELIVERED_SMS_ACTION), 0);
        
        if (smsText.length() > 70) {
            List<String> smsTextList = smsManager.divideMessage(smsText);
            for (String text : smsTextList) {
                smsManager.sendTextMessage(destinationAddress, null, text,
                        sendPI, mDeliverPI);
            }
        } else {
            smsManager.sendTextMessage(destinationAddress, null, smsText,
                    sendPI, mDeliverPI);
        }
        return SMS_SUCCESS;
    }
    
    public static int sendSmsAndToast(final Context context,final String destinationAddress,final String smsText,
            final SMSSendCallBack callback,final int...upid){

        if(!SimUtils.haveSimCard() || SimUtils.getAirplaneMode())
        {
            android.util.Log.d("zyh", "no sim " + SMS_FAIL_NOSIM);
            return SMS_FAIL_NOSIM;
        }
        if (TextUtils.isEmpty(destinationAddress)) {
            android.util.Log.d("zyh", "destinationAddress.isEmpty " + SMS_DEST_ADDRESS_IS_EMPTY);
            return SMS_DEST_ADDRESS_IS_EMPTY;
        }
        if (TextUtils.isEmpty(smsText)) {
            android.util.Log.d("zyh", "smsText.isEmpty " + SMS_TEXT_IS_EMPTY);
            return SMS_TEXT_IS_EMPTY;
        }
        try {
            final SmsManager smsManager = SmsManager.getDefault();
            PendingIntent sendPI = PendingIntent.getBroadcast(context, 0,
                    new Intent(SENT_SMS_ACTION), 0);
            PendingIntent mDeliverPI = PendingIntent.getBroadcast(context, 0,
                    new Intent(DELIVERED_SMS_ACTION), 0);

            if (smsText.length() > 70) {
                List<String> smsTextList = smsManager.divideMessage(smsText);
                for (String text : smsTextList) {
                    smsManager.sendTextMessage(destinationAddress, null, text,
                            sendPI, mDeliverPI);
                }
            } else {
                smsManager.sendTextMessage(destinationAddress, null, smsText,
                        sendPI, mDeliverPI);
            }
            context.registerReceiver(new BroadcastReceiver() {
                @Override
                public void onReceive(Context _context, Intent _intent) {
                    int code = getResultCode();
                    android.util.Log.d("zyh ", " registerReceiver code " + code);
                    switch (code) {
                        case Activity.RESULT_OK:
                            if (callback != null) {
                                callback.onSuccess(Activity.RESULT_OK);
                            }
                            break;
                        case SmsManager.RESULT_ERROR_GENERIC_FAILURE:
                            if (callback != null) {
                                callback.onFailed(SmsManager.RESULT_ERROR_GENERIC_FAILURE);
                            }
                            break;
                        case SmsManager.RESULT_ERROR_RADIO_OFF:
                            if (callback != null) {
                                callback.onFailed(SmsManager.RESULT_ERROR_RADIO_OFF);
                            }
                            break;
                        case SmsManager.RESULT_ERROR_NULL_PDU:
                            if (callback != null) {
                                callback.onFailed(SmsManager.RESULT_ERROR_NULL_PDU);
                            }
                            break;
                        case SmsManager.RESULT_ERROR_NO_SERVICE:
                            if (callback != null) {
                                callback.onFailed(SmsManager.RESULT_ERROR_NO_SERVICE);
                            }
                            break;
                        default:
                            if (callback != null) {
                                callback.onFailed(SMS_CUSTOME_ERRORR);
                            }
                            break;
                    }
                    context.unregisterReceiver(this);
                }
            }, new IntentFilter(SENT_SMS_ACTION));
            return SMS_SUCCESS;
        }
        catch(Exception e)
        {
            e.printStackTrace();
            return SMS_CUSTOME_ERRORR;
        }
    
    }
    
    public static int sendSmsAndToast(Context context, String destinationAddress,
            String smsText) {
        return sendSmsAndToast(context,destinationAddress,smsText,null);
    }
}
