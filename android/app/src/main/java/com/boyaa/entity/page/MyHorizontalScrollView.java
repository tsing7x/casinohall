package com.boyaa.entity.page;

import android.content.Context;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.animation.TranslateAnimation;
import android.widget.HorizontalScrollView;

public class MyHorizontalScrollView extends HorizontalScrollView {  
    private View inner;  
    private float x;  
    private Rect normal = new Rect();  
    private boolean isCount = false;// 是否开始计算
    
    @Override  
    protected void onFinishInflate() {
        super.onFinishInflate();
        if (getChildCount() > 0) {  
            inner = getChildAt(0);  
        }  
        System.out.println("getChildCount():" + getChildCount());  
    }  
      
    public MyHorizontalScrollView(Context context, AttributeSet attrs) {  
        super(context, attrs);  
    }  
      
    @Override  
    public boolean onTouchEvent(MotionEvent ev) {  
        if (inner == null) {  
            return super.onTouchEvent(ev);  
        } else {  
            commOnTouchEvent(ev);  
        }  
  
        return super.onTouchEvent(ev);  
    }  
  
    public void commOnTouchEvent(MotionEvent ev) {  
        int action = ev.getAction();  
        switch (action) {  
        case MotionEvent.ACTION_DOWN:  
            x = ev.getX();  
            break;  
        case MotionEvent.ACTION_UP:  
  
            if (isNeedAnimation()) { 
            	isCount = false;
                animation();  
            }  
  
            break;  
        case MotionEvent.ACTION_MOVE:  
            final float preX = x;  
            float nowX = ev.getX();  
            int deltaX = (int) (preX - nowX);  
            if (!isCount) {
            	deltaX = 0; // 在这里要归0.
            }

            x = nowX;  
            // 当滚动到最左或者最右时就不会再滚动，这时移动布局  
            if (isNeedMove()) {  
                if (normal.isEmpty()) {  
                    // 保存正常的布局位置  
                    normal.set(inner.getLeft(), inner.getTop(), inner.getRight(), inner.getBottom());  
                }  
                // 移动布局  
                inner.layout(inner.getLeft() - deltaX/2, inner.getTop() , inner.getRight()- deltaX/2, inner.getBottom() );  
            }  
            isCount = true;
            break;  
  
        default:  
            break;  
        }  
    }  
  
    // 开启动画移动  
    public void animation() {  
        // 开启移动动画  
        TranslateAnimation ta = new TranslateAnimation(0, 0, inner.getTop(), normal.top);  
        ta.setDuration(150);  
        inner.startAnimation(ta);  
        // 设置回到正常的布局位置  
        inner.layout(normal.left, normal.top, normal.right, normal.bottom);  
        normal.setEmpty();  
    }  
    // 是否需要开启动画  
    public boolean isNeedAnimation() {  
        return !normal.isEmpty();  
    }  
    // 是否需要移动布局  
    public boolean isNeedMove() {  
        int offset = inner.getMeasuredWidth() - getWidth();  
        int scrollX = getScrollX();  
        if (scrollX == 0 || scrollX == offset) {  
            return true;  
        }  
        return false;  
    }  
}
