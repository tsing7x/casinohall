#-*-coding:utf8-*-
import zipfile
import os
import shutil



#获取母包
def getParentPack(apkPath, outPath = "./out" , delList = []):
    outPath = os.path.realpath(outPath)

    with zipfile.ZipFile("Game.apk", "r") as fz:
        for file in fz.namelist():
            fz.extract(file, outPath)
    
    for fname in delList:
        fullPath = os.path.join(outPath, fname)
        if not os.path.exists(fullPath):
            continue
        if os.path.isdir(fullPath) :
            shutil.rmtree(fullPath)
        elif os.path.isfile(fullPath):
            os.remove(fullPath)

#从souce_dir拷贝代码至zip_dir目录下的
def packToZip(zipf, source_dir, zip_dir = None):
    fullSourcePath =  os.path.realpath(source_dir)
    
    if os.path.isfile(fullSourcePath):
        fileRelPath = os.path.basename(fullSourcePath)
        if zip_dir:
            fileRelPath = zip_dir      
        zipf.write(fullSourcePath, fileRelPath)
        return

    for parent, dirnames, filenames in os.walk(source_dir): 
        for filename in filenames:
            #获取文件绝对路径
            filePath = os.path.join(parent, filename)
            #获取文件相对的路径 
            fileRelPath = os.path.relpath(filePath, fullSourcePath)
            #需要加上前缀路径
            if zip_dir:
                fileRelPath = os.path.join(zip_dir, fileRelPath)

            zipf.write(filePath, fileRelPath)

#给apk签名
def signApk(keystorePath, storepass, keypass, aliseName, inAPK, outAPK):
    cmd = "jarsigner -verbose -keystore %s -storepass %s -keypass  %s  -signedjar %s %s %s"%(keystorePath, storepass, keypass, outAPK,inAPK,aliseName)
    os.system(cmd)

#生成母包解压文件
getParentPack("Game.apk", "./android", ["assets", "META-INF"])
#将文件打入新生成的apk
with zipfile.ZipFile("tmp.apk", "w", zipfile.ZIP_DEFLATED) as fz:
    packToZip(fz, "./android")
    packToZip(fz, r"F:\code\APP\agency\branch\develop\Resource\images", "assets/images")
    packToZip(fz, r"F:\code\APP\agency\branch\develop\Resource\scripts", "assets/scripts")
    packToZip(fz, r"F:\code\APP\agency\branch\develop\Resource\plugin", "assets/plugin")
#签名apk文件
signApk("boyaa_region_games.keystore", "boyaagames2014", "boyaagames2014", "boyaa_region_games.keystore", "tmp.apk", "new.apk")


    
