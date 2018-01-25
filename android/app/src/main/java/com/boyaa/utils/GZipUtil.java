package com.boyaa.utils;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.zip.DeflaterOutputStream;
import java.util.zip.GZIPInputStream;
import java.util.zip.GZIPOutputStream;
import java.util.zip.InflaterInputStream;

import android.text.TextUtils;

/**
 * GZIP 压缩解压工具
 * @author junmeng
 */
public class GZipUtil {
	
	/**
	 * 压缩文件
	 * @param inFileName 源文件
	 * @param outFileName 压缩后的文件
	 */
	public static void doCompressFile(String inFileName, String outFileName) {

		try {
			GZIPOutputStream out = null;
			try {
				out = new GZIPOutputStream(new FileOutputStream(outFileName));
			} catch (FileNotFoundException e) {
			}

			FileInputStream in = null;
			try {
				in = new FileInputStream(inFileName);
			} catch (FileNotFoundException e) {
			}

			byte[] buf = new byte[1024];
			int len;
			while ((len = in.read(buf)) > 0) {
				out.write(buf, 0, len);
			}
			in.close();

			out.finish();
			out.close();

		} catch (IOException e) {
		}

	}

	/**
	 * 解压文件
	 * @param inFileName 源文件
	 * @param outFileName 解压后的文件
	 */
	public static void doUncompressFile(String inFileName, String outFileName) {

		try {
			GZIPInputStream in = null;
			try {
				in = new GZIPInputStream(new FileInputStream(inFileName));
			} catch (FileNotFoundException e) {
			}

			FileOutputStream out = null;
			try {
				out = new FileOutputStream(outFileName);
			} catch (FileNotFoundException e) {
			}

			byte[] buf = new byte[1024];
			int len;
			while ((len = in.read(buf)) > 0) {
				out.write(buf, 0, len);
			}
			
			in.close();
			out.close();

		} catch (IOException e) {
		}
	}
	
	/**
	 * 用InflaterInputStream解压字符串
	 * @param zippedText
	 * @param srcCharset
	 * @param outCharset
	 * @return
	 */
	public static String unzipString(String zippedText, String srcCharset, String outCharset) {
	    String unzipped = null;
	    srcCharset = TextUtils.isEmpty(srcCharset)? "utf-8" : srcCharset;
	    outCharset = TextUtils.isEmpty(outCharset)? "utf-8" : outCharset;
	    try {
	        byte[] zbytes = zippedText.getBytes(srcCharset);
	        // Add extra byte to array when Inflater is set to true
	        byte[] input = new byte[zbytes.length + 1];
	        System.arraycopy(zbytes, 0, input, 0, zbytes.length);
	        input[zbytes.length] = 0;
	        ByteArrayInputStream bin = new ByteArrayInputStream(input);
	        InflaterInputStream in = new InflaterInputStream(bin);
	        ByteArrayOutputStream bout = new ByteArrayOutputStream(512);
	        int b;
			while ((b = in.read()) != -1) {
				bout.write(b);
			}
			bin.close();
	        bout.close();
	        unzipped = bout.toString(outCharset);
	    } catch (Exception e) {
	    	e.printStackTrace();
	    }
	    return unzipped;
	 }
	
	/**
	 * 压缩字符串(目前经测试貌似只有当压缩解压编码同时为ISO-8859-1时才能用GZIPInputStream解压GZIPOutputStream)
	 * @param sourceString 未压缩String
	 * @param sourceCharset
	 * @param outCharset
	 * @return
	 */
	public static String doCompressString(String sourceString, String sourceCharset, String outCharset) {
		String result = "";
		if (TextUtils.isEmpty(sourceString)) {
			return result;
		}
		
		byte[] inBytes = null;
		ByteArrayInputStream byteIn = null;
		ByteArrayOutputStream byteOut = null;
		GZIPOutputStream gzipOut = null;
		
		try {
			
			if (TextUtils.isEmpty(sourceCharset)) {
				inBytes = sourceString.getBytes();
			} else {
				inBytes = sourceString.getBytes(sourceCharset);
			}
			byteIn = new ByteArrayInputStream(inBytes);
			byteOut = new ByteArrayOutputStream();
			byte[] buffer = new byte[1024];
			int length;
			gzipOut = new GZIPOutputStream(byteOut);
			
			while((length = byteIn.read(buffer))>0) {
				gzipOut.write(buffer, 0, length);
			}
			gzipOut.finish();
			
			if (TextUtils.isEmpty(outCharset)) {
				result = byteOut.toString();
			} else {
				result = byteOut.toString(outCharset);
			}
			return result;
			
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (byteIn != null) {
				try {
					byteIn.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
			if (gzipOut != null) {
				try {
					gzipOut.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
			if (byteOut != null) {
				try {
					byteOut.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return result;
	}
	
	/**
	 * 解压字符串(目前经测试貌似只有当压缩解压编码同时为ISO-8859-1时才能用GZIPInputStream解压GZIPOutputStream)
	 * @param sourceString 已压缩String
	 * @param sourceCharset
	 * @param outCharset
	 * @return
	 */
	public static String doUncompressString(String sourceString, String sourceCharset, String outCharset) {
		String result = "";
		if (TextUtils.isEmpty(sourceString)) {
			return result;
		}
		
		byte[] inBytes = null;
		ByteArrayInputStream byteIn = null;
		ByteArrayOutputStream byteOut = null;
		GZIPInputStream gzipIn = null;
		
		try {
			
			if (TextUtils.isEmpty(sourceCharset)) {
				inBytes = sourceString.getBytes();
			} else {
				inBytes = sourceString.getBytes(sourceCharset);
			}
			
			byteIn = new ByteArrayInputStream(inBytes);
			byteOut = new ByteArrayOutputStream();
			byte[] buffer = new byte[1024];
			int length;
			gzipIn = new GZIPInputStream(byteIn);
			
			while((length = gzipIn.read(buffer))>0) {
				byteOut.write(buffer, 0, length);
			}
			
			if (TextUtils.isEmpty(outCharset)) {
				result = byteOut.toString();
			} else {
				result = byteOut.toString(outCharset);
			}
			return result;
			
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (gzipIn != null) {
				try {
					gzipIn.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
			if (byteIn != null) {
				try {
					byteIn.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
			if (byteOut != null) {
				try {
					byteOut.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return result;
	}
	
	public static byte[] zipString(String text, String srcCharset, String outCharset) {
	    byte[] zipped = null;
	    srcCharset = TextUtils.isEmpty(srcCharset)? "utf-8" : srcCharset;
	    outCharset = TextUtils.isEmpty(outCharset)? "utf-8" : outCharset;
	    try {
	        byte[] zbytes = text.getBytes(srcCharset);
	        // Add extra byte to array when Inflater is set to true
//	        byte[] input = new byte[zbytes.length + 1];
//	        System.arraycopy(zbytes, 0, input, 0, zbytes.length);
//	        input[zbytes.length] = 0;
	        ByteArrayOutputStream bout = new ByteArrayOutputStream();
	        DeflaterOutputStream out = new DeflaterOutputStream(bout);
			out.write(zbytes);
			out.close();
			zipped = bout.toByteArray();
	    } catch (Exception e) {
	    	e.printStackTrace();
	    }
	    
	    return zipped;
	 }
}
