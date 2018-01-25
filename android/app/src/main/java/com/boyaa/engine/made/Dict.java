package com.boyaa.engine.made;

/**
 * 1.存取数据类<br/>
 * 2.Android下生成的数据以文件形式存储路径：
 *   外部扩展卡(或SD)/.{package_name}/dict/中,<br/>
 *   以隐藏文件的形式存在。<br/>
 *   如果无外部扩展卡或者其不能访问应用程序将无法访问此文件。<br/>
 * 3.所有方法在lua线程中调用
 */
public class Dict {
	/**
	 * 设置int类型数据
	 * @param dictName dict的名字
	 * @param key 字符串key值
	 * @param value 需要设置的数据
	 * @return 设置成功返回0，否则返回-1
	 */
    public static int  setInt(String dictName, String key, int value) {
        return GhostLib.dictSetInt(dictName, key, value);
    }
    /**
     * 设置double类型数据
     * @param dictName dict的名字
	 * @param key 字符串key值
	 * @param value 需要设置的数据
     * @return 设置成功返回0，否则返回-1
     */
    public static int setDouble(String dictName, String key, double value) {
        return GhostLib.dictSetDouble(dictName, key, value);
    }
    /**
     * 设置string类型数据
     * @param dictName dict的名字
	 * @param key 字符串key值
	 * @param value 需要设置的数据
     * @return 设置成功返回0，否则返回-1
     */
    public static int      setString(String dictName, String key, String value) {
    	if ( null == value || 0 == value.length()){
			return GhostLib.dictSetString(dictName, key, null); 
		}
		byte[] barr = value.getBytes();
        return GhostLib.dictSetString(dictName, key, barr);
    }
    /**
     * 获取int类型数据
     * @param dictName dict的名字
	 * @param key 字符串key值
     * @param defaultValue 如果不存在此key，则返回defaultValue。
     * @return int类型数据
     */
    public static int getInt(String dictName, String key, int defaultValue) {
        return GhostLib.dictGetInt(dictName, key, defaultValue);
    }
    
    /**
     * 获取Double类型数据
     * @param dictName dict的名字
	 * @param key 字符串key值
     * @param defaultValue 如果不存在此key，则返回defaultValue。
     * @return Double类型数据
     */
    public static int getDouble(String dictName, String key, double defaultValue) {
        return GhostLib.dictGetDouble(dictName, key, defaultValue);
    }
    /**
     * 获取String类型数据
     * @param dictName dict的名字
	 * @param key 字符串key值
     * @return String类型数据
     */
    public static String   getString(String dictName, String key) {
        byte[] str = GhostLib.dictGetString(dictName,key);
        if (str != null && str.length > 0) {
            return new String(str);
        }

        return "";
    }
    /**
     * 删除某组本地数据
     * @param dictName dict的名字
     * @return 删除成功返回0，否则返回-1
     */
    public static int erase(String dictName) {
        return GhostLib.dictDelete(dictName);
    }
    
    /**
     * 存储某组本地数据
     * @param dictName dict的名字
     * @return 保存成功返回0，否则返回-1
     */
    public static int save(String dictName) {
        return GhostLib.dictSave(dictName);
    }
}
