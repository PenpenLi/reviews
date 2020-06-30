#!/bin/bash

# 输入的包名

name="mobile1"
codesigningidentity="Apple Distribution: Yang Zhang"
# Code Signing Identity: certificates in keychain
# Provisioning Profile: 如果配置了，重新签名如何处理.


echo "------SDK渠道包----------"

appName="${name}.app"

plistBuddy="/usr/libexec/PlistBuddy"

configName="Payload/${appName}/Info.plist"

ipa="${name}.ipa"

# 输出的新包所在的文件夹名

outUpdateAppDir="ChannelPackages"

# entitlements.plist路径

entitlementsDir="entitlements.plist"

# 切换到当前目录

currDir=${PWD}

cd ${currDir}

echo "-----${currDir}"

rm -rf Payload

# 解压缩-o：覆盖文件 -q：不显示解压过程

unzip -o -q ${ipa}

# 删除旧的文件夹，重新生成

rm -rf ${outUpdateAppDir}

mkdir ${outUpdateAppDir}

# 删除旧的 entitlements.plist，重新生成

rm -rf ${entitlementsDir}

/usr/libexec/PlistBuddy -x -c "print :Entitlements " /dev/stdin <<< $(security cms -D -i Payload/${appName}/embedded.mobileprovision) > entitlements.plist

echo "------------------------开始打包程序------------------------"

# 渠道列表文件开始打包

for line in $(cat channellist.txt)

# 循环数组，修改渠道信息

do

# 修改 plist 中的 Channel 值

$plistBuddy -c "Set :CHANNEL $line" ${configName}

# app 重签名

rm -rf Payload/${appName}/_CodeSignature

cp embedded.mobileprovision "Payload/${appName}/embedded.mobileprovision"

# 填入可用的证书 ID

codesign -f -s ${codesigningidentity} Payload/${appName}  --entitlements ${entitlementsDir}

# 若输出 Payload/MultiChannelDemo.app: replacing existing signature 说明重签名完成

# 压缩 -r:递归处理，将指定目录下的所有文件和子目录一并处理 -q:不显示处理过程

zip -rq "${outUpdateAppDir}/$line.ipa" Payload

echo "........渠道${line}打包已完成"

done



