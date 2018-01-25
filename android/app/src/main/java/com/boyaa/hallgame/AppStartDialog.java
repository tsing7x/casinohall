//package com.boyaa.hallgame;
//
//
//
//
//import android.app.Activity;
//import android.app.AlertDialog;
//import android.os.Bundle;
//import android.view.KeyEvent;
//import android.view.LayoutInflater;
//import android.view.View;
//
//import com.boyaa.hallgame.R;
//
//
//
//
//
///**
// * APP启动画面类
// */
//public class AppStartDialog extends AlertDialog {
//
//	/**
//	 * 应用启动画面构造函数
//	 * @param context
//	 * @return void
//	 */
//	public AppStartDialog(Activity context) {
//		super(context, R.style.appStartDialog_style);
//	}
//
//	/**
//	 * 当Dialog程序启动之后会首先调用此方法。<br/>
//	 * 在这个方法体里，你需要完成所有的基础配置<br/>
//	 * 这个方法会传递一个保存了此Dialog上一状态信息的Bundle对象
//	 * @param savedInstanceState 保存此Dialog上一次状态信息的Bundle对象
//	 */
//	@Override
//	protected void onCreate(Bundle savedInstanceState) {
//		super.onCreate(savedInstanceState);
//		LayoutInflater inflater = LayoutInflater.from(getContext());
//		View view = inflater.inflate(R.layout.start_screen, null);
//		setContentView(view);
//	}
//
//	/**
//	 * 监听物理按键
//	 * @return 相应返回键 返回true ; 否则返回 false
//	 */
//	@Override
//	public boolean onKeyDown(int keyCode, KeyEvent event)  {
//	    if (keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0) {
//	        return true;
//	    }
//	    return super.onKeyDown(keyCode, event);
//	}
//	public void stopForce()
//	{
////		if (startVideo != null && startVideo.isPlaying())
////		{
////			startVideo.stopPlayback();
////		}
//		dismiss();
//	}
//
//	public boolean requestDismiss(){
////		requestClose = true;
////		if (startVideo != null && startVideo.isPlaying())
////		{
////			return false;
////		}
////		else
////		{
//			dismiss();
//			return true;
////		}
//	}
//}
