package com.boyaa.entity.common.utils;

import android.widget.Toast;

import com.boyaa.hallgame.Game;

import java.security.MessageDigest;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

//import com.boyaa.made.AppActivity;
public class UtilTool {
	private static final char[] HEX_DIGITS = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
	public static final String MD5 = "MD5";
	public static final String SHA1 = "SHA1";

	public static void showToast(String text, int duration) {

		Toast.makeText(Game.getInstance(), text, duration).show();
	}

	public static void showToast(String text) {
		showToast(text , 1000);
	}

	public static void showToast(int resId) {
		String s = Game.getInstance().getString(resId);
		showToast(s);
	}

	public static String replaceBlank(String str) {
		String dest = "";
		if (str != null) {
			Pattern p = Pattern.compile("\\s*|\t|\r|\n");
			Matcher m = p.matcher(str);
			dest = m.replaceAll("");
		}
		return dest;
	}

	public static String getMsg(int resId){
		String str = Game.getInstance().getResources().getString(resId);
		return str;
	}

	public static String encodeString(String algorithm, String input)
	{
		if (input == null) {
			return null;
		}
		try {
			MessageDigest messageDigest = MessageDigest.getInstance(algorithm);
			messageDigest.update(input.getBytes());
			return getFormattedText(messageDigest.digest());
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

	private static String getFormattedText(byte[] bytes) {
		int len = bytes.length;
		StringBuilder buf = new StringBuilder(len * 2);
		// 把密文转换成十六进制的字符串形式
		for (int j = 0; j < len; j++) {
			buf.append(HEX_DIGITS[(bytes[j] >> 4) & 0x0f]);
			buf.append(HEX_DIGITS[bytes[j] & 0x0f]);
		}
		return buf.toString();
	}

	
}