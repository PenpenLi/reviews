//
//  WXApiHandler.h
//  Test
//
//  Created by Lu on 16/5/28.
//
//

#ifndef WXApiHandler_android_h
#define WXApiHandler_android_h

#include <stdio.h>

class WXApiHandler_android
{
public:

#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    static bool registerAppForAndroid(const char* appID);
    static bool sendAuthRequestForAndroid();
    static void shareWebToWeixinForAndroid(const char* title,const char* description,const char* image,const char* webpageUrl,int type);
    static void shareImageToWeixinForAndroid(const char* thumbImagepath,const char* imagepath,int type);
    static void jumpToWeixinPayForAndroid(const char* appId,const char* partnerId,const char* prepayId,const char* package,const char* sign,const char* nonceStr,int timeStamp);
    static void jumpToAlipayForAndroid(int payPlatform,const char* amountMoney, const char* orderCode,int userID);
    static float getBatteryLevelForAndroid();
    static float getWifiSignalLevelForAndroid();
    static int getWifiSignalStateForAndroid();
    static float getMobileSignalLevelForAndroid();
    static int getMobileSignalStateForAndroid();
    static const char* getIMEIForAndroid();
#endif
};

#endif /* WXApiHandler_h */
