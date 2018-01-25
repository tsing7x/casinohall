package com.boyaa.entity.images;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TreeMap;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.ContentUris;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.util.Log;

import com.boyaa.entity.common.SDTools;
import com.boyaa.entity.common.SdkVersion;
import com.boyaa.entity.common.utils.JsonUtil;
import com.boyaa.hallgame.Game;
//import com.boyaa.made.AppActivity;

public class SaveImage {
	
	private Game activity;
	private String strDicName;
	
	private static int MAXSIZE = 192;   //图片的长、宽最大长度
	private static int MINSIZE = 84;   //图片的长、宽最小长度
	private static int CROPSIZE = 300; //图片裁剪大小
	private static boolean isCrop = true;
	
	private String  imageName= "";
	private static boolean savesucess = false;
	
	public static final int PHOTO_PICKED_WITH_DATA = 1001; // 用来标识请求gallery的activity 
	public static final int CAMERA_WITH_DATA = 1002; // 用来标识请求camera的activity 
	public static final int PHOTO_CROP_WITH_DATA = 1003;
	public static final int PHOTO_PICKED_WITH_DATA_KITKAT = 1004; // 用来标识请求gallery的activity 
	File mCurrentPhotoFile;
	public SaveImage(Game activity , String strDicName){
		this(activity,strDicName,true,300);
	}
	
	public SaveImage(Game activity , String strDicName,int croplen){
		this(activity,strDicName,true,croplen);
	}
	
	public SaveImage(Game activity , String strDicName,boolean cropflag){
		this(activity,strDicName,cropflag,300);
	}
	
	public SaveImage(Game activity , String strDicName,boolean cropflag,int croplen){
		this.activity = activity;
		this.strDicName = strDicName;
		
		isCrop = cropflag;
		
		if(croplen <= 0){
			isCrop = false;
		}else{
			croplen = croplen < MINSIZE ? MINSIZE : croplen;
			croplen = croplen > MAXSIZE ? MAXSIZE : croplen;
			CROPSIZE = croplen;
		}
	}
		
	/**
	 * 请求Gallery程序
	 */
	public void pickImageFromGallery(){
	//	Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
	//	intent.setType("image/*");
//		if(isCrop == true){
//			intent.putExtra("crop", "true");
//			intent.putExtra("aspectX", 1);
//			intent.putExtra("aspectY", 1);
//			intent.putExtra("outputX", CROPSIZE);
//			intent.putExtra("outputY", CROPSIZE);
//			intent.putExtra("return-data", true);
//		}
		
		Intent intent=new Intent(Intent.ACTION_GET_CONTENT);//ACTION_OPEN_DOCUMENT  
		intent.addCategory(Intent.CATEGORY_OPENABLE);  
		intent.setType("image/*");  
		if(android.os.Build.VERSION.SDK_INT>=android.os.Build.VERSION_CODES.KITKAT){                  
		        //startActivityForResult(intent, SELECT_PIC_KITKAT);    
		        activity.startActivityForResult(Intent.createChooser(intent, "请选择图片"), PHOTO_PICKED_WITH_DATA_KITKAT);
		}else{                
		       // startActivityForResult(intent, SELECT_PIC); 
		        activity.startActivityForResult(Intent.createChooser(intent, "请选择图片"), PHOTO_PICKED_WITH_DATA);
		} 
		
		//activity.startActivityForResult(Intent.createChooser(intent, "请选择图片"), PHOTO_PICKED_WITH_DATA);
	}
	public void pickImageFromGallery(String name) {
		imageName = name;
				
		pickImageFromGallery();
	}
	
	/**
	 * 请求Camera程序
	 */
	public void pickImageFromCamera(){
		if (Environment.getExternalStorageState().equals(
				Environment.MEDIA_MOUNTED)) {
			mCurrentPhotoFile = new File(Game.getInstance().getImagePath(),  imageName + System.currentTimeMillis() + SDTools.PNG_SUFFIX); // 用当前时间给取得的图片命名

			Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
			Uri fromFile = Uri.fromFile(mCurrentPhotoFile);
			String string = fromFile.toString();
			Log.i("gp", string);
			intent.putExtra(MediaStore.EXTRA_OUTPUT, fromFile);
			activity.startActivityForResult(intent, CAMERA_WITH_DATA);
		} else {
			System.out.println("没有SD卡");
		}
	}
	
	public void pickImageFromCamera(String name){
		imageName = name;
		pickImageFromCamera();
	}
		
	public void cropImageFromCamara(Intent data){	
		if (mCurrentPhotoFile == null){
			return;
		}
		
		if(isCrop == true){
			Uri uri = Uri.fromFile(mCurrentPhotoFile);
			
			try {
				Log.e("xxxxxx", "启动gallery去剪辑这个照片");
				// 启动gallery去剪辑这个照片
				final Intent intent = getCropImageIntent(uri,CROPSIZE);
				
				activity.startActivityForResult(intent, PHOTO_CROP_WITH_DATA);
			} catch (Exception e) {
				System.out.println("剪切失败");
			}
		}
		else{
			saveBitmapImage(data);
		}
	}		
	public void cropImageFromPhoto(Intent data){	
		
		if(isCrop == true){
			Uri uri = null;
			if (data != null) {
				uri = data.getData();
			}else {
				uri = Uri.fromFile(mCurrentPhotoFile);
			}
			mCurrentPhotoFile = null;
			
			try {
				Log.e("xxxxxx", "启动gallery去剪辑这个照片 = " + uri.getPath());
				// 启动gallery去剪辑这个照片
				final Intent intent = getCropImageIntent(uri,CROPSIZE);
				activity.startActivityForResult(intent, PHOTO_CROP_WITH_DATA);
				
			} catch (Exception e) {
				System.out.println("剪切失败");
			}
		}
		else{
			saveBitmapImage(data);
		}
	}		
	public void cropImageFromPhotoKitkat(Intent data){	
		
		if(isCrop == true){
			Uri uri =  data.getData();
			
			try {
				Log.e("xxxxxx", "启动gallery去剪辑这个照片 = " + uri.getPath());
				// 启动gallery去剪辑这个照片

				//jaywillou-20160624-solved android6.0 can not crop image-start
				if (SdkVersion.Below23()) {//小于6.0
				    //原代码
					Log.d("xxxxxx","below6.0");
					String path = getPath(activity, uri);
					Uri pickUri = Uri.fromFile(new File(path));
					final Intent intent = getCropImageIntent(pickUri ,CROPSIZE);
					activity.startActivityForResult(intent, PHOTO_CROP_WITH_DATA);
				}else {
					//新代码
					Log.d("xxxxxx","above6.0");
					Bitmap bmp = null;
					String path = "";
					try {
						bmp = MediaStore.Images.Media.getBitmap(activity.getContentResolver(), uri);
						path = MediaStore.Images.Media.insertImage(activity.getContentResolver(), bmp, "", "");
					} catch (IOException e) {
						e.printStackTrace();
					}
					if (path != null) {
						Uri pickUri = Uri.parse(path);
						final Intent intent = getCropImageIntent(pickUri, CROPSIZE);
						activity.startActivityForResult(intent, PHOTO_CROP_WITH_DATA);
					}
				}
				//jaywillou-20160624-solved android6.0 can not crop image-end

			} catch (Exception e) {
				System.out.println("剪切失败");
			}
		}
		else{
			saveBitmapImage(data);
		}
	}		
	public void saveBitmapImage(Intent data){	
		if(imageName == null){
			Log.e("xxxx", "imageName = null");
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyMMddHHmmss");
			imageName = dateFormat.format(new Date());
		}
		
		Log.e("xxxx", "imageName = "+imageName);
		
		if(data != null){
			Bitmap image = data.getParcelableExtra("data");
			if (image != null) {
			
				Log.d("DEBUG", "big width = " + image.getWidth()
						+ " height = " + image.getHeight());
			
	
				savesucess = SDTools.saveBitmap(
						activity, Game.getInstance().getImagePath(), imageName , image);
				image.recycle();
				image = null;

				BitmapFactory.Options options = new BitmapFactory.Options();
				options.inJustDecodeBounds = true;
				BitmapFactory.decodeFile(Game.getInstance().getImagePath(), options);
				int maxlen = (options.outHeight > options.outWidth) ? options.outHeight
						: options.outWidth;
				options.inSampleSize = maxlen / MAXSIZE;
				options.inJustDecodeBounds = false;
				image = BitmapFactory.decodeFile(Game.getInstance().getImagePath(), options);
				if (null != image) {
					Log.d("DEBUG", "big width = " + image.getWidth()
							+ " height = " + image.getHeight());
					savesucess = SDTools.saveBitmap(
							activity, Game.getInstance().getImagePath(), imageName , image);
					image.recycle();
					image = null;
				}
			} else {
				Log.e("xxxx", "image = null");
				Uri uri = data.getData();
				if (uri != null) {
					String path = getPath(uri);
					if(path == null){
						savesucess = false;
					}
					BitmapFactory.Options options = new BitmapFactory.Options();
					options.inJustDecodeBounds = true;
					BitmapFactory.decodeFile(path, options);
					int maxlen = (options.outHeight > options.outWidth) ? options.outHeight
							: options.outWidth;
					options.inSampleSize = maxlen / MAXSIZE;
					options.inJustDecodeBounds = false;
					image = BitmapFactory.decodeFile(path, options);
					if (null != image) {
						Log.d("DEBUG", "big width = " + image.getWidth()
								+ " height = " + image.getHeight());
						savesucess = SDTools.saveBitmap(
								activity, Game.getInstance().getImagePath(), imageName , image);
						image.recycle();
						image = null;
					}
				}
			}
		}
		else{
			Log.e("ERROR", "saveBitmapImage data = null !");
		}
		
		
		if (savesucess){
		
			System.out.println("图片保存成功" + imageName + SDTools.PNG_SUFFIX);
				
			TreeMap<String, Object> map = new TreeMap<String, Object>();
			map.put("name",imageName + SDTools.PNG_SUFFIX);
			JsonUtil modelJson = new JsonUtil(map);
			final String reslut = modelJson.toString();
			Game.getInstance().callLuaFunc(strDicName, reslut);

			
			}else{
			failedSaveImage();		
		} 
	}
	
	public static void setCropMaxSize(int max){
		MAXSIZE = max;
	}
	
	public static void setCropMinSize(int min){
		MINSIZE = min;
	}
	
	public static void setCropSize(int len){
		CROPSIZE = len;
	}
	
	public static Bitmap comPressBitmapImage(Bitmap bitmap) {
		int height = bitmap.getHeight();
		int width = bitmap.getWidth();
		int maxlen = (width > height) ? width : height;
		float scale = ((float) MAXSIZE) / maxlen;
		Matrix matrix = new Matrix();
		matrix.postScale(scale, scale);
		return Bitmap.createBitmap(bitmap, 0, 0, maxlen, maxlen, matrix, true);
	}
	
	/**
	 * Constructs an intent for image cropping. 调用图片剪辑程序 剪裁后的图片跳转到新的界面
	 */
	public static Intent getCropImageIntent(Uri imageUri,int cropSize) {
		Intent intent = new Intent("com.android.camera.action.CROP");
		intent.setDataAndType(imageUri, "image/*");
		intent.putExtra("crop", "true");
		intent.putExtra("aspectX", 1);
		intent.putExtra("aspectY", 1);
		intent.putExtra("outputX", cropSize);
		intent.putExtra("outputY", cropSize);
		intent.putExtra("return-data", true);
		//jaywillou-20160624-add
//		if (!SdkVersion.Below23())
//		{
//			intent.putExtra("output",imageUri);
//			intent.putExtra("outputFormat",Bitmap.CompressFormat.PNG.toString());
//		}
		
		return intent;
	}
	
	public static Intent getCropImageIntent(Bitmap image,int cropSize) {
		Intent intent = new Intent("com.android.camera.action.CROP");
		intent.setType("image/*");
		intent.putExtra("data", image);
		intent.putExtra("crop", "true");
		intent.putExtra("aspectX", 1);
		intent.putExtra("aspectY", 1);
		intent.putExtra("outputX", cropSize);
		intent.putExtra("outputY", cropSize);
		intent.putExtra("return-data", true);
		return intent;
	}
	
	private String getPath(Uri uri) {
		if(uri == null){
			Log.e(this+"", "null uri!");
			return null;
		}
		String[] projection = { MediaStore.Images.Media.DATA };
		Cursor cursor = activity.managedQuery(uri, projection, null, null, null);
		if(cursor == null){
			//当使用第三方资源管理选择照片的时候
			String uriString = uri.toString();
			Log.d("DEBUG", "uri = "+uriString);
			uriString = uriString.replace("file://", "");
			Log.d("DEBUG", "uri2 = "+uriString);
			
			return uriString;
		}
		int column_index = cursor
				.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
		cursor.moveToFirst();
		return cursor.getString(column_index);
		//return getPath(activity, uri);
	}
	
	private void failedSaveImage(){
		Game.getInstance().callLuaFunc(strDicName, null);
	}
	
	@SuppressLint("NewApi")
	public static String getPath(final Context context, final Uri uri) {  
		  
	    final boolean isKitKat = Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT;  
	  
	    // DocumentProvider  
	    if (isKitKat && DocumentsContract.isDocumentUri(context, uri)) {  
	        // ExternalStorageProvider  
	        if (isExternalStorageDocument(uri)) {  
	            final String docId = DocumentsContract.getDocumentId(uri);  
	            final String[] split = docId.split(":");  
	            final String type = split[0];  
	  
	            if ("primary".equalsIgnoreCase(type)) {  
	                return Environment.getExternalStorageDirectory() + "/" + split[1];  
	            }  
	  
	            // TODO handle non-primary volumes  
	        }  
	        // DownloadsProvider  
	        else if (isDownloadsDocument(uri)) {  
	  
	            final String id = DocumentsContract.getDocumentId(uri);  
	            final Uri contentUri = ContentUris.withAppendedId(  
	                    Uri.parse("content://downloads/public_downloads"), Long.valueOf(id));  
	  
	            return getDataColumn(context, contentUri, null, null);  
	        }  
	        // MediaProvider  
	        else if (isMediaDocument(uri)) {  
	            final String docId = DocumentsContract.getDocumentId(uri);  
	            final String[] split = docId.split(":");  
	            final String type = split[0];  
	  
	            Uri contentUri = null;  
	            if ("image".equals(type)) {  
	                contentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;  
	            } else if ("video".equals(type)) {  
	                contentUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;  
	            } else if ("audio".equals(type)) {  
	                contentUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;  
	            }  
	  
	            final String selection = "_id=?";  
	            final String[] selectionArgs = new String[] {  
	                    split[1]  
	            };  
	  
	            return getDataColumn(context, contentUri, selection, selectionArgs);  
	        }  
	    }  
	    // MediaStore (and general)  
	    else if ("content".equalsIgnoreCase(uri.getScheme())) {  
	  
	        // Return the remote address  
	        if (isGooglePhotosUri(uri))  
	            return uri.getLastPathSegment();  
	  
	        return getDataColumn(context, uri, null, null);  
	    }  
	    // File  
	    else if ("file".equalsIgnoreCase(uri.getScheme())) {  
	        return uri.getPath();  
	    }  
	  
	    return null;  
	}  
	  
	/** 
	 * Get the value of the data column for this Uri. This is useful for 
	 * MediaStore Uris, and other file-based ContentProviders. 
	 * 
	 * @param context The context. 
	 * @param uri The Uri to query. 
	 * @param selection (Optional) Filter used in the query. 
	 * @param selectionArgs (Optional) Selection arguments used in the query. 
	 * @return The value of the _data column, which is typically a file path. 
	 */  
	public static String getDataColumn(Context context, Uri uri, String selection,  
	        String[] selectionArgs) {  
	  
	    Cursor cursor = null;  
	    final String column = "_data";  
	    final String[] projection = {  
	            column  
	    };  
	  
	    try {  
	        cursor = context.getContentResolver().query(uri, projection, selection, selectionArgs,  
	                null);  
	        if (cursor != null && cursor.moveToFirst()) {  
	            final int index = cursor.getColumnIndexOrThrow(column);  
	            return cursor.getString(index);  
	        }  
	    } finally {  
	        if (cursor != null)  
	            cursor.close();  
	    }  
	    return null;  
	}  
	  
	  
	/** 
	 * @param uri The Uri to check. 
	 * @return Whether the Uri authority is ExternalStorageProvider. 
	 */  
	public static boolean isExternalStorageDocument(Uri uri) {  
	    return "com.android.externalstorage.documents".equals(uri.getAuthority());  
	}  
	  
	/** 
	 * @param uri The Uri to check. 
	 * @return Whether the Uri authority is DownloadsProvider. 
	 */  
	public static boolean isDownloadsDocument(Uri uri) {  
	    return "com.android.providers.downloads.documents".equals(uri.getAuthority());  
	}  
	  
	/** 
	 * @param uri The Uri to check. 
	 * @return Whether the Uri authority is MediaProvider. 
	 */  
	public static boolean isMediaDocument(Uri uri) {  
	    return "com.android.providers.media.documents".equals(uri.getAuthority());  
	}  
	  
	/** 
	 * @param uri The Uri to check. 
	 * @return Whether the Uri authority is Google Photos. 
	 */  
	public static boolean isGooglePhotosUri(Uri uri) {  
	    return "com.google.android.apps.photos.content".equals(uri.getAuthority());  
	}  
}
