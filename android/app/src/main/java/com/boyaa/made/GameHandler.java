package com.boyaa.made;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.math.BigInteger;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.Iterator;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpConnectionParams;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.Manifest;
import android.app.Activity;
import android.app.DownloadManager;
import android.app.NotificationManager;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Handler;
import android.os.Message;
import android.preference.PreferenceManager.OnActivityResultListener;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.widget.Toast;
import android.location.Location;

import com.boyaa.engine.made.APNUtil;
import com.boyaa.engine.made.AppHttpPost;
import com.boyaa.engine.made.Dict;
import com.boyaa.engine.made.Sys;
// import com.boyaa.entity.activities.ActivityCenter;
import com.boyaa.entity.ad.BoyaaADUtil;
import com.boyaa.application.ConstantValue;
import com.boyaa.application.PushService;
import com.boyaa.entity.activities.MahjongActivities;
import com.boyaa.entity.ad.Constant;
import com.boyaa.entity.common.GZUtil;
import com.boyaa.entity.common.OnThreadTask;
import com.boyaa.entity.common.ThreadTask;
import com.boyaa.entity.common.utils.DownloadImageFile;
import com.boyaa.entity.common.utils.JsonUtil;
import com.boyaa.entity.common.SdkVersion;
import com.boyaa.entity.facebook.FBEntityEx;
import com.boyaa.entity.facebook.MsgInviteReceiver;
import com.boyaa.entity.images.SaveImage;
import com.boyaa.entity.images.UploadImage;
import com.boyaa.entity.record.EventRecorder;
import com.boyaa.entity.rule.Rule;
import com.boyaa.entity.sysInfo.SystemInfo;
//import com.boyaa.entity.umeng.UmengUtil;
import com.boyaa.entity.update.UpdateReceiver;
import com.boyaa.godsdk.callback.CallbackStatus;
import com.boyaa.godsdk.callback.SpecialMethodListener;
import com.boyaa.godsdk.core.GodSDKIAP;
import com.boyaa.hallgame.Game;
import com.boyaa.hallgame.R;
//import com.boyaa.made.AppActivity.DialogMessage;
//import com.boyaa.made.AppActivity.EditBoxMessage;
import com.boyaa.utils.PathUtil;
import com.boyaa.data.BoyaaAPI;
//import com.boyaa.sdk.BoyaaAPI;

import com.umeng.analytics.MobclickAgent;

import com.facebook.messenger.MessengerUtils;
import com.facebook.messenger.MessengerThreadParams;
//import com.facebook.messenger.ShareToMessengerParams;
import java.security.MessageDigest;

import com.boyaa.entity.download.ResumableDownloadManager;


public class GameHandler extends Handler {
    public static final String TAG = "GameHandler";
    private static Set<OnActivityResultListener> onActivityResultListeners = new LinkedHashSet<OnActivityResultListener>();
    private static Set<OnActivityResultListener> onActivityResultPermissionsListeners = new LinkedHashSet<OnActivityResultListener>();

    public final static String kcallLuaFunc = "LuaCallEvent"; // lua调用java
    public final static String kCallLuaEvent = "event_call"; //java调用lua
    public final static String kCallResult = "CallResult";
    public final static String kResultPostfix = "_result";
    public final static String kparmPostfix = "_parm";

    public final static String kTakePhoto = "takePhoto";
    public final static String kPickPhoto = "pickPhoto";
    public final static String kChooseFeedBackImg = "chooseFeedBackImg";

    //支付
    public static final String kUnicomPay = "UnicomPay";
    public static final String kMMPay = "MMPay";
    public final static String kTianYiPay = "TianYiPay"; // 电信天翼支付
    public static final String kLuoMaPay = "LuoMaPay";
    public static final String kTyLuoMaPay = "TyLuoMaPay";
    public static final String kUnitePay = "UnitePay";

    public final static String kUpdateSuccess = "UpdateSuccess"; // 更新
    public final static String kUpdating = "Updating";
    public static final String kUpdateVersion = "UpdateVersion";

    public final static String kActcenterCall = "ActcenterCall";

    public final static String KBackKey = "BackKey"; // 返回键
    public final static String KHomeKey = "HomeKey"; // home键
    /**************** 结束程序 ************************/
    public final static String KExit = "Exit"; // 结束程序

    public final static String kPay = "pay";

    public final static int HANDLER_SHOW_DIALOG = 1;
    public final static int HANDLER_SHOW_EDIT = 2;
    public final static int HANDLER_OPENGL_NOT_SUPPORT = 3;
    public final static int HANDLER_HTTPPOST_TIMEOUT = 4;
    public final static int HANDLER_HTTPGET_UPDATE_TIMEOUT = 5;
    public final static int HANDLER_BACKGROUND_REMAIN = 6;

    public final static int HANDLER_OPEN_WEB = 7;
    public final static int HANDLER_CLOSE_WEB = 8;

    public final static int HANDLER_PAY = 9;
    public final static int HANDLER_LOGIN = 10;

    public final static int HANDLER_OPEN_RULE = 11;
    public final static int HANDLER_CLSOE_RULE = 12;

    public final static int HANDLER_UMENG_UPDATA_PACK = 13;
    public final static int HANDLER_LOCAL_UPDATA_PACK = 14;

    public final static int HANDLER_LOGIN_RET = 15;

    public final static int HANDLER_CHECK_LOCAL_UPDATA_PACK = 16;

    private static String androidVer = "";

    private Game mActivity;

    private UpdateReceiver updateReceiver = null;
    private boolean isUpdateRegister = false; //控制注册和取消注册同步一致

    //for the callback of activity
    public GameHandler() {

    }

    public GameHandler(Game appActivity) {
        this.mActivity = appActivity;

        NotificationManager mNotificationManager = (NotificationManager) mActivity.getSystemService(Context.NOTIFICATION_SERVICE);
        mNotificationManager.cancel(PushService.NOTICE_ID); // 移除这个通知栏

        if (null == updateReceiver && !isUpdateRegister) {
            updateReceiver = new UpdateReceiver();
            mActivity.registerReceiver(updateReceiver, new IntentFilter(DownloadManager.ACTION_DOWNLOAD_COMPLETE));
            isUpdateRegister = true;
        }

    }

    public void OnDestory() {
        if (null != updateReceiver && isUpdateRegister) {
            mActivity.unregisterReceiver(updateReceiver);
            isUpdateRegister = false;
        }
    }


    public void handleMessage(Message msg) {
        switch (msg.what) {
            case HANDLER_SHOW_DIALOG:
//				mActivity.showDialog(((DialogMessage) msg.obj).title, ((DialogMessage) msg.obj).message);
                break;
            case HANDLER_OPENGL_NOT_SUPPORT:
//				final Dialog alertDialog = new AlertDialog.Builder(mActivity).setTitle("message").setMessage("device not support!").setIcon(android.R.drawable.ic_dialog_alert).setPositiveButton("ok", new DialogInterface.OnClickListener() {
//					@Override
//					public void onClick(DialogInterface dialog, int which) {
//						AppActivity.terminateProcess();
//					}
//				}).create();
//				alertDialog.show();
                break;
            case HANDLER_SHOW_EDIT:
//				EditBoxMessage editBoxMessage = (EditBoxMessage) msg.obj;
//				mActivity.showAppEditBoxDialog(editBoxMessage);
                break;
            case HANDLER_HTTPPOST_TIMEOUT:
                AppHttpPost.HandleTimeout(msg);
                break;

            case HANDLER_HTTPGET_UPDATE_TIMEOUT:
//				AppHttpGetUpdate.HandleTimeout(msg);
                break;
            case HANDLER_BACKGROUND_REMAIN:
                Game.terminateProcess();
                break;
            case HANDLER_OPEN_WEB:
                MahjongActivities.getInstance().openUrl((String) msg.obj);
                break;
            case HANDLER_CLOSE_WEB:
                //mMjActivity.close();
                break;
            case HANDLER_LOGIN_RET:
                Log.e("dddd", "msg.toString()" + msg.obj.toString());
                callLuaFunc("login", msg.obj != null ? msg.obj.toString() : "");
                break;
            case HANDLER_OPEN_RULE:
                Rule.getInstance().openUrl((String) msg.obj);
                break;
            case HANDLER_CLSOE_RULE:
                Rule.getInstance().close();
                break;
            case HANDLER_UMENG_UPDATA_PACK:
//			Log.e("","HANDLER_UMENG_UPDATA_PACKHANDLER_UMENG_UPDATA_PACK");
//			try {
//				JSONObject json = new JSONObject((String)msg.obj);
//				int isActUpdata = json.getInt("isActUpdata");// 0 玩家请求更新 1
//				// 游戏自动更新
//				int isDeltaUpdate = json.getInt("isDeltaUpdate");// 0 增量更新 1
//				// 整包更新
//				int isForceUpdate = json.getInt("isForceUpdate");// 0 强制更新 1
//				// 可选更新
//				int isCheckForProcess = json.getInt("isCheckForProcess");// 1为检测更新进度
//				UmengUtil.update(isDeltaUpdate, isActUpdata, isForceUpdate, (1 == isCheckForProcess) ? false : true);
//			} catch (JSONException e1) {
//				e1.printStackTrace();
//			}
                break;
            case HANDLER_LOCAL_UPDATA_PACK:
                //本地更新
                Log.e("lua", "HANDLER_LOCAL_UPDATA_PACK xxx");

                SystemInfo update = new SystemInfo();
                int returnCode = update.updateVersion((String) msg.obj);
                Log.e("lua", "returnCodexx = " + returnCode);
                if (returnCode == ConstantValue.NO_SDCARD) {
                    Toast.makeText(Game.getInstance().getApplicationContext(), "没有SD卡，更新失败", Toast.LENGTH_LONG).show();

                    if (ConstantValue.update_control == 1) {
                        TreeMap<String, Object> map = new TreeMap<String, Object>();
                        map.put("msg", "没有SD卡，更新失败");
                        map.put("updateCode", 2);
                        JsonUtil progressJson = new JsonUtil(map);
                        final String errorStr = progressJson.toString();
                        this.callLuaFunc(kUpdating, errorStr);
                    }
                } else if (returnCode != ConstantValue.SDCARD_SUCCESS
                        && returnCode != ConstantValue.ISUPDATING) {
                    TreeMap<String, Object> map = new TreeMap<String, Object>();
                    map.put("msg", "更新异常，请检查SD卡");
                    map.put("updateCode", 2);
                    JsonUtil progressJson = new JsonUtil(map);
                    final String errorStr = progressJson.toString();
                    this.callLuaFunc(kUpdating, errorStr);

                    return;
                }
                break;
            case HANDLER_CHECK_LOCAL_UPDATA_PACK:
                SystemInfo checkInfo = new SystemInfo();
                if (checkInfo.checkDownloaded((String) msg.obj)) {
                    TreeMap<String, Object> map = new TreeMap<String, Object>();
                    map.put("downloadSize", SystemInfo.m_totalSize);
                    map.put("totalSize", SystemInfo.m_totalSize);
                    JsonUtil progressJson = new JsonUtil(map);
                    final String errorStr = progressJson.toString();
                    this.callLuaFunc(kUpdateSuccess, errorStr);
                }
                break;
            default:
                onHandleMessage(msg);
                break;
        }
        super.handleMessage(msg);
    }

    private void onHandleMessage(Message msg) {
    }

    protected void OnBeforeLuaLoad() {
    }

    public boolean back() {
        //活动
        if (MahjongActivities.getInstance().getActivitiesIsShow()) {
            return MahjongActivities.getInstance().back();
        }
        //服务条款
        if (Rule.getInstance().isVisible()) {
            callLuaFunc("keyBack", "");
            return true;
        }


        return false;
    }

    /**
     * lua call 方法
     *
     * @param data
     * @param key
     */
    /*
	 * 退出游戏
	 */
    public void Exit(String data, String key) {
        MobclickAgent.onKillProcess(Game.getInstance());
        Game.terminateProcess();
    }

    public void CloseStartScreen(String data, String key) {
        ConstantValue.isLuaVMready = true;
        AppHelper.dismissStartDialog();
    }

    /**
     * 共用的业务
     */
    // 实时处理的业务
    public void GetInitValue(String data, String key) {
        AppHelper.GetInitValue(data, key);
    }

    // 获取网络
    public void GetNetAvaliable(String data, String key) {
        AppHelper.GetNetAvaliable(data, key);
    }

    public void compressString(String data, String key) {
        Log.d(TAG, "压缩前的字符串" + data + ", 长度 =" + data.getBytes().length);
        String resString = AppHelper.compressString(data);
        Log.d(TAG, "压缩后的字符串" + resString + ", 长度 =" + resString.getBytes().length);
        Dict.setString(key, key + kResultPostfix, resString);
    }

    // url encode
    public void encodeStr(String data, String key) {
        AppHelper.encodeStr(data, key);
    }

    /*
     * 解压字符串
     */
    public void unCompressString(String data, String key) {
        Log.d(TAG, "解压前的字符串" + data + ", 长度 =" + data.getBytes().length);
        String resString = AppHelper.unCompressString(data);
        Log.d(TAG, "解压后的字符串" + resString + ", 长度 =" + resString.getBytes().length);
        Dict.setString(key, key + kResultPostfix, resString);
    }

    /*
     * 图片是否存在
     */
    public void isFileExist(String data, String key) {
        AppHelper.isFileExist(data, key);
    }

    public void LoadSoundRes(String data, String key) {
        AppHelper.loadSoundRes(data, key);
    }

    public void ReportLuaError(String data, String key) {
        MobclickAgent.reportError(Game.getInstance(), data);
    }

    // 将消息加入队列并，同时添加回调处理
    public void postMessage(Runnable runnable) {
        sendMessage(Message.obtain(this, runnable));
    }

    public void addOnActivityResultListener(OnActivityResultListener listener) {
        onActivityResultListeners.add(listener);
    }

    public Set<OnActivityResultListener> getOnActivityResultListeners() {
        return onActivityResultListeners;
    }

    public void addOnActivityResultPermissionsListeners(OnActivityResultListener listener) {
        onActivityResultPermissionsListeners.add(listener);
    }

    public Set<OnActivityResultListener> getOnActivityResultPermissionsListeners() {
        return onActivityResultPermissionsListeners;
    }


    /**
     * 向lua 传送数据
     *
     * @param key    指令
     * @param result 结果 一般为json 格式字符串
     */
    public void callLuaFunc(final String key, final String result) {
        if (!ConstantValue.isLuaVMready) {
            Log.i(key, "Lua虚拟机未启动");
            return;
        }
        mActivity.runOnLuaThread(new Runnable() {
            @Override
            public void run() {

                Dict.setString(kcallLuaFunc, kcallLuaFunc, key);
                if (null != result) {
                    Dict.setInt(key, kCallResult, 0);
                    Dict.setString(key, key + kResultPostfix, result);
                } else {
                    Dict.setInt(key, kCallResult, 1);
                }
                Log.d(TAG, "java 调用 lua 方法" + kCallLuaEvent);
                Sys.callLua(kCallLuaEvent);
            }
        });
    }

    /**
     * 向lua 传送数据
     *
     * @param key    指令
     * @param result 失败原因
     */
    public void callLuaFuncFail(String key, String result) {
        Log.i(TAG, "获取数据失败： " + key + ":" + result);
        Dict.setString(kcallLuaFunc, kcallLuaFunc, key);
        Dict.setInt(key, kCallResult, 1);
        Sys.callLua(kCallLuaEvent);
    }

    /**
     * 获取参数值
     */
    public String getParm(String key) {
        String param = Dict.getString(key, key + kparmPostfix);
        Log.i(TAG, "获取参数值： " + param);
        return param;
    }

    public String getParam(String eventName, String[] keys) {
        TreeMap<String, Object> map = new TreeMap<String, Object>();

        for (int i = 0; i < keys.length; ++i) {
            map.put(keys[i], Dict.getString(eventName, keys[i]));
        }
        JsonUtil jsonUtil = new JsonUtil(map);
        String result = jsonUtil.toString();
        return result;
    }

    // 通过反射罩到方法
    public void OnLuaCall() {
        // invoke 方法调用
        String key = Dict.getString(kcallLuaFunc, kcallLuaFunc);
        String data = getParm(key);
        Log.d(TAG, "请求调用方法:" + key);

        Method method = null;
        for (Class<?> clazz = getClass(); clazz != Object.class; clazz = clazz.getSuperclass()) {
            try {
                method = clazz.getDeclaredMethod(key, new Class[]{String.class, String.class});
                break;
            } catch (NoSuchMethodException e) {
                // 这里甚么都不要做！并且这里的异常必须这样写，不能抛出去。
                // e.printStackTrace();
            }
        }
        if (null != method) {
            Log.d(TAG, "找到需要调用的java方法：" + key);

            try {
                method.invoke(this, data, key);
            } catch (IllegalAccessException e) {
                // TODO Auto-generated catch block
                Log.e(TAG, "IllegalAccessException | IllegalArgumentException | InvocationTargetException e:" + key);
                e.printStackTrace();
            } catch (IllegalArgumentException e) {
                // TODO Auto-generated catch block
                Log.e(TAG, "IllegalAccessException | IllegalArgumentException | InvocationTargetException e:" + key);
                e.printStackTrace();
            } catch (InvocationTargetException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
                Log.e(TAG, "IllegalAccessException | IllegalArgumentException | InvocationTargetException e:" + key);
            }

        } else {
            Log.d(TAG, "没有找到可调用的java方法：" + key);
        }
    }

    //拍照
    private void takePhoto(final String param, final String key) {
        if (Build.VERSION.SDK_INT >= 23) {
            int checkCallPhonePermission = mActivity.checkSelfPermission(Manifest.permission.CAMERA);
            if (checkCallPhonePermission == PackageManager.PERMISSION_GRANTED) {
                checkCallPhonePermission = mActivity.checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE);
            }
            if(checkCallPhonePermission != PackageManager.PERMISSION_GRANTED){
                addOnActivityResultPermissionsListeners(new OnActivityResultListener() {
                    @Override
                    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
                        if (requestCode == 222) {
                            if (resultCode == Activity.RESULT_OK){
                                takePhoto(param, key);
                            } else {
                                TreeMap<String, Object> map = new TreeMap<String, Object>();
                                final JsonUtil util = new JsonUtil(map);
                                Game.getInstance().callLuaFunc("cameraPermissionDenied", util.toString());
                            }
                            onActivityResultPermissionsListeners.remove(this);
                            return true;
                        }
                        return false;
                    }
                });
                mActivity.requestPermissions(new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.CAMERA},222);
                return;
            }
        }
        takePhoto2(param, key);
    }

    private void takePhoto2(String param, String key){
        final SaveImage saveImage = new SaveImage(mActivity, kTakePhoto);

        JSONObject json = null;
        String imgName = "";
        try {
            json = new JSONObject(param);
            imgName = json.getString("name");
            saveImage.pickImageFromCamera(imgName);

            addOnActivityResultListener(new OnActivityResultListener() {
                @Override
                public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
                    if (resultCode == Activity.RESULT_OK) {
                        if (requestCode == SaveImage.CAMERA_WITH_DATA) {
                            saveImage.cropImageFromPhoto(data);
                            return true;
                        } else if (requestCode == SaveImage.PHOTO_CROP_WITH_DATA) {
                            saveImage.saveBitmapImage(data);
                            onActivityResultListeners.remove(this);
                            return true;
                        }
                    } else {
                        if (requestCode == SaveImage.CAMERA_WITH_DATA || requestCode == SaveImage.PHOTO_CROP_WITH_DATA) {
                            onActivityResultListeners.remove(this);
                            saveImage.saveBitmapImage(data);
                            return true;
                        }
                    }
                    return false;
                }
            });


        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    //选择图片
    private void pickPhoto(String param, String key) {
        final SaveImage saveImage = new SaveImage(mActivity, kPickPhoto);

        JSONObject json = null;
        String imgName = "";
        try {
            json = new JSONObject(param);
            imgName = json.getString("name");
            saveImage.pickImageFromGallery(imgName);
            addOnActivityResultListener(new OnActivityResultListener() {
                @Override
                public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
                    if (resultCode == Activity.RESULT_OK) {
                        if (requestCode == SaveImage.PHOTO_PICKED_WITH_DATA) {
                            saveImage.cropImageFromPhoto(data);
                            return true;
                        } else if (requestCode == SaveImage.PHOTO_CROP_WITH_DATA) {
                            saveImage.saveBitmapImage(data);
                            onActivityResultListeners.remove(this);
                            return true;
                        } else if (requestCode == SaveImage.PHOTO_PICKED_WITH_DATA_KITKAT) {
                            saveImage.cropImageFromPhotoKitkat(data);
                            return true;
                        }
                    } else {
                        if (requestCode == SaveImage.PHOTO_PICKED_WITH_DATA || requestCode == SaveImage.PHOTO_CROP_WITH_DATA || requestCode == SaveImage.PHOTO_PICKED_WITH_DATA_KITKAT) {
                            onActivityResultListeners.remove(this);
                            saveImage.saveBitmapImage(data);
                            return true;
                        }
                    }
                    return false;
                }
            });

        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void chooseFeedBackImg(String param, String key){
        final SaveImage saveImage = new SaveImage(mActivity, kChooseFeedBackImg);

        JSONObject json = null;
        String imgName = "";
        try {
            json = new JSONObject(param);
            imgName = json.getString("name");
            saveImage.pickImageFromGallery(imgName);
            addOnActivityResultListener(new OnActivityResultListener() {
                @Override
                public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
                    if (resultCode == Activity.RESULT_OK) {
                        if (requestCode == SaveImage.PHOTO_PICKED_WITH_DATA) {
                            saveImage.cropImageFromPhoto(data);
                            return true;
                        } else if (requestCode == SaveImage.PHOTO_CROP_WITH_DATA) {
                            saveImage.saveBitmapImage(data);
                            onActivityResultListeners.remove(this);
                            return true;
                        } else if (requestCode == SaveImage.PHOTO_PICKED_WITH_DATA_KITKAT) {
                            saveImage.cropImageFromPhotoKitkat(data);
                            return true;
                        }
                    } else {
                        if (requestCode == SaveImage.PHOTO_PICKED_WITH_DATA || requestCode == SaveImage.PHOTO_CROP_WITH_DATA || requestCode == SaveImage.PHOTO_PICKED_WITH_DATA_KITKAT) {
                            onActivityResultListeners.remove(this);
                            saveImage.saveBitmapImage(data);
                            return true;
                        }
                    }
                    return false;
                }
            });

        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void uploadImage(String param, String key) {
        JSONObject upResult = null;
        try {
            upResult = new JSONObject(param);
            String url = upResult.getString("url");
            String api = upResult.getString("api");
            String imgName = upResult.getString("uploadImageName");
            String sid = upResult.getString("sid");
            String time = upResult.getString("time");
            String sig = upResult.getString("sig");
            String upload = upResult.getString("upload");
            String mid = upResult.getString("mid");
            int type = upResult.getInt("type");
            Log.e("", "type = " + type);
            UploadImage.toUploadImage(Game.getInstance(), imgName,
                    api, url, key, type, mid, sid, time, sig, upload);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void uploadFeedbackImage(String param, String key) {
        JSONObject upResult = null;
        try {
            upResult = new JSONObject(param);
            String url = upResult.getString("url");
            String api = upResult.getString("api");
            String imgName = upResult.getString("uploadImageName");
            int type = upResult.getInt("type");
            Log.e("", "type = " + type);
            UploadImage.toUploadImage(Game.getInstance(), imgName,
                    api, url, key, type, "", "", "", "", "");
        } catch (JSONException e) {
            e.printStackTrace();
        }

    }

    private void openLink(final String param, final String key) {
        postMessage(new Runnable() {
            @Override
            public void run() {
                try {
                    JSONObject upResult = new JSONObject(param);
                    String url = upResult.getString("url");
                    Intent viewIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
                    mActivity.startActivity(viewIntent);
                } catch (Exception e) {

                }

            }
        });

    }

    private void openWeb(String param, String key) {
        JSONObject upResult = null;
        try {
            upResult = new JSONObject(param);
            String url = upResult.getString("url");
            String api = upResult.getJSONObject("api").toString();
            //
            Message msg = new Message();
            msg.what = HANDLER_OPEN_WEB;
            msg.obj = url + "?m=activities&appid=9301&api=" + api;
            Log.e("", "openWeb");
            sendMessage(msg);


        } catch (JSONException e) {
            e.printStackTrace();
        }

    }

    private void closeWeb(String param, String key) {
        Log.e("", "closeWeb");
        sendEmptyMessage(HANDLER_CLOSE_WEB);
    }


    public Map jsonToObject(String jsonStr) throws Exception {
        JSONObject jsonObj = new JSONObject(jsonStr);
        Iterator<String> nameItr = jsonObj.keys();
        String name;
        Map<String, String> outMap = new HashMap<String, String>();
        while (nameItr.hasNext()) {
            name = nameItr.next();
            outMap.put(name, jsonObj.getString(name));
        }
        return outMap;
    }


    public void makePurchase(String orderId, String userId, String merchantId, String smsAddr) {

        Log.e("pay", "makePurchase  in");
        Map<String, String> payBack = new HashMap<String, String>();
        String smsTo = ""; // 短信发送的地址
        String smsContent = "";
        SMSSendCallBack smscallback = new SMSSendCallBack() {
            Map<String, String> payBack = new HashMap<String, String>();

            @Override
            public void onSuccess(int code) {
                //	callback(100,"");
                Log.d("zyh", "onSuccess " + code);
                payBack.put("code", "100");
                JsonUtil json = new JsonUtil(payBack);
                final String jsonStr = json.toString();
                Game.getInstance().callLuaFunc("Android_E2PayBack", jsonStr);
            }

            @Override
            public void onFailed(int code) {
                //	callback(300 + code,"");
                Log.d("zyh", "onFailed " + code);
                payBack.put("code", String.format("%d", 400 + code));
                JsonUtil json = new JsonUtil(payBack);
                final String jsonStr = json.toString();
                Game.getInstance().callLuaFunc("Android_E2PayBack", jsonStr);
            }

        };

        /** 将价格转换为价格ID **/
//		float f_price = 0f;
//		try{
//			f_price =  Float.parseFloat(priceId + "");
//		}catch(Exception e){
//			f_price = 0f;
//		}
//		String i_price = (int) f_price + ""; // 防止传入的价格带小数点
//		String priceID = "";
//		if (i_price.equals("10")) {
//			priceID = "01";
//		} else if (i_price.equals("20")) {
//			priceID = "02";
//		} else if (i_price.equals("49")) {
//			priceID = "04";
//		} else if (i_price.equals("79")) {
//			priceID = "07";
//		} else if (i_price.equals("99")) {
//			priceID = "09";
//		} else if (i_price.equals("149")) {
//			priceID = "14";
//		} else {
//			//callback(500,"");
//			return;
//		}
        int flag = 1;
        smsContent = merchantId.trim() + " " + orderId;
        if (flag == 1) {// 自动检测SIM运营商
            Log.e("pay", "makePurchase  in 1");
//			smsTo = "42105" + priceID;
            int code = SmsUtils.sendSmsAndToast(Game.getInstance(), smsAddr,
                    smsContent, smscallback);
            if (code != 0) {
                //	callback(400 + code,"");
                Log.d("zyh ", " code != 0 " + code);
                payBack.put("code", String.format("%d", 300 + code));
                JsonUtil json = new JsonUtil(payBack);
                final String jsonStr = json.toString();
                Game.getInstance().callLuaFunc("Android_E2PayBack", jsonStr);
            }
        }
//		} else if (flag == 2) {// 手动选择AIX
//			smsTo = "42105" + priceID;
//			SmsUtils.sendSmsAndToast(Game.getInstance(), smsTo,
//					smsContent, smscallback);
//		} else if (flag == 3) {// 手动选择DTAC,TRUEMOVE和TRUEMOVEH
//			smsTo = "42100" + priceID;
//			SmsUtils.sendSmsAndToast(Game.getInstance(), smsTo,
//					smsContent, smscallback);
//		} else if (flag == 4) {// 跳转到系统自带短信发送窗口
//			try {
//				Intent it = new Intent(Intent.ACTION_SENDTO, Uri.parse("smsto:42105" + priceID));
//				it.putExtra("sms_body", smsContent);
//				Game.getInstance().startActivity(it);
//			} catch (Exception e) {
//
//			}
////			toSendSMSActivity(Uri.parse("smsto:42105" + priceID),smsContent);
//		} else if (flag == 5) {
//			try {
//				Intent it = new Intent(Intent.ACTION_SENDTO, Uri.parse("smsto:42100" + priceID));
//				it.putExtra("sms_body", smsContent);
//				Game.getInstance().startActivity(it);
//			} catch (Exception e) {
//
//			}
////			toSendSMSActivity(Uri.parse("smsto:42100" + priceID),smsContent);
//
//		}
        return;
    }

    //{"pmode":"600","ORDER":"000713320600BYORDFLG003150090994","sitemid":"911488756737909","PAMOUNT_UNIT":"THB","PAMOUNT":"10"}
    private void pay(final String param, String key) {
        Log.e("pay", param);
        Map<String, String> paramMap = null;
        try {
            paramMap = jsonToObject(param);
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (paramMap != null) {
            String pmode = paramMap.get("pmode");
            if (pmode.equals("600")) {
                Log.e("pay", "makePerchase");
                makePurchase(paramMap.get("ORDER"), paramMap.get("sitemid"), paramMap.get("payID"), paramMap.get("smsAddr"));

            } else if (pmode.equals("601")) {
                String url = paramMap.get("url");
                Log.e("pay", "LinePay  601");
                Log.e("pay", url);

                openLink(param, "");
            } else {

                postMessage(new Runnable() {
                    @Override
                    public void run() {
                        GodSDKIAP.getInstance().requestPay(mActivity, param);
                    }
                });
            }
        }
    }

    /*
        检查是否有未完成checkout订单
    * */
    private void checkUnfinishIAP(final String param, String key) {
        Log.e("zyh", "checkUnfinishIAP");
//		mActivity.callLuaFunc("reportJavaLog", "java checkUnfinishIAP");
        postMessage(new Runnable() {
            @Override
            public void run() {
//				mActivity.callLuaFunc("reportJavaLog", "postMessage run");
                try {
//					mActivity.callLuaFunc("reportJavaLog", "doQueryInventory 12");
                    GodSDKIAP.getInstance().callSpecialMethod("12", "doQueryInventory", null, new SpecialMethodListener() {

                        @Override
                        public void onCallFailed(CallbackStatus status, Map arg1) {
//						mActivity.callLuaFunc("reportJavaLog", "onCallFailed");
                            Log.e("zyh", "checkUnfinishIAP onCallFailed");
                            try {
//							Map<String, String> jsonResult = new HashMap<String, String>();
//							jsonResult.put("status", "1");
//							jsonResult.put("pmode", "12");
//							jsonResult.put("test", "1");
//							final JsonUtil util = new JsonUtil(jsonResult);
//							mActivity.callLuaFunc(GameHandler.kPay, util.toString());
//							mActivity.callLuaFunc("reportJavaLog", "onCallFailed finish ");
                            } catch (Exception e) {
//							mActivity.callLuaFunc("reportJavaLog", "onCallFailed exception "+e.toString());
                                e.printStackTrace();
                            }
                        }

                        @Override
                        public void onCallSuccess(CallbackStatus status, Map map) {
                            Log.e("zyh", "checkUnfinishIAP onCallSuccess");
//						mActivity.callLuaFunc("reportJavaLog", "onCallSuccess");
                            //获取未消耗商品列表，结果是一个jsonArray格式的字符串
                            String result = (String) map.get("purchaseOwns");

                            //开始解析返回结果
                            try {
                                JSONArray json = new JSONArray(result);
                                Log.e("", "check out json " + json.length());
                                for (int i = 0; i < json.length(); i++) {
                                    JSONObject jo = (JSONObject) json.get(i);
                                    //通知发货
                                    Map<String, String> jsonResult = new HashMap<String, String>();
                                    jsonResult.put("status", "0");
                                    jsonResult.put("pmode", "12");
                                    jsonResult.put("signedData", (String) jo.get("OriginalJson"));
                                    jsonResult.put("signature", (String) jo.get("Signature"));
                                    final JsonUtil util = new JsonUtil(jsonResult);
                                    mActivity.callLuaFunc(GameHandler.kPay, util.toString());
//								mActivity.callLuaFunc("reportJavaLog", "onCallSuccess finish");
                                }
                            } catch (JSONException e) {
                                e.printStackTrace();
//							Map<String, String> jsonResult = new HashMap<String, String>();
//							jsonResult.put("status", "1");
//							jsonResult.put("pmode", "12");
//							jsonResult.put("test", "2");
//							jsonResult.put("exception", e.toString());
//							final JsonUtil util = new JsonUtil(jsonResult);
//							mActivity.callLuaFunc(GameHandler.kPay, util.toString());
//							mActivity.callLuaFunc("reportJavaLog", "onCallSuccess excetpion " + e.toString());
                            }
                        }
                    });
                } catch (Exception e) {
//					Map<String, String> jsonResult = new HashMap<String, String>();
//					jsonResult.put("status", "1");
//					jsonResult.put("pmode", "12");
//					jsonResult.put("test", "2");
//					jsonResult.put("exception", e.toString());
//					final JsonUtil util = new JsonUtil(jsonResult);
//					mActivity.callLuaFunc(GameHandler.kPay, util.toString());
//					mActivity.callLuaFunc("reportJavaLog", "postMessage run excetpion " + e.toString());
                }
            }
        });

    }

    /*
        完成订单
    * */
    private void consumeProduct(final String param, String key) {
        Log.e("zyh", "consumeProduct");
        JSONObject paramJson = null;
        try {
            paramJson = new JSONObject(param);
            final String productId = paramJson.getString("productId");
            postMessage(new Runnable() {
                @Override
                public void run() {
                    Map<String, Object> map = new HashMap<String, Object>();
                    map.put("sku", productId); //sku为商品id，是在google商品后台配置
                    GodSDKIAP.getInstance().callSpecialMethod("12", "doConsumeSku", map, new SpecialMethodListener() {
                        @Override
                        public void onCallFailed(CallbackStatus status, Map arg1) {
                            Log.d("zyh", "consumeProduct onCallFailed");
                        }

                        @Override
                        public void onCallSuccess(CallbackStatus status, Map arg1) {
                            Log.d("zyh", "consumeProduct onCallSuccess");
                        }
                    });
                }
            });

        } catch (JSONException e) {
            e.printStackTrace();
        }

    }

    private void collectByUmeng(final String param, String key) {

        postMessage(new Runnable() {
            @Override

            public void run() {
                try {
                    Log.e("zyh", "collectByUmeng = " + param);
                    Map event = jsonToObject(param);
                    String eventID = null;

                    if (event.containsKey("eventID")) {
                        eventID = (String) event.get("eventID");
                    }
                    int num = 0;
                    if (event.containsKey("num")) {
                        num = Integer.parseInt((String) event.get("num"));
                    }

                    String eventTree = null;
                    HashMap map = null;
                    if (event.containsKey("event")) {
                        eventTree = (String) event.get("event");
                        map = (HashMap) jsonToObject(eventTree);
                    }
                    if (eventTree != null && map != null && map.size() > 0) {
                        Log.e("zyh", "collectByUmeng 计算事件 ");
                        MobclickAgent.onEventValue(mActivity, eventID, map, num);
                    } else {
                        Log.e("zyh", "collectByUmeng 计数事件 ");
                        MobclickAgent.onEvent(mActivity, eventID);
                    }
                } catch (Exception e) {
                    Log.e("zyh", "collectByUmeng Exception" + e.toString());
                    e.printStackTrace();
                }

            }
        });

    }

    private void setupActcenter(final String param, String key){
        postMessage(new Runnable() {
            @Override
            public void run() {
                try{
                    Map paramTab = jsonToObject(param);

                    String key = null;
                    String url = null;
                    String usrMid = null;
                    String api = null;
                    String channelId = null;
                    String sitemid = null;
                    String version = null;
                    String usrType = null;
                    String deviceNo = null;

                    String gameId = null;
                    int languageId = 0;

                    if (paramTab.containsKey("key")) {
                        key = (String) paramTab.get("key");
                    }else{
                        key = "";
                    }

                    if (paramTab.containsKey("url")){
                        url = (String) paramTab.get("url");
                    }else{
                        url = "";
                    }

                    if (paramTab.containsKey("mid")) {
                        usrMid = (String) paramTab.get("mid");
                    }else{
                        usrMid = "0";
                    }

                    if (paramTab.containsKey("api")) {
                        api = (String) paramTab.get("api");
                    }else{
                        api = "";
                    }

                    if (paramTab.containsKey("channelId")) {
                        channelId = (String) paramTab.get("channelId");
                    }else{
                        channelId = "";
                    }

                    if (paramTab.containsKey("sitemid")) {
                        sitemid = (String) paramTab.get("sitemid");
                    }else{
                        sitemid = "";
                    }

                    if (paramTab.containsKey("version")) {
                        version = (String) paramTab.get("version");
                    }else{
                        version = "1.0.0";
                    }

                    if (paramTab.containsKey("userType")) {
                        usrType = (String) paramTab.get("userType");
                    }else{
                        usrType = "";
                    }

                    if (paramTab.containsKey("deviceNo")) {
                        deviceNo = (String) paramTab.get("deviceNo");
                    }else{
                        deviceNo = "";
                    }

                    if (paramTab.containsKey("gameId")) {
                        gameId = (String) paramTab.get("gameId");
                    }else{
                        gameId = "0";
                    }

                    if (paramTab.containsKey("languageId")) {
                        languageId = (int) paramTab.get("languageId");
                    }else{
                        languageId = 1;
                    }

                    // ActivityCenter.getInstance().setup(key, url, usrMid, api, channelId, sitemid, version, usrType, deviceNo);
                    // ActivityCenter.getInstance().setOtherParam(gameId, languageId);
                    // ActivityCenter.getInstance().finishSession();
                }catch (Exception e){
                    Log.e("tsing", "setupActcenter Exception" + e.toString());
                    e.printStackTrace();
                }
            }
        });
    }

    private void actcenterSwitchSvr(final String param, String key){
        postMessage(new Runnable() {
            @Override
            public void run() {
                try{
                    Map paramTab = jsonToObject(param);

                    int svrId = 1;
                    if (paramTab.containsKey("serverId")) {
                        svrId = (int) paramTab.get("serverId");
                    }

                    // ActivityCenter.getInstance().switchServer(svrId);
                    // ActivityCenter.getInstance().finishSession();
                }catch (Exception e){
                    Log.e("tsing", "actcenterSwitchSvr Exception" + e.toString());
                    e.printStackTrace();
                }
            }
        });
    }

    private void setActCenterSkin(final String param, String key){
        postMessage(new Runnable() {
            @Override
            public void run() {
                try{
                    Map paramTab = jsonToObject(param);

                    String skinVer = null;

                    if (paramTab.containsKey("skinVersion")) {
                        skinVer = (String) paramTab.get("skinVersion");
                    }else{
                        skinVer = "v1";
                    }

                    // ActivityCenter.getInstance().setActCenterSkin(skinVer);
                }catch (Exception e){
                    Log.e("tsing", "setActCenterSkin Exception" + e.toString());
                    e.printStackTrace();
                }
            }
        });
    }

    private void actcenterDisplay(final String param, String key){
        postMessage(new Runnable() {
            @Override
            public void run() {
                // ActivityCenter.getInstance().display();
            }
        });
    }

    private void actcenterDisplayAct(final String param, String key){
        postMessage(new Runnable() {
            @Override
            public void run() {
                try{
                    Map paramTab = jsonToObject(param);

                    String actId = null;

                    if (paramTab.containsKey("actId")) {
                        actId = (String) paramTab.get("actId");
                    }else{
                        actId = "";
                    }

                    // ActivityCenter.getInstance().displayAct(actId);
                }catch (Exception e){
                    Log.e("tsing", "actcenterDisplayAct Exception" + e.toString());
                    e.printStackTrace();
                }
            }
        });
    }

    private void actcenterDisplayRelate(final String param, String key){
        postMessage(new Runnable() {
            @Override
            public void run() {
                try{
                    Map paramTab = jsonToObject(param);

                    int displaySize = 0;

                    if (paramTab.containsKey("size")) {
                        displaySize = (int) paramTab.get("size");
                    }else{
                        displaySize = 1;
                    }

                    // ActivityCenter.getInstance().displayRelated(displaySize);
                }catch (Exception e){
                    Log.e("tsing", "actcenterDisplayRelate Exception" + e.toString());
                    e.printStackTrace();
                }
            }
        });
    }

    public void actcenterClearCache(){
        // ActivityCenter.getInstance().clearCache();
    }

    public void actcenterCallLua(){
//        Game.getInstance().callLuaFunc("ajwkj","wakjdawj");
//        callLuaFuncFail
    }

    /*
     * Facebook登录
     * */
    private void login(final String param, String key) {
        postMessage(new Runnable() {
            @Override
            public void run() {
                FBEntityEx.getInstance().login();
            }
        });

    }

    /*
     * Facebook登出
     * */
    private void logout(final String param, String key) {
        JSONObject json;
        try {
            json = new JSONObject(param);
            int loginType = json.getInt("loginType");
            if (loginType == 1) {
                postMessage(new Runnable() {
                    @Override
                    public void run() {
                        Log.e("", "run facebook logout");
                        FBEntityEx.getInstance().logout();
                    }
                });
            }
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

    }

    private void getFbAppInfo(final String param, String key) {
        postMessage(new Runnable() {
            @Override
            public void run() {
                FBEntityEx.getInstance().getAppRequest();
            }
        });
    }

    /*
     * Facebook获取好友
     * */
    private void getFbFriend(final String param, String key) {
        Log.d("zyh", "java getFbFriend ");
        postMessage(new Runnable() {
            @Override
            public void run() {
                FBEntityEx.getInstance().getInvitableFriends();
            }
        });
    }

    /*
     * 邀请Facebook好友
     * */
    private void inviteFbFriend(final String param, String key) {
        postMessage(new Runnable() {
            @Override
            public void run() {
                FBEntityEx.getInstance().sendInvites(param);
            }
        });
    }

    /**
     * @param param
     * @param key
     */
    private void share(final String param, String key) {
        postMessage(new Runnable() {

            @Override
            public void run() {
                // TODO Auto-generated method stub
                FBEntityEx.getInstance().share(param);
            }
        });
    }

    private void getClientId(final String param, String key) {
        /**
         postMessage(new Runnable() {

        @Override public void run() {
        // TODO Auto-generated method stub
        String clientId = GodSDKPush.getInstance().getRegistrationId(Game.getInstance());
        if (clientId != null) {
        Log.d(TAG, "clientId = " + clientId);
        Map<String, Object> json = new HashMap<String, Object>();
        json.put("clientId", clientId);
        final JsonUtil util = new JsonUtil(json);
        Game.getInstance().callLuaFunc("postClientId", util.toString());
        } else {
        Log.d(TAG, "clientId == null");
        }
        }
        });
         */
        new AsyncTask() {
            protected Object doInBackground(final Object... params) {
                String token;
                try {

                    token = Game.getInstance().getGcm().register(Game.getInstance().getString(R.string.project_number));
                    Log.i(TAG, "token is " + token);
                    if (token != null) {
                        Log.d(TAG, "clientId = " + token);

                        Map<String, Object> json = new HashMap<String, Object>();
                        json.put("clientId", token);
                        final JsonUtil util = new JsonUtil(json);
                        Game.getInstance().callLuaFunc("postClientId", util.toString());
                    } else {
                        Log.d(TAG, "clientId == null");
                    }
                } catch (IOException e) {
                    Log.i(TAG, e.getMessage());
                } catch (SecurityException e) {
                    Log.i("Registration Error", e.getMessage());
                } catch (Exception e) {

                }
                return true;
            }
        }.execute(null, null, null);
    }

    /**
     * @param param
     * @param key
     */
    private void score(final String param, String key) {
        postMessage(new Runnable() {

            @Override
            public void run() {
                // TODO Auto-generated method stub
                Uri uri = Uri.parse("market://details?id=" + Game.getInstance().getPackageName());
                Intent intent = new Intent(Intent.ACTION_VIEW, uri);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                Game.getInstance().startActivity(intent);
            }
        });
    }

    /*
     * 邀请Sms好友
     * */
    private void inviteSmsFriend(final String param, String key) {
        postMessage(new Runnable() {
            @Override
            public void run() {
                JSONObject json;
                try {
                    json = new JSONObject(param);
                    String content = json.getString("content");
                    TelephonyManager telphony = (TelephonyManager) Game.getInstance().getSystemService(Context.TELEPHONY_SERVICE);
                    //String phoneNumber = telphony.getLine1Number();
                    Uri smsToUri = Uri.parse("smsto:");
                    Intent intent = new Intent(Intent.ACTION_SENDTO, smsToUri);
                    intent.putExtra("sms_body", content);
                    intent.putExtra("msgFlag", MsgInviteReceiver.MsgInviteFlag);
                    Game.getInstance().startActivity(intent);
                } catch (JSONException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }

            }
        });
    }
//
//case HandlerManager.HANDLER_SYSTEM_INVITE:
//	data = msg.getData().getString("data");
//	try {
//		JSONObject json = new JSONObject(data);
//		int type = json.getInt("type");
//		String title = json.getString("title");
//		String content = json.getString("content");
//		String url = json.getString("url");
//		if(type==1){
//			TelephonyManager telphony=(TelephonyManager)this.getSystemService(Context.TELEPHONY_SERVICE);
//			String phoneNumber = telphony.getLine1Number();
//			Uri smsToUri = Uri.parse("smsto:"+phoneNumber);
//			Intent intent = new Intent(Intent.ACTION_SENDTO, smsToUri);
//			intent.putExtra("sms_body", content);
//			intent.putExtra("msgFlag", MsgInviteReceiver.MsgInviteFlag);
//			startActivity(intent);
//		}else if(type==2){
//			String selectEmailStr = json.getString("selectEmailStr");
//			Intent intent = new Intent(Intent.ACTION_SEND);
//			//intent.setType("plain/text");
//			intent.setType("message/rfc822");
//			intent.putExtra(Intent.EXTRA_SUBJECT, title);
//			intent.putExtra(Intent.EXTRA_TEXT, content);
//			startActivity(Intent.createChooser(intent, selectEmailStr));
//		}
//	} catch (Exception e) {
//		e.printStackTrace();
//	}
//	break;

    private void openRule(String param, String key) {
        JSONObject upResult = null;
        try {
            upResult = new JSONObject(param);
            String url = upResult.getString("url");
            String api = upResult.getJSONObject("api").toString();
            //
            Message msg = new Message();
            msg.what = HANDLER_OPEN_RULE;
            msg.obj = url + "&api=" + api;
            Log.e("", "openRule");
            sendMessage(msg);

        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void closeRule(String param, String key) {
        sendEmptyMessage(HANDLER_CLSOE_RULE);
    }

//	private void updatePackByUmeng(String param, String key)
//	{
//		Log.e("","updatePackByUmengc");
//		Message msg = new Message();
//		msg.what 	= HANDLER_UMENG_UPDATA_PACK;
//		msg.obj 	= param;
//		sendMessage(msg);
//	}

    private void updatePackByLocal(String param, String key) {
        Message msg = new Message();
        msg.what = HANDLER_LOCAL_UPDATA_PACK;
        msg.obj = param;
        sendMessage(msg);
    }

    private void checkPackByLocal(String param, String key) {
        Message msg = new Message();
        msg.what = HANDLER_CHECK_LOCAL_UPDATA_PACK;
        msg.obj = param;
        sendMessage(msg);
    }

    private void downloadImage(String param, String key) {
        new DownloadImageFile(param, key);
    }

    private void renameImage(String param, String key) {
        JSONObject upResult = null;
        try {
            upResult = new JSONObject(param);
            String oldName = upResult.getString("oldName");
            String newName = upResult.getString("newName");
            String url = upResult.getString("url");


            File file = new File(Game.getInstance().getImagePath() + "/head_images");
            if (!file.exists()) {
                file.mkdir();
            }

            File file1 = new File(Game.getInstance().getImagePath() + oldName);
            File file2 = new File(Game.getInstance().getImagePath() + newName);
            file2.delete();
            boolean ret = file1.renameTo(file2);
            TreeMap<String, Object> map = new TreeMap<String, Object>();
            map.put("status", ret ? 1 : 0);
            map.put("newName", newName);
            map.put("url", url);
            JsonUtil json = new JsonUtil(map);
            final String jsonStr = json.toString();

            Game.getInstance().runOnLuaThread(new Runnable() {
                public void run() {
                    Dict.setString(kcallLuaFunc, kcallLuaFunc, "renameImage");
                    Dict.setInt("renameImage", kCallResult, 0);
                    Dict.setString("renameImage", "renameImage" + kResultPostfix, jsonStr);
                    Sys.callLua(kCallLuaEvent);
                }
            });

        } catch (JSONException e) {
            e.printStackTrace();
        }

    }

    private void downloadFile(final String param, final String key) {
		/* 从URI地址拉图片过来 */
        ThreadTask.start(Game.getInstance(), "", false, new OnThreadTask() {
            private String mUrl;
            private String mFile;
            private String mType;
            private String mTag;
            private int mStatus = 0;
            private String mErrorReason = "";
            private float downSize = 0;

            @Override
            public void onThreadRun() {
                try {
                    JSONObject downloadJson = null;

                    downloadJson = new JSONObject(param);
                    String file = downloadJson.getString("file");
                    String url = downloadJson.getString("url");
                    String type = downloadJson.getString("type");
                    String tag = downloadJson.getString("tag");
                    String tmpFile = file + "tmp";
                    mUrl = url;
                    mFile = file;
                    mType = type;
                    mTag = tag;
                    if (type.equals("image")) {
                        file = Game.getInstance().getImagePath() + file;
                        tmpFile = Game.getInstance().getImagePath() + tmpFile;
                    } else if (type.equals("audio")) {
                        file = Game.getInstance().getAudioPath() + file;
                        tmpFile = Game.getInstance().getAudioPath() + tmpFile;
                    } else if (type.equals("update")) {
                        file = Game.getInstance().getUpdatePath() + file;
                        tmpFile = Game.getInstance().getUpdatePath() + tmpFile;
                        Log.e("", "update file=" + file);
                    } else if (type.equals("updatezip")) {
                        file = Game.getInstance().getUpdateZipPath() + file;
                        tmpFile = Game.getInstance().getUpdateZipPath() + tmpFile;
                    } else {
                        return;
                    }

                    PathUtil.mkdir(tmpFile);

                    Log.e("", "http get=" + url);

                    BasicHttpParams httpParams = new BasicHttpParams();
                    //设置连接5秒超时和接收数据20秒超时超时
                    HttpConnectionParams.setConnectionTimeout(httpParams, 10000);
                    HttpConnectionParams.setSoTimeout(httpParams, 15000);
                    HttpResponse response = new DefaultHttpClient(httpParams).execute(new HttpGet(url));
                    if (response.getStatusLine().getStatusCode() != 200)
                        return;
                    HttpEntity httpEntity = response.getEntity();
                    InputStream is = httpEntity.getContent();
                    long totalSize = httpEntity.getContentLength();
                    System.out.println("需要下载的文件大小为" + totalSize);
                    File fTmpFile = new File(tmpFile);
                    FileOutputStream fos = new FileOutputStream(fTmpFile);
                    byte[] buffer = new byte[4096];
                    int size = 0;
                    int progress = 0;
                    //用来刷新上一次的进度，防止过多刷新主线程
                    int lastProgress = 0;
                    while (true) {
                        size = is.read(buffer);
                        if (size > 0) {
                            fos.write(buffer, 0, size);
                            TreeMap<String, Object> map = new TreeMap<String, Object>();
                            map.put("status", 2);
                            map.put("path", mFile);
                            map.put("url", mUrl);
                            map.put("type", mType);
                            map.put("tag", mTag);
                            downSize = downSize + size;
                            progress = (int) ((downSize / totalSize) * 100.0f);
                            map.put("progress", progress); // 当前下载大小
                            map.put("downSize", downSize);
                            map.put("totalSize", totalSize);
                            System.out.println("当前下载的文件大小为" + downSize);
                            System.out.println("当前下载的文件进度为" + progress);
                            JsonUtil json = new JsonUtil(map);
                            final String jsonStr = json.toString();
                            if (progress - lastProgress >= 5) {
                                lastProgress = progress;
                                Game.getInstance().callLuaFunc(key, jsonStr);
                            }
                        } else {
                            //正常结束
                            if (size == -1) {
                                FileOp fileOperation = new FileOp();
                                fileOperation.deleteFile(file);
                                fTmpFile.renameTo(new File(file));
                                mStatus = 1;
                            }
                            //异常结束
                            else {
                                mStatus = 0;
                                mErrorReason = " size less than -1";
                            }
                            fos.flush();
                            fos.close();
                            buffer.clone();
                            is.close();
                            return;
                        }
                    }

                } catch (Exception e) {
                    Log.d("zyh", "downloadFile exception " + e.toString());
                    mErrorReason = " exception " + e.toString();
                    e.printStackTrace();
                }
            }

            @Override
            public void onAfterUIRun() {
                TreeMap<String, Object> map = new TreeMap<String, Object>();
                map.put("status", mStatus);
                map.put("path", mFile);
                map.put("url", mUrl);
                map.put("type", mType);
                map.put("tag", mTag);
                map.put("reason", mErrorReason);

                JsonUtil json = new JsonUtil(map);

                Game.getInstance().callLuaFunc(key, json.toString());
            }

            @Override
            public void onUIBackPressed() {
            }
        });
    }

    private void unzip(final String param, final String key) {
		/* 从URI地址拉图片过来 */
        ThreadTask.start(Game.getInstance(), "", false, new OnThreadTask() {
            private String mFile;
            private String mPath;
            private String mType;
            private String mTag;
            private int mStatus = 0;

            @Override
            public void onThreadRun() {
                try {
                    JSONObject downloadJson = null;

                    downloadJson = new JSONObject(param);
                    String file = downloadJson.getString("file");
                    String path = downloadJson.getString("path");
                    String type = downloadJson.getString("type");
                    String tag = downloadJson.getString("tag");
                    mFile = file;
                    mPath = path;
                    mType = type;
                    mTag = tag;

                    if (type.equals("image")) {
                        file = Game.getInstance().getImagePath() + file;
                        path = Game.getInstance().getImagePath() + path;
                    } else if (type.equals("audio")) {
                        file = Game.getInstance().getAudioPath() + file;
                        path = Game.getInstance().getAudioPath() + path;
                    } else if (type.equals("update")) {
                        file = Game.getInstance().getUpdateZipPath() + file;
                        path = Game.getInstance().getUpdatePath();
                    } else {
                        return;
                    }
                    Log.e("", "zip file = " + file);
                    Log.e("", "zip path = " + path);
                    boolean ret = GZUtil.unzipToDir(file, path);
                    mStatus = ret ? 1 : 0;
                    return;
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onAfterUIRun() {

                TreeMap<String, Object> map = new TreeMap<String, Object>();
                map.put("status", mStatus);
                map.put("file", mFile);
                map.put("path", mPath);
                map.put("type", mType);
                map.put("tag", mTag);

                JsonUtil json = new JsonUtil(map);
                final String jsonStr = json.toString();

                Game.getInstance().runOnLuaThread(new Runnable() {
                    public void run() {
                        Dict.setString(kcallLuaFunc, kcallLuaFunc, key);
                        Dict.setInt(key, kCallResult, 0);
                        Dict.setString(key, key + kResultPostfix, jsonStr);
                        Sys.callLua(kCallLuaEvent);
                    }
                });
            }

            @Override
            public void onUIBackPressed() {
            }
        });

    }

    /*
     * 解压游戏
     * */
    private void unzipGame(final String param, final String key) {
		/* 从URI地址拉图片过来 */
        final String rootPath = Dict.getString("android_app_info", "rootPath") + "/";

        ThreadTask.start(Game.getInstance(), "", false, new OnThreadTask() {
            private String mFile;
            private int mStatus = 0;

            @Override
            public void onThreadRun() {
                try {
                    JSONObject paramJson = null;
                    paramJson = new JSONObject(param);
                    mFile = paramJson.getString("file");

                    GZUtil.unzipToDir(rootPath + mFile, rootPath);
                    mStatus = 1;
                    return;
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onAfterUIRun() {
                TreeMap<String, Object> map = new TreeMap<String, Object>();
                map.put("status", mStatus);
                map.put("file", mFile);

                JsonUtil json = new JsonUtil(map);
                final String jsonStr = json.toString();

                Game.getInstance().runOnLuaThread(new Runnable() {
                    public void run() {
                        Dict.setString(kcallLuaFunc, kcallLuaFunc, key);
                        Dict.setInt(key, kCallResult, 0);
                        Dict.setString(key, key + kResultPostfix, jsonStr);
                        Sys.callLua(kCallLuaEvent);
                    }
                });
            }

            @Override
            public void onUIBackPressed() {
            }
        });

    }


    private void startRecord(final String param, final String key) {
        EventRecorder.getInstance().startRecord();
    }

    private void stopRecord(final String param, final String key) {
        EventRecorder.getInstance().stopRecord();
    }

    private void playBack(final String param, final String key) {
        EventRecorder.getInstance().playBack();
    }

    private void stopPlayBack(final String param, final String key) {
        EventRecorder.getInstance().stopPlayBack();
    }

    /**/
    public void boyaaAd(final String param, final String key) {
        postMessage(new Runnable() {

            @Override
            public void run() {
                // TODO Auto-generated method stub
                try {
                    JSONObject json = new JSONObject(param);
                    int type = json.optInt("type");
                    String value = json.optString("value");
                    HashMap<String, String> map = new HashMap<String, String>();
                    String appId = mActivity.getApplicationContext().getResources().getString(R.string.facebook_app_id);
                    map.put("fb_appId", appId);
                    map.put("uid", value);
                    if (type == BoyaaADUtil.METHOD_START) {
                        BoyaaADUtil.push(Game.getInstance(), map, BoyaaADUtil.METHOD_START);
                    } else if (type == BoyaaADUtil.METHOD_REG) {
                        Log.d("zyh", "register as " + json.optString("userType"));
                        map.put("userType", json.optString("userType"));
                        BoyaaADUtil.push(Game.getInstance(), map, BoyaaADUtil.METHOD_REG);
                    } else if (type == BoyaaADUtil.METHOD_LOGIN) {
                        BoyaaADUtil.push(Game.getInstance(), map, BoyaaADUtil.METHOD_LOGIN);
                    } else if (type == BoyaaADUtil.METHOD_PLAY) {
                        BoyaaADUtil.push(Game.getInstance(), map, BoyaaADUtil.METHOD_PLAY);
                    } else if (type == BoyaaADUtil.METHOD_PAY) {
                        String payMoney = json.optString("pay_money");
                        map.put("pay_money", payMoney);
                        String currencyCode = json.optString("currencyCode");
                        map.put("currencyCode", currencyCode);
                        map.put("order", json.optString("order"));
                        BoyaaADUtil.push(Game.getInstance(), map, BoyaaADUtil.METHOD_PAY);
                    } else if (type == BoyaaADUtil.METHOD_RECALL) {
                        BoyaaADUtil.push(Game.getInstance(), map, BoyaaADUtil.METHOD_RECALL);
                    } else if (type == BoyaaADUtil.METHOD_LOGOUT) {
                        BoyaaADUtil.push(Game.getInstance(), map, BoyaaADUtil.METHOD_LOGOUT);
                    } else if (type == BoyaaADUtil.METHOD_CUSTOM) {
                        map.put(Constant.AF_EVENT_CUSTOM, json.optString("event_name"));
                        BoyaaADUtil.push(Game.getInstance(), map, BoyaaADUtil.METHOD_CUSTOM);
                    } else if (type == BoyaaADUtil.METHOD_SHARE) {
                        BoyaaADUtil.push(Game.getInstance(), map, BoyaaADUtil.METHOD_SHARE);
                    } else if (type == BoyaaADUtil.METHOD_INVITE) {
                        BoyaaADUtil.push(Game.getInstance(), map, BoyaaADUtil.METHOD_INVITE);
                    } else if (type == BoyaaADUtil.METHOD_PURCHASE_CANCEL) {
                        BoyaaADUtil.push(Game.getInstance(), map, BoyaaADUtil.METHOD_PURCHASE_CANCEL);
                    }
                } catch (Exception e) {
                    // TODO: handle exception
                }
            }
        });
    }

    public void openActivity(final String param, final String key) {
        Game.getInstance().runOnUiThread(new Runnable() {
            public void run() {
                Log.d("openActivity", "openActivity");
                JSONObject activityParam = null;
                try {
                    activityParam = new JSONObject(param);
                    BoyaaAPI boyaaAPI = BoyaaAPI.getInstance(mActivity);
                    boyaaAPI.set_huodong_isSDK_back(true);
                    BoyaaAPI.BoyaaData boyaaData = boyaaAPI.getBoyaaData(mActivity);

                    boyaaData.setAppid(activityParam.optString("appId"));
                    boyaaData.setSecret_key(activityParam.optString("secret_key"));
                    boyaaData.setUrl(activityParam.optString("url"));

                    boyaaData.setMid(activityParam.optString("mid"));
                    boyaaData.setApi(activityParam.optString("sid"));
                    boyaaData.setChanneID(activityParam.optString("channelID"));

                    boyaaData.setVersion(activityParam.optString("version"));
                    boyaaData.setSitemid(activityParam.optString("sitemid"));
                    boyaaData.setDeviceno(activityParam.optString("sitemid"));
                    boyaaData.setUsertype(activityParam.optString("userType"));
                    boyaaData.cut_service(activityParam.optInt("debug"));
                    boyaaData.set_language(activityParam.optInt("language"));

//					boyaaData.set_current_lua_type("activity");
                    boyaaData.set_lua_class("com.boyaa.made.GameHandler");
                    boyaaData.set_lua_method("urlRedirect");
                    boyaaData.finish();
                    //open

//					BoyaaAPI boyaaAPI = BoyaaAPI.getInstance(mActivity);
//					boyaaAPI.set_huodong_anim_in(-1);
//					boyaaAPI.set_huodong_anim_out(-1);
//					boyaaAPI.set_close_by_oneClick(true);
                    int isReleated = activityParam.getInt("isReleated");
                    if (isReleated == -1) {
                        Log.d("zyh", "call display");
                        boyaaAPI.display(mActivity);
                    } else if (isReleated == -2) {
                        boyaaAPI.displayRelated(1150, 707);
                    } else {
                        Log.d("zyh", "call related");
                        boyaaAPI.displayRelated(isReleated);
                    }

                } catch (Exception e) {
                    Log.e("openActivity", e.toString());
                }
            }
        });


    }

    public void urlRedirect(final String key, final String param) {
        Log.e("", "urlRedirect");
        Log.e("", param);
        Log.e("", key);
        if (key == "activity") {
            Game.getInstance().runOnLuaThread(new Runnable() {
                public void run() {
                    String event = "ActivityGoFunction";
                    Dict.setString(kcallLuaFunc, kcallLuaFunc, event);
                    Dict.setInt(event, kCallResult, 0);
                    Dict.setString(event, event + kResultPostfix, param);
                    Sys.callLua(kCallLuaEvent);
                }
            });
        }
    }

    public void isMessengerExist(final String param, final String key) {
        if (MessengerUtils.hasMessengerInstalled(mActivity.getApplicationContext())) {
            Log.d("zyh", "MessengerExist");
            Dict.setInt(key, key + kResultPostfix, 1);
        } else {
            Log.d("zyh", "Messenger not Exist");
            Dict.setInt(key, key + kResultPostfix, 0);
        }

    }

    public void shareToMessenger(final String param, final String key) {
        FBEntityEx.getInstance().shareToMessenger(param);
//		Resources myAppRes = mActivity.getApplicationContext().getResources();
//		int myRes = R.drawable.fbmessengershare;
//		String myImgUri = ContentResolver.SCHEME_ANDROID_RESOURCE + "://" + myAppRes.getResourcePackageName(myRes)
//				+ "/" + myAppRes.getResourceTypeName(myRes) + "/" + String.valueOf(myRes);
//
//		String appId = mActivity.getApplicationContext().getResources().getString(R.string.facebook_app_id);
//
//		ShareToMessengerParams shareParam = ShareToMessengerParams.newBuilder(Uri.parse(myImgUri), "image/png", appId).setMetaData(param).build();
//		MessengerUtils.shareToMessenger(Game.getInstance(), 1, shareParam);
    }

    //用于获取启动方式，1表示从fb messenger启动
    public void getStartWay(final String param, final String key) {
        try {
            Log.d("zyh ", "getStartWay func");
            SharedPreferences deferred = mActivity.getSharedPreferences("deferredAppLinkData", Context.MODE_PRIVATE);
            String deferredData = deferred.getString("uri", "");
            //存在延迟深度链接的数据
            if (deferredData != null && (!deferredData.isEmpty())) {
                Log.d("zyh", "deferredData " + deferredData);
                TreeMap<String, Object> map = new TreeMap<String, Object>();
                map.put("startWay", "deepLink");
                map.put("metadata", deferredData);
                JsonUtil json = new JsonUtil(map);
                Dict.setString(key, key + kResultPostfix, json.toString());
                deferred.edit().clear().commit();
                return;
            }

            Intent intent = Game.getInstance().getIntent();
            if (intent == null) {
                Log.d("zyh ", "intent is null and return");
                Dict.setString(key, key + kResultPostfix, "");
                return;
            }

            String action = intent.getAction();
            if (action != null && !(action.isEmpty())) {
                Log.d("zyh", "action exist " + action);
                if (action.equals("android.intent.action.PICK")) {
                    Log.d("zyh ", "fbmessenger ");
                    MessengerThreadParams threadParams = MessengerUtils.getMessengerThreadParamsForIntent(intent);
                    if (threadParams != null) {
                        if (threadParams.origin == MessengerThreadParams.Origin.REPLY_FLOW) {
                            TreeMap<String, Object> map = new TreeMap<String, Object>();
                            map.put("startWay", "fbmessenger");
                            map.put("metadata", threadParams.metadata);
                            JsonUtil json = new JsonUtil(map);
                            Dict.setString(key, key + kResultPostfix, json.toString());
                            return;
                        }
                    }
                } else if (action.equals("android.intent.action.VIEW")) {
                    Log.d("zyh", "action view deep link");
                    Uri data = intent.getData();
                    Log.d("zyh", "data is " + data.toString());
                    TreeMap<String, Object> map = new TreeMap<String, Object>();
                    map.put("startWay", "deepLink");
                    map.put("metadata", data.toString());
                    final JsonUtil util = new JsonUtil(map);
                    Dict.setString(key, key + kResultPostfix, util.toString());
                    return;
                }
            }
            Log.d("zyh", "intent not from fb");
            if (intent.hasExtra("extra")) {
                Log.d("zyh", "getStartway notification");
                String extend = intent.getStringExtra("extra");
                Log.d("zyh", "intent has extra " + extend);
                TreeMap<String, Object> map = new TreeMap<String, Object>();
                map.put("startWay", "notification");
                map.put("metadata", extend);
                final JsonUtil util = new JsonUtil(map);
                Dict.setString(key, key + kResultPostfix, util.toString());
                return;
            } else {
                Log.d("zyh", "getStartway intent has no extras");
            }


            //其余错误情况
            Dict.setString(key, key + kResultPostfix, "");
        } catch (Exception e) {
            Log.d("zyh", "get start way exception " + e.toString());
            Dict.setString(key, key + kResultPostfix, "");
        }
    }

    //获取路径下的所有文件，用来解压游戏包用的
    public void getAllUpdateFile(final String param, final String key) {

        Log.d("zyh ", "getAllFile");
        JSONObject jsonParam = null;
        try {
            String path = Game.getInstance().getUpdateZipPath();
            Log.d("zyh ", "path is " + path);
            File mFile = new File(path);
            File[] allFile = mFile.listFiles();
            String resultString = "";
            for (int i = 0; i < allFile.length; ++i) {
                resultString += allFile[i].getName() + ",";
            }
            Log.d("zyh ", "resultString " + resultString);
            Dict.setString(key, key + kResultPostfix, resultString);
        } catch (Exception e) {
            Log.d("zyh ", "exception is " + e.toString());
            Dict.setString(key, key + kResultPostfix, "");
        }
    }

    //获取当前的网络类型
    public void getNetworkType(final String param, final String key) {
        boolean hasNetwork = APNUtil.isNetworkAvailable(mActivity);
        if (hasNetwork) {
            //有可用网络，检查网络类型
            String networkType = APNUtil.checkNetWork(mActivity);
            if (networkType.equals("wifi")) {
                Dict.setInt(key, key + kResultPostfix, 1);
            } else {
                Dict.setInt(key, key + kResultPostfix, 2);
            }
        } else {
            //没有网络，返回0
            Dict.setInt(key, key + kResultPostfix, 0);
        }
    }


    //定义文件操作类
    class FileOp {
        public boolean deleteFile(final String path) {
            File file = new File(path);
            if (file.isFile() && file.exists()) {
                return file.delete();
            }
            return false;
        }

        public boolean deleteDirectory(String path) {
            if (!path.endsWith(File.separator)) {
                path = path + File.separator;
            }
            File file = new File(path);
            if (!file.exists() || !file.isDirectory()) {
                Log.d("zyh ", "delete not exist" + path);
                return false;
            }
            boolean flag = true;
            File[] fileList = file.listFiles();
            for (int i = 0; i < fileList.length; ++i) {
                if (fileList[i].isFile()) {
                    flag = fileList[i].delete();
                    if (!flag) {
                        return false;
                    }
                } else {
                    //flag = deleteDirectory(fileList[i].getAbsolutePath());
                    flag = deleteDirectory(path + fileList[i].getName() + File.separator);
                    if (!flag) {
                        return false;
                    }
                }
            }
            return file.delete();
        }

        public boolean copyFolder(String oldPath, String newPath) {
            if (!oldPath.endsWith(File.separator)) {
                oldPath = oldPath + File.separator;
            }
            if (!newPath.endsWith(File.separator)) {
                newPath = newPath + File.separator;
            }
            File fileOld = new File(oldPath);
            File fileNew = new File(newPath);
            fileNew.mkdir();
            File[] fileList = fileOld.listFiles();
            for (int i = 0; i < fileList.length; ++i) {
                if (fileList[i].isFile()) {
                    try {
                        FileInputStream is = new FileInputStream(fileList[i]);
                        FileOutputStream os = new FileOutputStream(newPath + fileList[i].getName());
                        byte[] buffer = new byte[4096];
                        int len;
                        while ((len = is.read(buffer)) != -1) {
                            os.write(buffer, 0, len);
                        }
                        os.flush();
                        os.close();
                        is.close();

                    } catch (Exception e) {
                        Log.d("zyh", "copy scripts file fails");
                        return false;
                    }

                } else if (fileList[i].isDirectory()) {
                    copyFolder(oldPath + fileList[i].getName(), newPath + fileList[i].getName());
                }
            }
            return true;
        }

        public boolean renameFile(String oldPath, String newPath) {
            File oldFile = new File(oldPath);
            return oldFile.renameTo(new File(newPath));
        }

    }

    ;

    public void backupScripts(final String param, final String key) {

        String path = Game.getInstance().getUpdatePath() + "update" + File.separator + "scripts" + File.separator;
        String newPath = Game.getInstance().getUpdatePath() + "update" + File.separator + "scriptsbak" + File.separator;
        try {
            File file = new File(path);
            if (!file.exists()) {
                //update文件不存在，不需要copy
                Log.d("zyh ", "update/scripts file not exist ,no need to copy " + path);
                Dict.setInt(key, key + kResultPostfix, 1);
                return;
            }
            File fileBak = new File(newPath);
            FileOp fileOperation = new FileOp();
            if (!fileBak.exists()) {
                Log.d("zyh ", "backup file not exist");
                //文件不存在，正常新建然后拷贝
                if (fileOperation.copyFolder(path, newPath)) {
                    Log.d("zyh ", "backup success " + path + " " + newPath);
                    Dict.setInt(key, key + kResultPostfix, 1);
                } else {
                    Log.d("zyh ", "backup fail " + path + " " + newPath);
                    Dict.setInt(key, key + kResultPostfix, 0);
                }

            } else {
                //文件存在，可能是之前残留的，先删掉
                Log.d("zyh ", "backup file exist");
                if (fileOperation.deleteDirectory(newPath)) {
                    Log.d("zyh ", "backup file delete success " + newPath);
                    if (fileOperation.copyFolder(path, newPath)) {
                        Log.d("zyh ", "backup file copy  success ");
                        Dict.setInt(key, key + kResultPostfix, 1);
                    } else {
                        Log.d("zyh ", "backup file copy  fail ");
                        Dict.setInt(key, key + kResultPostfix, 0);
                    }
                } else {
                    Log.d("zyh", "backup exist and delete fail " + newPath);
                    Dict.setInt(key, key + kResultPostfix, 0);
                }

            }
        } catch (Exception e) {
            Log.d("zyh ", "backup scriptrs exception " + e.toString());
            Dict.setInt(key, key + kResultPostfix, 0);
        }
    }

    public void updateGameFinish(final String param, final String key) {
        Log.d("zyh", "update finish");
        String path = Game.getInstance().getUpdatePath() + "update" + File.separator + "scripts" + File.separator;
        String newPath = Game.getInstance().getUpdatePath() + "update" + File.separator + "scriptsbak" + File.separator;
        try {
            File filebak = new File(newPath);

            FileOp fileOperation = new FileOp();
            JSONObject json = new JSONObject(param);
            int updateResult = json.getInt("result");
            if (updateResult == 1) {
                //成功解压完所有的更新包
                Log.d("zyh", "unzip finally success ");
                if (!filebak.exists()) {
                    //不存在备份文件,无需任何处理
                    Log.d("zyh ", "no backup file exists");
                    return;
                }
                if (fileOperation.deleteDirectory(newPath)) {
                    Log.d("zyh ", "delete backup File success " + newPath);
                } else {
                    Log.d("zyh ", "delete backup File fail " + newPath);
                }
                Dict.setInt(key, key + kResultPostfix, 1);
            } else {
                //解压出现错误，删掉scripts文件夹，重命名scriptsbak
                Log.d("zyh", "unzip finally fail");

                if (fileOperation.deleteDirectory(path)) {
                    Log.d("zyh ", "delete success " + path);
                } else {
                    Log.d("zyh ", "delete fail " + path);
                    File mFile = new File(path);
                    File[] allFile = mFile.listFiles();
                    String resultString = "";
                    for (int i = 0; i < allFile.length; ++i) {
                        resultString += allFile[i].getName() + ",";
                    }
                    Log.d("zyh ", "after delete resultString " + resultString);
                }
                if (!filebak.exists()) {
                    //不存在备份文件,无需任何处理
                    Log.d("zyh ", "no backup file exists");
                    return;
                }
                if (fileOperation.renameFile(path, newPath)) {
                    Log.d("zyh", "renamFile success " + path + " " + newPath);
                } else {
                    Log.d("zyh", "renamFile fail " + path + " " + newPath);
                }
                Dict.setInt(key, key + kResultPostfix, 1);
            }

        } catch (Exception e) {
            Log.d("zyh", "updateGameFinish exception " + e.toString());
            Dict.setInt(key, key + kResultPostfix, 0);
        }
    }

    public void deleteFile(final String param, final String key) {

        try {
            FileOp fileOperation = new FileOp();
            JSONObject json = new JSONObject(param);
            String deleteType = json.getString("type");
            Log.d("zyh", "deleteType is " + deleteType);
            Log.d("zyh", " is eqaul " + deleteType.equals("updateZipDir"));
            if (deleteType.equals("updateZip")) {
                Log.d("zyh", "delete updateZip");
                String deleteFile = json.getString("file");
                //删除源文件和临时文件
                String path = Game.getInstance().getUpdateZipPath() + deleteFile;
                fileOperation.deleteFile(path);
                String tmpFile = path + "tmp";
                fileOperation.deleteFile(tmpFile);
            }
            //清除已经解压的update文件夹，用于已知崩溃情况的处理。
            else if (deleteType.equals("update")) {
                Log.d("zyh", "delete update");
                String path = Game.getInstance().getUpdatePath() + "update" + File.separator + "scripts" + File.separator;
                fileOperation.deleteDirectory(path);
            } else if (deleteType.equals("updateZipDir")) {
                Log.d("zyh", "delete updateZipDir");
                String path = Game.getInstance().getUpdateZipPath();
                fileOperation.deleteDirectory(path);
            } else {
                Log.d("zyh", "deleteFile not find type");
            }

        } catch (Exception e) {
            Log.d("zyh", "delete file fail " + e.toString());
        }

    }

    public void getLocation(final String param, final String key) {
        Location pos = APNUtil.getLocation(mActivity);
        if (pos != null) {
            TreeMap<String, Object> map = new TreeMap<String, Object>();
            map.put("latitude", pos.getLatitude());
            map.put("longitude", pos.getLongitude());
            map.put("accuracy", pos.getAccuracy());
            JsonUtil json = new JsonUtil(map);
            final String jsonStr = json.toString();
            Dict.setString(key, key + kResultPostfix, jsonStr);
        }
    }

    public void getFileMD5(final String param, final String key) {
        try {
            JSONObject downloadJson = null;

            downloadJson = new JSONObject(param);
            String fileName = downloadJson.getString("file");
            String type = downloadJson.getString("type");
            if (type.equals("updateZip")) {
                String file = Game.getInstance().getUpdateZipPath() + fileName;
                File calFile = new File(file);
                if (!calFile.isFile()) {
                    Log.d("zyh ", "not a file " + file);
                    return;
                }
                FileInputStream inFile = new FileInputStream(calFile);
                byte buffer[] = new byte[4096];
                MessageDigest digest = MessageDigest.getInstance("MD5");
                while (true) {
                    int len = inFile.read(buffer, 0, 4096);
                    if (len > 0) {
                        digest.update(buffer, 0, len);
                    }
                    //正常结束
                    else if (len == -1) {
                        Log.d("zyh", "calculate finish " + file);
                        break;
                    }
                    //文件读取错误
                    else {
                        return;
                    }
                }
                inFile.close();
                BigInteger bigInt = new BigInteger(1, digest.digest());
                String result = bigInt.toString(16).toLowerCase();
                Log.d("zyh", "cal md5 finish " + result);
                Dict.setString(key, key + kResultPostfix, result);
                return;
            }
            Dict.setString(key, key + kResultPostfix, "");
        } catch (Exception e) {
            Log.d("zyh ", "calFileMd5 exception " + e.toString());
            e.printStackTrace();
            Dict.setString(key, key + kResultPostfix, "");
        }
    }

    public void getPermission(String param, String key) {
        Log.d("zyh ", "getPermission " + param);
        try {
            JSONObject json = new JSONObject(param);
            String permission = json.getString("permission");
            String actualPer = null;
            DialogInterface.OnClickListener okListener = null;
            int requestCode = 1;
            if (permission.equals("storage")) {
                actualPer = Manifest.permission.WRITE_EXTERNAL_STORAGE;
                requestCode = ConstantValue.REQUEST_CODE_STORAGE;
                okListener = new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        ActivityCompat.requestPermissions(mActivity, new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, ConstantValue.REQUEST_CODE_STORAGE);
                    }
                };
            } else if (permission.equals("sms")) {
                actualPer = Manifest.permission.SEND_SMS;
                requestCode = ConstantValue.REQUEST_CODE_SMS;
                okListener = new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        ActivityCompat.requestPermissions(mActivity, new String[]{Manifest.permission.SEND_SMS}, ConstantValue.REQUEST_CODE_SMS);
                    }
                };
            } else if (permission.equals("location")) {
                actualPer = Manifest.permission.ACCESS_FINE_LOCATION;
                requestCode = ConstantValue.REQUEST_CODE_LOCATION;
                okListener = new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        ActivityCompat.requestPermissions(mActivity, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, ConstantValue.REQUEST_CODE_LOCATION);
                    }
                };
            } else if (permission.equals("calendar")) {
                actualPer = Manifest.permission.WRITE_CALENDAR;
                requestCode = ConstantValue.REQUEST_CODE_CALENDAR;
                okListener = new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        ActivityCompat.requestPermissions(mActivity, new String[]{Manifest.permission.WRITE_CALENDAR}, ConstantValue.REQUEST_CODE_CALENDAR);
                    }
                };
            } else if (permission.equals("camera")) {
                actualPer = Manifest.permission.CAMERA;
                requestCode = ConstantValue.REQUEST_CODE_CAMERA;
                okListener = new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        ActivityCompat.requestPermissions(mActivity, new String[]{Manifest.permission.CAMERA}, ConstantValue.REQUEST_CODE_CAMERA);
                    }
                };
            } else if (permission.equals("contacts")) {
                actualPer = Manifest.permission.WRITE_CONTACTS;
                requestCode = ConstantValue.REQUEST_CODE_CONTACTS;
                okListener = new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        ActivityCompat.requestPermissions(mActivity, new String[]{Manifest.permission.WRITE_CONTACTS}, ConstantValue.REQUEST_CODE_CONTACTS);
                    }
                };
            } else if (permission.equals("microphone")) {
                actualPer = Manifest.permission.RECORD_AUDIO;
                requestCode = ConstantValue.REQUEST_CODE_MICROPHONE;
                okListener = new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        ActivityCompat.requestPermissions(mActivity, new String[]{Manifest.permission.RECORD_AUDIO}, ConstantValue.REQUEST_CODE_MICROPHONE);
                    }
                };
            } else if (permission.equals("phone")) {
                actualPer = Manifest.permission.READ_PHONE_STATE;
                requestCode = ConstantValue.REQUEST_CODE_PHONE;
                okListener = new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        ActivityCompat.requestPermissions(mActivity, new String[]{Manifest.permission.READ_PHONE_STATE}, ConstantValue.REQUEST_CODE_PHONE);
                    }
                };
            } else if (permission.equals("sensors")) {
                actualPer = Manifest.permission.BODY_SENSORS;
                requestCode = ConstantValue.REQUEST_CODE_SENSORS;
                okListener = new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        ActivityCompat.requestPermissions(mActivity, new String[]{Manifest.permission.BODY_SENSORS}, ConstantValue.REQUEST_CODE_SENSORS);
                    }
                };
            }
            if (actualPer != null && okListener != null) {
                //申请的权限不存在，申请
                if (ContextCompat.checkSelfPermission(mActivity, actualPer) != PackageManager.PERMISSION_GRANTED) {
                    Log.d("zyh ", "no permission and request ");
                    ActivityCompat.requestPermissions(mActivity, new String[]{actualPer}, requestCode);
                } else {
                    Log.d("zyh", "check permission success " + param);
                    Dict.setString(key, key + kResultPostfix, "success");
                    return;
                }
            }
            Dict.setString(key, key + kResultPostfix, "fail");
        } catch (Exception e) {
            Log.d("zyh ", "getPermission exception " + e.toString());
            e.printStackTrace();
            Dict.setString(key, key + kResultPostfix, "fail");
        }
    }

    /*jaywillou-20161205-add:整包更新下载 -- start*/
    //开始下载
    public void downloadUpdateApk(String param, String key) {
        Log.d("zyh", "launchNewDownloadTask url：" + param);
        Log.d("zyh", "download file is " + ResumableDownloadManager.getInstance().getDownloadDir());
        try {
            JSONObject json = new JSONObject(param);
            String url = json.getString("url");
            ResumableDownloadManager.getInstance().launchNewDownloadTask(url);
        } catch (Exception e) {
            Log.d("zyh", "download apk task exception");
            e.printStackTrace();
        }

    }

    //暂停下载
    public void pauseDownloadUpdateApk(String param, String key) {
        Log.d("zyh", "pauseDownloadTask url：" + param);
        try {
            JSONObject json = new JSONObject(param);
            String url = json.getString("url");
            ResumableDownloadManager.getInstance().pauseDownloadTask(url);
        } catch (Exception e) {
            Log.d("zyh", "pauseDownloadTask");
            e.printStackTrace();
        }

    }

    public void installUpdateApk(String param, String key) {
        try {
            Log.d("zyh", "installUpdateApk");
            JSONObject json = new JSONObject(param);
            String fileName = json.getString("fileName");
            fileName = ResumableDownloadManager.getInstance().getDownloadDir() + fileName;
            Log.d("zyh", "install fileName " + fileName);
            Uri uri = Uri.fromFile(new File(fileName));
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.setDataAndType(uri, "application/vnd.android.package-archive");
            Game.getInstance().startActivity(intent);
        } catch (Exception e) {
            Log.d("zyh", "installUpdateApk");
            e.printStackTrace();
        }
    }

    //查询下载状态
    public void queryDownloadStatus(String param, String key) {
        Log.d("Ouyang", "queryDownloadStatus url：" + param);
        try {
            JSONObject json = new JSONObject(param);
            String url = json.getString("url");
            int status = ResumableDownloadManager.getInstance().queryDownloadStatus(url);
            Dict.setInt(key, key + kResultPostfix, status);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    //查询下载进度
    public void queryDownloadProgress(String param, String key) {
        try {
            JSONObject json = new JSONObject(param);
            String url = json.getString("url");
            int progress = ResumableDownloadManager.getInstance().queryDownloadProgress(url);
            Dict.setInt(key, key + kResultPostfix, progress);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    //删除下载
    public void deleteDownloadTask(String param, String key) {
        Log.d("Ouyang", "deleteDownloadTask url：" + param);
        try {
            JSONObject json = new JSONObject(param);
            String url = json.getString("url");
            boolean ret = ResumableDownloadManager.getInstance().deleteDownloadTask(url);
            Dict.setInt(key, key + kResultPostfix, ret ? 1 : 0);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void getSystemVersion(String param, String key) {
        if (androidVer.isEmpty()) {
            int version = SdkVersion.getSdkVersion();
            if (version == 15) {
                androidVer = "4.0.3";
            } else if (version == 16) {
                androidVer = "4.1";
            } else if (version == 17) {
                androidVer = "4.2";
            } else if (version == 18) {
                androidVer = "4.3";
            } else if (version == 19) {
                androidVer = "4.4";
            } else if (version == 21) {
                androidVer = "5.0";
            } else if (version == 22) {
                androidVer = "5.1";
            } else if (version == 23) {
                androidVer = "6.0";
            } else if (version == 24) {
                androidVer = "7.0";
            } else if (version == 25) {
                androidVer = "7.1";
            }
        }

        Dict.setString(key, key + kResultPostfix, androidVer);
    }

	/*jaywillou-20161205-add:整包更新下载 -- end*/

    /*steveyang-20170412-add:跳转到GooglePlay-- start*/
    public void gotoGooglePlay(String param, String key) {
        int status = 0;

        try {
            //这里开始执行一个应用市场跳转逻辑
            Intent intent = new Intent(Intent.ACTION_VIEW);
            //跳转到应用市场，非Google Play市场一般情况也实现了这个接口
            intent.setData(Uri.parse("market://details?id=" + Game.getInstance().getPackageName()));
            //存在手机里没安装应用市场的情况，跳转会包异常，做一个接收判断
            if (intent.resolveActivity(Game.getInstance().getPackageManager()) != null) { //可以接收
                Game.getInstance().startActivity(intent);
            } else {
                //没有应用市场，我们通过浏览器跳转到Google Play
                intent.setData(Uri.parse("https://play.google.com/store/apps/details?id=" + Game.getInstance().getPackageName()));
                //这里存在一个极端情况就是有些用户浏览器也没有，再判断一次
                if (intent.resolveActivity(Game.getInstance().getPackageManager()) != null) { //有浏览器
                    Game.getInstance().startActivity(intent);
                } else {
                    status = 1;
                }
            }
        } catch (Exception e) {
            status = 2;
        }

        //通知lua是否跳转成功
        TreeMap<String, Object> map = new TreeMap<String, Object>();
        map.put("status", status);
        final JsonUtil util = new JsonUtil(map);
        Game.getInstance().callLuaFunc("gotoGooglePlay", util.toString());
    }
	/*steveyang-20170412-add:整包更新下载 -- end*/


}
