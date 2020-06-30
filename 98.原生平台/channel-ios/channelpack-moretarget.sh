#!/bin/sh

echo "~~~~~~~~~~~~~~~~~~~~ 开始执行打包脚本 ~~~~~~~~~~~~~~~~~~~~"

########################## 工程基本信息配置 ###########################
#循环数组,需要打包的渠道名称,以空格隔开
channelArray=("wfyl-mobile" "mobile1" "mobile2")
#项目路径
MWBuildDir="/Users/aaron/Develop/github/projtest/frameworks/runtime-src/proj.ios_mac"
#工程名
projectName="wfyl"
#ExportOptions.plist 路径
exportOptionsPlistPath="/Users/aaron/Develop/github/projtest/frameworks/runtime-src/proj.ios_mac/ExportOptions.plist"
#Release还是Debug
buildConfiguration="Release"
#Ipa导出路径
IpaExportPath="/Users/aaron/Develop/github/projtest/frameworks/runtime-src/proj.ios_mac"


for ((i=0;i<${#channelArray[@]};i++))
do
    targetName=${channelArray[$i]}

    echo  $projectName
    echo  $targetName

    # #编译
    # xcodebuild archive -workspace ${projectName}.xcworkspace -scheme ${targetName} -configuration ${buildConfiguration} -sdk "iphoneos" clean archive -archivePath ./ArchivePath/${targetName}.xcarchive
    # #生成ipa
    # xcodebuild -exportArchive -archivePath ./ArchivePath/${targetName}.xcarchive -exportOptionsPlist ${exportOptionsPlistPath} -exportPath ${IpaExportPath}
    
    # rm -rf ${projectName}.xcarchive
    # rm -rf ${projectName}.ipa
    # xcodebuild clean -project ${projectName}.xcodeproj -scheme ${targetName}
    xcodebuild archive -project ${projectName}.xcodeproj -scheme ${targetName} -configuration ${buildConfiguration} -archivePath ${targetName}
    xcodebuild -exportArchive -archivePath ${targetName}.xcarchive -exportOptionsPlist ${exportOptionsPlistPath} -exportPath ./
 done
