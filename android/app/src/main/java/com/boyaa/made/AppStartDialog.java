package com.boyaa.made;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.ContentResolver;
import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.RotateAnimation;
import android.widget.ImageView;
import android.widget.VideoView;
import java.io.File;
import java.io.FileDescriptor;

import android.util.Log;
import com.boyaa.hallgame.R;

public class AppStartDialog extends AlertDialog {
	private int layoutId;
	private Activity mActivity;
	private boolean requestClose = false;
	private VideoView startVideo;

	public AppStartDialog(Activity context) {
		super(context, R.style.Transparent);
		this.layoutId = R.layout.start_screen;
		this.mActivity = context;
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		LayoutInflater inflater = LayoutInflater.from(getContext());
		View view = inflater.inflate(this.layoutId, null);
		setContentView(view);
		getWindow().setWindowAnimations(R.style.PopupAnimation);

		ImageView loadingBg = (ImageView)findViewById(R.id.loading_bg);
		Animation rotateAnim = new RotateAnimation(0, 360, Animation.RELATIVE_TO_SELF, 0.5f, Animation.RELATIVE_TO_SELF, 0.5f);
		rotateAnim.setRepeatCount(Animation.INFINITE);
		rotateAnim.setDuration(1000);
		loadingBg.startAnimation(rotateAnim);

		startVideo = (VideoView)findViewById(R.id.startVideo);
		String uriVideo = ContentResolver.SCHEME_ANDROID_RESOURCE + "://" + this.mActivity.getPackageName() + "/raw/start_screen";
		startVideo.setVideoURI(Uri.parse(uriVideo));

		startVideo.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
			@Override
			public void onCompletion(MediaPlayer mp) {
				if (requestClose)
				{
					dismiss();
				}
			}
		});
		try{
			startVideo.start();
		}catch(Exception e)
		{
			Log.d("zyh", "start video exception " + e.toString());
		}

	}

	public void stopForce()
	{
		if (startVideo != null && startVideo.isPlaying())
		{
			startVideo.stopPlayback();
		}
		dismiss();
	}

	public boolean requestDismiss(){
		requestClose = true;
		if (startVideo != null && startVideo.isPlaying())
		{
			return false;
		}
		else
		{
			dismiss();
			return true;
		}
	}
	@Override
	public void dismiss() {
		super.dismiss();

	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0) {
			return true;
		}

		return super.onKeyDown(keyCode, event);
	}

}
