package com.boyaa.entity.activities;

import java.util.TreeMap;

import android.content.Intent;
import android.net.Uri;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.webkit.DownloadListener;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.boyaa.entity.common.BoyaaProgressDialog;
import com.boyaa.entity.common.utils.JsonUtil;
import com.boyaa.hallgame.Game;

import com.boyaa.hallgame.R;

public class MahjongActivities
{
	private Game mActivity=null;
	private RelativeLayout mActLayout=null;
	private WebView  mWebView=null;
	private Button  backBtn=null;
	private Animation anim_decorate;
	private ImageView mImagedecorate;
	private boolean isShow=false; //活动界面是否显示
	private Boolean canBack = false;
	private static MahjongActivities mahjongActivities=null; // 麻将活动对象
	private BoyaaProgressDialog proDialog = null;
	private MahjongActivities(){
		mActivity =Game.getInstance();
		proDialog = new BoyaaProgressDialog(mActivity);
	}
	
	public static MahjongActivities getInstance(){
		if(mahjongActivities == null){
			mahjongActivities =new MahjongActivities();
		}
		return mahjongActivities;
	}
	public void openUrl(final String url)
	{   
		canBack=false;
		setActivitiesIsShow(true);
		mActivity.findViewById(R.id.huodong_layout).setVisibility(View.VISIBLE);
		
		mActLayout = (RelativeLayout)mActivity.findViewById(R.id.huodong_layout);
		mWebView = (WebView) mActLayout.findViewById(R.id.huodong_webview);
		backBtn = (Button) mActLayout.findViewById(R.id.btn_back);
		
		mImagedecorate = (ImageView) mActLayout.findViewById(R.id.scenc_right_decorate2);
		anim_decorate=AnimationUtils.loadAnimation(mActivity, R.anim.rotate_decorate);
		mImagedecorate.startAnimation(anim_decorate);

		// 清除缓存
		mWebView.getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);
		mWebView.clearCache(true);
		mWebView.clearView();
		mWebView.clearHistory();

		WebSettings settings = mWebView.getSettings();
		settings.setLoadWithOverviewMode(true);
		settings.setUseWideViewPort(true);
		settings.setBuiltInZoomControls(false);
		settings.setJavaScriptEnabled(true);
		mWebView.setScrollBarStyle(WebView.SCROLLBARS_OUTSIDE_OVERLAY);
		mWebView.setBackgroundColor(0);
		settings.setDefaultTextEncodingName("utf-8");
		backBtn.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				back();
			}
		});
		mWebView.requestFocus();
		mWebView.setDownloadListener(new WebViewDownLoadListener());
		mWebView.setWebViewClient(new WebViewClient() {
			@Override
			public boolean shouldOverrideUrlLoading(WebView view, String url) { // 重写此方法表明点击网页里面的链接还是在当前的webview里跳转，不跳到浏览器那边
				if (url.startsWith("boyaa-client-api:")) {// 从活动进入游戏功能判断
					close();
					activitiesGoFunction(url);
					return true;
				}
				showLoading();
				view.loadUrl(url);
				canBack=true;
				return true;
			}
			@Override
			public void onPageFinished(WebView view, String url) {
				hideLoading();
				super.onPageFinished(view, url);
			}
		});
		mActLayout.setFocusableInTouchMode(true);
		showLoading();
		mWebView.loadUrl(url);
	}
	
	private class WebViewDownLoadListener implements DownloadListener {
		@Override
		public void onDownloadStart(String url, String userAgent,
				String contentDisposition, String mimetype, long contentLength) {
			Log.d("mahjong", "活动是否需要下载，下载的地址 ： " + url);
			Log.d("mahjong", "活动是否需要下载，下载的大小 ： " + contentLength);
			Uri uri = Uri.parse(url);
			Intent intent = new Intent(Intent.ACTION_VIEW, uri);
			mActivity.startActivity(intent);
		}
	}

	
	/**
	 * 模拟支付流程，使用移动MM购买0.1元金币 jump = buyCoinsForActivityMM jump_param = 0.1
	 * url模板: boyaa-client-api://?jump=<功能>&jump_param=<参数> 完整url:
	 * boyaa-client-api://?jump=buyCoinsForActivityMM&jump_param=0.1
	 */
	private void activitiesGoFunction(String url) { //活动跳转功能
		
		// boyaa-client-api://?jump=<功能>&jump_param=<参数>
		int jumpIndex  = url.indexOf("jump=");
		int paramIndex = url.indexOf("jump_param=");
		String jump = "";
		String param = "";
		if (jumpIndex > 0) {
			jump = url.substring(jumpIndex + 5,url.indexOf("&") > 0 ? url.indexOf("&") : url.length());
		}
		if (paramIndex > 0) {
			param = url.substring(paramIndex + 11, url.length());
		}
		TreeMap<String, Object> map = new TreeMap<String, Object>();
		map.put("jump", jump);
		map.put("jump_param", param);
		JsonUtil statusJson = new JsonUtil(map);
		final String functionParasm = statusJson.toString();
		Game.getInstance().callLuaFunc("ActivityGoFunction",functionParasm);
	}
   
	private void setActivitiesIsShow(boolean isShow){
		this.isShow=isShow;
	}
    public boolean getActivitiesIsShow(){
		return isShow;
	}
    private void showLoading(){
 	   if (proDialog != null && mActivity != null){
 			proDialog.show();
 		}
    }
    
    private void hideLoading(){
 	   if (proDialog != null  && mActivity != null){
 			proDialog.dismiss();
 		}
    }
    
    //按back返回处理
    public boolean back(){
    	
    	if (mWebView.canGoBack() && canBack) { // 检查网页是否有历史记录
			//mWebView.goBack();//该方法 有些手机使用返回不正常 样式乱了 或者打不开，现在改局限是不可以超过二级界面
			mWebView.loadUrl(mWebView.copyBackForwardList().getItemAtIndex(mWebView.copyBackForwardList().getCurrentIndex()-1).getUrl());
			canBack=false;
			return true;
		} else {
			return close();
		}
    }
    
    //关闭活动界面
	private boolean close()
	{   
		mActivity.findViewById(R.id.huodong_layout).setVisibility(View.GONE);
		Game.getInstance().callLuaFunc("ActivityClose","");      //通知lua关闭活动界面
		//AppActivity.getHandler().luaCallEvent("updateactivityNum","");  //通知lua更新活动冒泡数
		setActivitiesIsShow(false);
		return true;
	}
}