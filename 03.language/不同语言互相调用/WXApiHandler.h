//
//  WXApiHandler.h
//  Test
//
//  Created by Lu on 16/5/28.
//
//

#ifndef WXApiHandler_h
#define WXApiHandler_h

#include <stdio.h>

class WXApiHandler
{
public:
    static bool registerApp(const char* appID);
    static bool sendAuthRequest();
    static void shareWebToWeixin(const char* title,const char* description,const char* image,const char* webpageUrl,int type);
    static void shareImageToWeixin(const char* thumbImagepath,const char* imagepath,int type);
    static void jumpToWeixinPay(const char* appId,const char* partnerId,const char* prepayId,const char* package,const char* sign,const char* nonceStr,int timeStamp);
    static float getBatteryLevel();
    static float getWifiSignalLevel();
    static int getWifiSignalState();
    static float getMobileSignalLevel();
    static int getMobileSignalState();
    static void setJoinRoomID(const char *gameid, const char *roomid);
    static const char* getIMEI();
};

#endif /* WXApiHandler_h */
