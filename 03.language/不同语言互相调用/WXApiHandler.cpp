//
//  WXApiHandler.cpp
//  Test
//
//  Created by Lu on 16/5/28.
//
//
#include "WXApiHandler.h"
#include "WechatHttpHandler.h"
#include "PayMentHandler.h"
#include "UtilAPI.h"
#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "WXApiHandler_android.h"
#else
#include "WXApiHandler_ios.h"
#endif

bool WXApiHandler::registerApp(const char* appID)
{
#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    return WXApiHandler_android::registerAppForAndroid(appID);
    
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    
    return WXApiHandler_ios::registerAppForIOS(appID);
#endif
}

bool WXApiHandler::sendAuthRequest()
{
#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    
    return WXApiHandler_android::sendAuthRequestForAndroid();
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    
    return WXApiHandler_ios::sendAuthRequestForIOS();
#endif

}

//手机电量：0~1
float WXApiHandler::getBatteryLevel()
{
#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    
    return WXApiHandler_android::getBatteryLevelForAndroid();
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    
    return WXApiHandler_ios::getBatteryLevelForIOS();
#endif
}

//type 0 分享给好友， 1 分享到朋友圈
void WXApiHandler::shareWebToWeixin(const char* title,const char* description,const char* image,const char* webpageUrl,int type)
{
    UserDefault::getInstance()->setBoolForKey("wx_activity", false);
#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    
    WXApiHandler_android::shareWebToWeixinForAndroid( title, description, image, webpageUrl,type);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    
    WXApiHandler_ios::shareWebToWeixinForIOS( title, description, image, webpageUrl,type);
#endif
    
}

//type 0 分享给好友， 1 分享到朋友圈
void WXApiHandler::shareImageToWeixin(const char* thumbImagepath,const char* imagepath,int type)
{
    // type%4 =  0 分享给好友， 1 分享到朋友圈  henping
    //        =  2 分享给好友， 3 分享到朋友圈 shuping
    
    // type > 4 copyFileToRelative
    UserDefault::getInstance()->setBoolForKey("wx_activity", false);
    if (type > 4) {
        
        std::string s_thumbImagepath = FileUtils::getInstance()->copyFileToRelative(thumbImagepath);
        std::string s_imagepath =  FileUtils::getInstance()->copyFileToRelative(imagepath);
#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        WXApiHandler_android::shareImageToWeixinForAndroid(s_thumbImagepath.c_str(), s_imagepath.c_str(), type%4);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        WXApiHandler_ios::shareImageToWeixinForIOS(s_thumbImagepath.c_str(), s_imagepath.c_str(), type%2);
#endif
    }else{
    
#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        WXApiHandler_android::shareImageToWeixinForAndroid(thumbImagepath, imagepath, type);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        WXApiHandler_ios::shareImageToWeixinForIOS(thumbImagepath, imagepath, type%2);
#endif
    }
}

void WXApiHandler::jumpToWeixinPay(const char* appId,const char* partnerId,const char* prepayId,const char* package,const char* sign,const char* nonceStr,int timeStamp)
{
#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    
    WXApiHandler_android::jumpToWeixinPayForAndroid(appId,partnerId,prepayId,package,sign, nonceStr,timeStamp);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    
    WXApiHandler_ios::jumpToWeixinPayForIOS(appId,partnerId,prepayId,package,sign, nonceStr,timeStamp);
#endif
}

//wifi信号强度：0~1
float WXApiHandler::getWifiSignalLevel()
{
#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    
    return WXApiHandler_android::getWifiSignalLevelForAndroid();
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    
    return WXApiHandler_ios::getWifiSignalLevelForIOS();
#endif
}

//wifi信号状态：0~1
int WXApiHandler::getWifiSignalState()
{
#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    
    return WXApiHandler_android::getWifiSignalStateForAndroid();
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    return WXApiHandler_ios::getWifiSignalStateForIOS();
    //return 0;
#endif
}

//手机信号强度：0~1
float WXApiHandler::getMobileSignalLevel()
{
#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    
    return WXApiHandler_android::getMobileSignalLevelForAndroid();
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    return WXApiHandler_ios::getMobileSignalLevelForIOS();
    //return 0.0f;
#endif
}

//手机信号状态：0~1
int WXApiHandler::getMobileSignalState()
{
#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    
    return WXApiHandler_android::getMobileSignalStateForAndroid();
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    
    return WXApiHandler_ios::getMobileSignalStateForIOS();
#endif
}

const char* WXApiHandler::getIMEI()
{
#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    
    return WXApiHandler_android::getIMEIForAndroid();
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    
    return WXApiHandler_ios::getIMEIForIOS();
#else
    
    srand( (unsigned)time( NULL ) );
    auto xx_prefix = UserDefault::getInstance()->getIntegerForKey("test_user_prefix", -1);
    if (xx_prefix < 100000) {
        UserDefault::getInstance()->setIntegerForKey("test_user_prefix", rand()%100000 + 100000);
        xx_prefix = UserDefault::getInstance()->getIntegerForKey("test_user_prefix", -1);
    }
    auto m_wxOpenID = StringUtils::format("%d", xx_prefix);
    return m_wxOpenID.c_str();
#endif
}

void WXApiHandler::setJoinRoomID(const char *gameid, const char *roomid)
{
    WechatHttpHandler::getInstance()->m_s_wxJoinGameid = gameid;
    WechatHttpHandler::getInstance()->m_s_wxJoinRoomid = roomid;
}

//MARK::微信 Android通过Jni调用java层接口

//net.sourceforge.simcpux.wxapi










