package com.boyaa.utils;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import android.app.Activity;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.Signature;
import android.content.pm.PackageManager.NameNotFoundException;
import android.util.Base64;
import android.util.Log;

public class PackageInfoUtil {
	
	public static void getKeyCode(Activity act,String packageName) {
		// Add code to print out the key hash
		Log.d("zyh ", "getKeyCode " + packageName);
	    try {
	    	if(packageName == null && act == null){
				Log.d("zyh ", "act is null and return");
	    		return;
	    	}
	    	if(packageName == null){
	    		packageName =  act.getPackageName();
	    	}
			Log.d("zyh", "packageName is " + packageName);
	        PackageInfo info = act.getPackageManager().getPackageInfo(packageName,PackageManager.GET_SIGNATURES);
			Log.d("zyh ", "before key code info ");
	        for (Signature signature : info.signatures) {
	            MessageDigest md = MessageDigest.getInstance("SHA");
	            md.update(signature.toByteArray());
				Log.d("zyh", "key hash");
	            Log.d("zyh KeyHash:", Base64.encodeToString(md.digest(), Base64.DEFAULT));
	        }
	    } catch (NameNotFoundException e) {
	    	e.printStackTrace();
	    } catch (NoSuchAlgorithmException e) {
	    	e.printStackTrace();
	    }
		
	}
}
