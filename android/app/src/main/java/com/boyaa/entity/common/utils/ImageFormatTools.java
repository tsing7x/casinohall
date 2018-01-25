package com.boyaa.entity.common.utils;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;

public class ImageFormatTools {
	public static InputStream Byte2InputStream(byte[] b) {
		ByteArrayInputStream bais = new ByteArrayInputStream(b);
		return bais;
	}

	public static byte[] InputStream2Bytes(InputStream is) {
		String str = "";
		byte[] readByte = new byte[1024];
		try {
			while ( is.read(readByte, 0, 1024) != -1) {
				str = str + new String(readByte).trim();
			}
			return str.getBytes();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	public static InputStream Bitmap2InputStream(Bitmap bm) {
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		bm.compress(Bitmap.CompressFormat.JPEG, 100, baos);
		InputStream is = new ByteArrayInputStream(baos.toByteArray());
		return is;
	}

	public static InputStream Bitmap2InputStream(Bitmap bm, int quality) {
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		bm.compress(Bitmap.CompressFormat.PNG, quality, baos);
		InputStream is = new ByteArrayInputStream(baos.toByteArray());
		return is;
	}

	public static Bitmap InputStream2Bitmap(InputStream is) {
		return BitmapFactory.decodeStream(is);
	}

	public static InputStream Drawable2InputStream(Drawable d) {
		Bitmap bitmap = Drawable2Bitmap(d);
		return Bitmap2InputStream(bitmap);
	}

	public static Drawable InputStream2Drawable(InputStream is) {
		Bitmap bitmap = InputStream2Bitmap(is);
		return Bitmap2Drawable(bitmap);
	}

	public static byte[] Drawable2Bytes(Drawable d) {
		Bitmap bitmap = Drawable2Bitmap(d);
		return Bitmap2Bytes(bitmap);
	}

	public static Drawable Bytes2Drawable(byte[] b) {
		Bitmap bitmap = Bytes2Bitmap(b);
		return Bitmap2Drawable(bitmap);
	}

	public static byte[] Bitmap2Bytes(Bitmap bm) {
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		bm.compress(Bitmap.CompressFormat.PNG, 100, baos);
		return baos.toByteArray();
	}

	public static Bitmap Bytes2Bitmap(byte[] b) {

		if (b.length != 0) {
			return BitmapFactory.decodeByteArray(b, 0, b.length);
		}
		return null;
	}

	public static Bitmap Drawable2Bitmap(Drawable drawable) {

		Bitmap bitmap = Bitmap.createBitmap(drawable.getIntrinsicWidth(),
				drawable.getIntrinsicHeight(),
				drawable.getOpacity() != -1 ? Bitmap.Config.ARGB_8888
						: Bitmap.Config.RGB_565);

		Canvas canvas = new Canvas(bitmap);
		drawable.setBounds(0, 0, drawable.getIntrinsicWidth(),
				drawable.getIntrinsicHeight());
		drawable.draw(canvas);

		return bitmap;
	}

	@SuppressWarnings("deprecation")
	public static Drawable Bitmap2Drawable(Bitmap bitmap) {
		BitmapDrawable bd = new BitmapDrawable(bitmap);
		Drawable d = bd;
		return d;
	}
	
	public static Bitmap resizeBitmap( Bitmap bitmap, int width, int height ){
		if ( bitmap == null ) {
			return null;
		}
		int orgWidth = bitmap.getWidth();
		int orgHeight = bitmap.getHeight();
		float scaleX = width / (float)orgWidth;
		float scaleY = height / (float)orgHeight;
		Matrix matrix = new Matrix();
		matrix.postScale(scaleX, scaleY);
		Bitmap newBitmap = Bitmap.createBitmap(bitmap, 0, 0,orgWidth, orgHeight, matrix , true );
		return newBitmap;
	}
}
