package com.boyaa.engine.made;

import android.media.MediaPlayer.OnCompletionListener;

/**
 * 音乐，音效控制类
 */
public class AppSound {
	static AppMusic sAppMusic = new AppMusic();
	static AppEffect sAppEffect = new AppEffect();

	/**
	 * 预加载音乐
	 * @param path 指定装载音乐文件绝对路径或者URL地址
	 */
	public static void preloadMusic(String path) {
		sAppMusic.preload(path);
	}

	/**
	 * 播放音乐
	 * @param path 指定装载音乐文件绝对路径或者URL地址
	 * @param isLoop 设置为true表示循环播放；false表示单曲播放
	 */
	public static void playMusic(String path, boolean isLoop) {
		sAppMusic.play(path, isLoop);
	}


	public static void setOnCompletionListener(OnCompletionListener listener) {
		sAppMusic.setOnCompletionListener(listener);
	}

	/**
	 * 停止音乐播放
	 * @param doRelease 无效
	 */
	public static void stopMusic(boolean doRelease) {
		sAppMusic.stop(doRelease);
	}

	/**
	 * 暂停播放
	 */
	public static void pauseMusic() {
		sAppMusic.pause();
	}

	/**
	 * 回复播放，从暂停播放处，重新开始播放
	 */
	public static void resumeMusic() {
		sAppMusic.resume();
	}

	/**
	 * 从头开始播放
	 */
	public static void rewindMusic() {
		sAppMusic.rewind();
	}

	/**
	 * 判断音乐是否在播放
	 * @return true 播放中；false 未播放或停止播放
	 */
	public static boolean isMusicPlaying() {
		return sAppMusic.isPlaying();
	}

	/**
	 * 获取当前音乐音量 ，取值为0~1.0(左右声道同一个值)
	 */
	public static float getMusicVolume() {
		return sAppMusic.getVolume();
	}

	/**
	 * 设置音乐音量(左右声道同一个值)，值域0.0~1.0
	 * @param volume 音乐音量
	 */
	public static void setMusicVolume(float volume) {
		sAppMusic.setVolume(volume);
	}

	/**
	 * 预加载音效
	 * @param path 指定装载音效文件绝对路径
	 */
	public static void preloadEffect(String path) {
		sAppEffect.preload(path);
	}

	/**
	 * 播放音效
	 * @param path 指定装载音效文件绝对路径
	 * @param isLoop 设置为true表示循环播放；false表示单曲播放
	 */
	public static int playEffect(String path, boolean isLoop) {
		return sAppEffect.play(path, isLoop);
	}

	/**
	 * 停止播放音效
	 * @param id 播放音效id
	 */
	public static void stopEffect(int id) {
		sAppEffect.stop(id);
	}

	/**
	 * 暂停播放音效
	 */
	public static void pauseEffect(int id) {
		sAppEffect.pause(id);
	}

	/**
	 * 恢复音效播放，从暂停播放处，重新开始播放
	 */
	public static void resumeEffect(int id) {
		sAppEffect.resume(id);
	}

	/**
	 * 暂停所有播放音效
	 */
	public static void pauseAllEffects() {
		sAppEffect.pauseAll();
	}
	/**
	 * 恢复所有音效播放，从暂停播放处，重新开始播放
	 */
	public static void resumeAllEffects() {
		sAppEffect.resumeAll();
	}
	/**
	 * 停止音效播放
	 */
	public static void stopAllEffect() {
		sAppEffect.stopAll();
	}
	/**
	 * 通过音效id卸载音效
	 * @param id 音效id
	 */
	public static void unloadEffect(int id) {
		sAppEffect.unload(id);
	}
	/**
	 * 通过音效路径卸载音效
	 * @param id 音效id
	 */
	public static void unloadEffect(String path) {
		sAppEffect.unload(path);
	}

	/**
	 * 获取音效音量 ，取值为0~1.0(左右声道同一个值)
	 * @return 音效音量
	 */
	public static float getEffectVolume() {
		return sAppEffect.getVolume();
	}
	/**
	 * 设置音效音量(左右声道同一个值)，值域为0.0~1.0
	 * @param volume 音效音量
	 */
	public static void setEffectVolume(float volume) {
		sAppEffect.setVolume(volume);
	}

	/**
	 * 释放所有声音资源
	 */
	public static void end() {
		sAppMusic.stop(true);
		sAppEffect.release();
	}

	/**
	 * 获取当前音乐路径
	 */
	public static String getCurrentMusicPath() {
		return sAppMusic.getCurrentMusicPath();
	}
}
