package com.boyaa.entity.rule;

import android.util.Log;
import android.view.View;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.RelativeLayout;

//import com.boyaa.made.AppActivity;
import com.boyaa.hallgame.Game;
import com.boyaa.hallgame.R;

public class Rule
{
	private Game mActivity=null;
	private RelativeLayout 	mActLayout=null;
	private WebView  		mWebView=null;
	private static Rule 	mInstance=null;
	private Rule(){
		mActivity =Game.getInstance();
	}
	
	public static Rule getInstance(){
		if(mInstance == null){
			mInstance =new Rule();
		}
		return mInstance;
	}
	public void openUrl(final String url)
	{
		mActivity.findViewById(R.id.rule_layout).setVisibility(View.VISIBLE);
		
		mActLayout = (RelativeLayout)mActivity.findViewById(R.id.rule_layout);
		mWebView = (WebView) mActLayout.findViewById(R.id.rule_webview);

		// 清除缓存
		mWebView.getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);
		mWebView.clearCache(true);
		mWebView.clearView();
		mWebView.clearHistory();

		WebSettings settings = mWebView.getSettings();
		settings.setLoadWithOverviewMode(true);
		//settings.setUseWideViewPort(true);
		settings.setBuiltInZoomControls(false);
		mWebView.setScrollBarStyle(WebView.SCROLLBARS_OUTSIDE_OVERLAY);
		mWebView.setBackgroundColor(0);
		
		settings.setDefaultTextEncodingName("utf-8");
		
		mWebView.requestFocus();
		
		mWebView.setWebViewClient(new WebViewClient() {
			@Override
			public void onPageFinished(WebView view, String url) {
				//call back
				Game.getInstance().callLuaFunc("ruleFinish","");
				super.onPageFinished(view, url);
			}
		});
		mActLayout.setFocusableInTouchMode(true);
		Log.e("xxxxx", url);
		mWebView.loadUrl(url);
	}
	
	public boolean isVisible()
	{
		return mActivity.findViewById(R.id.rule_layout).getVisibility() == View.VISIBLE;
	}
	
	
    //关闭活动界面
	public boolean close()
	{   
		mActivity.findViewById(R.id.rule_layout).setVisibility(View.GONE);
		Game.getInstance().callLuaFunc("ruleClose","");
		return true;
	}
}