package com.boyaa.entity.common.utils;

public class PassportData {
	public final static String BOYAAKEY = "1362118190";
	public final static String BOYAASECRET = "ermj124!%#z%xu2a*F$Jp05!@#zSoz*A";
	
	public static String BOYAARC4SECRET_NORMAL = "by@#RKas[d09fik2#R_k5|s*op";
	public static String BOYAARC4SECRET_TEST = "by$!Gl_+d#f$%)Sk2=,>zI-l";  //测试
	
	public static String BOYAARC4SECRET = BOYAARC4SECRET_NORMAL;
	
	public static String PASSPORT_QUICK_URL_NORMAL = "http://passport.boyaa.com/user/check";
	public static String PASSPORT_QUICK_URL_TEST = "http://passport-debug.boyaa.com/user/check";
	
	public static String PASSPORT_QUICK_URL = PASSPORT_QUICK_URL_NORMAL; 
	
	public static String PASSPORT_H5_URL_NORMAL = "http://id.boyaa.com/h5/";
	public static String PASSPORT_H5_URL_TEST = "http://192.168.202.12/h5/";
	
	public static String PASSPORT_H5_URL = PASSPORT_H5_URL_NORMAL;
	
	public static void changeMode(boolean isTest) {
		if( isTest) {
			BOYAARC4SECRET = BOYAARC4SECRET_TEST;
			PASSPORT_QUICK_URL = PASSPORT_QUICK_URL_TEST;
			PASSPORT_H5_URL = PASSPORT_H5_URL_TEST;
		} else {
			BOYAARC4SECRET = BOYAARC4SECRET_NORMAL;
			PASSPORT_QUICK_URL = PASSPORT_QUICK_URL_NORMAL;
			PASSPORT_H5_URL = PASSPORT_H5_URL_NORMAL;
		}
	}
}
