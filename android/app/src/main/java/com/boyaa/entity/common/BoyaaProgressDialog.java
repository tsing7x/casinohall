/*
 * Copyright (C) 2007 The Android Open Source Project
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.boyaa.entity.common;
import android.app.Activity;
import android.app.AlertDialog;
import android.graphics.drawable.AnimationDrawable;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewTreeObserver.OnPreDrawListener;
import android.view.Window;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;
import android.widget.TextView;

import com.boyaa.hallgame.R;
public class BoyaaProgressDialog extends AlertDialog implements android.view.View.OnClickListener {

	public interface onCancelListener
	{
		public abstract void onCancel();
	}
	private onCancelListener listener = null;
	public void setOnCancelListener( onCancelListener listener)
	{
		this.listener = listener;
	}
	private ImageView mImageViewYun;
	private ImageView mImageViewGril;
	private TextView mTipsView;
	private CharSequence mTitle;
	private AnimationDrawable animation;
	private Animation anim_gril;
	private View view;

	public BoyaaProgressDialog(Activity context) {
		super(context);
	}
	public BoyaaProgressDialog(Activity context,CharSequence title) {
		super(context);
		this.mTitle=title;
	}

	public static BoyaaProgressDialog show(Activity context, CharSequence title) {
		BoyaaProgressDialog dialog = new BoyaaProgressDialog(context);
		dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
		dialog.setCancelable(false);
		dialog.setCanceledOnTouchOutside(false);
		dialog.mTitle = title;
		dialog.show();
		return dialog;
	}
	

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		LayoutInflater inflater = LayoutInflater.from(getContext());
		view = inflater.inflate(R.layout.load_resource, null);
		mImageViewYun = (ImageView) view.findViewById(R.id.loading_yun_ani);
		if(mTitle==null || "".equals(mTitle)){
			mTitle="???...";
		}
		setContentView(view);
		mImageViewYun.getViewTreeObserver().addOnPreDrawListener(
				new OnPreDrawListener() {
					@Override
					public boolean onPreDraw() {
						animation = (AnimationDrawable) mImageViewYun.getDrawable();
						animation.start();
						return true;
					}
	   });
		
		
	    mImageViewGril = (ImageView) view.findViewById(R.id.loading_gril_ani);
		mImageViewGril.getViewTreeObserver().addOnPreDrawListener(
				new OnPreDrawListener() {
					@Override
					public boolean onPreDraw() {
						animation = (AnimationDrawable) mImageViewGril.getDrawable();
						animation.start();
						return true;
					}
	   });
		anim_gril=AnimationUtils.loadAnimation(getContext(), R.anim.loading_gril_translate);
		mImageViewGril.startAnimation(anim_gril);
	
	}
	
	@Override
	public void show() {
		super.show();
		if(mImageViewGril !=null && anim_gril != null ){
			mImageViewGril.startAnimation(anim_gril);
		}
	}
	
	@Override
	public void dismiss() {
		super.dismiss();
		if(mImageViewGril !=null){
			mImageViewGril.clearAnimation();
		}
	}
	
	public void setVisible(boolean flag){
		view.setVisibility(flag?View.VISIBLE:View.GONE);
		mImageViewYun.setVisibility(flag?View.VISIBLE:View.GONE);
		mImageViewGril.setVisibility(flag?View.VISIBLE:View.GONE);
		mTipsView.setVisibility(flag?View.VISIBLE:View.GONE);
	}
	@Override
	public void onStart(){
		super.onStart();
	}
	@Override
	protected void onStop(){
		super.onStop();
		if(animation != null){
			animation.stop();
		}
		mImageViewYun.setAnimation(null);
		mImageViewGril.setAnimation(null);
	}
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event)  {
	    if (keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0) {
	    	this.cancelRequest();
	    	dismiss();
	    	if ( null != this.listener )
	    	{
	    		this.listener.onCancel();
	    	}
	        return true;
	    }
	    return super.onKeyDown(keyCode, event);
	}
	@Override
	public void onClick(View v) {
		this.cancelRequest();
		this.dismiss();
	}
	private void cancelRequest(){
	}
}
