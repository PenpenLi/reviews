#ifndef WXApiHandler_ios_h
#define WXApiHandler_ios_h

#include "cocos2d.h"

class WXApiHandler_ios
{
public: 
#if(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    static bool registerAppForIOS(const char* appID);
    static bool sendAuthRequestForIOS();
    static void onRespForIOS(const char* code);
    static void onShareRespForIOS(const int errCode);
    static void onPayRespForIOS(const int errCode);
    static void shareWebToWeixinForIOS(const char* title,const char* description,const char* image,const char* webpageUrl,int type);
    static void shareImageToWeixinForIOS(const char* thumbImagepath,const char* imagepath,int type);
    static const char* getIMEIForIOS();//获取机器码，暂时先放这
    static void jumpToWeixinPayForIOS(const char* appId,const char* partnerId,const char* prepayId,const char* package,const char* sign,const char* nonceStr,int timeStamp);
    static void jumpToAlipayForIOS(const char* outTradeNO,const char* totalFee);
    static float getBatteryLevelForIOS();
    static float getWifiSignalLevelForIOS();
    static int getWifiSignalStateForIOS();
    static float getMobileSignalLevelForIOS();
    static int getMobileSignalStateForIOS();
#endif
};

#endif /* WXApiHandler_h */
