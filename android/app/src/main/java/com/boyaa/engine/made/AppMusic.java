package com.boyaa.engine.made;

import java.io.FileInputStream;
import java.io.IOException;

import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.util.Log;

/**
 * Created by VincentGong on 15/8/6.
 */
public class AppMusic implements MediaPlayer.OnPreparedListener,
		MediaPlayer.OnErrorListener {

	private final static String TAG = "AppMusic";
	private float mLeftVolume;
	private float mRightVolume;
	private MediaPlayer mMediaPlayer;
	private boolean mIsPaused;
    private OnCompletionListener mListener;

	public String getCurrentMusicPath() {
		return mCurrentPath;
	}

	private String mCurrentPath;
	public AppMusic() {
		initData();
	}

	private void initData() {
		mLeftVolume = 0.5f;
		mRightVolume = 0.5f;
		mMediaPlayer = null;
		mIsPaused = false;
		mCurrentPath = null;
	}

	void setOnCompletionListener(OnCompletionListener listener) {
        mListener = listener;
	}

	// Music
	void preload(String path) {
		Release();
		createMediaplayerFromFile(path);
	}

	public void end() {
		if (mMediaPlayer != null) {
			mMediaPlayer.release();
		}
		mMediaPlayer = null;
		mIsPaused = false;
		mCurrentPath = null;
	}

	public void Release() {
		end();
	}

	private void createMediaplayerFromFile(String path) {
		Release();
		mMediaPlayer = new MediaPlayer();
        if(mListener != null){
            mMediaPlayer.setOnCompletionListener(mListener);
        }
        FileInputStream fs = null;
		try {
			fs = new FileInputStream(path);
			mMediaPlayer.setDataSource(fs.getFD());
			mMediaPlayer.setVolume(mLeftVolume, mRightVolume);
			mMediaPlayer.prepare();
		}catch (Exception e) {
			e.printStackTrace();
		}finally{
			if(null != fs){
				try {
					fs.close();
				} catch (IOException e) {
					Log.e(TAG, e.toString());
				}
			}
		}
		mCurrentPath = path;
		mIsPaused = false;
	}


	void play(String path, boolean isLoop) {
		if (path == null) {
			return;
		}
		if (!path.equals(mCurrentPath)) {
			Release();
			createMediaplayerFromFile(path);
		}
		if (mMediaPlayer != null) {
			try {
				mMediaPlayer.setLooping(isLoop);
				if (!mIsPaused) {
					mMediaPlayer.seekTo(0);
				}
				mMediaPlayer.start();
				mIsPaused = false;
			} catch (IllegalStateException e) {
				e.printStackTrace();
			}
		}
	}

	public void stopBackgroundMusic() {
		Release();
	}

	public void pauseBackgroundMusic() {
		if (mMediaPlayer != null) {
			mMediaPlayer.pause();
			mIsPaused = true;
		}
	}

	public void resumeBackgroundMusic() {
		if (mIsPaused && mMediaPlayer != null) {
			mMediaPlayer.start();
			mIsPaused = false;
		}
	}

	public void rewindBackgroundMusic() {
		if (mMediaPlayer != null) {
			try {
				mMediaPlayer.seekTo(0);
				mMediaPlayer.start();
				mIsPaused = false;
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	void stop(boolean doRelease) {
		Release();
	}

	void pause() {
		if (mMediaPlayer != null) {
			mMediaPlayer.pause();
			mIsPaused = true;
		}
	}


	void resume() {
		if (mIsPaused && mMediaPlayer != null) {
			mMediaPlayer.start();
			mIsPaused = false;
		}
	}

	void rewind() {
		if (mMediaPlayer != null) {
			try {
				mMediaPlayer.seekTo(0);
				mMediaPlayer.start();
				mIsPaused = false;
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	boolean isPlaying() {
		return mMediaPlayer != null
				&& mMediaPlayer.isPlaying();
	}

	float getVolume() {
		if (mMediaPlayer != null) {
			return (mLeftVolume + mRightVolume) / 2f;
		}
		return 0;
	}

	void setVolume(float volume) {
		if (mMediaPlayer != null) {
			mMediaPlayer.setVolume(volume, volume);
		}
		mLeftVolume = volume;
		mRightVolume = volume;
	}

	@Override
	public void onPrepared(MediaPlayer mp) {

	}

	@Override
	public boolean onError(MediaPlayer mp, int what, int extra) {

		return false;
	}
}
