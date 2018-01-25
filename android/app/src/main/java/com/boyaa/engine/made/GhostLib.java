/*
 * Copyright (C) 2007 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.boyaa.engine.made;

// Wrapper for native library

public class GhostLib {

     static {
         System.loadLibrary("lua");
    	 System.loadLibrary("tolua");
         System.loadLibrary("babe");
     }

    /**
     * @param width the current view width
     * @param height the current view height
     */
    public static native void create(int width, int height);
    public static native void setOrientation(int orientation);
    public static native boolean update();

    public static native void onPause();
    public static native void onResume();

    public static native void onTouchDown(float x, float y, long event_time);
    public static native void onTouchMove(float x, float y, long event_time);
    public static native void onTouchUp(float x, float y, long event_time);
    public static native void onTouchCancel(float x, float y, long event_time);

    public static native void onKeyDown(int key);

    public static native int      sysSetInt(String key, int value);
    public static native int      sysSetDouble(String key, double value);
    public static native int      sysSetString(String key, String value);
    public static native int      sysGetInt(String key, int defaultValue);
    public static native double   sysGetDouble(String key, double defaultValue);
    public static native String   sysGetString(String key);

    public static native int      dictSetInt(String dictName, String key, int value);
    public static native int      dictSetDouble(String dictName, String key, double value);
    public static native int      dictSetString(String dictName, String key, byte[] value);
    public static native int      dictGetInt(String dictName, String key, int defaultValue);
    public static native int      dictGetDouble(String dictName, String key, double defaultValue);
    public static native byte[]   dictGetString(String dictName, String key);

    public static native int      dictSave(String dictName);
    public static native int      dictDelete(String dictName);


    public static native int      callLua(String name);
    public static native int      callLuaWithArgs(String name, String args);
    public static native int      onImeClosed(byte[] text, int flag);
    public static native void     onLowMemory();
}
