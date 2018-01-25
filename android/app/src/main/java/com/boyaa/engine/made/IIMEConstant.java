package com.boyaa.engine.made;
/**
 * 
 *	预定义输入和软键盘的各种参数,包括输入类型、输入类型标志、布局方式以及与Lua交互的字段名称等
 */
public interface IIMEConstant {
	/**
	 * The user is allowed to enter any text, including line breaks.
	 */
	public final static int kEditBoxInputModeAny = 0;

	/**
	 * The user is allowed to enter an e-mail address.
	 */
	public final static int kEditBoxInputModeEmailAddr = 1;

	/**
	 * The user is allowed to enter an integer value.
	 */
	public final static int kEditBoxInputModeNumeric = 2;

	/**
	 * The user is allowed to enter a phone number.
	 */
	public final static int kEditBoxInputModePhoneNumber = 3;

	/**
	 * The user is allowed to enter a URL.
	 */
	public final static int kEditBoxInputModeUrl = 4;

	/**
	 * The user is allowed to enter a real number value. This extends
	 * kEditBoxInputModeNumeric by allowing a decimal point.
	 */
	public final static int kEditBoxInputModeDecimal = 5;

	/**
	 * The user is allowed to enter any text, except for line breaks.
	 */
	public final static int kEditBoxInputModeSingleLine = 6;

	/**
	 * The user is allowed to enter any text,multLine
	 */
	public final static int kEditBoxInputModeMultLine = 7;

	/**
	 * Indicates that the text entered is confidential data that should be
	 * obscured whenever possible. This implies EDIT_BOX_INPUT_FLAG_SENSITIVE.
	 */
	public final static int kEditBoxInputFlagPassword = 0;

	/**
	 * Indicates that the text entered is sensitive data that the implementation
	 * must never store into a dictionary or table for use in predictive,
	 * auto-completing, or other accelerated input schemes. A credit card number
	 * is an example of sensitive data.
	 */
	public final static int kEditBoxInputFlagSensitive = 1;

	/**
	 * This flag is a hint to the implementation that during text editing, the
	 * initial letter of each word should be capitalized.
	 */
	public final static int kEditBoxInputFlagInitialCapsWord = 2;

	/**
	 * This flag is a hint to the implementation that during text editing, the
	 * initial letter of each sentence should be capitalized.
	 */
	public final static int kEditBoxInputFlagInitialCapsSentence = 3;

	/**
	 * Capitalize all characters automatically.
	 */
	public final static int kEditBoxInputFlagInitialCapsAllCharacters = 4;

	/**
	 * 扩充可见密码
	 */
	public final static int kEditBoxInputFlagVisiblePassword = 5;
	
	/**
	 * 返回类型
	 */
	public final static int kKeyboardReturnTypeDefault = 0;
	public final static int kKeyboardReturnTypeDone = 1;
	public final static int kKeyboardReturnTypeSend = 2;
	public final static int kKeyboardReturnTypeSearch = 3;
	public final static int kKeyboardReturnTypeGo = 4;

	// 扩充布局方式
	public final static int EX_LAYOUT_LINEARLAYOUT_FULL_WIDTH = 1;
	public final static int EX_LAYOUT_RELATIVELAYOUT_NOT_FULL_WIDTH = 2;

	// 扩充输入类型
	public final static int EX_INPUT_TYPE_NOT_USE = 0;
	public final static int EX_INPUT_TYPE_NUMBER = 1;
	public final static int EX_INPUT_TYPE_PHONE_NUMBER = 2;
	
	/**
	 * 与引擎传递数据的字段名称
	 */
	public final static String EX_DICT_TABLE_NAME = "inputEditExTable";
	public final static String EX_DICT_KEY_LAYOUTEX = "layoutEx";
	public final static String EX_DICT_KEY_MODEEX = "modeEx";
	public final static String EX_DICT_KEY_INPUTTIPS = "inputTips";
	public final static String EX_DICT_KEY_MINLENGTH = "minLength";
	public final static String EX_DICT_KEY_MINLENGTHTIPS = "minLengthTips";
	public final static String EX_DICT_KEY_RECTX = "editTextRectX";
	public final static String EX_DICT_KEY_RECTY = "editTextRectY";
	public final static String EX_DICT_KEY_RECTW = "editTextRectW";
	public final static String EX_DICT_KEY_RECTH = "editTextRectH";
	public final static String EX_DICT_KEY_INPUTMODE = "inputMode";
	public final static String EX_DICT_KEY_INPUTFLAG = "inputFlag";
	public final static String EX_DICT_KEY_RETURNTYPE = "returnType";
	public final static String EX_DICT_KEY_FONTSIZE = "editTextFontSize";
	public final static String EX_DICT_KEY_FONTCOLOR = "editTextFontColor";
}
