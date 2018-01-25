package com.boyaa.engine.made;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.text.InputFilter;
import android.text.InputType;
import android.text.method.NumberKeyListener;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.TextView.OnEditorActionListener;

/**
 * AppEditBoxView的实现类,提供了一种具体的实现方式,构造一个Java层的原生UI输入控件EditText,覆盖在引擎绘制的输入框上方,
 * EditText作为用户和游戏真正的输入框之间的过度者,EditText打开系统的软键盘,监听和处理用户的输入,最终返回给游戏的输入框.
 * 
 * 开发者可以根据借鉴该类的实现,通过覆写对应的方法,定制传递参数等,开发者可定制输入框的输入类型和软键盘的打开方式等,以实现实际的需求.
 * 
 */
public class AppEditBoxView {

	/**
	 * Fields,including parameters for Customizing input EditText and soft
	 * keyboard
	 */
	private AppActivity mActivity;
	private String mTitle;
	private String mContent;
	private int mInputMode;
	private int mInputFlag;
	private int mReturnType;
	private int mMaxLength;
	private int mRectX;
	private int mRectY;
	private int mRectW;
	private int mRectH;
	private String mFontName;
	private int mFontSize;
	private int mFontColor;

	//
	private EditText mInputEditText;
	private int keyboardHeight = 0;
	private int mInputFlagConstraints;
	private int mInputModeContraints;
	private RelativeLayout outerLayout;

	// 监听动作的地方比较多，防止多次调用
	private boolean isCallAction = false;
	private int oldImeOptions;

	public static void openIMEEdit(byte[] text,  int maxLen,
								   byte[] fontname,  int fontSize,
								   int r, final int g,  int b,
								   int x, final int y,  int w,  int h) {
		open(text,maxLen,fontname,fontSize,r,g,b,x,y,w,h);
	}

	public static void open(final byte[] text, final int maxLen,
								   final byte[] fontname, final int fontSize,
								   final int r, final int g, final int b,
								   final int x, final int y, final int w, final int h) {
		AppActivity.getInstance().runOnUiThread(new Runnable() {
			@Override
			public void run() {
				String content = "";
				String font = "";
				if (null != text && text.length > 0) {
					content = new String(text);
				}
				if (null != fontname && fontname.length > 0) {
					font = new String(fontname);
				}
				AppEditBoxView appEditBoxView = new AppEditBoxView(AppActivity.getInstance(), content,
						maxLen, font, fontSize, r, g, b, x, y, w, h);
				appEditBoxView.show();
			}
		});
	}

	public static native void onImeClosed(byte[] text, int flag);

	/**
	 * 构造方法
	 *
	 * @param text
	 *            打开软键盘之前,输入框已有的字符
	 * @param maxLen
	 *            最大的可输入长度
	 * @param fontname
	 *            字体名
	 * @param fontSize
	 *            字体大小
	 * @param r
	 *            三基色中的red色值
	 * @param g
	 *            三基色中的green色值
	 * @param b
	 *            三基色中的blue色值
	 * @param x
	 *            输入框的x坐标
	 * @param y
	 *            输入框的y坐标
	 * @param w
	 *            输入框的宽
	 * @param h
	 *            输入框的高
	 * @param inputMode
	 * @param inputFlag
	 * @param returnType
	 */
	private AppEditBoxView(AppActivity activity, String text, int maxLen, String fontname,
						  int fontSize, int r, int g, int b, int x, int y, int w, int h) {
		
		
		mActivity = activity;
		mTitle = "";
		mContent = text;
		mMaxLength = maxLen;
		mRectX = x;
		mRectY = y;
		mRectW = w;
		mRectH = h;
		mFontName = fontname;
		mFontSize = fontSize;
		mFontColor = Color.rgb(r, g, b);
	}

	private void show() {
		// 初始化输入框UI
		initUI();

		// 打开系统软键盘
		openKeyboard();
	}

	
	private Typeface getTypeFace(String fontName) {
        if (fontName == null || fontName.length() <= 0 || !fontName.endsWith(".ttf")) {
            return null;
        }
        Typeface typeFace = Typeface.create(fontName, Typeface.NORMAL);
        return typeFace;
    }
	
	private void initUI() {
		RelativeLayout.LayoutParams lp = new RelativeLayout.LayoutParams(
				RelativeLayout.LayoutParams.MATCH_PARENT,
				RelativeLayout.LayoutParams.MATCH_PARENT);
		// 显示输入层
		outerLayout = new RelativeLayout(mActivity);
		mInputEditText = new EditText(mActivity);
		outerLayout.addView(mInputEditText);
		mActivity.addContentView(outerLayout, lp);

		// 初始化输入框
		mInputEditText.setBackgroundColor(0x00000000);
		mInputEditText.setCursorVisible(true);

		
		// 设置字体、大小、颜色
		
		mInputEditText.setTypeface(getTypeFace(mFontName));
		mInputEditText.setTextSize(TypedValue.COMPLEX_UNIT_PX, mFontSize);
		mInputEditText.setTextColor(mFontColor);
		mInputEditText.setGravity(Gravity.CENTER_VERTICAL);
		mInputEditText.setImeOptions(EditorInfo.IME_ACTION_NONE | EditorInfo.IME_FLAG_NO_EXTRACT_UI);
		mInputEditText.setPadding(0, 0, 0, 0);
		mInputEditText.setGravity(Gravity.LEFT);
		oldImeOptions = mInputEditText.getImeOptions();

		// 设置输入框的位置大小
		ViewGroup.MarginLayoutParams mp = (ViewGroup.MarginLayoutParams)mInputEditText.getLayoutParams();
		mp.leftMargin = mRectX;
		mp.topMargin = mRectY;
		mp.width = mRectW;
		mp.height = mRectH;

		// 点击输入键盘外部关闭输入框
		outerLayout.setClickable(true);
		outerLayout.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View arg0) {
				inputCancel();
			}
		});

		// 监听输入法键盘高度变化
		mInputEditText.getViewTreeObserver().addOnGlobalLayoutListener(
				new ViewTreeObserver.OnGlobalLayoutListener() {

					@Override
					public void onGlobalLayout() {
						Rect r = new Rect();
						mInputEditText
								.getWindowVisibleDisplayFrame(r);
						int screenHeight = mInputEditText
								.getRootView().getHeight();
						int height = screenHeight - (r.bottom - r.top);

						// 输入法高变化
						if (height > keyboardHeight) {
							keyboardHeight = height;
						}
						// 输入法关闭
						if (keyboardHeight > 0 && height < keyboardHeight) {
							keyboardHeight = 0;
							inputCancel();
						}
					}
				});
		
		//inputeModel,inputFlag,returnType
		mInputMode = Dict.getInt(IIMEConstant.EX_DICT_TABLE_NAME,IIMEConstant.EX_DICT_KEY_INPUTMODE,0);
		mInputFlag = Dict.getInt(IIMEConstant.EX_DICT_TABLE_NAME,IIMEConstant.EX_DICT_KEY_INPUTFLAG ,0);
		mReturnType = Dict.getInt(IIMEConstant.EX_DICT_TABLE_NAME,IIMEConstant.EX_DICT_KEY_RETURNTYPE, 0);
		// 设置输入法模式类型
		switch (mInputMode) {
		case IIMEConstant.kEditBoxInputModeAny:
			mInputModeContraints = InputType.TYPE_CLASS_TEXT
					| InputType.TYPE_TEXT_FLAG_MULTI_LINE;
			break;
		case IIMEConstant.kEditBoxInputModeEmailAddr:
			mInputModeContraints = InputType.TYPE_CLASS_TEXT
					| InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS;
			break;
		case IIMEConstant.kEditBoxInputModeNumeric:
			mInputModeContraints = InputType.TYPE_CLASS_NUMBER
					| InputType.TYPE_NUMBER_FLAG_SIGNED;
			break;
		case IIMEConstant.kEditBoxInputModePhoneNumber:
			mInputModeContraints = InputType.TYPE_CLASS_PHONE;
			break;
		case IIMEConstant.kEditBoxInputModeUrl:
			mInputModeContraints = InputType.TYPE_CLASS_TEXT
					| InputType.TYPE_TEXT_VARIATION_URI;
			break;
		case IIMEConstant.kEditBoxInputModeDecimal:
			mInputModeContraints = InputType.TYPE_CLASS_NUMBER
					| InputType.TYPE_NUMBER_FLAG_DECIMAL
					| InputType.TYPE_NUMBER_FLAG_SIGNED;
			break;
		case IIMEConstant.kEditBoxInputModeSingleLine:
			mInputModeContraints = InputType.TYPE_CLASS_TEXT;
			break;
		case IIMEConstant.kEditBoxInputModeMultLine:
			mInputModeContraints = InputType.TYPE_CLASS_TEXT
					| InputType.TYPE_TEXT_FLAG_MULTI_LINE;
			mInputEditText.setGravity(Gravity.LEFT);
			break;
		default:
			break;
		}
		//
		switch (mInputFlag) {
		case IIMEConstant.kEditBoxInputFlagPassword:
			mInputFlagConstraints = InputType.TYPE_CLASS_TEXT
					| InputType.TYPE_TEXT_VARIATION_PASSWORD;
			break;
		case IIMEConstant.kEditBoxInputFlagSensitive:
			mInputFlagConstraints = InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS;
			break;
		case IIMEConstant.kEditBoxInputFlagInitialCapsWord:
			mInputFlagConstraints = InputType.TYPE_TEXT_FLAG_CAP_WORDS;
			break;
		case IIMEConstant.kEditBoxInputFlagInitialCapsSentence:
			mInputFlagConstraints = InputType.TYPE_TEXT_FLAG_CAP_SENTENCES;
			break;
		case IIMEConstant.kEditBoxInputFlagInitialCapsAllCharacters:
			mInputFlagConstraints = InputType.TYPE_TEXT_FLAG_CAP_CHARACTERS;
			break;
		case IIMEConstant.kEditBoxInputFlagVisiblePassword:
			mInputFlagConstraints = InputType.TYPE_CLASS_TEXT
					| InputType.TYPE_TEXT_VARIATION_PASSWORD;
			break;
		default:
			break;
		}
		//
		mInputEditText.setInputType(mInputModeContraints
				| mInputFlagConstraints);
		// 设置键盘返回类型
		switch (mReturnType) {
		case IIMEConstant.kKeyboardReturnTypeDefault:
			mInputEditText.setImeOptions(oldImeOptions
					| EditorInfo.IME_ACTION_NONE);
			break;
		case IIMEConstant.kKeyboardReturnTypeDone:
			mInputEditText.setImeOptions(oldImeOptions
					| EditorInfo.IME_ACTION_DONE);
			break;
		case IIMEConstant.kKeyboardReturnTypeSend:
			mInputEditText.setImeOptions(oldImeOptions
					| EditorInfo.IME_ACTION_SEND);
			break;
		case IIMEConstant.kKeyboardReturnTypeSearch:
			mInputEditText.setImeOptions(oldImeOptions
					| EditorInfo.IME_ACTION_SEARCH);
			break;
		case IIMEConstant.kKeyboardReturnTypeGo:
			mInputEditText.setImeOptions(oldImeOptions
					| EditorInfo.IME_ACTION_GO);
			break;
		default:
			mInputEditText.setImeOptions(oldImeOptions
					| EditorInfo.IME_ACTION_NONE);
			break;
		}
		
		//
		setExtraKeyListener();

		// 设置输入框运行的字符集,这里默认为输入所有字符,实现者可以扩展定义
//		mInputModeContraints = InputType.TYPE_CLASS_TEXT
//				| InputType.TYPE_TEXT_FLAG_MULTI_LINE;

		// 设置输入的内容标志(比如是密码,是否首字大写等等),实现者请自定义
//		mInputFlagConstraints = InputType.TYPE_CLASS_TEXT;

		// 输入类型结合了输入框允许字符和字符内容标志
//		mInputEditText.setInputType(mInputModeContraints | mInputFlagConstraints);

		// 设置键盘返回类型,默认不做额外处理,实现者可以扩展
//		mInputEditText.setImeOptions(oldImeOptions | EditorInfo.IME_ACTION_NONE);

		// 设置动作完成监听
		mInputEditText.setOnEditorActionListener(new OnEditorActionListener() {
			@Override
			public boolean onEditorAction(final TextView v,
										  final int actionId, final KeyEvent event) {
						/*
						 * If user didn't set keyboard type, this callback will
						 * be invoked twice with 'KeyEvent.ACTION_DOWN' and
						 * 'KeyEvent.ACTION_UP'.
						 */
				if (actionId != EditorInfo.IME_NULL
						|| (actionId == EditorInfo.IME_NULL
						&& event != null && event.getAction() == KeyEvent.ACTION_DOWN)) {
					inputDone();
					return true;
				}
				return false;
			}
		});

		// 设置回退键监听
		mInputEditText.setOnKeyListener(new View.OnKeyListener() {

			@Override
			public boolean onKey(View v, int keyCode, KeyEvent event) {
				if (keyCode == KeyEvent.KEYCODE_BACK) {
					inputCancel();
					return true;
				}
				return false;
			}
		});

		// 设置最大输入长度
		if (mMaxLength > 0) {
			mInputEditText.setFilters(new InputFilter[] { new InputFilter.LengthFilter(
							mMaxLength) });
		}
		// 获取焦点
		mInputEditText.requestFocus();
		mInputEditText.setText(mContent);
		mInputEditText.setSelection(mInputEditText.length());
	}

	
	private void inputDone() {
		if (!isCallAction) {
			final String returnStr = mInputEditText.getText().toString();
			close();

			// 返回输入结果给Lua
			mActivity.runOnLuaThread(new Runnable() {
				@Override
				public void run() {
					onImeClosed(returnStr.getBytes(), 1);
				}
			});

			isCallAction = true;
		}
	}

	private void inputCancel() {
		if (!isCallAction) {
			final String returnStr = mInputEditText.getText().toString();
			close();

			// 返回输入结果给Lua
			mActivity.runOnLuaThread(new Runnable() {
				@Override
				public void run() {
					onImeClosed(returnStr.getBytes(), 0);
				}
			});

			isCallAction = true;
		}

	}

	private void openKeyboard() {
		final InputMethodManager imm = (InputMethodManager) mActivity
				.getSystemService(Context.INPUT_METHOD_SERVICE);
		imm.showSoftInput(mInputEditText, 0);
	}

	private void closeKeyboard() {
		final InputMethodManager imm = (InputMethodManager) mActivity
				.getSystemService(Context.INPUT_METHOD_SERVICE);
		imm.hideSoftInputFromWindow(mInputEditText.getWindowToken(), 0);
	}

	private void close() {
		closeKeyboard();
		outerLayout.setVisibility(View.GONE);
	}
	
	private void setExtraKeyListener() {
		if (mInputFlag == IIMEConstant.kEditBoxInputFlagVisiblePassword
				|| mInputFlag == IIMEConstant.kEditBoxInputFlagPassword) {
			mInputEditText.setKeyListener(new NumberKeyListener() {

				// 硬性要求密码输入只能是[0-9a-zA-Z]
				private final char[] chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
						.toCharArray();

				@Override
				public int getInputType() {
					return mInputModeContraints
							| mInputFlagConstraints;
				}

				@Override
				protected char[] getAcceptedChars() {
					return chars;
				}
			});
		}
	}
}
