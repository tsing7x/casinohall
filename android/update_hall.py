import io
import re
import os
import shutil
import time

res_path = os.getcwd() + r"\..\Win32\Resource"

noNeedDir = [
"attendence", "broke", "buddyRoom",
"cash", "duijiang", "feedback", "friend",
"popu", "setting", "shop", "task", "user",
"hongdong\\bomb", "hongdong\\cheers", "hongdong\\dog", 
"hongdong\\hammer", "hongdong\\pourwater", "hongdong\\rowse", 
"hongdong\\tomato",
]
noNeedGame = ["dice", "h3", "makhos", "ks", "mixedTen", "dummy", "hilo", "pokdeng", "kaeng", "kaengWild", "makhosMatch", "nineke", "suoha", "suoha7", ]

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


delFile("update")
os.mkdir("update")
verFilePath = r"%s\scripts\version.lua" % (res_path)
versionFile = open(verFilePath, 'r')

pattern = re.compile("return (\d+)")
for line in versionFile.readlines():
	searchResult = pattern.search(line)
	if searchResult:
		version = searchResult.group(1)

print "start copy resource file"
copyFile(res_path+'\\images', "update\\images")
copyFile(res_path+'\\scripts', "update\\scripts")

for file in noNeedDir:
	imgPath = "update" + "\\images\\" + file
	delFile(imgPath)
for game in noNeedGame:
	delFile("update"+"\\images\\games\\"+game)
	delFile("update"+"\\scripts\\app\\games\\"+game)
	delFile("update"+"\\scripts\\view\\games\\"+game)

print "copy resource file success"

zipFile = 'tpe_hall2.0_'+version
delFile(zipFile)
dir = os.getcwd()
shutil.make_archive(zipFile, "zip", dir, "update")
print zipFile + " build success"


