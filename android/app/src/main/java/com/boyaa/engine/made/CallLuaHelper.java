package com.boyaa.engine.made;

public class CallLuaHelper {
	private static AppGLSurfaceView ms_GLView = null;

    public static void init(AppGLSurfaceView gl_view) {
        ms_GLView = gl_view;
    }

    public static void callLua(final String func_name) {
        if (ms_GLView != null) {
            ms_GLView.runOnGLThread(new Runnable() {
                @Override
                public void run() {
                    GhostLib.callLua(func_name);
                }
            });
        }
    }

    public static void callLuaWithArgs(final String func_name, final String args) {
        if (ms_GLView != null) {
            ms_GLView.runOnGLThread(new Runnable() {
                @Override
                public void run() {
                    GhostLib.callLuaWithArgs(func_name, args);
                }
            });
        }
    }
}
