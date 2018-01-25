package com.boyaa.engine.made;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.text.Layout;
import android.text.StaticLayout;
import android.text.TextPaint;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.HashMap;

/**
 * Created by VincentGong on 15/8/3.
 */
public class AppBitmap {
    private final static int ALIGN_TOP = 0x13;
    private final static int ALIGN_TOPLEFT = 0x11;
    private final static int ALIGN_TOPRIGHT = 0x12;

    private final static int ALIGN_BOTTOM = 0x23;
    private final static int ALIGN_BOTTOMLEFT = 0x21;
    private final static int ALIGN_BOTTOMRIGHT = 0x22;

    private final static int ALIGN_CENTER = 0x33;
    private final static int ALIGN_LEFT = 0x31;
    private final static int ALIGN_RIGHT = 0x32;

    private Context mContext;
    private Paint mPaint = new Paint();
    private HashMap<String,Typeface> mFontNameTypefaceMap = new HashMap<String,Typeface>();

    private static AppBitmap mInstance;

    public static void createBitmap(byte[] content,
                                    byte[] fontName, int fontSize,
                                    int alignment,
                                    int width, int height,
                                    int iMultiLine) {
        ReturnInfo info = AppBitmap.getInstance().createTextBitmap(content,fontName,fontSize,alignment,width,height,iMultiLine);
        initReturnBitmap(info.Pixels,info.width,info.height);
    }

    private static AppBitmap getInstance() {
        if (mInstance == null) {
            mInstance = new AppBitmap(AppActivity.getInstance().getApplication());
        }

        return mInstance;
    }

    AppBitmap(Context context) {
        mContext = context;
    }

    public ReturnInfo createTextBitmap(byte[] contentByteArray,
                                       byte[] fontNameByteArray, int fontSize,
                                        int alignment,
                                        int width, int height,
                                        int iMultiLine) {

        String content = convertByteArrayToString(contentByteArray);
        String fontName = convertByteArrayToString(fontNameByteArray);

        width = width < 0 ? 0 : width;
        height = height < 0 ? 0 : height;
        fontSize = fontSize <= 0 ? 1 : fontSize;

        Paint paint = initPaint(fontName, fontSize);
        Bitmap bitmap;
        if (iMultiLine == 0) {
            bitmap = drawSingleLineText(paint,content,alignment,width,height);
        } else {
            bitmap = drawMultiLineText(paint,content,alignment,width,height);
        }

        ReturnInfo ret = new ReturnInfo();
        ret.Pixels = getPixels(bitmap);
        ret.width = bitmap.getWidth();
        ret.height = bitmap.getHeight();

        return ret;
    }

    private Paint initPaint(String fontName, int fontSize) {
        mPaint.reset();
        mPaint.setColor(Color.WHITE);
        mPaint.setTextAlign(Paint.Align.LEFT);
        mPaint.setAntiAlias(true);
        mPaint.setTypeface(getTypeFace(fontName));
        mPaint.setTextSize(fontSize);

        return mPaint;
    }

    private Bitmap drawSingleLineText(Paint paint, String content, int alignment, int width, int height) {
        content = content.replaceAll("(\r\n|\n\r|\r|\n)","");
        int maxWidth = (int) Math.ceil(paint.measureText(content,0,content.length()));
        Paint.FontMetricsInt fm = paint.getFontMetricsInt();
        int maxHeight = (int) Math.ceil(fm.bottom - fm.top);

        width = width < maxWidth ? maxWidth : width;
        height = height < maxHeight ? maxHeight : height;
        width = width > 1024 ? 1024 : width;

        Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);

        Rect rect = new Rect();
        paint.getTextBounds(content,0,content.length(),rect);
        int textWidth = (int)paint.measureText(content);

        float x = getDiffX(alignment,width,textWidth);
        float y = getDiffY(alignment, height, rect.height());

        canvas.save();
        canvas.translate(0, -rect.top);
        canvas.drawText(content,x,y,paint);
//        canvas.drawText(content, (bitmap.getWidth() - rect.width())/2,
//                (bitmap.getHeight() - rect.height())/2, paint);
        canvas.restore();
        return bitmap;
    }

    private Bitmap drawMultiLineText(Paint paint, String content, int alignment, int width, int height) {
        Layout.Alignment align = castAlignment(alignment);

        width = width < 8 ? 8 : width;
        TextPaint textPaint = new TextPaint();
        textPaint.set(paint);
        StaticLayout layout = new StaticLayout(content,textPaint,width,align,1.0f,0.0f,false);

        int y = 0;
        if (layout.getHeight() < height) {
            y = getDiffY(alignment,height,layout.getHeight());
            //height = height;
        } else {
            y = 0;
            height = layout.getHeight();
        }

        Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);
        canvas.translate(0, y);
        layout.draw(canvas);

        return bitmap;
    }

    private Typeface getTypeFace(String fontName) {
        if (fontName == null || fontName.length() <= 0 || !fontName.endsWith(".ttf")) {
            return null;
        }

        if (!mFontNameTypefaceMap.containsKey(fontName)) {
            try {
                Typeface typeface = Typeface.createFromAsset(mContext.getAssets(), "fonts/" + fontName);
                mFontNameTypefaceMap.put(fontName,typeface);
            } catch (Exception e) {
                return null;
            }
        }

        return mFontNameTypefaceMap.get(fontName);
    }

    private byte[] getPixels(Bitmap bitmap) {
        if (bitmap == null) {
            return null;
        }

        byte[] pixels = new byte[bitmap.getWidth() * bitmap.getHeight() * 4];
        ByteBuffer buffer = ByteBuffer.wrap(pixels);
        buffer.order(ByteOrder.nativeOrder());
        bitmap.copyPixelsToBuffer(buffer);
        return pixels;
    }

    private int getDiffX(int alignment, int bitmapWidth, int textWidth) {
        switch (alignment) {
            case ALIGN_TOP:
            case ALIGN_BOTTOM:
            case ALIGN_CENTER:
                return (bitmapWidth - textWidth) / 2;
            case ALIGN_LEFT:
            case ALIGN_TOPLEFT:
            case ALIGN_BOTTOMLEFT:
                return 0;
            case ALIGN_RIGHT:
            case ALIGN_TOPRIGHT:
            case ALIGN_BOTTOMRIGHT:
                return bitmapWidth - textWidth;
            default:
                return 0;
        }
    }

    private int getDiffY(int alignment, int bitmapHeight, int textHeight) {
        switch (alignment) {
            case ALIGN_TOP:
            case ALIGN_TOPLEFT:
            case ALIGN_TOPRIGHT:
                return 0;
            case ALIGN_BOTTOM:
            case ALIGN_BOTTOMLEFT:
            case ALIGN_BOTTOMRIGHT:
                return bitmapHeight - textHeight;
            case ALIGN_CENTER:
            case ALIGN_LEFT:
            case ALIGN_RIGHT:
                return (bitmapHeight - textHeight) / 2;
            default:
                return 0;
        }
    }

    private Layout.Alignment castAlignment(int alignment) {
        switch (alignment) {
            case ALIGN_LEFT:
            case ALIGN_TOPLEFT:
            case ALIGN_BOTTOMLEFT:
                return Layout.Alignment.ALIGN_NORMAL;
            case ALIGN_RIGHT:
            case ALIGN_TOPRIGHT:
            case ALIGN_BOTTOMRIGHT:
                return Layout.Alignment.ALIGN_OPPOSITE;
            case ALIGN_CENTER:
            case ALIGN_TOP:
            case ALIGN_BOTTOM:
                return Layout.Alignment.ALIGN_CENTER;
            default:
                return Layout.Alignment.ALIGN_NORMAL;
        }
    }

    private String convertByteArrayToString(byte[] byteArray) {
        if (byteArray == null || byteArray.length == 0) {
            return "";
        }

        return new String(byteArray);
    }

    class ReturnInfo {
        public byte[] Pixels;
        int width;
        int height;
    };

    public static native void initReturnBitmap(byte[] pixels, int width, int height);
}
