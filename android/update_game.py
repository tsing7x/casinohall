import io
import re
import os
import shutil
import time

res_path = os.getcwd() + r"\..\Win32\Resource"

#game name is used to give a tips which game to zip
gameName = ["dice", "h3", "makhos", "mixedTen", "ks", "dummy", "pokdeng", "hilo", "hilo_dealer", "nineke"]
#game directory in the res_path
gamePath = ["dice", "h3", "makhos", "mixedTen", "ks", "dummy", "pokdeng", "hilo", "hilo", "nineke"]
#version file path
verPath = ["dice", "h3", "makhos", "mixedTen", "ks", "dummy", "pokdeng", "hilo", r"hilo\dealer", "nineke"]

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

def packGame(gameIndex, gameName, gamePath, verPath, res_path):
	delFile("update")
	time.sleep(1)
	os.mkdir("update")

	zipName = gameName[gameIndex]
	game = gamePath[gameIndex]
	version = verPath[gameIndex]

	verFilePath = r"%s\scripts\app\games\%s\version.lua" % (res_path, version)
	if gameIndex == 6:
		verFilePath = r"%s\scripts\app\games\%s\chipGame\version.lua" % (res_path, version)

	versionFile = open(verFilePath, 'r')

	pattern = re.compile("return (\d+)")
	for line in versionFile.readlines():
		searchResult = pattern.search(line)
		if searchResult:
			version = searchResult.group(1)
			break

	copyFile(res_path+'\\images\\games\\'+game, "update\\images\\games\\"+game)
	copyFile(res_path+'\\scripts\\app\\games\\'+game, "update\\scripts\\app\\games\\"+game)
	copyFile(res_path+'\\scripts\\app\\view\\games'+game, "update\\scripts\\app\\view\\games\\"+game)
	copyFile(res_path+'\\audio\\ogg\\'+game, "update\\audio\\ogg\\"+game)
	# copyFile(res_path+'\\audio\\mp3\\'+game, "update\\audio\\mp3\\"+game)
	print "copy resource file success"

	zipFile = zipName+'_'+version
	delFile(zipFile)
	dir = os.getcwd()
	shutil.make_archive(zipFile, "zip", dir, "update")
	print zipFile + " build success"


print "input 0 to zip all game"
for i in range(len(gameName)) :
	print "input %d to zip %s " % (i + 1, gameName[i])
gameIndex = input("choose:")

if gameIndex == 0:
	for i in range(len(gameName)):
		packGame(i, gameName, gamePath, verPath, res_path)
else:
	packGame(gameIndex-1, gameName, gamePath, verPath, res_path)

