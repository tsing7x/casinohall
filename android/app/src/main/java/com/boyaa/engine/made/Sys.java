package com.boyaa.engine.made;

/**
 * 1.系统存取数据类<br/>
 * 2.所有方法在lua线程中调用
 */

public class Sys {
	
	/**
	 * 设置int类型数据
	 * @param key 字符串key值
	 * @param value 需要设置的数据
	 * @return 设置成功返回0，否则返回-1
	 */
    public static int  setInt(String key, int value) {
        return GhostLib.sysSetInt(key, value);
    }

    /**
     * 设置double类型数据
	 * @param key 字符串key值
	 * @param value 需要设置的数据
     * @return 设置成功返回0，否则返回-1
     */
    public static int  setDouble(String key, double value) {
        return  GhostLib.sysSetDouble(key, value);
    }
    /**
     * 设置string类型数据
	 * @param key 字符串key值
	 * @param value 需要设置的数据
     * @return 设置成功返回0，否则返回-1
     */
    public static int      setString(String key, String value) {
        return GhostLib.sysSetString(key, value);
    }

    /**
     * 获取int类型数据
	 * @param key 字符串key值
     * @param defaultValue 如果不存在此key，则返回defaultValue。
     * @return int类型数据
     */
    public static int getInt(String key, int defaultValue) {
        return GhostLib.sysGetInt(key, defaultValue);
    }
    /**
     * 获取Double类型数据
	 * @param key 字符串key值
     * @param defaultValue 如果不存在此key，则返回defaultValue。
     * @return Double类型数据
     */
    public static double   getDouble(String key, double defaultValue) {
        return GhostLib.sysGetDouble(key, defaultValue);
    }
    /**
     * 获取String类型数据
	 * @param key 字符串key值
     * @return String类型数据
     */
    public static String   getString(String key) {
        return GhostLib.sysGetString(key);
    }
    /**
     * java 调用 lua 方法
	 * @param name lua方法名
     * @return 0:调用成功<br/>
	          -1:调用失败：Lua引擎已经进入error.lua页面<br/>
              -2:调用失败：strFunc为空<br/>
              -3:调用失败：函数名strFunc不符合格式要求<br/>
              -4:调用失败：无法找到strFunc定义的函数<br/>
              -5:调用失败：执行strFunc函数失败<br/>
     */
    public static int  callLua(String name) {
    	if (!AppActivity.checkThread()) {
			return -1;
		}
        return GhostLib.callLua(name);
    }
}
