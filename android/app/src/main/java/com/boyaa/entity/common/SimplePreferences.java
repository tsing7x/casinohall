package com.boyaa.entity.common;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
/**
 * 简单的数据存储类
 */
public class SimplePreferences {

	private static final String PREFERENCES_NAME = "SimplePreferences";
	private static SharedPreferences INSTANCE;
	private static Editor EDITORINSTANCE;

	public static SharedPreferences getInstance(final Context ctx) {

		if (SimplePreferences.INSTANCE == null) {

			SimplePreferences.INSTANCE = ctx.getSharedPreferences(
					SimplePreferences.PREFERENCES_NAME, Context.MODE_PRIVATE);
		}
		return SimplePreferences.INSTANCE;
	}

	public static Editor getEditorInstance(final Context ctx) {

		if (SimplePreferences.EDITORINSTANCE == null) {

			SimplePreferences.EDITORINSTANCE = SimplePreferences.getInstance(
					ctx).edit();
		}
		return SimplePreferences.EDITORINSTANCE;
	}

	public synchronized static String getString(final Context ctx,
			final String key, final String defValue) {

		return getInstance(ctx).getString(key, defValue);
	}

	public synchronized static void putString(final Context ctx,
			final String key, final String value) {

		getEditorInstance(ctx).putString(key, value).commit();
	}

	public synchronized static int getInt(final Context ctx, final String key,
			final int defValue) {

		return getInstance(ctx).getInt(key, defValue);
	}

	public synchronized static void putInt(final Context ctx, final String key,
			final int value) {

		getEditorInstance(ctx).putInt(key, value).commit();
	}

	public synchronized static boolean getBoolean(final Context ctx,
			final String key, final boolean defValue) {

		return getInstance(ctx).getBoolean(key, defValue);
	}

	public synchronized static void putBoolean(final Context ctx,
			final String key, final boolean value) {

		getEditorInstance(ctx).putBoolean(key, value).commit();
	}
	
	public synchronized static float getFloat(final Context ctx,
			final String key, final float defValue) {

		return getInstance(ctx).getFloat(key, defValue);
	}

	public synchronized static void putFloat(final Context ctx,
			final String key, final float value) {

		getEditorInstance(ctx).putFloat(key, value).commit();
	}
	
	public synchronized static void putLong(final Context ctx,
			final String key, final long value) {
		getEditorInstance(ctx).putLong(key, value).commit();
	}
}
