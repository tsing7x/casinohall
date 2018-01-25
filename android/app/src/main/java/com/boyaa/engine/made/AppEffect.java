package com.boyaa.engine.made;

import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import android.content.Context;
import android.media.AudioManager;
import android.media.SoundPool;

/**
 * Created by VincentGong on 15/8/6.
 */
public class AppEffect {
	private final int INVAILD_ID = -1;
	private final int MAX_STREAMDS = 5;
	private final int SOUND_QUALITY = 5;

	public static int sCustomID = 0;

	private class SoundItem {
		public int customID = INVAILD_ID;
		public String path;
		public int soundID = INVAILD_ID;
		public int streamID = INVAILD_ID;

		// it is auto increment, I think it will be safe
		SoundItem() {
			customID = ++sCustomID;
		}
	};

	private float mVolume = 1.0f;

	// private ExecutorService mExecutorService =
	// Executors.newSingleThreadScheduledExecutor();
	// mSoundPool will be visited in mExecutorService thread
	private SoundPool mSoundPool = new SoundPool(MAX_STREAMDS,
			AudioManager.STREAM_MUSIC, 0);

	// These will be visited in AppEfect thread
	private Map<String, Integer> mPathCustomIDMap = Collections.synchronizedMap(new HashMap<String, Integer>());
	private Map<Integer, SoundItem> mCustomIDSoundItemMap = Collections.synchronizedMap(new HashMap<Integer, SoundItem>());
	private Set<Integer> mAutoPlayCustomIDArray = Collections.synchronizedSet(new HashSet<Integer>());

	Context mContext;

	public AppEffect() {
		setOnLoadCompleteListener();
	}

	public void setOnLoadCompleteListener() {

		if (mSoundPool != null) {
			mSoundPool
					.setOnLoadCompleteListener(new SoundPool.OnLoadCompleteListener() {
						@Override
						public void onLoadComplete(final SoundPool soundPool,
								final int sampleId, int status) {
							// load successfully
							if (status == 0) {
								Iterator<Integer> iterator = mAutoPlayCustomIDArray
										.iterator();
								while (iterator.hasNext()) {
									int customID = iterator.next();
									SoundItem item = getItem(customID);
									if (item != null
											&& item.soundID == sampleId) {
										iterator.remove();
										int streamID = soundPool.play(sampleId,
												mVolume, mVolume,
												SOUND_QUALITY, 0, 1.0f);
										item.streamID = streamID;
										return;
									}
								}
							}
						}
					});
		}
	}

	/**
	 * By default,not play automatically
	 * @param path
	 */
	public int preload(String path) {
		/*
		 * if (mPathCustomIDMap.containsKey(path)) { Integer customID =
		 * mPathCustomIDMap.get(path); // if it is here, that it must be loading
		 * or loaded return customID; } if(mSoundPool == null){ mSoundPool = new
		 * SoundPool(MAX_STREAMDS, AudioManager.STREAM_MUSIC,0); } final
		 * SoundItem item = new SoundItem(); item.path = path;
		 * mCustomIDSoundItemMap.put(item.customID,item);
		 * mPathCustomIDMap.put(path,item.customID);
		 * 
		 * int soundID = mSoundPool.load(path, 1); item.soundID = soundID;
		 * return item.customID;
		 */
		return preload(path, false);
	}

	public int preload(String path, boolean autoPlay) {
		if (mPathCustomIDMap.containsKey(path)) {
			Integer customID = mPathCustomIDMap.get(path);
			if (autoPlay) {
				mAutoPlayCustomIDArray.add(customID);
			}
			// if it is here, that it must be loading or loaded
			return customID;
		}

		if (mSoundPool == null) {
			mSoundPool = new SoundPool(MAX_STREAMDS, AudioManager.STREAM_MUSIC,
					0);
			setOnLoadCompleteListener();
		}

		final SoundItem item = new SoundItem();
		item.path = path;
		mCustomIDSoundItemMap.put(item.customID, item);
		mPathCustomIDMap.put(path, item.customID);

		int soundID = mSoundPool.load(path, 1);
		item.soundID = soundID;
		if (autoPlay) {
			mAutoPlayCustomIDArray.add(item.customID);
		}
		return item.customID;
	}

	public int play(String path, boolean isLoop) {
		if (!mPathCustomIDMap.containsKey(path)) {
			int customID = preload(path);
			mAutoPlayCustomIDArray.add(customID);
			return customID;
		}

		Integer customID = mPathCustomIDMap.get(path);
		final SoundItem item = mCustomIDSoundItemMap.get(customID);

		// If it is removed, reload it
		if (item == null) {
			int newCustomID = preload(path);
			mAutoPlayCustomIDArray.add(newCustomID);
			return newCustomID;
		}

		// loading, put it in auto play list
		if (item.soundID == INVAILD_ID) {
			mAutoPlayCustomIDArray.add(customID);
		} else {
			// loaded, play it
			// if it is vaild, stop it first
			if (item.streamID != INVAILD_ID) {
				mSoundPool.stop(item.streamID);
			}
			int loop = isLoop ? -1 : 0;
			item.streamID = mSoundPool.play(item.soundID, mVolume, mVolume,
					SOUND_QUALITY, loop, 1.0f);
		}

		return customID;
	}

	public void stop(int customID) {
		final SoundItem item = getItem(customID);
		// never played, or has been removed
		if (item == null) {
			return;
		}
		mSoundPool.stop(item.streamID);
		item.streamID = INVAILD_ID;
	}

	public void unload(int customID) {
		SoundItem item = getItem(customID);

		if (item == null) {
			return;
		}

		removeItem(customID);

		int streamID = item.streamID;
		int soundID = item.soundID;

		if (streamID != INVAILD_ID) {
			mSoundPool.stop(streamID);
		}
		mSoundPool.unload(soundID);
	}

	public void unload(String path) {
		int customID = INVAILD_ID;
		if (mPathCustomIDMap.containsKey(path)) {
			customID = mPathCustomIDMap.get(path);
		}

		unload(customID);
	}

	public void pause(int customID) {
		SoundItem item = getItem(customID);
		if (item != null && item.streamID != INVAILD_ID) {
			mSoundPool.pause(item.streamID);
		}
	}

	public void resume(int customID) {
		SoundItem item = getItem(customID);
		if (item != null && item.streamID != INVAILD_ID) {
			mSoundPool.resume(item.streamID);
		}
	}

	public float getVolume() {
		return mVolume;
	}

	public void setVolume(float volume) {
		mVolume = volume;
	}

	public void pauseAll() {
		mSoundPool.autoPause();
	}

	public void resumeAll() {
		mSoundPool.autoResume();
	}

	public void stopAll() {
		int length = mCustomIDSoundItemMap.size();
		for (int i = 0; i < length; i++) {
			stop(mCustomIDSoundItemMap.get(i).customID);
		}
	}

	/**
	 * release resources,Initialization is resumed
	 */
	public void release() {
		if (mSoundPool != null) {
			mSoundPool.release();
			mSoundPool = null;
			mPathCustomIDMap = new HashMap<String, Integer>();
			mCustomIDSoundItemMap = new HashMap<Integer, SoundItem>();
			mAutoPlayCustomIDArray = new HashSet<Integer>();
		}
	}

	private void removeItem(int customID) {
		mCustomIDSoundItemMap.remove(customID);
	}

	private SoundItem getItem(int customID) {
		return mCustomIDSoundItemMap.get(customID);
	}
}
