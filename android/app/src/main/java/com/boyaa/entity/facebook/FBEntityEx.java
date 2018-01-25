package com.boyaa.entity.facebook;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONObject;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Resources;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

import com.boyaa.entity.common.utils.JsonUtil;
import com.boyaa.hallgame.Game;
import com.boyaa.hallgame.R;
//import com.boyaa.made.AppActivity;

import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookRequestError;
import com.facebook.FacebookSdk;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.facebook.HttpMethod;
import com.facebook.applinks.AppLinkData;
import com.facebook.AccessToken;
import com.facebook.AccessTokenTracker;
import com.facebook.Profile;
import com.facebook.ProfileTracker;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;

import com.facebook.share.model.GameRequestContent;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.widget.AppInviteDialog;
import com.facebook.share.widget.GameRequestDialog;
import com.facebook.share.widget.ShareDialog;
import com.facebook.share.Sharer;

import com.facebook.messenger.MessengerUtils;
import com.facebook.messenger.ShareToMessengerParams;

import com.umeng.analytics.MobclickAgent;


public class FBEntityEx {

	private static final String TAG = "zyh FBEntityEx";
	private static FBEntityEx instance;

	public static FBEntityEx getInstance() {
		if (instance == null) {
			instance = new FBEntityEx();
		}
		return instance;
	}
	//facebook权限
	private static final List<String> PERMISSIONS = new ArrayList<String>() {
		{
			add("user_friends");
			add("public_profile");
			add("email");
		}
	};
	
	private String feedData = "";
	private String inviteData = "";

	//lua KEY
	private final static String kfblogin 	= "login";
	private final static String kGetFbFriend = "getFbFriend";

	private PendingAction pendingAction = PendingAction.NONE;
//	private AccessTokenTracker accessTokenTracker;
//	private ProfileTracker profileTracker;
	private CallbackManager callbackManager;

	private enum PendingAction {
		NONE, LOGIN, LOGOUT, INVITABLE_FRIENDS, SEND_INVITES, GETAPPREQUEST, SHARE_FEED
	}

	public FBEntityEx() {
		// TODO Auto-generated constructor stub
	}
	//on Event 与  activity事件同步
	public void onCreate(final Activity activity) {
//		FacebookSdk.sdkInitialize(activity.getApplicationContext());
		callbackManager = CallbackManager.Factory.create();

//		日志开关
//		FacebookSdk.setIsDebugEnabled(true);
//		FacebookSdk.addLoggingBehavior(LoggingBehavior.APP_EVENTS);

		LoginManager.getInstance().registerCallback(callbackManager, new FacebookCallback<LoginResult>() {
			@Override
			public void onSuccess(LoginResult loginResult) {
				Log.d(TAG, "login success");
				handlePendingAction();
			}
			//取消登录的话原来的操作也要取消
			@Override
			public void onCancel() {
				Log.d(TAG, "login cancel");
				pendingAction = PendingAction.NONE;
			}

			@Override
			public void onError(FacebookException e) {
				Log.d(TAG, "login error " + e.toString());
				pendingAction = PendingAction.NONE;
			}
		});

//		accessTokenTracker = new AccessTokenTracker() {
//			@Override
//			protected void onCurrentAccessTokenChanged(AccessToken oldAccessToken, AccessToken newAccessToken) {
//			}
//		};
//
//		profileTracker = new ProfileTracker() {
//			@Override
//			protected void onCurrentProfileChanged(Profile oldProfile, Profile newProfile) {
//
//			}
//		};

		//延迟深度链接数据
		AppLinkData.fetchDeferredAppLinkData(activity.getApplicationContext(), new AppLinkData.CompletionHandler() {
			@Override
			public void onDeferredAppLinkDataFetched(AppLinkData appLinkData) {
				Log.d(TAG, "onDeferredAppLinkDataFetched ");
				try{
					if (appLinkData != null)
					{
						Log.d(TAG, "appLinkData not null");
						Uri data = appLinkData.getTargetUri();
						Log.d("zyh", "defer app link data uri " + data.toString());
						//				获取深度链接数据，因为lua层未启动，先记录下来，在appHandler getStartway里统一处理
						SharedPreferences deepLinkData = activity.getSharedPreferences("deferredAppLinkData", Context.MODE_PRIVATE);
						SharedPreferences.Editor dataEdit = deepLinkData.edit();
						dataEdit.putString("uri", data.toString());
						dataEdit.commit();
					}else{
						Log.d(TAG, "appLink is null");
					}
				}catch (Exception e){
					Log.d(TAG, "exception " + e.toString());
				}
			}
		});

	}

	public void onResume() {

	}

	public void onPause() {

	}

	public void onDestroy() {
//		accessTokenTracker.stopTracking();
//		profileTracker.stopTracking();
	}

	public void login(){
		performFbAction(PendingAction.LOGIN);
	}

	public void logout(){
		Log.d(TAG, "logout");
		LoginManager.getInstance().logOut();
	}

	public void share(String param){
		feedData = param;
		performFbAction(PendingAction.SHARE_FEED);
	}

	public void sendInvites(String param){
		inviteData = param;
		performFbAction(PendingAction.SEND_INVITES);
	}

	public void getInvitableFriends(){
		performFbAction(PendingAction.INVITABLE_FRIENDS);
	}

	public void getAppRequest(){
		performFbAction(PendingAction.GETAPPREQUEST);
	}

	public void shareToMessenger(String param){
		try{
			Log.d(TAG, "shareToMessenger " + param);
			Resources myAppRes = Game.getInstance().getApplicationContext().getResources();
			int myRes = R.drawable.fbmessengershare;
			String myImgUri = ContentResolver.SCHEME_ANDROID_RESOURCE + "://" + myAppRes.getResourcePackageName(myRes)
					+ "/" + myAppRes.getResourceTypeName(myRes) + "/" + String.valueOf(myRes);
			ShareToMessengerParams shareParam = ShareToMessengerParams.newBuilder(Uri.parse(myImgUri), "image/png").setMetaData(param).build();
			MessengerUtils.shareToMessenger(Game.getInstance(), 1, shareParam);
		}catch (Exception e){
			Log.d(TAG, "shareToMessenger exception " + e.toString());
		}

	}

	private void performFbAction(PendingAction action){
		Log.d(TAG, "performFbAction " + action);
		AccessToken accessToken = AccessToken.getCurrentAccessToken();
		pendingAction = action;
		if (accessToken != null && (! accessToken.isExpired())){
			Log.d(TAG, "accessToken not null");
			handlePendingAction();
		}else{
			Log.d(TAG, "accessToken is " + (accessToken == null ? "accessToken is null" : "accessToken is expired"));
			LoginManager.getInstance().logInWithReadPermissions(Game.getInstance(), PERMISSIONS);
		}
	}

	private void handlePendingAction(){
		PendingAction previouslyPendingAction = pendingAction;
		pendingAction = PendingAction.NONE;
		switch (previouslyPendingAction){
			case LOGIN:
				requestLoginInfo();
				break;
			case INVITABLE_FRIENDS:
				requestInvitableFriends(null);
				break;
			case SEND_INVITES:
				showInviteDialog();
				break;
			case GETAPPREQUEST:
				requestGetAppRequest();
				break;
			case SHARE_FEED:
				shareFeed();
				break;
		}
	}

	private void requestLoginInfo(){
		Log.d(TAG, "requestLoginInfo");
		final AccessToken accessToken = AccessToken.getCurrentAccessToken();
		if (accessToken != null && (!accessToken.isExpired())){
			Bundle parameters = new Bundle();
			parameters.putString(GraphRequest.FIELDS_PARAM, "id,name,picture");
			new GraphRequest(accessToken, "me", parameters, HttpMethod.GET, new GraphRequest.Callback() {
				@Override
				public void onCompleted(GraphResponse graphResponse) {
					try{
						JSONObject jsonObject = graphResponse.getJSONObject();
						FacebookRequestError error = graphResponse.getError();
						Log.d(TAG, "requestLoginInfo GraphRequest Callback onCompleted jsonObject " + (jsonObject!=null ? jsonObject.toString() : " null"));
						Log.d(TAG, "requestLoginInfo GraphRequest Callback onCompleted error " + (error!=null ? error.toString() : " null"));
						if (jsonObject != null && error == null){
							Log.d(TAG, "jsonObject " + jsonObject.toString());
							String id = jsonObject.optString("id");
							String name = jsonObject.optString("name");
//						String url = jsonObject.optString("picture");
							String token = accessToken.getToken();
							Log.d(TAG, "name " + name + " id " + id);
							Map<String, String> jsonResult = new HashMap<String, String>();
							//1表示fb登陆
							jsonResult.put("type", "1");
							jsonResult.put("status", "0");
							jsonResult.put("name", name);
							jsonResult.put("siteMid", id);
							jsonResult.put("accessToken", token);
							final JsonUtil util = new JsonUtil(jsonResult);
							Game.getInstance().callLuaFunc(kfblogin, util.toString());
						}else{
							Log.d(TAG, "jsonObject is null and error is " + (error != null ? error.toString() : " null"));
							Map<String, String> jsonResult = new HashMap<String, String>();
							jsonResult.put("type", "1");
							jsonResult.put("status", "1");
							jsonResult.put("error", error != null ? error.getErrorMessage() : "login error");
							final JsonUtil util = new JsonUtil(jsonResult);
							Game.getInstance().callLuaFunc(kfblogin, util.toString());
						}
					}catch(Exception e){
						Log.d(TAG, "requestLogininfo onComplete exception " + e.toString());
						e.printStackTrace();
					}
				}
			}).executeAsync();
		}else{
			Log.d(TAG, "requestLoginInfo error " + (accessToken == null ? "accessToken is null" : "accessToken is expired"));
		}
	}

	private void requestInvitableFriends(String after){
		Log.d(TAG, "requestInvitableFriends");
		final AccessToken accessToken = AccessToken.getCurrentAccessToken();
		if (accessToken != null && (!accessToken.isExpired())){
			Bundle parameters = new Bundle();
			parameters.putString(GraphRequest.FIELDS_PARAM, "id,name,picture");
//			facebook默认返回25个。
//			parameters.putString("limit", "5");
			if (after != null){
				parameters.putString("after", after);
			}

			new GraphRequest(accessToken, "me/invitable_friends", parameters, HttpMethod.GET, new GraphRequest.Callback() {
				@Override
				public void onCompleted(GraphResponse graphResponse) {
					try{
						Log.d(TAG, "invitable_friends onCompleted ");
						JSONObject jsonObject = graphResponse.getJSONObject();
						FacebookRequestError error = graphResponse.getError();
						Log.d(TAG, "invitable_friends Callback onCompleted jsonObject " + (jsonObject!=null ? jsonObject.toString() : " null"));
						Log.d(TAG, "invitable_friends Callback onCompleted error " + (error!=null ? error.toString() : " null"));
						if (error != null || jsonObject == null){
							Log.d(TAG, "no friend data");
							Map<String, Object> jsonResult = new HashMap<String, Object>();
							jsonResult.put("status", "1");
							jsonResult.put("error", error.toString());
							final JsonUtil util = new JsonUtil(jsonResult);
							// 通知Lua端
							Game.getInstance().callLuaFunc(kGetFbFriend, util.toString());
							return;
						}else{
							Log.d(TAG, "get friend suc");
							JSONArray dataArray = jsonObject.optJSONArray("data");
							Log.d(TAG, "dataArray " + (dataArray != null ? dataArray.toString() : " null"));
							Game.getInstance().callLuaFunc(kGetFbFriend, dataArray.toString());

							JSONObject paging = jsonObject.optJSONObject("paging");
							if (paging != null) {
								Log.d(TAG, "paging is " + paging.toString());
								String next = paging.optString("next");
								if (next != null && !next.isEmpty()){
									Log.d(TAG, "next is " + next);
									JSONObject cursors = paging.optJSONObject("cursors");
									if (cursors != null){
										Log.d(TAG, "cursor is " + cursors.toString());
										String cursorAfter = cursors.optString("after");
										if (cursorAfter != null && !cursorAfter.isEmpty()){
											requestInvitableFriends(cursorAfter);
										}
									}
									else{
										Log.d(TAG, "cursor is null");
									}
								}else{
									Log.d(TAG, "next is null");
								}

							}else{
								Log.d(TAG, "paging is null");
							}

						}
					}catch(Exception e){
						Log.d(TAG, "get invitable_friend suc onComplete exception " + e.toString());
						e.printStackTrace();
					}
				}
			}).executeAsync();
		}else{
			Log.d(TAG, "requestLoginInfo error " + (accessToken == null ? "accessToken is null" : "accessToken is expired"));
		}
	}

	private void shareFeed(){
		Log.d(TAG, "shareFeed feedData is " + (feedData == null ? " null" : feedData));
		Log.d(TAG, "canshow shareDialog " + ShareDialog.canShow(ShareLinkContent.class));
		if(feedData != null && (!feedData.isEmpty()) && ShareDialog.canShow(ShareLinkContent.class)) {
			try {
					Log.d(TAG, "share Feed start");
					JSONObject json = new JSONObject(feedData);
//					String name = json.optString("name");
//					String captinon = json.optString("caption");
//					String message = json.optString("message");
//					String link = json.optString("link");
//					String picture = json.optString("picture");
					final String from = json.optString("from");
					final String expand = json.optString("expand");

					ShareLinkContent.Builder shareLinkContentBuilder = new ShareLinkContent.Builder()
							.setContentDescription(json.optString("caption"))
							.setContentTitle(json.optString("name"))
							.setContentUrl(Uri.parse(json.optString("link")));
					if (json.has("picture")) {
						shareLinkContentBuilder.setImageUrl(Uri.parse(json.optString("picture")));
					}
					ShareLinkContent shareLinkContent = shareLinkContentBuilder.build();
					ShareDialog shareDialog = new ShareDialog(Game.getInstance());
					shareDialog.registerCallback(callbackManager, new FacebookCallback<Sharer.Result>() {
						@Override
						public void onSuccess(Sharer.Result result) {
							Log.d(TAG, "shareDialog success");
							Map<String, Object> json = new HashMap<String, Object>();
							json.put("shareData", "1");
							if (from != null && (! from.isEmpty())){
								json.put("from", from);
							}
							if (expand != null && (! expand.isEmpty()))
							{
								json.put("expand", expand);
							}
							final JsonUtil util = new JsonUtil(json);
							Log.d(TAG, "call lua shareResult " + util.toString());
							Game.getInstance().callLuaFunc("shareResult", util.toString());
						}

						@Override
						public void onCancel() {
							Log.d(TAG, "shareDialog cancel");
							Map<String, Object> json = new HashMap<String, Object>();
							json.put("shareData", "0");
							final JsonUtil util = new JsonUtil(json);
							Game.getInstance().callLuaFunc("shareResult", util.toString());
						}

						@Override
						public void onError(FacebookException e) {
							Log.d(TAG, "shareDialog callback error " + e.toString());
							e.printStackTrace();
							Map<String, Object> json = new HashMap<String, Object>();
							json.put("shareData", "-1");
							final JsonUtil util = new JsonUtil(json);
							Game.getInstance().callLuaFunc("shareResult", util.toString());
						}
					});
					shareDialog.show(shareLinkContent);

			} catch(Exception e) {
				Log.e(TAG, e.getMessage(), e);
			}
		} else {
			Log.d(TAG, "share data is null");
		}
	}

	private void showInviteDialog(){
		try{
			Log.d(TAG, "showInviteDialog is " + (inviteData == null ? " null" : inviteData));
			Log.d(TAG, "canshow showInviteDialog " + AppInviteDialog.canShow());
			if (inviteData != null && !inviteData.isEmpty()){
				Log.d(TAG, "inviteData exist");
				JSONObject jsonObject = new JSONObject(inviteData);
				String title = jsonObject.optString("title");
				final String originalTo = jsonObject.optString("inviteToIds");
				final String action = jsonObject.optString("action");
				final String expandData = jsonObject.getString("expandData");
				String[] recipientsArray = originalTo.split(",");

				GameRequestContent gameRequestContent = new GameRequestContent.Builder()
						.setTitle(title)
						.setMessage(jsonObject.optString("content"))
						.setRecipients(Arrays.asList(recipientsArray))
						.setData(expandData)
						.build();

				GameRequestDialog gameRequestDialog = new GameRequestDialog(Game.getInstance());
				gameRequestDialog.registerCallback(callbackManager, new FacebookCallback<GameRequestDialog.Result>() {
					@Override
					public void onSuccess(GameRequestDialog.Result result) {
						try
						{
							Log.d(TAG, "sendinvite onSuccess");
							String requestId = result.getRequestId();
							Log.d(TAG, "requestId is " + (requestId == null ? "null" : requestId));
							List<String> to = result.getRequestRecipients();
							StringBuilder inviteIds = new StringBuilder();
							for (String id : to){
								inviteIds.append(id);
								inviteIds.append(",");
							}
							Map<String, Object> json = new HashMap<String, Object>();
							json.put("requestId", requestId != null ? requestId : "0");
							//这是fb邀请成功后返回来的用户id，用来上报邀请成功数量的
							json.put("toIds", inviteIds);
							//邀请时客户端传过来的id，用来确定哪些玩家已经邀请过了。在安卓上面的id是用户的id，但获取好友得到的id是token，originalTo与这个inviteIds不一样。
							json.put("to", originalTo);
							Log.d(TAG, "sendinvite onSuccess inviteIds " + inviteIds + "  originalTo " + originalTo);
							final JsonUtil util = new JsonUtil(json);
							// 通知Lua端
							//成功发送邀请消息
							if (action.equals("recall")) {
								Game.getInstance().callLuaFunc("sendRecalls",util.toString());
							}else {
								Game.getInstance().callLuaFunc("sendInvites",util.toString());
							}

						}catch(Exception e){
							Log.d(TAG, "sendinvite success but handle result exception " + e.toString());
							MobclickAgent.onEvent(Game.getInstance(), "fbInviteSucButExc");
						}
					}

					@Override
					public void onCancel() {
						Log.d(TAG, "sendinvite cancel");
					}

					@Override
					public void onError(FacebookException error) {
						Log.d(TAG, "sendinvite onError " + error.toString());
						MobclickAgent.onEvent(Game.getInstance(), "fbInviteReturnError");
					}
				});

				gameRequestDialog.show(Game.getInstance(), gameRequestContent);
			}else
			{
				Log.d(TAG, "cannot show invite dialog");
				MobclickAgent.onEvent(Game.getInstance(), "fbInviteCantShow");
			}
		}catch (Exception e){
			Log.d(TAG, "showInviteDialog exception " + e.toString());
			MobclickAgent.onEvent(Game.getInstance(), "fbInviteShowExc");
		}

	}

	private void requestGetAppRequest(){
		Log.d(TAG, "requestGetAppRequest");
		final AccessToken accessToken = AccessToken.getCurrentAccessToken();
		if (accessToken != null && (!accessToken.isExpired())) {
			new GraphRequest(accessToken, "me/apprequests", null, HttpMethod.GET, new GraphRequest.Callback() {
				@Override
				public void onCompleted(GraphResponse graphResponse) {
					try{
						JSONObject jsonObject = graphResponse.getJSONObject();
						FacebookRequestError error = graphResponse.getError();
						Log.d(TAG, "requestGetAppRequest Callback onCompleted jsonObject " + (jsonObject!=null ? jsonObject.toString() : " null"));
						Log.d(TAG, "requestGetAppRequest Callback onCompleted error " + (error!=null ? error.toString() : " null"));
						if (error == null && jsonObject != null){
							Log.d(TAG, "requestGetAppRequest success");
							JSONArray dataArr = jsonObject.optJSONArray("data");
							if (dataArr.length() > 0){
								Log.d(TAG, "requestGetAppRequest dataArr len > 0 " + dataArr.toString());
								Map<String, Object> jsonResult = new HashMap<String, Object>();
								jsonResult.put("dataArrStr",dataArr.toString());
								jsonResult.put("length", dataArr.length());
								final JsonUtil util = new JsonUtil(jsonResult);
								if(util != null)
								{
									Game.getInstance().callLuaFunc("getFbAppInfo", util.toString());
								}
							}
						}
					}catch (Exception e){
						Log.d(TAG, "requestGetAppRequest exception "+ e.toString());
					}
				}
			}).executeAsync();
		}else{
			Log.d(TAG, "requestGetAppRequest error " + (accessToken == null ? "accessToken is null" : "accessToken is expired"));
		}
	}

	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		callbackManager.onActivityResult(requestCode, resultCode, data);
	}

}
