package com.boyaa.utils;

import java.io.File;

public class PathUtil
{
	public static boolean mkdir(String path)
	{
		for(int i = 0, l = path.length(); i < l; ++i)
		{
			if(path.charAt(i) == File.separatorChar)
			{
				File f = new File(path.substring(0, i + 1));
				if( !f.exists()) {
					if(!f.mkdirs())
					{
						return false;
					}
				}
			}
		}
		return true;
	}
	
	public static boolean isExist(String file)
	{
		File f = new File(file);
		return f.exists();
	}
}
