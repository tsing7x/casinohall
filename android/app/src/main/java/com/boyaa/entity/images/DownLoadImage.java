//package com.boyaa.entity.images;
//
//import java.io.File;
//import java.util.List;
//import java.util.TreeMap;
//
//import android.graphics.Bitmap;
//import android.util.Log;
//
//import com.boyaa.entity.common.OnThreadTask;
//import com.boyaa.entity.common.SDTools;
//import com.boyaa.entity.common.ThreadTask;
//import com.boyaa.entity.common.utils.JsonUtil;
//import com.boyaa.entity.core.HandMachine;
//import com.boyaa.entity.php.PHPPost;
//import com.boyaa.made.AppActivity;
//
//public class DownLoadImage {
//
//	private String strDicName;
//
//	public DownLoadImage() {
//
//	}
//
//	public DownLoadImage(String strDicName) {
//		this.strDicName = strDicName;
//	}
//
//	private String imageUrl = "";
//	private String imageName = "";
//	private int imageType = 0; // 0默认每次拉取
//	private boolean savesucess = false;
//
//	public void doDownloadImage(String url, String name, int type) {
//		imageUrl = url;
//		imageName = name;
//		imageType = type;
//		System.out.println("图片地址"+ url +"图片名称" + imageName );
//		if (imageType != 0) {
//			String path = AppActivity.mActivity.getImagePath() + imageName; // 检查本地是否有图片
//			File file = new File(path);
//			if (file.exists() && file.canWrite() && file.isFile()) {
//				System.out.println("图片名称" + imageName + "已经存在了");
//				onFinishedDownloadImage(true);
//			} else {
//				onDownloadImage();
//			}
//		} else {
//			onDownloadImage();
//		}
//	}
//
//	public void onDownloadImage() {
//		if (imageUrl.length() > 5) {
//			/* 从URI地址拉图片过来 */
//			ThreadTask.start(AppActivity.mActivity, "", false,
//					new OnThreadTask() {
//						boolean savesucess = false;
//
//						@Override
//						public void onThreadRun() {
//							Bitmap bitmap = PHPPost.loadPic(imageUrl);
//							if (null != bitmap) {
//								Log.d("DEBUG",
//										"big width = " + bitmap.getWidth()
//												+ " height = "
//												+ bitmap.getHeight());
//								savesucess = SDTools.saveBitmap(
//										AppActivity.mActivity,
//										AppActivity.mActivity.getImagePath(),
//										imageName, bitmap);
//								bitmap.recycle();
//								bitmap = null;
//							}
//						}
//
//						@Override
//						public void onAfterUIRun() {
//							onFinishedDownloadImage(savesucess);
//						}
//
//						@Override
//						public void onUIBackPressed() {
//
//						}
//					});
//
//		} else {
//			savesucess = false;
//			onFinishedDownloadImage(savesucess);
//		}
//	}
//
//	public void onFinishedDownloadImage(final boolean savesucess) {
//		onFinishDownloadImageToLua(savesucess, imageName);
//	}
//	
//	public void onFinishDownloadImageToLua(final boolean savesucess, final String imgName) {
//		AppActivity.mActivity.runOnLuaThread(new Runnable() {
//			@Override
//			public void run() {
//				if (savesucess) {
//					TreeMap<String, Object> map = new TreeMap<String, Object>();
//					map.put("downloadImageName", imgName);
//					JsonUtil json = new JsonUtil(map);
//					String ret = json.toString();
//					HandMachine.getHandMachine().luaCallEvent(strDicName, ret);
//				} else {
//					HandMachine.getHandMachine().luaCallEvent(strDicName, null);
//				}
//			}
//		});
//	}
//
//	/**
//	 * 多个图片开一个线程下载
//	 * 
//	 * @param imageList
//	 * @param type
//	 */
//	public void doDownloadImages(final List<PicInfoBean> imageList,
//			final int imageType) {
//		final int size = imageList.size();
//		if (size > 0) {
//			/* 从URI地址拉图片过来 */
//			ThreadTask.start(AppActivity.mActivity, "", false,
//					new OnThreadTask() {
//						@Override
//						public void onThreadRun() {
//							for (int i = 0; i < size; i++) {
//								PicInfoBean bean = imageList.get(i);
//								String imageUrl = bean.getUrl();
//								String imageName = bean.getImageName();
//								
//								if (imageType != 0) {
//									String path = AppActivity.mActivity.getImagePath()
//											+ imageName; // 检查本地是否有图片
//									File file = new File(path);
//									if (file.exists() && file.canWrite()
//											&& file.isFile()) {
//										System.out.println("图片名称" + imageName
//												+ "已经存在了");
//										onFinishDownloadImageToLua(true, imageName);
//									} else {
//										downLoadSinglePic(imageUrl, imageName);
//									}
//								} else {
//									downLoadSinglePic(imageUrl, imageName);
//								}
//							}
//						}
//
//						@Override
//						public void onAfterUIRun() {
//						}
//
//						@Override
//						public void onUIBackPressed() {
//						}
//					});
//		}
//
//	}
//
//	protected void downLoadSinglePic(String url, String imgName) {
//		Bitmap bitmap = PHPPost.loadPic(url);
//		if (null != bitmap) {
//			Log.d("DEBUG",
//					"big width = " + bitmap.getWidth()
//							+ " height = "
//							+ bitmap.getHeight());
//			boolean savesucess = SDTools.saveBitmap(
//					AppActivity.mActivity,
//					AppActivity.mActivity.getImagePath(),
//					imgName, bitmap);
//			bitmap.recycle();
//			bitmap = null;
//			onFinishDownloadImageToLua(savesucess, imgName);
//		}
//	}
//
//}
