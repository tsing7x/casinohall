# -*- coding: utf-8 -*-
import os, time
import codecs
import copy
import re
import shutil

# from PyQt4 import QtCore, QtGui, uic

from string import Template
import sys
import uuid

cur_path = os.getcwd()
proj_path = cur_path
srcpath = proj_path+"/../Win32/Resource"

app_path = proj_path + r'\app'
assert_path = app_path + r'\src\main\assets'
res_path = app_path + r'\src\main\res'

def delFile(file):
	if os.path.exists(file):
		if os.path.isfile(file):
			os.remove(file)
		elif os.path.isdir(file):
			shutil.rmtree(file)
def copyFile(src, dst):
	if os.path.exists(src):
		
		if os.path.isfile(src):
			#dst is file and dir not exist, create first
			if not os.path.exists(os.path.dirname(dst)):
				os.mkdir(os.path.dirname(dst))
			shutil.copy(src, dst)
		elif os.path.isdir(src):
			shutil.copytree(src, dst, False, shutil.ignore_patterns("*.svn*"))

#复制assert以及res资源
def copyRes():
	delFile(app_path + r'\src\main\assets')
	os.mkdir(app_path + r'\src\main\assets')
	copyFile(srcpath + r'\scripts', assert_path + r'\scripts')
	copyFile(srcpath + r'\images', assert_path + r'\images')
	#delFile(assert_path + r'\images/language')

	copyFile(srcpath + r'\audio', assert_path + r'\audio')
	copyFile(srcpath + r'\plugin', assert_path)

	delFile(app_path + r'\build')
	delFile(res_path + r'\values\strings.xml')
	delFile(res_path + r'\values\strings.xml')
	delFile(res_path + r'\drawable\hallgame_icon.png')
	delFile(res_path + r'\drawable-hdpi\hallgame_icon.png')
	delFile(res_path + r'\drawable-ldpi\hallgame_icon.png')
	delFile(res_path + r'\drawable-mdpi\hallgame_icon.png')
	delFile(res_path + r'\drawable-xhdpi\hallgame_icon.png')
	delFile(app_path + r'\build.gradle')
	delFile(app_path + r'\keystore\PokDeng.keystore')
	delFile(app_path + r'\src\main\AndroidManifest.xml')
	print "delete last project file success "

	#copy the project and icon file
	game = "pokdeng"
	copyFile(proj_path + r'\diff\%s\strings.xml' % game, res_path + r'\values')
	copyFile(proj_path + r'\diff\%s\hallgame_icon.png' % game, res_path + r'\drawable')
	copyFile(proj_path + r'\diff\%s\hallgame_icon.png' % game, res_path + r'\drawable-hdpi')
	copyFile(proj_path + r'\diff\%s\hallgame_icon.png' % game, res_path + r'\drawable-ldpi')
	copyFile(proj_path + r'\diff\%s\hallgame_icon.png' % game, res_path + r'\drawable-mdpi')
	copyFile(proj_path + r'\diff\%s\hallgame_icon.png' % game, res_path + r'\drawable-xhdpi')
	copyFile(proj_path + r'\diff\%s\build.gradle' % game, app_path)
	copyFile(proj_path + r'\diff\%s\PokDeng.keystore' % game, app_path + r'\keystore')
	copyFile(proj_path + r'\diff\%s\AndroidManifest.xml' % game, app_path + r'\src\main')
	print "copy project file success " + game

#打包
def buildApk():
	os.system('gradlew assembleRelease')
	shutil.move(app_path + r'\build\outputs\apk\app-release.apk', proj_path + r'\%s.apk' % "casinoHall")

copyRes()
buildApk()

# qtCreatorFile = cur_path+"/layout.ui" # Enter file here.

# Ui_MainWindow, QtBaseClass = uic.loadUiType(qtCreatorFile)

# class MyApp(QtGui.QMainWindow, Ui_MainWindow):
#     def __init__(self):
#         QtGui.QMainWindow.__init__(self)
#         Ui_MainWindow.__init__(self)
#         self.setupUi(self)
#         self.copyRes.clicked.connect(self.CopyAssert)
#         self.buildApk.clicked.connect(self.BuildApk)

#     def CopyAssert(self):
# 		self.text_status.setText("is copying res")
# 		copyRes()
# 		self.text_status.setText("copy finish")
#     def BuildApk(self):
#     	self.text_status.setText("is building apk")
#         buildApk()
#         self.text_status.setText("build finish")


# if __name__ == "__main__":
# 	app = QtGui.QApplication(sys.argv)
# 	window = MyApp()
# 	window.show()
# 	sys.exit(app.exec_())
