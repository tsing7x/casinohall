package com.boyaa.entity.common.utils;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.IntBuffer;

import javax.microedition.khronos.opengles.GL10;

import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.opengl.GLES10;
import android.os.Environment;
import android.util.Log;

public class ScreenShot {

	public static boolean shottingEnded = true;
	public static Bitmap bitmap;
	public static int showTipFlag = 0;

	/**
	 * 创建截图
	 */
	public static synchronized boolean quickShotcut(int x, int y, int width, int height) {
		shottingEnded = false;
		long time = System.currentTimeMillis();

		if (bitmap != null)
			bitmap.recycle();

		bitmap = createBitmapFromGLSurface(x, y, width, height);
		time = System.currentTimeMillis() - time;
		Log.d("LuaEvent", "截屏耗时:" + time);
		shottingEnded = true;

		return bitmap == null ? false : true;
	}

	/**
	 * 创建截图。必须是gl线程
	 * 
	 * @param x
	 * @param y
	 * @param w
	 * @param h
	 * @return
	 */
	public static synchronized Bitmap createBitmapFromGLSurface(int x, int y, int w, int h) {
		int bitmapBuffer[] = new int[w * h];
		int bitmapSource[] = new int[w * h];
		IntBuffer intBuffer = IntBuffer.wrap(bitmapBuffer);
		intBuffer.position(0);

		try {
			GLES10.glReadPixels(x, y, w, h, GL10.GL_RGBA,
					GL10.GL_UNSIGNED_BYTE, intBuffer);
			int offset1, offset2;
			for (int i = 0; i < h; i++) {
				offset1 = i * w;
				offset2 = (h - i - 1) * w;
				for (int j = 0; j < w; j++) {
					int texturePixel = bitmapBuffer[offset1 + j];
					int blue = (texturePixel >> 16) & 0xff;
					int red = (texturePixel << 16) & 0x00ff0000;
					int pixel = (texturePixel & 0xff00ff00) | red | blue;
					bitmapSource[offset2 + j] = pixel;
				}
			}
		} catch (Exception e) {
			return null;
		}
		Bitmap bmp = Bitmap.createBitmap(bitmapSource, w, h,
				Bitmap.Config.RGB_565);
		int width = bmp.getWidth();
		int height = bmp.getHeight();
		if (width > 1280) {
			float scale = (float) bmp.getWidth() / (float) bmp.getHeight();
			width = 1280;
			height = (int) (width / scale);
			bmp = Bitmap.createScaledBitmap(bmp, width, height, true);
		}
		return bmp;
	}

	public static synchronized String saveBitmapAsFile(Bitmap bmp, String fileName) {
		Log.d("share", "saveBitmapAsFile" + fileName);
		File file = new File(Environment.getExternalStorageDirectory() + "/mjShare/");
		File pic = null;
		try {
			if( !file.exists() || !file.isDirectory()) {
				file.mkdir();
			}
			pic = new File(Environment.getExternalStorageDirectory() + "/mjShare/", fileName);
			if (!pic.exists()) {
				pic.createNewFile();
			} 
		} catch (IOException e) {
			return null;
		}
		savePic(bmp, pic.getAbsolutePath(), Bitmap.CompressFormat.JPEG);
		return pic.getAbsolutePath();
	}

	public static boolean savePic(Bitmap b, String strFileName,
			CompressFormat format) {
		FileOutputStream fos = null;
		try {
			fos = new FileOutputStream(strFileName);
			if (null != fos) {
				b.compress(format, 100, fos);
				fos.flush();
				fos.close();
				return true;
			}
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return false;
	}
}