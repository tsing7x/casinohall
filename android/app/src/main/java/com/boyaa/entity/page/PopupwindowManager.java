package com.boyaa.entity.page;

import java.util.HashMap;

import android.app.Activity;

public class PopupwindowManager {
	private static PopupwindowManager instance;
	private HashMap<Integer, PopupWindowBase> popups = new HashMap<Integer, PopupWindowBase>();

	private PopupwindowManager() {
	}

	public static PopupwindowManager getPopupwindowManager() {
		if (instance == null) {
			instance = new PopupwindowManager();
		}
		return instance;
	}

	public void showPopupWindow(Activity context, int popupId, String url, HashMap<String, String> paramMap) {
		PopupWindowBase popup = popups.get(popupId);
		if (popup != null) {
			popup.initInfo(url, paramMap);
			popup.show();
			return;
		}
		switch (popupId) {
		default:
			break;
		}
		if (popup != null)
			popup.show();
	}

	public void closePopupWindow(int popid) {
		PopupWindowBase pop = popups.get(popid);
		if (pop != null) {
			pop.close();
		}
	}

	public HashMap<Integer, PopupWindowBase> getPopups() {
		return popups;
	}

}
