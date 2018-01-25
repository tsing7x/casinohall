package com.boyaa.entity.common;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PushbackInputStream;
import java.io.UnsupportedEncodingException;
import java.util.Enumeration;
import java.util.zip.GZIPInputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import java.util.zip.ZipInputStream;

import android.util.Log;

public class GZUtil extends GZIPInputStream {

	public GZUtil(InputStream in, int size) throws IOException {
		// Wrap the stream in a PushbackInputStream...
		super(new PushbackInputStream(in, size), size);
		this.size = size;
	}

	public GZUtil(InputStream in) throws IOException {
		// Wrap the stream in a PushbackInputStream...
		super(new PushbackInputStream(in, 1024));
		this.size = -1;
	}

	private GZUtil(GZUtil parent) throws IOException{
		super(parent.in);
		this.size = -1;
		this.parent = parent.parent == null ? parent : parent.parent;
		this.parent.child = this;
	}

	private GZUtil(GZUtil parent, int size) throws IOException {
		super(parent.in, size);
		this.size = size;
		this.parent = parent.parent == null ? parent : parent.parent;
		this.parent.child = this;
	}

	private GZUtil parent;

	private GZUtil child;

	private int size;

	private boolean eos;

	public int read(byte[] inputBuffer, int inputBufferOffset,
			int inputBufferLen) throws IOException {

		if (eos) {
			return -1;
		}
		if (this.child != null)
			return this.child.read(inputBuffer, inputBufferOffset,
					inputBufferLen);

		int charsRead = super.read(inputBuffer, inputBufferOffset,
				inputBufferLen);
		if (charsRead == -1) {
			// Push any remaining buffered data back onto the stream
			// If the stream is then not empty, use it to construct
			// a new instance of this class and delegate this and any
			// future calls to it...
			int n = inf.getRemaining() - 8;
			if (n > 0) {
				// More than 8 bytes remaining in deflater
				// First 8 are gzip trailer. Add the rest to
				// any un-read data...
				((PushbackInputStream) this.in).unread(buf, len - n, n);
			} else {
				// Nothing in the buffer. We need to know whether or not
				// there is unread data available in the underlying stream
				// since the base class will not handle an empty file.
				// Read a byte to see if there is data and if so,
				// push it back onto the stream...
				byte[] b = new byte[1];
				int ret = in.read(b, 0, 1);
				if (ret == -1) {
					eos = true;
					return -1;
				} else
					((PushbackInputStream) this.in).unread(b, 0, 1);
			}

			GZUtil child;
			if (this.size == -1)
				child = new GZUtil(this);
			else
				child = new GZUtil(this, this.size);
			return child.read(inputBuffer, inputBufferOffset, inputBufferLen);
		} else
			return charsRead;
	}

	public static void unZip(String gzPath, String topath) {

		try {
			int nnumber;

			FileInputStream fin = new FileInputStream(gzPath);

			GZUtil MmGz = new GZUtil(fin);
			FileOutputStream fout = new FileOutputStream(topath);

			byte[] buf = new byte[1024];

			nnumber = MmGz.read(buf, 0, buf.length);

			while (nnumber != -1) {

				fout.write(buf, 0, nnumber);
				nnumber = MmGz.read(buf, 0, buf.length);

			}
			MmGz.close();
			fout.close();
			fin.close();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	
	/**
	 * 解压zip文件
	 * @param zipFile  解压的zip 文件
	 * @param targetDir解压到的目录
	 */
	public static boolean unzipToDir(String zipFile, String targetDir) {
		boolean ret = true;
		int BUFFER = 4096; // 这里缓冲区我们使用4KB，
		String strEntry; // 保存每个zip的条目名称
		try {
			BufferedOutputStream dest = null; // 缓冲输出流
			FileInputStream fis = new FileInputStream(zipFile);
			ZipInputStream zis =  new ZipInputStream(new BufferedInputStream(fis));
			ZipEntry entry; // 每个zip条目的实例
			Log.i("Unzip: ", "begin unzip");
			while ((entry = zis.getNextEntry()) != null && ret) {
				if(entry.isDirectory())
				{
					Log.e("", "isDirectory="+entry.getName());
					File entryDir = new File(entry.getName());
					if (!entryDir.exists()) {
						
						entryDir.mkdirs();
					}
					continue;
				}
				try {
					Log.i("Unzip: ", "=" + entry);
					int count;
					byte data[] = new byte[BUFFER];
					strEntry = entry.getName();
					File entryFile = new File(targetDir + strEntry);
					File entryDir = new File(entryFile.getParent());

					if (!entryDir.exists()) {
						entryDir.mkdirs();
					}

					FileOutputStream fos = new FileOutputStream(entryFile);
					dest = new BufferedOutputStream(fos, BUFFER);
//					while ((count = zis.read(data, 0, BUFFER)) != -1) {
//						Log.d("zyh ", "unzip read count is " + count);
//						dest.write(data, 0, count);
//					}
					while(true)
					{
						count = zis.read(data, 0, BUFFER);
						//文件还有数据
						if(count > 0)
						{
							dest.write(data, 0, count);
						}
						//文件正常结束
						else if (count == -1)
						{
							break;
						}
						//错误情况，可能为0，或者其他负值，解压失败
						else
						{
							ret = false;
							break;
						}
					}
					dest.flush();
					dest.close();
				} catch (Exception ex) {
					ex.printStackTrace();
					ret = false;
					Log.i("Unzip: ", "ex=" + ex.toString());
				}
			}
			zis.close();
		} catch (Exception cwj) {
			cwj.printStackTrace();
			ret = false;
			Log.i("Unzip: ", "cwj=" + cwj.toString());
		}
		return ret;
	}
	/**
	 * 解压zip文件
	 * @param zipFile  解压的zip 文件
	 * @param targetDir解压到的目录
	 */
	public static void unzipToDir1(String zipFile, String targetDir) {
		
		int BUFFER = 4096; // 这里缓冲区我们使用4KB，
		String strEntry; // 保存每个zip的条目名称
		try {
			BufferedOutputStream dest = null; // 缓冲输出流
			FileInputStream fis = new FileInputStream(zipFile);
			ZipInputStream zis =  new ZipInputStream(new BufferedInputStream(fis));
			ZipEntry entry; // 每个zip条目的实例
			Log.i("Unzip: ", "begin unzip");
			while ((entry = zis.getNextEntry()) != null) {

				try {
					Log.i("Unzip: ", "=" + entry);
					int count;
					byte data[] = new byte[BUFFER];
					strEntry = entry.getName();

					File entryFile = new File(targetDir + strEntry);
					File entryDir = new File(entryFile.getParent());
				
					if (!entryDir.exists()) {
						
						entryDir.mkdirs();
					}

					FileOutputStream fos = new FileOutputStream(entryFile);
					dest = new BufferedOutputStream(fos, BUFFER);
					while ((count = zis.read(data, 0, BUFFER)) != -1) {
						dest.write(data, 0, count);
					}
					dest.flush();
					dest.close();
				} catch (Exception ex) {
					ex.printStackTrace();
					Log.i("Unzip: ", "ex=" + ex.toString());
				}
			}
			zis.close();
		} catch (Exception cwj) {
			cwj.printStackTrace();
			Log.i("Unzip: ", "cwj=" + cwj.toString());
		}
	}
	
	/**
     * 解压缩功能.
     * 将zipFile文件解压到folderPath目录下.
     * @throws Exception
 */
     public static int upZipFile(File zipFile, String folderPath){
     
    	 try {
         ZipFile zfile=new ZipFile(zipFile);
         Enumeration<?> zList=zfile.entries();
         ZipEntry ze=null;
         byte[] buf=new byte[1024];
         while(zList.hasMoreElements()){
             ze=(ZipEntry)zList.nextElement();    
             if(ze.isDirectory()){
                 Log.d("upZipFile", "ze.getName() = "+ze.getName());
                 String dirstr = folderPath + ze.getName();
                 //dirstr.trim();
                 dirstr = new String(dirstr.getBytes("8859_1"), "GB2312");
                 Log.d("upZipFile", "str = "+dirstr);
                 File f=new File(dirstr);
                 f.mkdir();
                 continue;
             }
             Log.d("upZipFile", "ze.getName() = "+ze.getName());
             OutputStream os=new BufferedOutputStream(new FileOutputStream(getRealFileName(folderPath, ze.getName())));
             InputStream is=new BufferedInputStream(zfile.getInputStream(ze));
             int readLen=0;
             while ((readLen=is.read(buf, 0, 1024))!=-1) {
                 os.write(buf, 0, readLen);
             }
             is.close();
             os.close();    
         }
         zfile.close();
    	 }catch(Exception e){
    		 e.printStackTrace();
    		 
    		 return -1;
    	 }
         return 0;
     }
 
     /**
     * 给定根目录，返回一个相对路径所对应的实际文件名.
     * @param baseDir 指定根目录
     * @param absFileName 相对路径名，来自于ZipEntry中的name
     * @return java.io.File 实际的文件
 */
     public static File getRealFileName(String baseDir, String absFileName){
         String[] dirs=absFileName.split("/");
         File ret=new File(baseDir);
         String substr = null;
         if(dirs.length>1){
             for (int i = 0; i < dirs.length-1;i++) {
                 substr = dirs[i];
                 try {
                     //substr.trim();
                     substr = new String(substr.getBytes("8859_1"), "GB2312");
                     
                 } catch (UnsupportedEncodingException e) {
                     // TODO Auto-generated catch block
                     e.printStackTrace();
                 }
                 ret=new File(ret, substr);
                 
             }
             Log.d("upZipFile", "1ret = "+ret);
             if(!ret.exists())
                 ret.mkdirs();
             substr = dirs[dirs.length-1];
             try {
                 //substr.trim();
                 substr = new String(substr.getBytes("8859_1"), "GB2312");
                 Log.d("upZipFile", "substr = "+substr);
             } catch (UnsupportedEncodingException e) {
                 // TODO Auto-generated catch block
                 e.printStackTrace();
             }
             ret=new File(ret, substr);
             Log.d("upZipFile", "2ret = "+ret);
             return ret;
         }else{
        	 ret=new File(ret,absFileName);
         }
         return ret;
     }
}
