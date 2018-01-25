# -*- coding: utf-8 -*-
import os, time
import codecs
import copy
import re
import shutil

cur_path = os.getcwd()
proj_path = cur_path
srcpath = proj_path+"/Resource"

imagesPath = srcpath+"/images"
languagePath = srcpath+"/images/language"


def coverFiles(srcDir,  dstDir): 
	for file in os.listdir(srcDir): 
		srcFile = os.path.join(srcDir,  file) 
		dstFile = os.path.join(dstDir,  file) 
		print dstFile
		if os.path.isfile(srcFile):
			if os.path.exists(dstFile):
				os.remove(dstFile)
			open(dstFile, "wb").write(open(srcFile, "rb").read())
		elif os.path.isdir(srcFile):
			if not os.path.exists(dstFile):
				os.mkdir(dstFile)
			coverFiles(srcFile,dstFile)

languageList = []
for file in os.listdir(languagePath):
	languageList.append(file)

for i in range(len(languageList)) :
	print "input %d to choose %s " % (i, languageList[i])
index = input("choose:")


coverFiles(os.path.join(languagePath,  languageList[index]),imagesPath)

input("\nenter to exit")