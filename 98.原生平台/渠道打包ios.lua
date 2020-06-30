-- =============================================
-- USEFUL: 2020: https://juejin.im/post/5e4ba0fe51882549564b5000
-- HELP: https://www.jianshu.com/p/dc7660c56bd4
-- HELP:2: https://www.jianshu.com/p/6b68cd9307bc
-- =============================================
-- ================ 多个target =============================
1.修改scheme, target, info.plist;
通过info.plist或者preprocessor 判断target;
2.配置ExportOptions.plist
直接导出包，内附带，然后再修改
method: app-store, ad-hoc, enterprise, development,
provisioningProfiles: 生成的配置文件
signingCertificate：Apple Distribution， Apple development,
teamID：489DK7LVZ4，
3.注意事项
❗️Xcode项目必须先配置，然后再去执行打包
❗️PROJECT设置Build Settings-Code Signing Identity
❗️TARGETS设置Provisioning Profile
❗️xcodebuild命令行都是在项目下面执行的
4.xcodebuild打包
xcodebuild archive -project wfyl.xcodeproj -scheme mobile1 -configuration Release -archivePath mobile1
xcodebuild -exportArchive -archivePath mobile1.xcarchive -exportOptionsPlist ExportOptions.plist -exportPath ./
xcodebuild -help --// xcodebuild 所有命令行
xcodebuild -list --// 查看项目一些配置
xcodebuild -showsdks --//查看可用的SDK
xcodebuild clean [-optionName]...-- 清除编译过程生成文件
xcodebuild clean -project wfyl.xcodeproj -scheme mobile1
5.两个文件
channelpack-moretarget.sh
ExportOptions.plist
-- ================ 修改plist方式 =============================
1.修改plist文件，添加key
NSDictionary *channelDic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Channel" ofType:@"plist"]];
NSString *channel = channelDic[@"CHANNEL"];
2.使用可用的证书打包，获取有用文件。
demo.ipa, 母包
Info.plist, 修改渠道
embedded.mobileprovision， 描述文件，用于重签名
channelpack-plist.sh 
channellist.txt
3.开始执行步骤 shell
├── ChannelList.txt
├── ChannelPackage.sh
├── ChannelPackages
│   ├── channel02.ipa
│   ├── channel03.ipa
│   └── channel04.ipa
├── MultiChannelDemo.ipa
├── Payload
│   └── MultiChannelDemo.app
├── embedded.mobileprovision
└── entitlements.plist
-- =============================================
-- =============================================
-- =============================================
-- HELP: 重签名ipa: https://www.jianshu.com/p/f27211ae9ca9





